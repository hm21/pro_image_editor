// Dart imports:
// ignore_for_file: use_build_context_synchronously

// Dart imports:
import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'dart:ui' as ui;

// Flutter imports:
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';

// Package imports:
import 'package:image/image.dart' as img;

// Project imports:
import 'package:pro_image_editor/models/editor_configs/pro_image_editor_configs.dart';
import 'package:pro_image_editor/pro_image_editor.dart';
import 'package:pro_image_editor/utils/unique_id_generator.dart';
import '../../models/isolate_models/isolate_capture_model.dart';
import 'isolate_model.dart';
import 'utils/content_recorder_models.dart';
import 'utils/dart_ui_remove_transparent_image_areas.dart';

import 'utils/web_worker/web_worker_image_converter_dummy.dart' if (dart.library.html) 'utils/web_worker/web_worker_image_converter.dart';

// This code is inspired from the package `screenshot` from the autor SachinGanesh.
// https://pub.dev/packages/screenshot

/// A controller class responsible for capturing and processing images
/// using an isolated thread for performance improvements.
class ContentRecorderController {
  /// A key to identify the container widget for rendering the image.
  late final GlobalKey containerKey;

  final ProImageEditorConfigs configs;

  /// A map to store unique completers for handling asynchronous image processing tasks.
  final Map<String, Completer<Uint8List?>> _uniqueCompleter = {};

  /// List of isolate models used for managing isolates.
  final List<IsolateModel> _isolateModels = [];

  /// Instance of ProImageEditorWebWorker used for web worker communication.
  final ProImageEditorWebWorker _webWorkerManager = ProImageEditorWebWorker();

  bool _destroyed = false;

  /// Constructor to initialize the controller and set up the isolate if not running on the web.
  ContentRecorderController({
    required this.configs,
    bool ignore = false,
  }) {
    containerKey = GlobalKey();
    if (!ignore) {
      _initIsolate();
    }
  }

  ProcessorConfigs get _processorConfigs => configs.imageGenerationConfigs.processorConfigs;

  /// Initializes the isolate and sets up communication ports.
  void _initIsolate() async {
    if (kIsWeb) {
      _webWorkerManager.init(configs);
    } else {
      int processors = getNumberOfProcessors(configs: _processorConfigs, deviceNumberOfProcessors: Platform.numberOfProcessors);
      for (var i = 0; i < processors; i++) {
        if (!_destroyed) {
          var isolate = IsolateModel(
            processorConfigs: _processorConfigs,
            coreNumber: i + 1,
            onMessage: (message) {
              _uniqueCompleter[message.completerId]!.complete(message.bytes);
            },
          );
          _isolateModels.add(isolate);

          /// Await that isolate is ready before spawn a new one.
          await isolate.isolateReady.future;
          isolate.isReady = true;
          if (_destroyed) {
            isolate.destroy();
          }
        }
      }
    }
  }

  /// Destroys the isolate and closes the receive port if not running on the web.
  Future<void> destroy() async {
    _destroyed = true;
    if (!kIsWeb) {
      for (var model in _isolateModels) {
        model.destroy();
      }
    } else {
      _webWorkerManager.destroy();
    }
  }

  /// Captures an image using the provided configuration and optionally a specific completer ID and pixel ratio.
  /// The method determines if the task should be processed in an isolate or on the main thread based on the platform.
  ///
  /// [configs] - The configuration for image capturing.
  /// [onImageCaptured] - Optional callback to handle the captured image.
  /// [completerId] - Optional unique identifier for the completer.
  /// [pixelRatio] - Optional pixel ratio for image rendering.
  /// [image] - Optional pre-rendered image.
  Future<Uint8List?> capture({
    required double? pixelRatio,
    Function(ui.Image?)? onImageCaptured,
    bool stateHistroyScreenshot = false,
    String? completerId,
    ui.Image? image,
  }) async {
    // If we're just capturing a screenshot for the state history in the web platform,
    // but web worker is not supported, we return null.
    if (kIsWeb && stateHistroyScreenshot && !_webWorkerManager.supportWebWorkers) {
      return null;
    }

    image ??= await _getRenderedImage(
      pixelRatio: pixelRatio,
      generateOnlyImageBounds: configs.imageGenerationConfigs.generateOnlyImageBounds,
    );
    completerId ??= generateUniqueId();
    onImageCaptured?.call(image);
    if (image == null) return null;

    if (configs.imageGenerationConfigs.generateIsolated) {
      try {
        if (!kIsWeb) {
          // Run in dart native the thread isolated.
          return await _captureNativeIsolated(image: image, completerId: completerId);
        } else {
          // Run in web worker
          return await _captureInsideWebWorker(image: image, completerId: completerId);
        }
      } catch (e) {
        // Fallback to the main thread.
        debugPrint('Fallback to main thread: $e');
        return await _captureInsideMainThread(image: image);
      }
    } else {
      return await _captureInsideMainThread(image: image);
    }
  }

  /// Captures an image on the main thread and processes it according to the provided configuration.
  ///
  /// [configs] - The configuration for image capturing.
  /// [image] - The image to be processed.
  Future<Uint8List?> _captureInsideMainThread({
    required ui.Image image,
  }) async {
    if (configs.imageGenerationConfigs.generateOnlyImageBounds) {
      image = await dartUiRemoveTransparentImgAreas(
            image,
          ) ??
          image;
    }

    // toByteData is a very slow task
    final croppedByteData = await image.toByteData(format: ui.ImageByteFormat.png);

    image.dispose();

    return croppedByteData?.buffer.asUint8List();
  }

  /// Captures an image using an isolated thread and processes it according to the provided configuration.
  ///
  /// [configs] - The configuration for image capturing.
  /// [image] - The image to be processed.
  /// [completerId] - The unique identifier for the completer.
  Future<Uint8List?> _captureNativeIsolated({
    required ui.Image image,
    required String completerId,
  }) async {
    var models = _isolateModels.where((model) => model.isReady).toList();
    if (models.isEmpty) models.add(_isolateModels.first);

    // Find the minimum number of active tasks among the ready models
    int minActiveTasks = models.map((model) => model.activeTasks).reduce(min);
    // Filter the models to include only those with the minimum number of active tasks
    List<IsolateModel> leastActiveTaskModels = models.where((model) => model.activeTasks == minActiveTasks).toList();
    // Randomly select one model from the list of models with the minimum number of active tasks
    IsolateModel isolateModel = leastActiveTaskModels[Random().nextInt(leastActiveTaskModels.length)];

    isolateModel.activeTasks++;

    /// Await that isolate is ready and setup new completer
    if (!isolateModel.isolateReady.isCompleted) {
      await isolateModel.isolateReady.future;
    }
    _uniqueCompleter[completerId] = Completer.sync();

    /// Kill all active isolates if reach limit
    if (_processorConfigs.processorMode == ProcessorMode.limit && isolateModel.activeTasks > _processorConfigs.maxConcurrency) {
      _uniqueCompleter.forEach((key, value) async {
        value.complete(null);
        await value.future;
      });

      await destroy();

      _uniqueCompleter.clear();
      _isolateModels.clear();

      _initIsolate();

      isolateModel = _isolateModels.first;
      await isolateModel.isolateReady.future;
    }

    /// Send to isolate
    isolateModel.send(
      ImageFromMainThread(
        completerId: completerId,
        generateOnlyImageBounds: configs.imageGenerationConfigs.generateOnlyImageBounds,
        image: await _convertFlutterUiToImage(image),
      ),
    );

    Uint8List? bytes = await _uniqueCompleter[completerId]!.future;
    _uniqueCompleter.remove(completerId);
    return bytes;
  }

  /// Captures an image using an web worker and processes it according to the provided configuration.
  ///
  /// [configs] - The configuration for image capturing.
  /// [image] - The image to be processed.
  /// [completerId] - The unique identifier for the completer.
  Future<Uint8List?> _captureInsideWebWorker({
    required ui.Image image,
    required String completerId,
  }) async {
    if (!_webWorkerManager.supportWebWorkers) {
      return await _captureInsideMainThread(image: image);
    } else {
      return await _webWorkerManager.sendImage(
        ImageFromMainThread(
          completerId: completerId,
          generateOnlyImageBounds: configs.imageGenerationConfigs.generateOnlyImageBounds,
          image: await _convertFlutterUiToImage(image),
        ),
      );
    }
  }

  /// Converts a Flutter ui.Image to img.Image suitable for processing.
  ///
  /// [uiImage] - The image to be converted.
  Future<img.Image> _convertFlutterUiToImage(ui.Image uiImage) async {
    final uiBytes = await uiImage.toByteData(format: ui.ImageByteFormat.rawRgba);

    final image = img.Image.fromBytes(
      width: uiImage.width,
      height: uiImage.height,
      bytes: uiBytes!.buffer,
      numChannels: 4,
    );

    return image;
  }

  /// Get the rendered image from the widget tree using the specified pixel ratio.
  ///
  /// [pixelRatio] - The pixel ratio to be used for rendering the image.
  Future<ui.Image?> _getRenderedImage({
    required double? pixelRatio,
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

      RenderRepaintBoundary boundary = findRenderObject as RenderRepaintBoundary;
      BuildContext? context = containerKey.currentContext;

      if (context != null && context.mounted) {
        if (!generateOnlyImageBounds && pixelRatio != null) {
          pixelRatio = max(pixelRatio, MediaQuery.of(context).devicePixelRatio);
        } else {
          pixelRatio ??= MediaQuery.of(context).devicePixelRatio;
        }
      }
      ui.Image image = await boundary.toImage(pixelRatio: pixelRatio ?? 1);

      return image;
    } catch (e) {
      return null;
    }
  }

  /// Value for [delay] should increase with widget tree size. Prefered value is 1 seconds
  ///
  /// [context] parameter is used to Inherit App Theme and MediaQuery data.
  Future<Uint8List?> captureFromWidget(
    Widget widget, {
    double? pixelRatio,
    BuildContext? context,
    Size? targetSize,
    Function(ui.Image?)? onImageCaptured,
    bool stateHistroyScreenshot = false,
    String? completerId,
  }) async {
    ui.Image image = await _widgetToUiImage(
      widget,
      pixelRatio: pixelRatio,
      context: context,
      targetSize: targetSize,
    );
    return capture(
      image: image,
      pixelRatio: pixelRatio,
      completerId: completerId,
      onImageCaptured: onImageCaptured,
      stateHistroyScreenshot: stateHistroyScreenshot,
    );
  }

  /// If you are building a desktop/web application that supports multiple view. Consider passing the [context] so that flutter know which view to capture.
  Future<ui.Image> _widgetToUiImage(
    Widget widget, {
    double? pixelRatio,
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
    final view = context == null ? fallBackView : View.maybeOf(context) ?? fallBackView;
    Size logicalSize = targetSize ?? view.physicalSize / view.devicePixelRatio; // Adapted
    Size imageSize = targetSize ?? view.physicalSize; // Adapted

    assert(logicalSize.aspectRatio.toStringAsPrecision(5) == imageSize.aspectRatio.toStringAsPrecision(5)); // Adapted (toPrecision was not available)

    final RenderView renderView = RenderView(
      view: view,
      child: RenderPositionedBox(alignment: Alignment.center, child: repaintBoundary),
      configuration: ViewConfiguration(
        // size: logicalSize,
        logicalConstraints: BoxConstraints(
          maxWidth: logicalSize.width,
          maxHeight: logicalSize.height,
        ),
        devicePixelRatio: pixelRatio ?? 1.0,
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

    final RenderObjectToWidgetElement<RenderBox> rootElement = RenderObjectToWidgetAdapter<RenderBox>(
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

      image = await repaintBoundary.toImage(pixelRatio: pixelRatio ?? (imageSize.width / logicalSize.width));

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
  void isolateCaptureImage({
    required double? pixelRatio,
    required List<IsolateCaptureState> screenshots,
    Widget? widget,
  }) async {
    if (!configs.imageGenerationConfigs.generateImageInBackground || !configs.imageGenerationConfigs.generateIsolated) {
      return;
    }

    /// Set every screenshot to broken which didn't read the ui image before
    /// changes happen.
    screenshots.where((el) => !el.readedRenderedImage).forEach((screenshot) {
      screenshot.broken = true;
    });
    IsolateCaptureState isolateCaptureState = IsolateCaptureState();
    screenshots.add(isolateCaptureState);
    Uint8List? bytes = widget == null
        ? await capture(
            completerId: isolateCaptureState.id,
            pixelRatio: pixelRatio,
            stateHistroyScreenshot: true,
            onImageCaptured: (img) {
              isolateCaptureState.readedRenderedImage = true;
            },
          )
        : await captureFromWidget(
            widget,
            completerId: isolateCaptureState.id,
            pixelRatio: pixelRatio,
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

  void isolateAddEmptyScreenshot({
    required List<IsolateCaptureState> screenshots,
  }) {
    IsolateCaptureState isolateCaptureState = IsolateCaptureState();
    isolateCaptureState.broken = true;
    screenshots.add(isolateCaptureState);
  }

  Future<Uint8List?> getFinalScreenshot({
    required double? pixelRatio,
    required IsolateCaptureState? backgroundScreenshot,
    Widget? widget,
    BuildContext? context,
    Uint8List? originalImageBytes,
  }) async {
    Uint8List? bytes;

    bool activeScreenshotGeneration = backgroundScreenshot != null && !backgroundScreenshot.broken;
    String completerId = activeScreenshotGeneration ? backgroundScreenshot.id : generateUniqueId();

    try {
      if (originalImageBytes == null) {
        if (_isolateModels.isNotEmpty) _destroyed = true;

        if (activeScreenshotGeneration) {
          // Get screenshot from isolated generated thread.
          bytes = await backgroundScreenshot.completer.future;
        } else {
          // Take a new screenshot if the screenshot is broken.
          bytes = widget == null
              ? await capture(
                  pixelRatio: pixelRatio,
                  completerId: completerId,
                )
              : await captureFromWidget(
                  widget,
                  context: context,
                  pixelRatio: pixelRatio,
                  completerId: completerId,
                );
        }
      } else {
        // If the user didn't change anything return the original image.
        bytes = originalImageBytes;
      }
    } catch (e) {
      debugPrint(e.toString());
      // Take a new screenshot when something goes wrong.
      bytes = widget == null
          ? await capture(
              pixelRatio: pixelRatio,
              completerId: completerId,
            )
          : await captureFromWidget(
              widget,
              context: context,
              pixelRatio: pixelRatio,
              completerId: completerId,
            );
    }
    return bytes;
  }
}

int getNumberOfProcessors({
  required ProcessorConfigs configs,
  required int deviceNumberOfProcessors,
}) {
  switch (configs.processorMode) {
    case ProcessorMode.auto:
      if (deviceNumberOfProcessors <= 4) {
        return deviceNumberOfProcessors - 1;
      } else if (deviceNumberOfProcessors <= 6) {
        return 4;
      } else if (deviceNumberOfProcessors <= 10) {
        return 6;
      } else {
        return 8;
      }
    case ProcessorMode.limit:
      return configs.numberOfBackgroundProcessors;
    case ProcessorMode.maximum:
      // One processor for the main-ui
      return deviceNumberOfProcessors - 1;
    case ProcessorMode.minimum:
      return 1;
  }
}
