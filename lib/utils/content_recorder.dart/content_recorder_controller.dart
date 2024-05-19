// Dart imports:
import 'dart:async';
import 'dart:isolate';
import 'dart:ui' as ui;

// Flutter imports:
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

// Package imports:
import 'package:image/image.dart' as img;

// Project imports:
import 'package:pro_image_editor/pro_image_editor.dart';
import 'package:pro_image_editor/utils/unique_id_generator.dart';
import 'utils/content_recorder_models.dart';
import 'utils/dart_ui_remove_transparent_image_areas.dart';
import 'utils/isolate_image_converter.dart';
import 'utils/web_worker/web_worker_image_converter_dummy.dart'
    if (dart.library.html) 'utils/web_worker/web_worker_image_converter.dart';

// This code is inspired from the package `screenshot` from the autor SachinGanesh.
// https://pub.dev/packages/screenshot

/// A controller class responsible for capturing and processing images
/// using an isolated thread for performance improvements.
class ContentRecorderController {
  /// A key to identify the container widget for rendering the image.
  late final GlobalKey containerKey;

  /// The isolate used for offloading image processing tasks.
  Isolate? _isolate;

  /// A map to store unique completers for handling asynchronous image processing tasks.
  final Map<String, Completer<Uint8List?>> _uniqueCompleter = {};

  /// The port used to send messages to the isolate.
  late SendPort _sendPort;

  /// The port used to receive messages from the isolate.
  late ReceivePort _receivePort;

  /// A completer to track when the isolate is ready for communication.
  late Completer _isolateReady;

  final ProImageEditorWebWorker _webWorker = ProImageEditorWebWorker();

  /// Constructor to initialize the controller and set up the isolate if not running on the web.
  ContentRecorderController() {
    containerKey = GlobalKey();
    _initIsolate();
  }

  /// Initializes the isolate and sets up communication ports.
  void _initIsolate() async {
    if (kIsWeb) {
      _webWorker.init();
    } else {
      _isolateReady = Completer.sync();
      _receivePort = ReceivePort();
      _receivePort.listen((message) {
        if (message is SendPort) {
          _sendPort = message;
          _isolateReady.complete();
        } else if (message is ResponseFromImageThread) {
          _uniqueCompleter[message.completerId]!.complete(message.bytes);
        }
      });
      _isolate =
          await Isolate.spawn(isolatedImageConverter, _receivePort.sendPort);
    }
  }

  /// Destroys the isolate and closes the receive port if not running on the web.
  void destroy() {
    if (!kIsWeb) {
      _isolate?.kill();
      _receivePort.close();
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
    required ProImageEditorConfigs configs,
    Function(ui.Image?)? onImageCaptured,
    bool stateHistroyScreenshot = false,
    String? completerId,
    double? pixelRatio,
    ui.Image? image,
  }) async {
    // If we're just capturing a screenshot for the state history in the web platform,
    // but web worker is not supported, we return null.
    if (kIsWeb &&
        stateHistroyScreenshot &&
        !(await _webWorker.readyState.future)) {
      return null;
    }

    image ??= await _getRenderedImage(pixelRatio);
    completerId ??= generateUniqueId();
    onImageCaptured?.call(image);
    if (image == null) return null;

    if (configs.enableIsolatedGeneration) {
      try {
        if (!kIsWeb) {
          // Run in dart native the thread isolated.
          return await _captureNativeIsolated(
              configs: configs, image: image, completerId: completerId);
        } else {
          // Run in web worker
          return await _captureInsideWebWorker(
              configs: configs, image: image, completerId: completerId);
        }
      } catch (e) {
        // Fallback to the main thread.
        debugPrint('Fallback to main thread: $e');
        return await _captureInsideMainThread(configs: configs, image: image);
      }
    } else {
      return await _captureInsideMainThread(configs: configs, image: image);
    }
  }

  /// Captures an image on the main thread and processes it according to the provided configuration.
  ///
  /// [configs] - The configuration for image capturing.
  /// [image] - The image to be processed.
  Future<Uint8List?> _captureInsideMainThread({
    required ProImageEditorConfigs configs,
    required ui.Image image,
  }) async {
    if (configs.removeTransparentAreas) {
      image = await dartUiRemoveTransparentImgAreas(
            image,
          ) ??
          image;
    }

    // toByteData is a very slow task
    final croppedByteData =
        await image.toByteData(format: ui.ImageByteFormat.png);

    image.dispose();

    return croppedByteData?.buffer.asUint8List();
  }

  /// Captures an image using an isolated thread and processes it according to the provided configuration.
  ///
  /// [configs] - The configuration for image capturing.
  /// [image] - The image to be processed.
  /// [completerId] - The unique identifier for the completer.
  Future<Uint8List?> _captureNativeIsolated({
    required ProImageEditorConfigs configs,
    required ui.Image image,
    required String completerId,
  }) async {
    if (!_isolateReady.isCompleted) await _isolateReady.future;
    _uniqueCompleter[completerId] = Completer.sync();

    _sendPort.send(
      ImageFromMainThread(
        completerId: completerId,
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
    required ProImageEditorConfigs configs,
    required ui.Image image,
    required String completerId,
  }) async {
    bool readyAndSupported = await _webWorker.readyState.future;
    if (!readyAndSupported) {
      return await _captureInsideMainThread(configs: configs, image: image);
    } else {
      return await _webWorker.sendImage(ImageFromMainThread(
        completerId: completerId,
        image: await _convertFlutterUiToImage(image),
      ));
    }
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
  ///
  /// [pixelRatio] - The pixel ratio to be used for rendering the image.
  Future<ui.Image?> _getRenderedImage(double? pixelRatio) async {
    try {
      var findRenderObject = containerKey.currentContext?.findRenderObject();
      if (findRenderObject == null) return null;

      // If the render object's paint information is dirty we waiting until it's painted
      // or 500ms are ago.
      int retryHelper = 0;
      while (findRenderObject.debugNeedsPaint && retryHelper < 25) {
        await Future.delayed(const Duration(milliseconds: 20));
        retryHelper++;
      }

      RenderRepaintBoundary boundary =
          findRenderObject as RenderRepaintBoundary;
      BuildContext? context = containerKey.currentContext;

      if (context != null && context.mounted) {
        pixelRatio ??= MediaQuery.of(context).devicePixelRatio;
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
    Duration delay = const Duration(seconds: 1),
    double? pixelRatio,
    BuildContext? context,
    Size? targetSize,
    required ProImageEditorConfigs configs,
  }) async {
    ui.Image image = await _widgetToUiImage(widget,
        delay: delay,
        pixelRatio: pixelRatio,
        context: context,
        targetSize: targetSize);
    return capture(
      configs: configs,
      image: image,
      pixelRatio: pixelRatio,
    );
  }

  /// If you are building a desktop/web application that supports multiple view. Consider passing the [context] so that flutter know which view to capture.
  Future<ui.Image> _widgetToUiImage(
    Widget widget, {
    Duration delay = const Duration(seconds: 1),
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

      image = await repaintBoundary.toImage(
          pixelRatio: pixelRatio ?? (imageSize.width / logicalSize.width));

      ///This delay sholud increas with Widget tree Size
      await Future.delayed(delay);

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
}
