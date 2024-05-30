// Dart imports:
import 'dart:async';
import 'dart:math';
import 'dart:ui' as ui;

// Flutter imports:
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';

// Package imports:
import 'package:image/image.dart' as img;
import 'package:mime/mime.dart';
import 'package:pro_image_editor/utils/content_recorder.dart/threads_managers/isolate/isolate_manager.dart';

import '../../models/editor_configs/pro_image_editor_configs.dart';
import '../../models/multi_threading/thread_capture_model.dart';
import '../../models/multi_threading/thread_request_model.dart';
import '../decode_image.dart';
import '../unique_id_generator.dart';
import 'utils/dart_ui_remove_transparent_image_areas.dart';
import 'utils/encode_image.dart';
import 'threads_managers/web_worker/web_worker_manager_dummy.dart'
    if (dart.library.html) 'threads_managers/web_worker/web_worker_manager.dart';

/// A controller class responsible for capturing and processing images
/// using an isolated thread for performance improvements.
class ContentRecorderController {
  /// A key to identify the container widget for rendering the image.
  late final GlobalKey containerKey;

  final ProImageEditorConfigs _configs;

  /// Instance of ProImageEditorWebWorker used for web worker communication.
  final WebWorkerManager _webWorkerManager = WebWorkerManager();

  /// Instance of ProImageEditorIsolate used for isolate communication.
  final IsolateManager _isolateManager = IsolateManager();

  /// Constructor to initialize the controller and set up the isolate if not running on the web.
  ContentRecorderController({
    required ProImageEditorConfigs configs,
    bool ignoreGeneration = false,
  }) : _configs = configs {
    containerKey = GlobalKey();

    if (!ignoreGeneration) _initMultiThreading();
  }

  /// Initializes the isolate and sets up communication ports.
  void _initMultiThreading() async {
    if (!kIsWeb) {
      _isolateManager.init(_configs);
    } else {
      _webWorkerManager.init(_configs);
    }
  }

  /// Destroys the isolate and closes the receive port if not running on the web.
  Future<void> destroy() async {
    if (!kIsWeb) {
      _isolateManager.destroy();
    } else {
      _webWorkerManager.destroy();
    }
  }

  /// Captures an image using the provided configuration and optionally a specific completer ID and pixel ratio.
  /// The method determines if the task should be processed in an isolate or on the main thread based on the platform.
  ///
  /// [onImageCaptured] - Optional callback to handle the captured image.
  /// [id] - Optional unique identifier for the completer.
  /// [pixelRatio] - Optional pixel ratio for image rendering.
  /// [image] - Optional pre-rendered image.
  Future<Uint8List?> _capture({
    required ImageInfos imageInfos,
    Function(ui.Image?)? onImageCaptured,
    bool stateHistroyScreenshot = false,
    String? id,
    ui.Image? image,
  }) async {
    // If we're just capturing a screenshot for the state history in the web platform,
    // but web worker is not supported, we return null.
    if (kIsWeb &&
        stateHistroyScreenshot &&
        !_webWorkerManager.supportWebWorkers) {
      return null;
    }

    image ??= await _getRenderedImage(
      imageInfos: imageInfos,
      generateOnlyImageBounds:
          _configs.imageGenerationConfigs.generateOnlyImageBounds,
    );
    id ??= generateUniqueId();
    onImageCaptured?.call(image);
    if (image == null) return null;

    if (_configs.imageGenerationConfigs.generateIsolated) {
      try {
        if (!kIsWeb) {
          // Run in dart native the thread isolated.
          return await _captureWithNativeIsolated(
            image: image,
            id: id,
          );
        } else {
          // Run in web worker
          return await _captureWithWebWorker(
            image: image,
            id: id,
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

  /// Captures an image using an isolated thread and processes it according to the provided configuration.
  ///
  /// [image] - The image to be processed.
  /// [id] - The unique identifier for the completer.
  Future<Uint8List?> _captureWithNativeIsolated({
    required ui.Image image,
    required String id,
  }) async {
    return await _isolateManager.send(
      await _generateSendImageData(id: id, image: image),
    );
  }

  /// Captures an image using an web worker and processes it according to the provided configuration.
  ///
  /// [image] - The image to be processed.
  /// [id] - The unique identifier for the completer.
  Future<Uint8List?> _captureWithWebWorker({
    required ui.Image image,
    required String id,
  }) async {
    if (!_webWorkerManager.supportWebWorkers) {
      return await _captureWithMainThread(image: image);
    } else {
      return await _webWorkerManager.send(
        await _generateSendImageData(id: id, image: image),
      );
    }
  }

  /// Captures an image on the main thread and processes it according to the provided configuration.
  ///
  /// [image] - The image to be processed.
  Future<Uint8List?> _captureWithMainThread({
    required ui.Image image,
  }) async {
    if (_configs.imageGenerationConfigs.generateOnlyImageBounds) {
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

  /// Get the rendered image from the widget tree using the specified pixel ratio.
  Future<ui.Image?> _getRenderedImage({
    required ImageInfos imageInfos,
    required bool generateOnlyImageBounds,
  }) async {
    try {
      var findRenderObject = containerKey.currentContext?.findRenderObject();
      if (findRenderObject == null) return null;

      // If the render object's paint information is dirty we waiting until it's painted
      // or 500ms are ago.
      int retryHelper = 0;
      while (!findRenderObject.attached && retryHelper < 25) {
        await Future.delayed(const Duration(milliseconds: 20));
        retryHelper++;
      }

      RenderRepaintBoundary boundary =
          findRenderObject as RenderRepaintBoundary;
      BuildContext? context = containerKey.currentContext;

      double outputRatio = imageInfos.pixelRatio;
      if (!generateOnlyImageBounds && context != null && context.mounted) {
        outputRatio =
            max(imageInfos.pixelRatio, MediaQuery.of(context).devicePixelRatio);
      }

      if (_isOutputSizeTooLarge(imageInfos.renderedSize, outputRatio)) {
        outputRatio = min(
          _maxOutputDimension.width / imageInfos.renderedSize.width,
          _maxOutputDimension.height / imageInfos.renderedSize.height,
        );
      }

      ui.Image image = await boundary.toImage(pixelRatio: outputRatio);

      return image;
    } catch (e) {
      return null;
    }
  }

  /// Retrieves the maximum output dimension for image generation from the configuration.
  Size get _maxOutputDimension =>
      _configs.imageGenerationConfigs.maxOutputDimension;

  /// Checks if the output size exceeds the maximum allowable dimensions.
  bool _isOutputSizeTooLarge(Size renderedSize, double outputRatio) {
    Size outputSize = renderedSize * outputRatio;

    return outputSize.width > _maxOutputDimension.width ||
        outputSize.height > _maxOutputDimension.height;
  }

  /// Value for [delay] should increase with widget tree size. Prefered value is 1 seconds
  ///
  /// [context] parameter is used to Inherit App Theme and MediaQuery data.
  ///
  /// This function is inspired from the package `screenshot` from the autor SachinGanesh.
  /// https://pub.dev/packages/screenshot
  Future<Uint8List?> captureFromWidget(
    Widget widget, {
    required ImageInfos imageInfos,
    BuildContext? context,
    Size? targetSize,
    Function(ui.Image?)? onImageCaptured,
    bool stateHistroyScreenshot = false,
    String? id,
  }) async {
    ui.Image image = await _widgetToUiImage(
      widget,
      context: context,
      targetSize: targetSize,
    );
    return _capture(
      image: image,
      imageInfos: imageInfos,
      id: id,
      onImageCaptured: onImageCaptured,
      stateHistroyScreenshot: stateHistroyScreenshot,
    );
  }

  /// If you are building a desktop/web application that supports multiple view. Consider passing the [context] so that flutter know which view to capture.
  Future<ui.Image> _widgetToUiImage(
    Widget widget, {
    BuildContext? context,
    Size? targetSize,
  }) async {
    int retryCounter = 3;
    bool isDirty = false;

    Widget child = widget;
    if (context != null) {
      child = InheritedTheme.captureAll(
        context,
        MediaQuery(
          data: MediaQuery.of(context),
          child: Material(
            color: Colors.transparent,
            child: child,
          ),
        ),
      );
    }

    final RenderRepaintBoundary repaintBoundary = RenderRepaintBoundary();
    final platformDispatcher = WidgetsBinding.instance.platformDispatcher;
    final fallBackView = platformDispatcher.views.first;
    final view =
        context == null ? fallBackView : View.maybeOf(context) ?? fallBackView;
    Size logicalSize =
        targetSize ?? view.physicalSize / view.devicePixelRatio; // Adapted
    Size imageSize = targetSize ?? view.physicalSize; // Adapted

    assert(logicalSize.aspectRatio.toStringAsPrecision(5) ==
        imageSize.aspectRatio
            .toStringAsPrecision(5)); // Adapted (toPrecision was not available)

    final RenderView renderView = RenderView(
      view: view,
      child: RenderPositionedBox(
          alignment: Alignment.center, child: repaintBoundary),
      configuration: ViewConfiguration(
        // size: logicalSize,
        logicalConstraints: BoxConstraints(
          maxWidth: logicalSize.width,
          maxHeight: logicalSize.height,
        ),
        devicePixelRatio: 1.0,
      ),
    );

    final PipelineOwner pipelineOwner = PipelineOwner();
    final BuildOwner buildOwner = BuildOwner(
        focusManager: FocusManager(),
        onBuildScheduled: () {
          ///current render is dirty, mark it.
          isDirty = true;
        });

    pipelineOwner.rootNode = renderView;
    renderView.prepareInitialFrame();

    final RenderObjectToWidgetElement<RenderBox> rootElement =
        RenderObjectToWidgetAdapter<RenderBox>(
            container: repaintBoundary,
            child: Directionality(
              textDirection: TextDirection.ltr,
              child: child,
            )).attachToRenderTree(
      buildOwner,
    );

    ///Render Widget
    buildOwner.buildScope(
      rootElement,
    );
    buildOwner.finalizeTree();

    pipelineOwner.flushLayout();
    pipelineOwner.flushCompositingBits();
    pipelineOwner.flushPaint();

    ui.Image? image;

    do {
      ///Reset the dirty flag
      isDirty = false;

      // If the render object's paint information is dirty we waiting until it's painted
      // or 1000ms are ago.
      int retryHelper = 0;
      while (!repaintBoundary.attached && retryHelper < 50) {
        await Future.delayed(const Duration(milliseconds: 20));
        retryHelper++;
      }

      image = await repaintBoundary.toImage(
        pixelRatio: imageSize.width / logicalSize.width,
      );

      ///Check does this require rebuild
      if (isDirty) {
        ///Previous capture has been updated, re-render again.
        buildOwner.buildScope(
          rootElement,
        );
        buildOwner.finalizeTree();
        pipelineOwner.flushLayout();
        pipelineOwner.flushCompositingBits();
        pipelineOwner.flushPaint();
      }
      retryCounter--;

      ///retry untill capture is successfull
    } while (isDirty && retryCounter >= 0);
    try {
      /// Dispose All widgets
      // rootElement.visitChildren((Element element) {
      //   rootElement.deactivateChild(element);
      // });
      buildOwner.finalizeTree();
    } catch (e) {
      // Handle error
    }

    return image; // Adapted to directly return the image and not the Uint8List
  }

  /// Capture an image of the current editor state in an isolate.
  ///
  /// This method captures the current state of the image editor as a screenshot.
  /// It sets all previously unprocessed screenshots to broken before capturing a new one.
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
        !_configs.imageGenerationConfigs.generateIsolated) {
      return;
    }

    /// Set every screenshot to broken which didn't read the ui image before
    /// changes happen.
    screenshots.where((el) => !el.readedRenderedImage).forEach((screenshot) {
      screenshot.broken = true;
    });
    ThreadCaptureState isolateCaptureState = ThreadCaptureState();
    screenshots.add(isolateCaptureState);
    Uint8List? bytes = widget == null
        ? await _capture(
            id: isolateCaptureState.id,
            imageInfos: imageInfos,
            stateHistroyScreenshot: true,
            onImageCaptured: (img) {
              isolateCaptureState.readedRenderedImage = true;
            },
          )
        : await captureFromWidget(
            widget,
            id: isolateCaptureState.id,
            imageInfos: imageInfos,
            targetSize: targetSize,
            stateHistroyScreenshot: true,
            onImageCaptured: (img) {
              isolateCaptureState.readedRenderedImage = true;
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
                  context: context,
                  id: id,
                  targetSize: targetSize,
                  imageInfos: imageInfos,
                );
        }
      } else {
        // If the user didn't change anything just ensure the outputformat
        // is correct.
        bytes = originalImageBytes;

        String contentType = lookupMimeType('', headerBytes: bytes) ?? 'Unkown';
        List<String> sp = contentType.split('/');
        bool formatIsCorrect = sp.length > 1 &&
            (_configs.imageGenerationConfigs.outputFormat.name == sp[1] ||
                (sp[1] == 'jpeg' &&
                    _configs.imageGenerationConfigs.outputFormat ==
                        OutputFormat.jpg));

        double outputRatio = imageInfos.pixelRatio;
        if (!_configs.imageGenerationConfigs.generateOnlyImageBounds &&
            context != null &&
            context.mounted) {
          outputRatio = max(
              imageInfos.pixelRatio, MediaQuery.of(context).devicePixelRatio);
        }

        if (!formatIsCorrect ||
            _isOutputSizeTooLarge(imageInfos.renderedSize, outputRatio)) {
          final ui.Image image = await decodeImageFromList(originalImageBytes);
          if (_configs.imageGenerationConfigs.generateIsolated) {
            if (kIsWeb ||
                _isOutputSizeTooLarge(imageInfos.renderedSize, outputRatio)) {
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
                      // ignore: use_build_context_synchronously
                      context: context,
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
              // ignore: use_build_context_synchronously
              context: context,
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
    ThreadCaptureState isolateCaptureState = ThreadCaptureState();
    isolateCaptureState.broken = true;
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
  }) async {
    return ImageConvertThreadRequest(
      id: id,
      generateOnlyImageBounds:
          _configs.imageGenerationConfigs.generateOnlyImageBounds,
      outputFormat: _configs.imageGenerationConfigs.outputFormat,
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
