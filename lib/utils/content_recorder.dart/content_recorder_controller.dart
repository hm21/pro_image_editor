import 'dart:async';
import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;
import 'package:mime/mime.dart';
import 'package:pro_image_editor/pro_image_editor.dart';

import '../../models/multi_threading/thread_capture_model.dart';
import '../../models/multi_threading/thread_request_model.dart';
import '../unique_id_generator.dart';
import 'threads_managers/isolate/isolate_manager.dart';
import 'threads_managers/web_worker/web_worker_manager_dummy.dart'
    if (dart.library.html) 'threads_managers/web_worker/web_worker_manager.dart';
import 'utils/dart_ui_remove_transparent_image_areas.dart';
import 'utils/encode_image.dart';

/// A controller class responsible for capturing and processing images
/// using an isolated thread for performance improvements.
class ContentRecorderController {
  /// Constructor to initialize the controller and set up the isolate if not
  /// running on the web.
  ContentRecorderController({
    required ProImageEditorConfigs configs,
    bool ignoreGeneration = false,
  }) : _configs = configs {
    containerKey = GlobalKey();
    recorderKey = GlobalKey();
    recorderStream = StreamController();

    if (!ignoreGeneration) _initMultiThreading();
  }

  /// A key to identify the container widget for rendering the image.
  late final GlobalKey containerKey;

  /// A key to identify the recorder widget for rendering the image.
  late final GlobalKey recorderKey;

  final ProImageEditorConfigs _configs;

  /// Generate only a thumbnail as final image.
  bool generateOnlyThumbnail = false;

  /// Instance of ProImageEditorWebWorker used for web worker communication.
  final WebWorkerManager _webWorkerManager = WebWorkerManager();

  /// Instance of ProImageEditorIsolate used for isolate communication.
  final IsolateManager _isolateManager = IsolateManager();

  /// Send widgets to the recorder widget which will draw them.
  late final StreamController<Widget?> recorderStream;

  /// A helper to ensure the widget is painted.
  Completer<bool> recordReadyHelper = Completer();

  /// Initializes the isolate and sets up communication ports.
  void _initMultiThreading() async {
    if (!kIsWeb) {
      _isolateManager.init(_configs);
    } else {
      _webWorkerManager.init(_configs);
    }
  }

  /// Destroys the isolate and closes the receive port if not running on the
  /// web.
  Future<void> destroy() async {
    await recorderStream.close();
    if (!recordReadyHelper.isCompleted) {
      recordReadyHelper.complete(true);
    }

    if (!kIsWeb) {
      _isolateManager.destroy();
    } else {
      _webWorkerManager.destroy();
    }
  }

  /// Captures an image using the provided configuration and optionally a
  /// specific completer ID and pixel ratio.
  /// The method determines if the task should be processed in an isolate or on
  /// the main thread based on the platform.
  ///
  /// [onImageCaptured] - Optional callback to handle the captured image.
  /// [id] - Optional unique identifier for the completer.
  /// [pixelRatio] - Optional pixel ratio for image rendering.
  /// [image] - Optional pre-rendered image.
  Future<Uint8List?> _capture({
    required ImageInfos imageInfos,
    Function(ui.Image?)? onImageCaptured,
    bool stateHistoryScreenshot = false,
    String? id,
    ui.Image? image,
    OutputFormat? outputFormat,
  }) async {
    /// If we're just capturing a screenshot for the state history in the web
    /// platform, but web worker is not supported, we return null.
    if (kIsWeb &&
        stateHistoryScreenshot &&
        !_webWorkerManager.supportWebWorkers) {
      return null;
    }

    outputFormat ??= _configs.imageGenerationConfigs.outputFormat;
    image ??= await _getRenderedImage(imageInfos: imageInfos);
    id ??= generateUniqueId();
    onImageCaptured?.call(image);
    if (image == null) return null;

    return await chooseCaptureMode(
      image: image,
      id: id,
      format: outputFormat,
    );
  }

  /// Selects the appropriate capture mode based on the platform and
  /// configuration.
  ///
  /// This function determines the capture mode based on the platform and
  /// configuration settings specified in [_configs]. If the configuration
  /// allows, the image generation may be offloaded to a separate thread or
  /// web worker for better performance. If an error occurs, it falls back
  /// to the main thread.
  Future<Uint8List?> chooseCaptureMode({
    required ui.Image image,
    required String id,
    OutputFormat? format,
  }) async {
    format ??= _configs.imageGenerationConfigs.outputFormat;

    if (_configs.imageGenerationConfigs.generateInsideSeparateThread) {
      try {
        if (!kIsWeb) {
          // Run in dart native the thread isolated.
          return await _captureWithNativeIsolated(
            image: image,
            id: id,
            format: format,
          );
        } else {
          // Run in web worker
          return await _captureWithWebWorker(
            image: image,
            id: id,
            format: format,
          );
        }
      } catch (e) {
        // Fallback to the main thread.
        debugPrint('Fallback to main thread: $e');
        return await _captureWithMainThread(image: image);
      }
    } else {
      return await _captureWithMainThread(image: image);
    }
  }

  /// Captures an image using an isolated thread and processes it according to
  /// the provided configuration.
  ///
  /// [image] - The image to be processed.
  /// [id] - The unique identifier for the completer.
  Future<Uint8List?> _captureWithNativeIsolated({
    required ui.Image image,
    required String id,
    required OutputFormat format,
  }) async {
    return await _isolateManager.send(
      await _generateSendImageData(
        id: id,
        image: image,
        format: format,
      ),
    );
  }

  /// Captures an image using an web worker and processes it according to the
  /// provided configuration.
  ///
  /// [image] - The image to be processed.
  /// [id] - The unique identifier for the completer.
  Future<Uint8List?> _captureWithWebWorker({
    required ui.Image image,
    required String id,
    required OutputFormat format,
  }) async {
    if (!_webWorkerManager.supportWebWorkers) {
      return await _captureWithMainThread(image: image);
    } else {
      return await _webWorkerManager.send(
        await _generateSendImageData(
          id: id,
          image: image,
          format: format,
        ),
      );
    }
  }

  /// Captures an image on the main thread and processes it according to the
  /// provided configuration.
  ///
  /// [image] - The image to be processed.
  Future<Uint8List?> _captureWithMainThread({
    required ui.Image image,
  }) async {
    if (_configs.imageGenerationConfigs.captureOnlyDrawingBounds) {
      image = await dartUiRemoveTransparentImgAreas(image) ?? image;
    }

    return await _encodeImage(image);
  }

  /// Converts a Flutter ui.Image to img.Image suitable for processing.
  ///
  /// [uiImage] - The image to be converted.
  Future<img.Image> _convertFlutterUiToImage(ui.Image uiImage) async {
    final uiBytes =
        await uiImage.toByteData(format: ui.ImageByteFormat.rawRgba);

    final image = img.Image.fromBytes(
      width: uiImage.width,
      height: uiImage.height,
      bytes: uiBytes!.buffer,
      numChannels: 4,
    );

    return image;
  }

  /// Get the rendered image from the widget tree using the specified pixel
  /// ratio.
  Future<ui.Image?> _getRenderedImage({
    required ImageInfos imageInfos,
    bool? useThumbnailSize,
    GlobalKey? widgetKey,
  }) async {
    try {
      widgetKey ??= containerKey;

      RenderObject? findRenderObject =
          widgetKey.currentContext?.findRenderObject();
      if (findRenderObject == null) return null;

      // If the render object's paint information is dirty we waiting until
      // it's painted or 500ms are ago.
      int retryHelper = 0;
      while (!findRenderObject.attached && retryHelper < 25) {
        await Future.delayed(const Duration(milliseconds: 20));
        retryHelper++;
      }

      RenderRepaintBoundary boundary =
          findRenderObject as RenderRepaintBoundary;
      BuildContext? context = widgetKey.currentContext;

      double outputRatio = imageInfos.pixelRatio;
      if (!_configs.imageGenerationConfigs.captureOnlyDrawingBounds &&
          context != null &&
          context.mounted) {
        outputRatio =
            max(imageInfos.pixelRatio, MediaQuery.of(context).devicePixelRatio);
      }

      useThumbnailSize ??= generateOnlyThumbnail;
      bool isOutputSizeTooLarge = _isOutputSizeTooLarge(
        imageInfos.renderedSize,
        outputRatio,
        useThumbnailSize,
      );
      if (isOutputSizeTooLarge) {
        outputRatio = max(
          _maxOutputDimension(useThumbnailSize).width / boundary.size.width,
          _maxOutputDimension(useThumbnailSize).height / boundary.size.height,
        );
      }

      double pixelRatio =
          _configs.imageGenerationConfigs.customPixelRatio ?? outputRatio;

      ui.Image image = await boundary.toImage(pixelRatio: pixelRatio);

      if (_configs.imageGenerationConfigs.captureOnlyBackgroundImageArea) {
        double cropRectRatio = !imageInfos.isRotated
            ? imageInfos.cropRectSize.aspectRatio
            : 1 / imageInfos.cropRectSize.aspectRatio;

        Size convertedImgSize = Size(
          image.width.toDouble(),
          image.height.toDouble(),
        );

        double convertedImgWidth = convertedImgSize.width;
        double convertedImgHeight = convertedImgSize.height;

        if (convertedImgSize.aspectRatio > cropRectRatio) {
          // Fit to height
          convertedImgSize =
              Size(convertedImgHeight * cropRectRatio, convertedImgHeight);
        } else {
          // Fit to width
          convertedImgSize =
              Size(convertedImgWidth, convertedImgWidth / cropRectRatio);
        }

        double cropWidth = convertedImgSize.width;
        double cropHeight = convertedImgSize.height;
        double cropX = max(0, image.width.toDouble() - cropWidth) / 2;
        double cropY = max(0, image.height.toDouble() - cropHeight) / 2;

        ui.PictureRecorder recorder = ui.PictureRecorder();
        Canvas(recorder).drawImageRect(
          image,
          Rect.fromLTWH(cropX, cropY, cropWidth, cropHeight),
          Rect.fromLTWH(0, 0, cropWidth, cropHeight),
          Paint(),
        );

        image = await recorder.endRecording().toImage(
              cropWidth.ceil(),
              cropHeight.ceil(),
            );
      }

      return image;
    } catch (e) {
      return null;
    }
  }

  /// Retrieves the original image based on the provided image information.
  ///
  /// This method asynchronously fetches the original image without using the
  /// thumbnail size.
  /// It calls the `_getRenderedImage` method with the `useThumbnailSize`
  /// parameter set to false.
  Future<ui.Image> getOriginalImage({required ImageInfos imageInfos}) async {
    return (await _getRenderedImage(
      imageInfos: imageInfos,
      useThumbnailSize: false,
    ))!;
  }

  /// Retrieves the maximum output dimension for image generation from the
  /// configuration.
  Size _maxOutputDimension(bool useThumbnailSize) => !useThumbnailSize
      ? _configs.imageGenerationConfigs.maxOutputSize
      : _configs.imageGenerationConfigs.maxThumbnailSize;

  /// Checks if the output size exceeds the maximum allowable dimensions.
  bool _isOutputSizeTooLarge(
    Size renderedSize,
    double outputRatio,
    bool useThumbnailSize,
  ) {
    Size outputSize = renderedSize * outputRatio;

    return outputSize.width > _maxOutputDimension(useThumbnailSize).width ||
        outputSize.height > _maxOutputDimension(useThumbnailSize).height;
  }

  /// Capture an invisible widget.
  Future<Uint8List?> captureFromWidget(
    Widget widget, {
    required ImageInfos imageInfos,
    Size? targetSize,
    OutputFormat? format,
    Function(ui.Image?)? onImageCaptured,
    bool stateHistoryScreenshot = false,
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
    ui.Image? image = await _getRenderedImage(
      imageInfos: imageInfos,
      useThumbnailSize: false,
      widgetKey: recorderKey,
    );

    recorderStream.add(null);

    return _capture(
      image: image,
      imageInfos: imageInfos,
      id: id,
      onImageCaptured: onImageCaptured,
      stateHistoryScreenshot: stateHistoryScreenshot,
      outputFormat: format,
    );
  }

  /// Capture an image of the current editor state in an isolate.
  ///
  /// This method captures the current state of the image editor as a
  /// screenshot.
  /// It sets all previously unprocessed screenshots to broken before
  /// capturing a new one.
  ///
  /// - `screenshotCtrl`: The controller to capture the screenshot.
  /// - `configs`: Configuration for the image editor.
  /// - `pixelRatio`: The pixel ratio to use for capturing the screenshot.
  void captureImage({
    required ImageInfos imageInfos,
    required List<ThreadCaptureState> screenshots,
    Size? targetSize,
    Widget? widget,
  }) async {
    if (!_configs.imageGenerationConfigs.generateImageInBackground ||
        !_configs.imageGenerationConfigs.generateInsideSeparateThread) {
      return;
    }

    /// Set every screenshot to broken which didn't read the ui image before
    /// changes happen.
    screenshots.where((el) => !el.processedRenderedImage).forEach((screenshot) {
      screenshot.broken = true;
    });
    ThreadCaptureState isolateCaptureState = ThreadCaptureState();
    screenshots.add(isolateCaptureState);
    Uint8List? bytes = widget == null
        ? await _capture(
            id: isolateCaptureState.id,
            imageInfos: imageInfos,
            stateHistoryScreenshot: true,
            onImageCaptured: (img) {
              isolateCaptureState.processedRenderedImage = true;
            },
          )
        : await captureFromWidget(
            widget,
            id: isolateCaptureState.id,
            imageInfos: imageInfos,
            targetSize: targetSize,
            stateHistoryScreenshot: true,
            onImageCaptured: (img) {
              isolateCaptureState.processedRenderedImage = true;
            },
          );
    isolateCaptureState.completer.complete(bytes ?? Uint8List.fromList([]));
    if (bytes == null) {
      isolateCaptureState.broken = true;
    }
  }

  /// Captures the final screenshot based on the provided parameters.
  ///
  /// This method handles the screenshot capture process, either by using an
  /// existing background screenshot, creating a new screenshot, or validating
  /// an existing image's format and size. It ensures the screenshot meets the
  /// required format and size, and handles errors by attempting a new capture.
  ///
  /// - Parameters:
  ///   - imageInfos: Information about the image being captured.
  ///   - backgroundScreenshot: An optional existing screenshot to use.
  ///   - widget: An optional widget to capture a screenshot from.
  ///   - context: The build context for the widget.
  ///   - originalImageBytes: Optional bytes of the original image.
  ///
  /// - Returns: The captured screenshot as a `Uint8List?`.
  Future<Uint8List?> captureFinalScreenshot({
    required ImageInfos imageInfos,
    required ThreadCaptureState? backgroundScreenshot,
    Widget? widget,
    BuildContext? context,
    Uint8List? originalImageBytes,
    Size? targetSize,
  }) async {
    Uint8List? bytes;

    bool activeScreenshotGeneration =
        backgroundScreenshot != null && !backgroundScreenshot.broken;
    String id = activeScreenshotGeneration
        ? backgroundScreenshot.id
        : generateUniqueId();

    try {
      if (!kIsWeb) {
        _isolateManager.destroyAllActiveTasks(id);
      } else {
        _webWorkerManager.destroyAllActiveTasks(id);
      }

      if (originalImageBytes == null) {
        if (activeScreenshotGeneration) {
          // Get screenshot from isolated generated thread.
          bytes = await backgroundScreenshot.completer.future;
        } else {
          // Capture a new screenshot if the current screenshot is broken or
          // didn't exists.
          bytes = widget == null
              ? await _capture(
                  id: id,
                  imageInfos: imageInfos,
                )
              : await captureFromWidget(
                  widget,
                  id: id,
                  targetSize: targetSize,
                  imageInfos: imageInfos,
                );
        }
      } else {
        // If the user didn't change anything just ensure the output-format
        // is correct.
        bytes = originalImageBytes;

        String contentType =
            lookupMimeType('', headerBytes: bytes) ?? 'Unknown';
        List<String> sp = contentType.split('/');
        bool formatIsCorrect = sp.length > 1 &&
            (_configs.imageGenerationConfigs.outputFormat.name == sp[1] ||
                (sp[1] == 'jpeg' &&
                    _configs.imageGenerationConfigs.outputFormat ==
                        OutputFormat.jpg));

        double outputRatio = imageInfos.pixelRatio;
        if (!_configs.imageGenerationConfigs.captureOnlyDrawingBounds &&
            context != null &&
            context.mounted) {
          outputRatio = max(
              imageInfos.pixelRatio, MediaQuery.of(context).devicePixelRatio);
        }
        bool isOutputSizeTooLarge = _isOutputSizeTooLarge(
          imageInfos.renderedSize,
          outputRatio,
          generateOnlyThumbnail,
        );
        if (!formatIsCorrect || isOutputSizeTooLarge) {
          final ui.Image image = await decodeImageFromList(originalImageBytes);
          if (_configs.imageGenerationConfigs.generateInsideSeparateThread) {
            if (kIsWeb || isOutputSizeTooLarge) {
              /// currently in the web flutter decode the image wrong so we need
              /// to recapture it.
              /// bytes = await _webWorkerManager.send(
              ///   await _generateSendEncodeData(
              ///     id: id,
              ///     image: image,
              ///   ),
              /// );
              bytes = widget == null
                  ? await _capture(
                      id: id,
                      imageInfos: imageInfos,
                    )
                  : await captureFromWidget(
                      widget,
                      id: id,
                      targetSize: targetSize,
                      imageInfos: imageInfos,
                    );
            } else {
              bytes = await _isolateManager.send(
                await _generateSendEncodeData(
                  id: id,
                  image: image,
                ),
              );
            }
          } else {
            bytes = await _encodeImage(image);
          }
        }
      }
    } catch (e) {
      debugPrint(e.toString());

      // Take a new screenshot when something went wrong.
      bytes = widget == null
          ? await _capture(
              id: id,
              imageInfos: imageInfos,
            )
          : await captureFromWidget(
              widget,
              id: id,
              targetSize: targetSize,
              imageInfos: imageInfos,
            );
    }
    return bytes;
  }

  /// Adds an empty screenshot to the provided list of screenshots.
  ///
  /// This method creates a `ThreadCaptureState` marked as broken and adds it
  /// to the list of screenshots.
  ///
  /// - Parameters:
  ///   - screenshots: The list of screenshots to add the empty screenshot to.
  void addEmptyScreenshot({
    required List<ThreadCaptureState> screenshots,
  }) {
    ThreadCaptureState isolateCaptureState = ThreadCaptureState()
      ..broken = true;
    screenshots.add(isolateCaptureState);
  }

  /// Encodes the provided image into the desired format.
  ///
  /// This method takes a `ui.Image` and encodes it based on the current
  /// configuration settings, such as output format, quality, and other
  /// parameters.
  ///
  /// - Parameters:
  ///   - image: The `ui.Image` to encode.
  ///
  /// - Returns: The encoded image as a `Uint8List`.
  Future<Uint8List> _encodeImage(ui.Image image) async {
    return await encodeImage(
      image: await _convertFlutterUiToImage(image),
      outputFormat: _configs.imageGenerationConfigs.outputFormat,
      singleFrame: _configs.imageGenerationConfigs.singleFrame,
      jpegQuality: _configs.imageGenerationConfigs.jpegQuality,
      jpegChroma: _configs.imageGenerationConfigs.jpegChroma,
      pngFilter: _configs.imageGenerationConfigs.pngFilter,
      pngLevel: _configs.imageGenerationConfigs.pngLevel,
    );
  }

  /// Generates the image data for sending to a separate thread.
  ///
  /// This method creates an `ImageConvertThreadRequest` with the necessary
  /// information to convert the image in a separate thread, based on the
  /// current configuration settings.
  ///
  /// - Parameters:
  ///   - image: The `ui.Image` to convert.
  ///   - id: The unique identifier for the request.
  ///
  /// - Returns: The `ImageConvertThreadRequest` with the image data.
  Future<ImageConvertThreadRequest> _generateSendImageData({
    required ui.Image image,
    required String id,
    required OutputFormat format,
  }) async {
    return ImageConvertThreadRequest(
      id: id,
      generateOnlyImageBounds:
          _configs.imageGenerationConfigs.captureOnlyDrawingBounds,
      outputFormat: format,
      jpegChroma: _configs.imageGenerationConfigs.jpegChroma,
      jpegQuality: _configs.imageGenerationConfigs.jpegQuality,
      pngFilter: _configs.imageGenerationConfigs.pngFilter,
      pngLevel: _configs.imageGenerationConfigs.pngLevel,
      singleFrame: _configs.imageGenerationConfigs.singleFrame,
      image: await _convertFlutterUiToImage(image),
    );
  }

  /// Generates the encode data for sending to a separate thread.
  ///
  /// This method creates a `ThreadRequest` with the necessary information to
  /// encode the image in a separate thread, based on the current configuration
  /// settings.
  ///
  /// - Parameters:
  ///   - image: The `ui.Image` to encode.
  ///   - id: The unique identifier for the request.
  ///
  /// - Returns: The `ThreadRequest` with the encode data.
  Future<ThreadRequest> _generateSendEncodeData({
    required ui.Image image,
    required String id,
  }) async {
    return ThreadRequest(
      id: id,
      image: await _convertFlutterUiToImage(image),
      outputFormat: _configs.imageGenerationConfigs.outputFormat,
      singleFrame: _configs.imageGenerationConfigs.singleFrame,
      jpegQuality: _configs.imageGenerationConfigs.jpegQuality,
      jpegChroma: _configs.imageGenerationConfigs.jpegChroma,
      pngFilter: _configs.imageGenerationConfigs.pngFilter,
      pngLevel: _configs.imageGenerationConfigs.pngLevel,
    );
  }
}
