import 'dart:async';
import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mime/mime.dart';

import '/core/models/editor_configs/pro_image_editor_configs.dart';
import '/core/models/multi_threading/thread_capture_model.dart';
import '/core/models/multi_threading/thread_request_model.dart';
import '/shared/utils/decode_image.dart';
import '/shared/utils/unique_id_generator.dart';
import '../services/image_converter_service.dart';
import '../services/image_render_service.dart';
import '../services/isolate_manager.dart';
import '../services/thread_fallback_manager.dart';
import '../services/thread_manager.dart';
import '../services/web_worker/web_worker_manager_dummy.dart'
    if (dart.library.js_interop) '../services/web_worker/web_worker_manager.dart';
import '../utils/converters/convert_flutter_ui_to_image.dart';
import '../utils/encoder/encode_image.dart';

/// Manages the recording and rendering of widgets into image data,
/// leveraging multi-threading for efficient processing.
class ContentRecorderController {
  /// Initializes the controller with the specified configuration.
  /// Optionally enables thumbnail generation and skips initialization.
  ContentRecorderController({
    required ImageGenerationConfigs configs,
    this.enableThumbnailGeneration = false,
    bool ignoreGeneration = false,
  }) : _configs = configs {
    containerKey = GlobalKey();
    recorderKey = GlobalKey();
    recorderStream = StreamController();

    _initializeMultiThreading(ignoreGeneration);
  }

  /// A flag indicating whether thumbnail generation is enabled.
  final bool enableThumbnailGeneration;

  /// The key used to identify the container widget for rendering.
  late final GlobalKey containerKey;

  /// The key used to identify the recorder widget for rendering.
  late final GlobalKey recorderKey;

  /// A service to handle image conversion tasks.
  late final ImageConverterService _imageConverterService;

  /// A service to manage image rendering operations.
  late final ImageRenderService _imageRenderService;

  /// Manages threads for multi-threaded image generation.
  late final ThreadManager _threadManager;

  /// Configuration settings for image generation.
  final ImageGenerationConfigs _configs;

  /// A stream for sending widgets to the recorder for drawing.
  late final StreamController<Widget?> recorderStream;

  /// Ensures that the widget has completed rendering before proceeding.
  Completer<bool> recordReadyHelper = Completer();

  /// Sets up the multi-threading environment, using isolates or web workers.
  void _initializeMultiThreading(bool ignoreGeneration) async {
    if (ignoreGeneration) {
      _threadManager = ThreadFallbackManager(_configs);
    } else if (!kIsWeb) {
      _threadManager = IsolateManager(_configs);
    } else {
      _threadManager = WebWorkerManager(_configs);
    }

    _imageConverterService = ImageConverterService(
      configs: _configs,
      threadManager: _threadManager,
    );
    _imageRenderService = ImageRenderService(_configs);
  }

  /// Cleans up resources, destroys threads, and closes the recorder stream.
  Future<void> destroy() async {
    await recorderStream.close();
    if (!recordReadyHelper.isCompleted) {
      recordReadyHelper.complete(true);
    }

    _threadManager.destroy();
  }

  /// Converts a given `ui.Image` into a `Uint8List` format, which can be used
  /// for storage or further processing. Accepts an optional `id` to uniquely
  /// identify the conversion task.
  Future<Uint8List?> convertRawImageData({
    required ui.Image image,
    String? id,
  }) {
    return _imageConverterService.convert(
      image: image,
      id: id ?? generateUniqueId(),
    );
  }

  /// Captures image content based on the provided `ImageInfos` and optional
  /// parameters like output format and an existing raw image. It supports
  /// notifying callbacks when an image is captured and handles specific
  /// behaviors like screenshots in state history on the web.
  Future<Uint8List?> _captureImageContent({
    required ImageInfos imageInfos,
    Function(ui.Image?)? onImageCaptured,
    bool stateHistoryScreenshot = false,
    String? id,
    ui.Image? image,
    OutputFormat? outputFormat,
  }) async {
    /// If we're just capturing a screenshot for the state history in the web
    /// platform, but web worker is not supported, we return null.
    if (kIsWeb && stateHistoryScreenshot && (!_threadManager.isSupported)) {
      return null;
    }

    outputFormat ??= _configs.outputFormat;
    image ??= await getRawRenderedImage(imageInfos: imageInfos);
    id ??= generateUniqueId();
    onImageCaptured?.call(image);

    if (image == null) return null;

    return await _imageConverterService.convert(
      image: image,
      id: id,
      format: outputFormat,
    );
  }

  /// Captures the visual representation of a widget, rendering it into an image
  /// and optionally applying target dimensions, output formats, or additional
  /// processing for state history screenshots. Ensures the widget is fully
  /// rendered before capture.
  Future<Uint8List?> _captureWidget(
    Widget widget, {
    required ImageInfos imageInfos,
    Size? targetSize,
    OutputFormat? format,
    Function(ui.Image?)? onImageCaptured,
    bool enableStateHistoryScreenshot = false,
    String? id,
  }) async {
    recordReadyHelper = Completer();
    recorderStream.add(
      SizedBox(
        width: targetSize?.width,
        height: targetSize?.height,
        child: FittedBox(
          fit: BoxFit.contain,
          child: widget,
        ),
      ),
    );

    /// Ensure the recorder is ready
    if (!recordReadyHelper.isCompleted) {
      await recordReadyHelper.future;
    }
    ui.Image? image = await getRawRenderedImage(
      imageInfos: imageInfos,
      useThumbnailSize: false,
      widgetKey: recorderKey,
    );

    recorderStream.add(null);

    return _captureImageContent(
      image: image,
      imageInfos: imageInfos,
      id: id,
      onImageCaptured: onImageCaptured,
      stateHistoryScreenshot: enableStateHistoryScreenshot,
      outputFormat: format,
    );
  }

  /// Handles the process of capturing an image from the provided configuration
  /// or widget. If multi-threading is enabled, the capture leverages a separate
  /// isolate or worker to improve performance. The method also tracks the state
  /// of ongoing captures for synchronization.
  Future<Uint8List?> capture({
    required ImageInfos imageInfos,
    List<ThreadCaptureState>? screenshots,
    Size? targetSize,
    Widget? widget,
    OutputFormat? outputFormat,
  }) async {
    if (!_configs.generateImageInBackground ||
        !_configs.generateInsideSeparateThread) {
      return null;
    }
    ThreadCaptureState isolateCaptureState = ThreadCaptureState();

    if (screenshots != null) {
      /// Set every screenshot to broken which didn't read the ui image before
      /// changes happen.
      screenshots
          .where((el) => !el.processedRenderedImage)
          .forEach((screenshot) {
        screenshot.broken = true;
      });
      screenshots.add(isolateCaptureState);
    }

    Uint8List? bytes = widget == null
        ? await _captureImageContent(
            id: isolateCaptureState.id,
            imageInfos: imageInfos,
            stateHistoryScreenshot: true,
            outputFormat: outputFormat,
            onImageCaptured: (img) {
              isolateCaptureState.processedRenderedImage = true;
            },
          )
        : await _captureWidget(
            widget,
            id: isolateCaptureState.id,
            imageInfos: imageInfos,
            targetSize: targetSize,
            enableStateHistoryScreenshot: true,
            format: outputFormat,
            onImageCaptured: (img) {
              isolateCaptureState.processedRenderedImage = true;
            },
          );
    isolateCaptureState.completer.complete(bytes ?? Uint8List.fromList([]));
    if (bytes == null) {
      isolateCaptureState.broken = true;
    }

    return bytes;
  }

  /// Generates a final screenshot by either processing a previously captured
  /// image or initiating a new capture. The method ensures the output meets the
  /// required format, size, and quality constraints while supporting retries
  /// when errors occur.
  Future<Uint8List?> captureFinalScreenshot({
    required ImageInfos imageInfos,
    required ThreadCaptureState? backgroundScreenshot,
    Widget? widget,
    BuildContext? context,
    Uint8List? originalImageBytes,
    Size? targetSize,
  }) async {
    Uint8List? bytes;

    bool isGenerationActive =
        backgroundScreenshot != null && !backgroundScreenshot.broken;
    String id =
        isGenerationActive ? backgroundScreenshot.id : generateUniqueId();

    try {
      _threadManager.destroyAllActiveTasks(id);

      if (originalImageBytes == null) {
        if (isGenerationActive) {
          // Await the image data from the thread.
          bytes = await backgroundScreenshot.completer.future;
        } else {
          // Capture a new screenshot if the current screenshot is broken or
          // didn't exists.
          bytes = widget == null
              ? await _captureImageContent(
                  id: id,
                  imageInfos: imageInfos,
                )
              : await _captureWidget(
                  widget,
                  id: id,
                  targetSize: targetSize,
                  imageInfos: imageInfos,
                );
        }
      } else {
        // If the user didn't change anything just ensure the output-format
        // is correct.
        bytes = await convertImageFormat(
          imageInfos: imageInfos,
          imageBytes: originalImageBytes,
          context: context,
          id: id,
          targetSize: targetSize,
          widget: widget,
        );
      }
    } catch (e) {
      debugPrint(e.toString());

      // Take a new screenshot when something went wrong.
      bytes = widget == null
          ? await _captureImageContent(
              id: id,
              imageInfos: imageInfos,
            )
          : await _captureWidget(
              widget,
              id: id,
              targetSize: targetSize,
              imageInfos: imageInfos,
            );
    }
    return bytes;
  }

  /// Converts the format of an image and ensures its size adheres to the
  /// defined constraints. The method recaptures or re-encodes the image
  /// if the format or size is incompatible with the configuration.
  /// Multi-threaded or main-thread processing is selected based on platform
  /// and configuration settings.
  Future<Uint8List?> convertImageFormat({
    required ImageInfos imageInfos,
    required Uint8List imageBytes,
    required BuildContext? context,
    required String id,
    Size? targetSize,
    Widget? widget,
  }) async {
    Uint8List? bytes = imageBytes;

    /// Check content type
    String contentType = lookupMimeType('', headerBytes: bytes) ?? 'Unknown';

    /// Check if the image format is already same like the output format.
    List<String> sp = contentType.split('/');
    bool isFormatSame = sp.length > 1 &&
        (_configs.outputFormat.name == sp[1] ||
            (sp[1] == 'jpeg' && _configs.outputFormat == OutputFormat.jpg));

    /// Check if the output size is too large.
    double outputRatio = imageInfos.pixelRatio;
    if (!_configs.captureOnlyDrawingBounds &&
        context != null &&
        context.mounted) {
      outputRatio =
          max(imageInfos.pixelRatio, MediaQuery.devicePixelRatioOf(context));
    }
    bool isOutputSizeTooLarge = _imageRenderService.checkOutputSizeIsTooLarge(
      imageInfos.renderedSize,
      outputRatio,
      enableThumbnailGeneration,
    );
    if (!isFormatSame || isOutputSizeTooLarge) {
      final ui.Image image = await decodeImageFromList(bytes);
      if (_configs.generateInsideSeparateThread) {
        /// Recapture the image if the output format is incorrect or the output
        /// size is too large.
        if (kIsWeb || isOutputSizeTooLarge) {
          /// Due to a known issue with image decoding in Flutter web, we need
          /// to recapture the image to ensure accuracy.
          bytes = widget == null
              ? await _captureImageContent(
                  id: id,
                  imageInfos: imageInfos,
                )
              : await _captureWidget(
                  widget,
                  id: id,
                  targetSize: targetSize,
                  imageInfos: imageInfos,
                );
        } else {
          /// Send the image to the separate thread for encoding.
          bytes = await _threadManager.send(
            await _generateSendEncodeData(
              id: id,
              image: image,
            ),
          );
        }
      } else {
        /// Encode the image on the main thread.
        bytes = await encodeImageFromThreadRequest(
          await _generateSendEncodeData(image: image, id: 'id'),
        );
      }
    }

    return bytes;
  }

  /// Retrieves the raw rendered dart ui image from the widget tree based on the
  /// provided `ImageInfos`. This method supports capturing images at
  /// different pixel ratios and optional thumbnail generation.
  Future<ui.Image?> getRawRenderedImage({
    required ImageInfos imageInfos,
    bool? useThumbnailSize,
    GlobalKey? widgetKey,
  }) async {
    return _imageRenderService.getRawRenderedImage(
      imageInfos: imageInfos,
      containerKey: containerKey,
      widgetKey: widgetKey,
      useThumbnailSize: useThumbnailSize ?? enableThumbnailGeneration,
    );
  }

  /// Adds a placeholder screenshot entry to the provided list of
  /// `ThreadCaptureState` objects. The placeholder is marked as broken and can
  /// be used to track incomplete or failed captures in multi-threaded
  /// processing.
  void addEmptyScreenshot({
    required List<ThreadCaptureState> screenshots,
  }) {
    screenshots.add(ThreadCaptureState()..broken = true);
  }

  /// Prepares a `ThreadRequest` object with all the required data to encode
  /// an image using the current configuration. This data is used for
  /// processing in a separate isolate or web worker.
  Future<ThreadRequest> _generateSendEncodeData({
    required ui.Image image,
    required String id,
  }) async {
    return ThreadRequest.fromConfigs(
      id: id,
      image: await convertFlutterUiToImage(image),
      configs: _configs,
    );
  }
}
