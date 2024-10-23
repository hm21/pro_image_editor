// Dart imports:
import 'dart:io';
import 'dart:math';
import 'dart:ui';

// Flutter imports:
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart' hide Image;
import 'package:flutter/services.dart';

// Project imports:
import 'package:pro_image_editor/mixins/converted_callbacks.dart';
import 'package:pro_image_editor/models/crop_rotate_editor/transform_factors.dart';
import 'package:pro_image_editor/modules/crop_rotate_editor/utils/crop_area_history.dart';
import 'package:pro_image_editor/plugins/defer_pointer/defer_pointer.dart';
import 'package:pro_image_editor/pro_image_editor.dart';
import 'package:pro_image_editor/utils/content_recorder.dart/utils/record_invisible_widget.dart';
import 'package:pro_image_editor/utils/debounce.dart';
import 'package:pro_image_editor/widgets/extended/extended_transform_scale.dart';
import 'package:pro_image_editor/widgets/outside_gestures/crop_rotate_gesture_detector.dart';
import 'package:pro_image_editor/widgets/outside_gestures/outside_gesture_listener.dart';
import 'package:pro_image_editor/widgets/screen_resize_detector.dart';
import '../../mixins/converted_configs.dart';
import '../../mixins/extended_loop.dart';
import '../../mixins/standalone_editor.dart';
import '../../models/transform_helper.dart';
import '../../utils/layer_transform_generator.dart';
import '../../widgets/extended/extended_custom_paint.dart';
import '../../widgets/extended/extended_mouse_cursor.dart';
import '../../widgets/extended/extended_transform_translate.dart';
import '../../widgets/layer_stack.dart';
import '../../widgets/outside_gestures/outside_gesture_behavior.dart';
import '../../widgets/transform/transformed_content_generator.dart';
import '../filter_editor/widgets/filtered_image.dart';
import 'utils/crop_area_part.dart';
import 'utils/crop_aspect_ratios.dart';
import 'utils/crop_desktop_interaction_manager.dart';
import 'utils/rotate_angle.dart';
import 'widgets/crop_corner_painter.dart';

export 'widgets/crop_aspect_ratio_options.dart';

/// The `CropRotateEditor` widget allows users to editing images with crop, flip
/// and rotate tools.
///
/// You can create a `CropRotateEditor` using one of the factory methods
/// provided:
/// - `CropRotateEditor.file`: Loads an image from a file.
/// - `CropRotateEditor.asset`: Loads an image from an asset.
/// - `CropRotateEditor.network`: Loads an image from a network URL.
/// - `CropRotateEditor.memory`: Loads an image from memory as a `Uint8List`.
/// - `CropRotateEditor.autoSource`: Automatically selects the source based on
/// provided parameters.
class CropRotateEditor extends StatefulWidget
    with StandaloneEditor<CropRotateEditorInitConfigs> {
  /// Constructs a `CropRotateEditor` widget.
  ///
  /// The [key] parameter is used to provide a key for the widget.
  /// The [editorImage] parameter specifies the image to be edited.
  /// The [initConfigs] parameter specifies the initialization configurations
  /// for the editor.
  const CropRotateEditor._({
    super.key,
    required this.editorImage,
    required this.initConfigs,
  });

  /// Constructs a `CropRotateEditor` widget with image data loaded from memory.
  factory CropRotateEditor.memory(
    Uint8List byteArray, {
    Key? key,
    required CropRotateEditorInitConfigs initConfigs,
  }) {
    return CropRotateEditor._(
      key: key,
      editorImage: EditorImage(byteArray: byteArray),
      initConfigs: initConfigs,
    );
  }

  /// Constructs a `CropRotateEditor` widget with an image loaded from a file.
  factory CropRotateEditor.file(
    File file, {
    Key? key,
    required CropRotateEditorInitConfigs initConfigs,
  }) {
    return CropRotateEditor._(
      key: key,
      editorImage: EditorImage(file: file),
      initConfigs: initConfigs,
    );
  }

  /// Constructs a `CropRotateEditor` widget with an image loaded from an asset.
  factory CropRotateEditor.asset(
    String assetPath, {
    Key? key,
    required CropRotateEditorInitConfigs initConfigs,
  }) {
    return CropRotateEditor._(
      key: key,
      editorImage: EditorImage(assetPath: assetPath),
      initConfigs: initConfigs,
    );
  }

  /// Constructs a `CropRotateEditor` widget with an image loaded from a
  /// network URL.
  factory CropRotateEditor.network(
    String networkUrl, {
    Key? key,
    required CropRotateEditorInitConfigs initConfigs,
  }) {
    return CropRotateEditor._(
      key: key,
      editorImage: EditorImage(networkUrl: networkUrl),
      initConfigs: initConfigs,
    );
  }

  /// Constructs a `CropRotateEditor` widget with an image loaded automatically
  /// based on the provided source.
  ///
  /// Either [byteArray], [file], [networkUrl], or [assetPath] must be provided.
  factory CropRotateEditor.autoSource({
    Key? key,
    required CropRotateEditorInitConfigs initConfigs,
    Uint8List? byteArray,
    File? file,
    String? assetPath,
    String? networkUrl,
  }) {
    if (byteArray != null) {
      return CropRotateEditor.memory(
        byteArray,
        key: key,
        initConfigs: initConfigs,
      );
    } else if (file != null) {
      return CropRotateEditor.file(
        file,
        key: key,
        initConfigs: initConfigs,
      );
    } else if (networkUrl != null) {
      return CropRotateEditor.network(
        networkUrl,
        key: key,
        initConfigs: initConfigs,
      );
    } else if (assetPath != null) {
      return CropRotateEditor.asset(
        assetPath,
        key: key,
        initConfigs: initConfigs,
      );
    } else {
      throw ArgumentError(
          "Either 'byteArray', 'file', 'networkUrl' or 'assetPath' "
          'must be provided.');
    }
  }
  @override
  final CropRotateEditorInitConfigs initConfigs;
  @override
  final EditorImage editorImage;

  @override
  State<CropRotateEditor> createState() => CropRotateEditorState();
}

/// A state class for ImageCropRotateEditor widget.
///
/// This class handles the state and UI for an image editor
/// that supports cropping, rotating, and aspect ratio adjustments.
class CropRotateEditorState extends State<CropRotateEditor>
    with
        TickerProviderStateMixin,
        ImageEditorConvertedConfigs,
        ImageEditorConvertedCallbacks,
        StandaloneEditorState<CropRotateEditor, CropRotateEditorInitConfigs>,
        ExtendedLoop,
        CropAreaHistory {
  final _mouseCursorsKey = GlobalKey<ExtendedMouseRegionState>();

  /// A key used to access the state of the CropRotateGestureDetector widget.
  final _gestureKey = GlobalKey<CropRotateGestureDetectorState>();

  /// A ScrollController for controlling the scrolling behavior of the bottom
  /// navigation bar.
  late ScrollController _bottomBarScrollCtrl;

  /// Debounce object for handling the end of a scaling gesture.
  late final Debounce _onScaleEndDebounce;

  /// Debounce object for allowing updates during a scaling gesture.
  late final Debounce _onScaleAllowUpdateDebounce;

  /// A debounce object for scroll history actions.
  late final Debounce _scrollHistoryDebounce;

  /// Indicates whether to show the fake hero animation.
  bool _showFakeHero = true;

  /// Indicates whether interaction is currently blocked.
  bool _blockInteraction = false;

  /// Indicates whether scaling has started.
  bool _scaleStarted = false;

  /// Indicates whether interaction is currently active.
  bool _interactionActive = false;

  /// Determines if the image sticks to the screen width based on the image
  /// width and content constraints.
  bool get imageSticksToScreenWidth => _imgWidth >= editorBodySize.width;

  /// Determines if the image is rotated 90 degrees based on the rotation count.
  bool get _rotated90deg => rotationCount % 2 != 0;

  /// Indicates whether an active scale out gesture is in progress.
  bool _activeScaleOut = false;

  /// Indicates whether the image needs to be decoded.
  bool _imageNeedDecode = false;

  /// Indicates whether the image size has been decoded.
  bool _imageSizeIsDecoded = true;

  /// Generate a fake hero widget to animate between screens.
  bool enableFakeHero = false;

  /// Skip the first update because the outside listener needs one frame
  /// to correctly detect events.
  bool _scaleAllowUpdateHelper = false;

  /// The number of active pointers (touch points).
  int _activePointers = 0;

  /// The area considered for interactive corner gestures.
  late final double _interactiveCornerArea;

  /// Gets the width of the main image.
  double get _imgWidth => _mainImageSize.width;

  /// Gets the height of the main image.
  double get _imgHeight => _mainImageSize.height;

  /// The vertical space for cropping.
  double _cropSpaceVertical = 0;

  /// The horizontal space for cropping.
  double _cropSpaceHorizontal = 0;

  /// The ratio used for cropping, based on the aspect ratio and main image
  /// size.
  double get _ratio =>
      1 / (aspectRatio == 0 ? _mainImageSize.aspectRatio : aspectRatio);

  /// The opacity of the painter.
  double _painterOpacity = 0;

  /// The interaction progress for opacity.
  double _interactionOpacityProgress = 0;

  /// The padding around the screen.
  final double _screenPadding = 20;

  /// The starting scale value for pinch gestures.
  double _startingPinchScale = 1;

  /// Helper variable to store the initial scale value at the start of a
  /// scaling gesture.
  double _scaleStartZoomHelper = 1;

  /// The starting translate offset for gestures.
  Offset _startingTranslate = Offset.zero;

  /// The starting center offset for gestures.
  Offset _startingCenterOffset = Offset.zero;

  /// The view rectangle for the cropping area.
  Rect _viewRect = Rect.zero;

  /// Gets the size of the rendered image based on the constraints and rotation
  /// state.
  Size get _renderedImgSize => Size(
        _rotated90deg
            ? _renderedImgConstraints.maxHeight
            : _renderedImgConstraints.maxWidth,
        _rotated90deg
            ? _renderedImgConstraints.maxWidth
            : _renderedImgConstraints.maxHeight,
      );

  /// Gets the size of the main image, using decoded dimensions if not provided.
  Size get _mainImageSize =>
      mainImageSize ?? imageInfos?.renderedSize ?? Size.zero;

  /// The constraints for the rendered image.
  late BoxConstraints _renderedImgConstraints = const BoxConstraints();

  /// Details of the tap down event for double-tap gestures.
  late TapDownDetails _doubleTapDetails;

  /// The current part of the crop area being interacted with.
  CropAreaPart _currentCropAreaPart = CropAreaPart.none;

  /// Manager class for handling desktop interactions.
  late final CropDesktopInteractionManager _desktopInteractionManager;

  /// Configuration for the fake hero transformation.
  late TransformConfigs _fakeHeroTransformConfigs;

  /// List of layers in the image.
  late List<Layer> _layers;

  /// List of raw layers without any transformation.
  late List<Layer> _rawLayers;

  /// The current cursor style.
  MouseCursor _mouseCursor = SystemMouseCursors.basic;

  bool _hasToolbar = true;

  /// Sets the current mouse cursor and updates the widget that manages the
  /// cursor.
  set _cursor(MouseCursor cursor) {
    _mouseCursor = cursor;
    _mouseCursorsKey.currentState?.setCursor(cursor);
  }

  double _rotationScaleFactor = 1;

  @override
  CropCornerPainter? get cropPainter {
    return showWidgets
        ? CropCornerPainter(
            offset: translate,
            cropRect: cropRect,
            viewRect: _viewRect,
            scaleFactor: userScaleFactor,
            rotationScaleFactor: _rotationScaleFactor,
            interactionOpacity: _interactionOpacityProgress,
            screenSize: Size(
              editorBodySize.width,
              editorBodySize.height,
            ),
            fadeInOpacity: _painterOpacity,
            cornerThickness:
                imageEditorTheme.cropRotateEditor.cropCornerThickness,
            cornerLength: imageEditorTheme.cropRotateEditor.cropCornerLength,
            imageEditorTheme: imageEditorTheme,
            drawCircle: cropRotateEditorConfigs.roundCropper,
          )
        : null;
  }

  /// Returns the current mouse cursor style.
  MouseCursor get _cursor => _mouseCursor;

  @override
  void initState() {
    super.initState();

    // Initialize debounce
    _onScaleEndDebounce = Debounce(const Duration(milliseconds: 10));
    _onScaleAllowUpdateDebounce = Debounce(const Duration(milliseconds: 1));
    _scrollHistoryDebounce = Debounce(const Duration(milliseconds: 350));

    // Initialize controllers
    _bottomBarScrollCtrl = ScrollController();
    _fakeHeroTransformConfigs =
        initialTransformConfigs ?? TransformConfigs.empty();
    _interactiveCornerArea = isDesktop
        ? cropRotateEditorConfigs.desktopCornerDragArea
        : cropRotateEditorConfigs.mobileCornerDragArea;
    _desktopInteractionManager =
        CropDesktopInteractionManager(context: context);
    ServicesBinding.instance.keyboard.addHandler(_onKeyEvent);

    // Initialize image and layers
    _imageNeedDecode = mainImageSize == null;
    _imageSizeIsDecoded = !_imageNeedDecode;
    _layers = initConfigs.layers ?? [];
    _setRawLayers();

    // Initialize rotate animation
    double initAngle = initialTransformConfigs?.angle ?? 0.0;
    rotateCtrl = AnimationController(
        duration: cropRotateEditorConfigs.animationDuration, vsync: this);
    rotateCtrl.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        if (_blockInteraction) {
          addHistory(scaleRotation: oldScaleFactor);
        }
        _blockInteraction = false;
        cropRotateEditorCallbacks?.handleRotateEnd(rotateAnimation.value);
      }
    });
    rotateAnimation =
        Tween<double>(begin: initAngle, end: initAngle).animate(rotateCtrl);

    // Initialize scale animation
    double initScale = (initialTransformConfigs?.scaleRotation ?? 1);
    scaleCtrl = AnimationController(
        duration: cropRotateEditorConfigs.animationDuration, vsync: this);
    scaleAnimation =
        Tween<double>(begin: initScale, end: initScale).animate(scaleCtrl);

    // Initialize aspect ratio
    aspectRatio =
        cropRotateEditorConfigs.initAspectRatio ?? CropAspectRatios.custom;

    // Set pixel ratio if needed
    if (widget.initConfigs.convertToUint8List) {
      setImageInfos(activeHistory: activeHistory);
    }

    // Initialize transform configs if available
    if (initialTransformConfigs != null &&
        initialTransformConfigs!.isNotEmpty) {
      rotationCount = (initialTransformConfigs!.angle * 2 / pi).abs().toInt();
      flipX = initialTransformConfigs!.flipX;
      flipY = initialTransformConfigs!.flipY;
      translate = initialTransformConfigs!.offset;
      userScaleFactor = initialTransformConfigs!.scaleUser;
      aspectRatio = initialTransformConfigs!.aspectRatio;
      cropRect = initialTransformConfigs!.cropRect;
      _viewRect = initialTransformConfigs!.cropRect;
      oldScaleFactor = initialTransformConfigs!.scaleRotation;
      _rotationScaleFactor = oldScaleFactor;

      setInitHistory(initialTransformConfigs!);
    }

    // Initialize fake hero settings
    enableFakeHero = initConfigs.enableFakeHero;
    _showFakeHero = enableFakeHero;

    // Perform post-frame initialization
    cropRotateEditorCallbacks?.onInit?.call();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      cropRotateEditorCallbacks?.onAfterViewInit?.call();
      initialized = true;
      if (initialTransformConfigs != null &&
          initialTransformConfigs!.isNotEmpty &&
          initialTransformConfigs!.aspectRatio < 0) {
        aspectRatio = initialTransformConfigs!.cropRect.size.aspectRatio;
        calcCropRect(onlyViewRect: initialTransformConfigs?.isEmpty == false);
        aspectRatio = -1;
      } else {
        calcCropRect(onlyViewRect: initialTransformConfigs?.isEmpty == false);
      }

      if (!enableFakeHero) hideFakeHero();
      _updateAllStates();
      _setRawLayers();

      /// Skip one frame to ensure the image is correctly transformed
      Size? originalSize = initialTransformConfigs?.originalSize;
      if (originalSize != null && !originalSize.isInfinite) {
        WidgetsBinding.instance.addPostFrameCallback((_) async {
          /// Fit to the screen and set duration to zero
          double oldScaleAnimationValue = scaleAnimation.value;
          scaleCtrl.duration = Duration.zero;
          calcFitToScreen();
          scaleCtrl.duration = cropRotateEditorConfigs.animationDuration;

          _setCropRectBounding(oldScaleAnimationValue: oldScaleAnimationValue);
        });
      }
    });
  }

  @override
  void dispose() {
    _onScaleEndDebounce.dispose();
    _onScaleAllowUpdateDebounce.dispose();
    _bottomBarScrollCtrl.dispose();
    rotateCtrl.dispose();
    scaleCtrl.dispose();
    ServicesBinding.instance.keyboard.removeHandler(_onKeyEvent);
    super.dispose();
  }

  @override
  void setState(void Function() fn) {
    rebuildController.add(null);
    super.setState(fn);
  }

  void _setRawLayers({bool refit = false}) {
    if (refit) calcFitToScreen(animated: false);
    _rawLayers = LayerTransformGenerator(
      layers: _layers,
      activeTransformConfigs: _fakeHeroTransformConfigs,
      newTransformConfigs: TransformConfigs.empty(),
      layerDrawAreaSize: originalSize.isInfinite || originalSize.isEmpty
          ? mainBodySize ?? Size.zero
          : originalSize,
      undoChanges: true,
      fitToScreenFactor: _transformHelperScale,
      transformHelperScale: _transformHelperScale,
    ).updatedLayers;
  }

  double get _transformHelperScale => originalSize.isEmpty
      ? 1
      : TransformHelper(
          mainBodySize: (mainBodySize ?? editorBodySize),
          mainImageSize: _mainImageSize,
          editorBodySize: originalSize,
        ).scale;

  void _updateAllStates() {
    userScaleKey.currentState?.setScale(userScaleFactor);
    cropPainterKey.currentState?.update(
      foregroundPainter: cropPainter,
      isComplex: showWidgets,
      willChange: showWidgets,
    );
    translateKey.currentState?.setOffset(translate);

    setState(() {});
  }

  void _decodeImage() async {
    _imageSizeIsDecoded = false;
    _imageNeedDecode = false;

    var decodedImage =
        await decodeImageFromList(await editorImage.safeByteArray(context));

    if (!mounted) return;
    var w = decodedImage.width;
    var h = decodedImage.height;

    var widthRatio = w.toDouble() / editorBodySize.width;
    var heightRatio = h.toDouble() / editorBodySize.height;
    var pixelRatio = max(heightRatio, widthRatio);

    imageInfos = ImageInfos(
      rawSize: Size(w.toDouble(), h.toDouble()),
      renderedSize: Size(w / pixelRatio, h / pixelRatio),
      cropRectSize: cropRect.size,
      isRotated: _rotated90deg,
      pixelRatio: pixelRatio,
    );

    calcCropRect();
    _updateAllStates();
    // Skip a few frames to ensure image constraints are set correctly
    Future.delayed(const Duration(milliseconds: 60), () {
      calcCropRect();
      calcFitToScreen();
      _imageSizeIsDecoded = true;
      _updateAllStates();
      cropRotateEditorCallbacks?.handleUpdateUI();
    });
  }

  /// Hides the fake hero widget and updates the related UI states.
  void hideFakeHero() {
    /// Set the fake hero visibility flag to false.
    _showFakeHero = false;

    /// Show other widgets by setting the flag to true.
    showWidgets = true;

    /// Update the state of the crop painter with the current widget visibility.
    cropPainterKey.currentState?.update(
      isComplex: showWidgets,
      willChange: showWidgets,
    );

    /// Animate the opacity transition for the painter.
    loopWithTransitionTiming(
      (double curveT) {
        /// Adjust the painter opacity based on the transition curve.
        _painterOpacity = 1 * curveT;

        /// Update the crop painter with the new opacity.
        cropPainterKey.currentState?.update(foregroundPainter: cropPainter);
      },
      mounted: mounted,
      transitionFunction:
          cropRotateEditorConfigs.fadeInOutsideCropAreaAnimationCurve.transform,
      duration: cropRotateEditorConfigs.fadeInOutsideCropAreaAnimationDuration,
      onDone: takeScreenshot,
    );

    /// Call the method to update all states.
    _updateAllStates();
  }

  bool _onKeyEvent(KeyEvent event) {
    return _desktopInteractionManager.onKey(
      event,
      onRotate: rotate,
      onFlip: flip,
      onTranslate: (offset) async {
        // Calculate correct offset even image is rotated or flipped
        double radianAngle = rotateAnimation.value;
        double cosAngle = cos(radianAngle);
        double sinAngle = sin(radianAngle);

        double dx = offset.dy * sinAngle + offset.dx * cosAngle;
        double dy = offset.dy * cosAngle - offset.dx * sinAngle;

        dx *= (flipX ? -1 : 1);
        dy *= (flipY ? -1 : 1);

        Offset startOffset = translate;
        Offset targetOffset = translate += Offset(dx, dy);

        await loopWithTransitionTiming(
          (double curveT) {
            translate = Offset(
              lerpDouble(startOffset.dx, targetOffset.dx, curveT)!,
              lerpDouble(startOffset.dy, targetOffset.dy, curveT)!,
            );
            _setOffsetLimits();
          },
          mounted: mounted,
          duration: cropRotateEditorConfigs.animationDuration,
          transitionFunction:
              cropRotateEditorConfigs.scaleAnimationCurve.transform,
        );
        startOffset = targetOffset;
        _setOffsetLimits();
        addHistory();
      },
      onScale: (scale) async {
        double startZoom = userScaleFactor;
        double targetZoom = (userScaleFactor + scale)
            .clamp(1, cropRotateEditorConfigs.maxScale);

        await loopWithTransitionTiming(
          (double curveT) {
            userScaleFactor = startZoom + (targetZoom - startZoom) * curveT;

            _setOffsetLimits();
          },
          mounted: mounted,
          duration: cropRotateEditorConfigs.animationDuration,
          transitionFunction:
              cropRotateEditorConfigs.scaleAnimationCurve.transform,
        );
        startZoom = targetZoom;
        _setOffsetLimits();
        addHistory();
      },
      onUndoRedo: (undo) {
        if (undo) {
          undoAction();
        } else {
          redoAction();
        }
      },
    );
  }

  /// Handles the crop image operation.
  Future<void> done() async {
    if (_interactionActive ||
        (!_imageSizeIsDecoded && initConfigs.convertToUint8List)) {
      return;
    }
    _interactionActive = true;
    initConfigs.onImageEditingStarted?.call();

    /// If the user set a custom initAspectRatio we need to enforce add
    /// a history even there was no changes
    if (!canUndo &&
        cropRotateEditorConfigs.initAspectRatio != CropAspectRatios.custom) {
      addHistory();
    }

    TransformConfigs transformC =
        !canRedo && !canUndo && initialTransformConfigs != null
            ? initialTransformConfigs!
            : activeHistory;

    _showFakeHero = enableFakeHero;
    _fakeHeroTransformConfigs = transformC;
    _updateAllStates();

    if (!initConfigs.convertToUint8List) {
      List<Layer> updatedLayers = LayerTransformGenerator(
        layers: initConfigs.layers ?? [],
        activeTransformConfigs:
            initConfigs.transformConfigs ?? TransformConfigs.empty(),
        newTransformConfigs: transformC,
        layerDrawAreaSize: originalSize,
        fitToScreenFactor: _transformHelperScale,
        undoChanges: false,
      ).updatedLayers;
      _layers = updatedLayers;
      _updateAllStates();

      /// Read the image information in the case the user require them
      if (cropRotateEditorConfigs.provideImageInfos && imageInfos == null) {
        await setImageInfos(activeHistory: activeHistory);
      }

      await initConfigs.onDone
          ?.call(transformC, _transformHelperScale, imageInfos);
      if (mounted) Navigator.pop(context, transformC);
    } else {
      LoadingDialog.instance.show(
        context,
        configs: configs,
        theme: theme,
        message: i18n.doneLoadingMsg,
      );

      if (imageInfos == null) {
        await setImageInfos(activeHistory: activeHistory);
      }

      if (!mounted) {
        LoadingDialog.instance.hide();
        return;
      }
      Uint8List? bytes;
      int retry = 0;
      do {
        if (retry > 0) {
          debugPrint('Generation failed! Retry $retry');

          /// Cooldown for the case the image generation failed
          await Future.delayed(const Duration(milliseconds: 500));
          if (!mounted) return;
        }
        bytes = await screenshotCtrl.captureFinalScreenshot(
          imageInfos: imageInfos!,
          context: context,
          widget: _screenshotWidget(transformC),
          targetSize: _rotated90deg
              ? imageInfos!.renderedSize.flipped
              : imageInfos!.renderedSize,
          backgroundScreenshot:
              screenshotHistoryPosition >= screenshotHistory.length
                  ? null
                  : screenshotHistory[screenshotHistoryPosition],
        );
        retry++;
      } while (bytes == null && retry < 7 && mounted);

      if (bytes == null) {
        debugPrint('Failed to capture the final image.');
      }

      await initConfigs.onImageEditingComplete
          ?.call(bytes ?? Uint8List.fromList([]));

      LoadingDialog.instance.hide();

      initConfigs.onCloseEditor?.call();
    }
    cropRotateEditorCallbacks?.handleDone();
    _interactionActive = false;
  }

  /// Takes a screenshot of the current editor state.
  @override
  void takeScreenshot() async {
    if (!widget.initConfigs.convertToUint8List) return;

    await setImageInfos(activeHistory: activeHistory, forceUpdate: true);
    // Capture the screenshot in a post-frame callback to ensure the UI is
    //fully rendered.
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (initialTransformConfigs == null &&
          history.length == 1 &&
          history.first.isEmpty) {
        setInitHistory(
          TransformConfigs(
            angle: rotateAnimation.value,
            cropRect: cropRect,
            originalSize: originalSize,
            cropEditorScreenRatio: cropEditorScreenRatio,
            scaleUser: userScaleFactor,
            scaleRotation: scaleAnimation.value,
            aspectRatio: aspectRatio,
            flipX: flipX,
            flipY: flipY,
            offset: translate,
          ),
        );
      }

      TransformConfigs transformC =
          !canRedo && !canUndo && initialTransformConfigs != null
              ? initialTransformConfigs!
              : activeHistory;

      screenshotCtrl.captureImage(
        imageInfos: imageInfos!,
        screenshots: screenshotHistory,
        targetSize: _rotated90deg
            ? imageInfos!.renderedSize.flipped
            : imageInfos!.renderedSize,
        widget: _screenshotWidget(transformC),
      );
    });
  }

  /// Flip the image horizontally
  void flip() {
    if (!cropRotateEditorConfigs.canFlip) return;

    if (rotationCount % 2 != 0) {
      flipY = !flipY;
    } else {
      flipX = !flipX;
    }
    cropRotateEditorCallbacks?.handleFlip(flipX, flipY);
    addHistory();
    _updateAllStates();
  }

  /// Rotates the image clockwise.
  void rotate() {
    if (!cropRotateEditorConfigs.canRotate) return;

    _blockInteraction = true;
    var piHelper =
        cropRotateEditorConfigs.rotateDirection == RotateDirection.left
            ? -pi
            : pi;

    rotationCount++;
    rotateAnimation = Tween<double>(
            begin: rotateAnimation.value, end: rotationCount * piHelper / 2)
        .animate(
      CurvedAnimation(
        parent: rotateCtrl,
        curve: cropRotateEditorConfigs.rotateAnimationCurve,
      ),
    );
    rotateCtrl
      ..reset()
      ..forward();
    calcFitToScreen();

    cropRotateEditorCallbacks?.handleRotateStart(rotateAnimation.value);
  }

  @override
  calcFitToScreen({
    Curve? curve,
    Size? imageSize,
    bool animated = true,
  }) {
    if (!animated) scaleCtrl.duration = Duration.zero;
    Size contentSize = Size(
      editorBodySize.width - _screenPadding * 2,
      editorBodySize.height - _screenPadding * 2,
    );

    double cropSpaceHorizontal =
        _rotated90deg ? _cropSpaceVertical : _cropSpaceHorizontal;
    double cropSpaceVertical =
        _rotated90deg ? _cropSpaceHorizontal : _cropSpaceVertical;

    Size renderedSize = imageSize ?? _renderedImgSize;

    double scaleX =
        contentSize.width / (renderedSize.width - cropSpaceHorizontal);
    double scaleY =
        contentSize.height / (renderedSize.height - cropSpaceVertical);

    double scale = min(scaleX, scaleY);

    scaleAnimation = Tween<double>(begin: oldScaleFactor, end: scale).animate(
      CurvedAnimation(
        parent: scaleCtrl,
        curve: curve ?? cropRotateEditorConfigs.rotateAnimationCurve,
      ),
    );
    scaleCtrl
      ..reset()
      ..forward();

    double startRotateFactor = oldScaleFactor;
    double targetRotateFactor = scale;

    oldScaleFactor = scale;

    cropPainterKey.currentState?.setForegroundPainter(cropPainter);

    if (!startRotateFactor.isInfinite &&
        !startRotateFactor.isNaN &&
        !targetRotateFactor.isInfinite &&
        !targetRotateFactor.isNaN) {
      loopWithTransitionTiming(
        (double curveT) {
          _rotationScaleFactor =
              lerpDouble(startRotateFactor, targetRotateFactor, curveT)!;
          cropPainterKey.currentState?.setForegroundPainter(cropPainter);
        },
        mounted: mounted,
        duration: cropRotateEditorConfigs.animationDuration,
        transitionFunction:
            (curve ?? cropRotateEditorConfigs.rotateAnimationCurve).transform,
      );
    } else {
      _rotationScaleFactor = 1;
    }

    if (!animated) {
      scaleCtrl.duration = cropRotateEditorConfigs.animationDuration;
    }
  }

  void _setCropRectBounding({
    double? oldScaleAnimationValue,
  }) {
    if (!_renderedImgSize.isInfinite) {
      bool fitToWidth =
          (cropRect.width + _cropSpaceHorizontal) > _renderedImgSize.width;
      bool fitToHeight =
          (cropRect.height + _cropSpaceVertical) > _renderedImgSize.height;
      double ratio = cropRect.size.aspectRatio;

      /// If the cropRect is to small or it will fit to both sizes we choose
      /// from the aspect ratio.
      if ((fitToWidth && fitToHeight) ||
          (!fitToHeight &&
              !fitToWidth &&
              cropRect.width < _renderedImgSize.width &&
              cropRect.height < _renderedImgSize.height)) {
        fitToHeight = ratio < editorBodySize.aspectRatio;
        fitToWidth = !fitToHeight;
      }

      /// return if the cropRect has already the correct size
      if (!fitToWidth && !fitToHeight) return;

      Size oldSize = cropRect.size;

      calcCropRect(newRatio: 1 / ratio);

      /// Fit to the screen and set duration to zero
      calcFitToScreen(animated: false);

      double scaleFactor = fitToHeight
          ? cropRect.height / oldSize.height
          : cropRect.width / oldSize.width;

      /// Seems like this calculation is not required but it there is an issue
      /// we should multiply it below with the scaleFactor
      /// double scaleFitFactor = oldScaleAnimationValue == null ||
      /// _renderedImgSize.aspectRatio < ratio ?
      ///     1 :
      ///     scaleAnimation.value / oldScaleAnimationValue;

      translate = Offset(
        translate.dx * scaleFactor,
        translate.dy * scaleFactor,
      );
      _setOffsetLimits();
    }
  }

  /// Opens a dialog to select from predefined aspect ratios.
  void openAspectRatioOptions() {
    showModalBottomSheet<double>(
        context: context,
        backgroundColor:
            imageEditorTheme.cropRotateEditor.aspectRatioSheetBackgroundColor,
        isScrollControlled: true,
        builder: (BuildContext context) {
          return customWidgets.cropRotateEditor.aspectRatioOptions?.call(
                this,
                rebuildController.stream,
                aspectRatio,
                _mainImageSize.aspectRatio,
              ) ??
              CropAspectRatioOptions(
                aspectRatio: aspectRatio,
                configs: configs,
                originalAspectRatio: _mainImageSize.aspectRatio,
              );
        }).then((value) {
      if (value != null) {
        updateAspectRatio(value);
      }
    });
  }

  /// Updates the current aspect ratio with a new value and adds a new history
  /// entry.
  ///
  /// This method performs the following steps:
  /// 1. Resets the editor state while skipping the addition of a history entry.
  /// 2. Updates the aspect ratio to the provided value.
  /// 3. Triggers any necessary callbacks related to the new aspect ratio.
  /// 4. Recalculates the crop rectangle and fits it to the screen.
  /// 5. Adds a new history entry with the current scale factor and a rotation
  /// angle of zero.
  /// 6. Updates all relevant states in the editor.
  void updateAspectRatio(double value) {
    reset(skipAddHistory: true);
    aspectRatio = value;
    cropRotateEditorCallbacks?.handleRatioSelected(value);

    calcCropRect();
    calcFitToScreen();
    addHistory(scaleRotation: oldScaleFactor, angle: 0);
    _updateAllStates();
  }

  @override
  void calcCropRect({bool onlyViewRect = false, double? newRatio}) {
    double imgSizeRatio = _imgHeight / _imgWidth;

    var imgConstraints = _renderedImgConstraints.biggest.isInfinite
        ? imageInfos?.renderedSize ?? _renderedImgConstraints.biggest
        : _renderedImgConstraints.biggest;

    double imgW = imgConstraints.width;
    double imgH = imgConstraints.height;

    double realImgW = imageSticksToScreenWidth ? imgW : imgH / imgSizeRatio;
    double realImgH = imageSticksToScreenWidth ? imgW * imgSizeRatio : imgH;

    // Rect stick horizontal
    double ratio = newRatio ?? (_ratio > 0 ? _ratio : imgSizeRatio);
    double left = 0;
    double top = 0;

    if (imgSizeRatio >= ratio) {
      double newH = realImgW * ratio;
      top = (realImgH - newH) / 2;
      realImgH = newH;
    }
    // Rect stick vertical
    else {
      double newW = realImgH / ratio;
      left = (realImgW - newW) / 2;
      realImgW = newW;
    }

    _cropSpaceVertical = top * 2;
    _cropSpaceHorizontal = left * 2;

    if (!onlyViewRect) {
      cropRect = Rect.fromLTWH(left, top, realImgW, realImgH);
    }
    _viewRect = Rect.fromLTWH(left, top, realImgW, realImgH);
    cropPainterKey.currentState?.setForegroundPainter(cropPainter);
  }

  CropAreaPart _determineCropAreaPart(Offset localPosition) {
    Offset offset =
        _getRealHitPoint(zoom: userScaleFactor, position: localPosition) +
            translate * userScaleFactor;
    double dx = offset.dx;
    double dy = offset.dy;

    if (cropRotateEditorConfigs.roundCropper) {
      double halfWidth = cropRect.width / 2;
      double halfHeight = cropRect.height / 2;

      double halfInteractiveCornerArea = _interactiveCornerArea / 2;

      if (halfWidth + halfInteractiveCornerArea > offset.distance ||
          halfHeight + halfInteractiveCornerArea > offset.distance) {
        double cursorAreaHitWidth = halfWidth * 0.5;
        double cursorAreaHitHeight = halfHeight * 0.5;

        bool nearTopEdge = dy < -cursorAreaHitHeight;
        bool nearBottomEdge = dy > cursorAreaHitHeight;
        bool nearLeftEdge = dx < -cursorAreaHitWidth;
        bool nearRightEdge = dx > cursorAreaHitWidth;

        if (offset.distance < halfWidth - halfInteractiveCornerArea) {
          return CropAreaPart.inside;
        }
        // Bottom Left
        else if (nearBottomEdge && nearLeftEdge) {
          return CropAreaPart.bottomLeft;
        }
        // Bottom Right
        else if (nearBottomEdge && nearRightEdge) {
          return CropAreaPart.bottomRight;
        }
        // Top Left
        else if (nearTopEdge && nearLeftEdge) {
          return CropAreaPart.topLeft;
        }
        // Top Right
        else if (nearTopEdge && nearRightEdge) {
          return CropAreaPart.topRight;
        }
        // Bottom
        else if (nearBottomEdge) {
          return CropAreaPart.bottom;
        }
        // Top
        else if (nearTopEdge) {
          return CropAreaPart.top;
        }
        // Left
        else if (nearLeftEdge) {
          return CropAreaPart.left;
        }
        // Right
        else if (nearRightEdge) {
          return CropAreaPart.right;
        }

        return CropAreaPart.inside;
      } else {
        return CropAreaPart.none;
      }
    }

    Rect rect = Rect.fromCenter(
      center: cropRect.center - translate,
      width: cropRect.width + _interactiveCornerArea,
      height: cropRect.height + _interactiveCornerArea,
    );

    double halfCropWidth = rect.width / 2;
    double halfCropHeight = rect.height / 2;

    double left = dx + halfCropWidth;
    double right = dx - halfCropWidth;
    double top = dy + halfCropHeight;
    double bottom = dy - halfCropHeight;

    bool nearLeftEdge = left.abs() <= _interactiveCornerArea;
    bool nearRightEdge = right.abs() <= _interactiveCornerArea;
    bool nearTopEdge = top.abs() <= _interactiveCornerArea;
    bool nearBottomEdge = bottom.abs() <= _interactiveCornerArea;

    if (rect.contains(localPosition)) {
      if (nearLeftEdge && nearTopEdge) {
        return CropAreaPart.topLeft;
      } else if (nearRightEdge && nearTopEdge) {
        return CropAreaPart.topRight;
      } else if (nearLeftEdge && nearBottomEdge) {
        return CropAreaPart.bottomLeft;
      } else if (nearRightEdge && nearBottomEdge) {
        return CropAreaPart.bottomRight;
      } else if (nearLeftEdge) {
        return CropAreaPart.left;
      } else if (nearRightEdge) {
        return CropAreaPart.right;
      } else if (nearTopEdge) {
        return CropAreaPart.top;
      } else if (nearBottomEdge) {
        return CropAreaPart.bottom;
      } else {
        return CropAreaPart.inside;
      }
    } else {
      return CropAreaPart.none;
    }
  }

  void _zoomOutside() async {
    const int frameHelper = 1000 ~/ 60;
    while (userScaleFactor > 1 && _activeScaleOut) {
      double oldZoom = userScaleFactor;

      double zoomFactor = 0.025;
      userScaleFactor -= zoomFactor;
      userScaleFactor = max(1, userScaleFactor);

      var zoomOutsideWidth = _viewRect.width / oldZoom * userScaleFactor;
      var zoomOutsideHeight = _viewRect.height / oldZoom * userScaleFactor;

      double offsetHelperX = 0;
      double offsetHelperY = 0;

      if (_currentCropAreaPart == CropAreaPart.left ||
          _currentCropAreaPart == CropAreaPart.topLeft ||
          _currentCropAreaPart == CropAreaPart.bottomLeft ||
          _currentCropAreaPart == CropAreaPart.right ||
          _currentCropAreaPart == CropAreaPart.topRight ||
          _currentCropAreaPart == CropAreaPart.bottomRight) {
        offsetHelperX = zoomOutsideWidth - _viewRect.width;

        if (_currentCropAreaPart == CropAreaPart.right ||
            _currentCropAreaPart == CropAreaPart.topRight ||
            _currentCropAreaPart == CropAreaPart.bottomRight) {
          offsetHelperX *= -1;
        }
      }

      if (_currentCropAreaPart == CropAreaPart.top ||
          _currentCropAreaPart == CropAreaPart.topLeft ||
          _currentCropAreaPart == CropAreaPart.topRight ||
          _currentCropAreaPart == CropAreaPart.bottom ||
          _currentCropAreaPart == CropAreaPart.bottomLeft ||
          _currentCropAreaPart == CropAreaPart.bottomRight) {
        offsetHelperY = zoomOutsideHeight - _viewRect.height;

        if (_currentCropAreaPart == CropAreaPart.bottom ||
            _currentCropAreaPart == CropAreaPart.bottomLeft ||
            _currentCropAreaPart == CropAreaPart.bottomRight) {
          offsetHelperY *= -1;
        }
      }

      Offset offsetHelper = Offset(offsetHelperX, offsetHelperY);

      translate -= offsetHelper / userScaleFactor / 2;

      calcCropRect();
      _setOffsetLimits();

      await Future.delayed(const Duration(milliseconds: frameHelper));
    }
    _activeScaleOut = false;
  }

  void _onScaleStart(ScaleStartDetails details) {
    if (_blockInteraction || details.pointerCount > 2) return;
    _blockInteraction = true;

    _startingPinchScale = userScaleFactor;
    _startingTranslate = translate;
    // Calculate the center offset point from the old zoomed view
    _startingCenterOffset = _startingTranslate +
        _getRealHitPoint(
                position: details.localFocalPoint, zoom: userScaleFactor) /
            userScaleFactor;

    if (!_scaleStarted) {
      /// On desktop devices we detect always in `onPointerHover` events.
      if (!isDesktop) {
        _currentCropAreaPart = _determineCropAreaPart(details.localFocalPoint);
      }

      loopWithTransitionTiming(
        (double curveT) {
          _interactionOpacityProgress = 1 * curveT;
          cropPainterKey.currentState!.setForegroundPainter(cropPainter);
        },
        mounted: mounted,
        transitionFunction: Curves.decelerate.transform,
        duration: cropRotateEditorConfigs.opacityOutsideCropAreaDuration,
      );
    }

    _scaleAllowUpdateHelper = false;
    _onScaleAllowUpdateDebounce(() {
      _scaleAllowUpdateHelper = true;
    });

    _interactionActive = true;
    _scaleStarted = true;
    _blockInteraction = false;
  }

  void _onScaleUpdate(ScaleUpdateDetails details) {
    if (_blockInteraction ||
        details.pointerCount > 2 ||
        !_scaleAllowUpdateHelper) return;
    _blockInteraction = true;
    if (details.pointerCount == 2) {
      double newZoom = (_startingPinchScale * details.scale)
          .clamp(1.0, cropRotateEditorConfigs.maxScale);

      // Calculate the center offset point from the new zoomed view
      Offset centerZoomOffset =
          _startingCenterOffset * _startingPinchScale / newZoom;

      // Update translation and zoom values
      translate = _startingTranslate - _startingCenterOffset + centerZoomOffset;
      userScaleFactor = newZoom;

      // Set offset limits and trigger widget rebuild
      _setOffsetLimits();
      cropRotateEditorCallbacks?.handleScale();
    } else {
      if (_currentCropAreaPart != CropAreaPart.none &&
          _currentCropAreaPart != CropAreaPart.inside) {
        Offset offset = _getRealHitPoint(
                zoom: _startingPinchScale, position: details.localFocalPoint) +
            _startingTranslate * _startingPinchScale;
        bool roundCropper = cropRotateEditorConfigs.roundCropper;

        double imgW = _renderedImgConstraints.maxWidth;
        double imgH = _renderedImgConstraints.maxHeight;

        double halfSpaceHorizontal = _cropSpaceHorizontal / 2;
        double halfSpaceVertical = _cropSpaceVertical / 2;

        double outsidePadding = _screenPadding * 2;
        double cornerGap =
            imageEditorTheme.cropRotateEditor.cropCornerLength * 2.25;
        double minCornerDistance = outsidePadding + cornerGap;

        double halfViewRectW = _viewRect.width / 2;
        double halfViewRectH = _viewRect.height / 2;

        double circleGapX = 0;
        double circleGapY = 0;

        if (roundCropper) {
          circleGapX = sqrt(pow(halfViewRectW, 2) -
                  pow(min(offset.dy.abs(), halfViewRectW), 2)) -
              halfViewRectW;
          circleGapY = sqrt(pow(halfViewRectH, 2) -
                  pow(min(offset.dx.abs(), halfViewRectH), 2)) -
              halfViewRectH;

          circleGapX *= -offset.dx.sign;
          circleGapY *= -offset.dy.sign;
        }

        double dx =
            offset.dx + halfViewRectW + halfSpaceHorizontal + circleGapX;
        double dy = offset.dy + halfViewRectH + halfSpaceVertical + circleGapY;

        double maxRight = cropRect.right + outsidePadding - minCornerDistance;
        double maxBottom = cropRect.bottom + outsidePadding - minCornerDistance;

        double minLeft = halfSpaceHorizontal;
        double minRight = imgW - halfSpaceHorizontal;
        double minTop = halfSpaceVertical;
        double minBottom = imgH - halfSpaceVertical;

        bool isFreeAspectRatio = _ratio < 0;
        if (isFreeAspectRatio) {
          minLeft = -(imgW * userScaleFactor / 2 -
              _viewRect.width / 2 -
              halfSpaceHorizontal -
              translate.dx * userScaleFactor);
          minRight = imgW +
              (imgW * userScaleFactor / 2 -
                  _viewRect.width / 2 -
                  halfSpaceHorizontal +
                  translate.dx * userScaleFactor);
          minTop = -(imgH * userScaleFactor / 2 -
              _viewRect.height / 2 -
              halfSpaceVertical -
              translate.dy * userScaleFactor);
          minBottom = imgH +
              (imgH * userScaleFactor / 2 -
                  _viewRect.height / 2 -
                  halfSpaceVertical +
                  translate.dy * userScaleFactor);
        }

        Size realViewRectSize = _viewRect.size * scaleAnimation.value;
        if (_rotated90deg) {
          realViewRectSize =
              Size(realViewRectSize.height, realViewRectSize.width);
        }

        double doubleInteractiveArea = _interactiveCornerArea * 2;
        double halfScreenPadding = _screenPadding / 2;

        double zoomOutHitAreaX = max(
            halfScreenPadding,
            (editorBodySize.width - realViewRectSize.width) / 2 -
                doubleInteractiveArea);
        double zoomOutHitAreaY = max(
            halfScreenPadding,
            (editorBodySize.height - realViewRectSize.height) / 2 -
                doubleInteractiveArea);

        double outsideHitPosY = details.focalPoint.dy -
            (_hasToolbar ? kToolbarHeight : 0) -
            MediaQuery.of(context).padding.top;

        bool outsideLeft = details.focalPoint.dx < zoomOutHitAreaX;
        bool outsideRight =
            details.focalPoint.dx > editorBodySize.width - zoomOutHitAreaX;
        bool outsideTop = outsideHitPosY < zoomOutHitAreaY;
        bool outsideBottom =
            outsideHitPosY > editorBodySize.height - zoomOutHitAreaY;

        // Scale outside when the user move outside the scale area
        if (!isFreeAspectRatio &&
            (outsideLeft || outsideRight || outsideTop || outsideBottom)) {
          if (!_activeScaleOut) {
            _activeScaleOut = true;
            _zoomOutside();
          }
        } else if (!_activeScaleOut ||
            (offset.dx.abs() < _viewRect.width / 2 - _interactiveCornerArea)) {
          _activeScaleOut = false;
          switch (_currentCropAreaPart) {
            case CropAreaPart.topLeft:
              cropRect = Rect.fromLTRB(
                dx.clamp(minLeft, maxRight),
                dy.clamp(minTop, maxBottom),
                cropRect.right,
                cropRect.bottom,
              );

              break;
            case CropAreaPart.topRight:
              cropRect = Rect.fromLTRB(
                cropRect.left,
                dy.clamp(minTop, maxBottom),
                dx.clamp(cornerGap + cropRect.left, minRight),
                cropRect.bottom,
              );

              break;
            case CropAreaPart.bottomLeft:
              cropRect = Rect.fromLTRB(
                dx.clamp(minLeft, maxRight),
                cropRect.top,
                cropRect.right,
                dy.clamp(cornerGap + cropRect.top, minBottom),
              );
              break;
            case CropAreaPart.bottomRight:
              cropRect = Rect.fromLTRB(
                cropRect.left,
                cropRect.top,
                dx.clamp(cornerGap + cropRect.left, minRight),
                dy.clamp(cornerGap + cropRect.top, minBottom),
              );
              break;
            case CropAreaPart.left:
              cropRect = Rect.fromLTRB(
                dx.clamp(minLeft, maxRight),
                cropRect.top,
                cropRect.right,
                cropRect.bottom,
              );
              _setOffsetLimits();
              break;
            case CropAreaPart.right:
              cropRect = Rect.fromLTRB(
                cropRect.left,
                cropRect.top,
                dx.clamp(cornerGap + cropRect.left, minRight),
                cropRect.bottom,
              );
              break;
            case CropAreaPart.top:
              cropRect = Rect.fromLTRB(
                cropRect.left,
                dy.clamp(minTop, maxBottom),
                cropRect.right,
                cropRect.bottom,
              );
              break;
            case CropAreaPart.bottom:
              cropRect = Rect.fromLTRB(
                cropRect.left,
                cropRect.top,
                cropRect.right,
                dy.clamp(cornerGap + cropRect.top, minBottom),
              );
              break;
            default:
              break;
          }

          if (_ratio >= 0 && cropRect.size.aspectRatio != _ratio) {
            if (_currentCropAreaPart == CropAreaPart.left ||
                _currentCropAreaPart == CropAreaPart.right) {
              cropRect = Rect.fromCenter(
                center: cropRect.center,
                width: cropRect.width,
                height: cropRect.width * _ratio,
              );
            } else if (_currentCropAreaPart == CropAreaPart.top ||
                _currentCropAreaPart == CropAreaPart.bottom) {
              cropRect = Rect.fromCenter(
                center: cropRect.center,
                width: cropRect.height / _ratio,
                height: cropRect.height,
              );
            } else if (_currentCropAreaPart == CropAreaPart.topLeft ||
                _currentCropAreaPart == CropAreaPart.topRight) {
              double gapBottom = _viewRect.height - cropRect.bottom;
              cropRect = Rect.fromLTRB(
                cropRect.left,
                _viewRect.height - gapBottom - cropRect.width * _ratio,
                cropRect.right,
                cropRect.bottom,
              );
            } else if (_currentCropAreaPart == CropAreaPart.bottomLeft ||
                _currentCropAreaPart == CropAreaPart.bottomRight) {
              cropRect = Rect.fromLTRB(
                cropRect.left,
                cropRect.top,
                cropRect.right,
                cropRect.width * _ratio + cropRect.top,
              );
            }
          }
        }

        cropPainterKey.currentState!.update(foregroundPainter: cropPainter);
      } else {
        double scaleFactor = userScaleFactor / _scaleStartZoomHelper;
        translate +=
            Offset(details.focalPointDelta.dx, details.focalPointDelta.dy) /
                scaleFactor *
                (cropRotateEditorConfigs.reverseDragDirection ? -1 : 1);
        _setOffsetLimits();
        cropRotateEditorCallbacks?.handleMove();

        cropPainterKey.currentState!.update(foregroundPainter: cropPainter);
      }
    }
    _blockInteraction = false;
  }

  void _onScaleEnd(ScaleEndDetails details) async {
    Rect interpolatedRect(Rect initRect, Rect targetRect, double curveT) {
      return Rect.fromLTRB(
        lerpDouble(initRect.left, targetRect.left, curveT)!,
        lerpDouble(initRect.top, targetRect.top, curveT)!,
        lerpDouble(initRect.right, targetRect.right, curveT)!,
        lerpDouble(initRect.bottom, targetRect.bottom, curveT)!,
      );
    }

    if (_blockInteraction || details.pointerCount > 2) return;
    _blockInteraction = true;
    _interactionActive = false;

    _onScaleEndDebounce(() {
      if (_activePointers <= 0) {
        _scaleStarted = false;
        loopWithTransitionTiming(
          (double curveT) {
            _interactionOpacityProgress = 1 - 1 * curveT;
            cropPainterKey.currentState!.setForegroundPainter(cropPainter);
          },
          mounted: mounted,
          transitionFunction: Curves.decelerate.transform,
          duration: cropRotateEditorConfigs.opacityOutsideCropAreaDuration,
        );
      }
    });

    if (cropRect != _viewRect) {
      /// Return is important for tests
      if (cropRect.isEmpty) return;

      Rect initRect = Rect.fromCenter(
          center: _viewRect.center,
          width: _viewRect.width,
          height: _viewRect.height);
      Duration animationDuration =
          cropRotateEditorConfigs.cropDragAnimationDuration;
      Curve animationCurve = cropRotateEditorConfigs.cropDragAnimationCurve;

      /// Recalculate crop rect when aspect ratio is set to `free`
      if (_ratio < 0) {
        calcCropRect(
          onlyViewRect: true,
          newRatio: 1 / cropRect.size.aspectRatio,
        );
        scaleCtrl.duration = animationDuration;
        calcFitToScreen(curve: animationCurve);
        scaleCtrl.duration = cropRotateEditorConfigs.animationDuration;
      }

      Rect startCropRect = cropRect;
      Rect targetCropRect = _viewRect;

      double startZoom = userScaleFactor;
      double targetZoom = min(
        userScaleFactor *
            targetCropRect.size.longestSide /
            startCropRect.size.longestSide,
        cropRotateEditorConfigs.maxScale,
      );

      Offset startOffset = translate;
      Offset targetOffset = startOffset -
          Offset(
                (startCropRect.left -
                    (targetCropRect.right - startCropRect.right) -
                    _cropSpaceHorizontal / 2),
                (startCropRect.top -
                    (targetCropRect.bottom - startCropRect.bottom) -
                    _cropSpaceVertical / 2),
              ) /
              startZoom /
              2;

      await loopWithTransitionTiming(
        (double curveT) {
          userScaleFactor = lerpDouble(startZoom, targetZoom, curveT)!;

          translate = Offset(
            startOffset.dx +
                (targetOffset.dx - startOffset.dx) *
                    (targetCropRect.width / cropRect.width) *
                    curveT,
            startOffset.dy +
                (targetOffset.dy - startOffset.dy) *
                    (targetCropRect.height / cropRect.height) *
                    curveT,
          );

          cropRect = interpolatedRect(startCropRect, targetCropRect, curveT);
          _setOffsetLimits(
            rect: _ratio < 0
                ? interpolatedRect(initRect, targetCropRect, curveT)
                : null,
          );
        },
        mounted: mounted,
        duration: animationDuration,
        transitionFunction: animationCurve.transform,
      );

      cropRect = targetCropRect;
      translate = targetOffset;
      userScaleFactor = targetZoom;

      _setOffsetLimits();
      calcFitToScreen();
      cropRotateEditorCallbacks?.handleResize();
    }
    _activeScaleOut = false;
    _blockInteraction = false;

    addHistory();
  }

  void _handleDoubleTapDown(TapDownDetails details) {
    _doubleTapDetails = details;
  }

  void _handleDoubleTap() async {
    double clampValue(double value, double min, double max) {
      if (value < min) {
        return min;
      } else if (value > max) {
        return max;
      } else {
        return value;
      }
    }

    if (!cropRotateEditorConfigs.enableDoubleTap || _blockInteraction) return;
    _blockInteraction = true;

    cropRotateEditorCallbacks?.handleDoubleTap();

    bool zoomInside = userScaleFactor <= 1;
    double startZoom = userScaleFactor;
    double targetZoom =
        zoomInside ? cropRotateEditorConfigs.doubleTapScaleFactor : 1;
    Offset startOffset = translate;

    Offset targetOffset = zoomInside
        ? (translate -
            Offset(
              _doubleTapDetails.localPosition.dx -
                  _renderedImgConstraints.maxWidth / 2,
              _doubleTapDetails.localPosition.dy -
                  _renderedImgConstraints.maxHeight / 2,
            ))
        : Offset.zero;

    double maxOffsetX =
        (_renderedImgConstraints.maxWidth * targetZoom - _viewRect.width) /
            2 /
            targetZoom;
    double maxOffsetY =
        (_renderedImgConstraints.maxHeight * targetZoom - _viewRect.height) /
            2 /
            targetZoom;

    /// direct double clamp trigger an error on android samsung s10 so better
    /// use own solution to clamp
    targetOffset = Offset(
      clampValue(targetOffset.dx, -maxOffsetX, maxOffsetX),
      clampValue(targetOffset.dy, -maxOffsetY, maxOffsetY),
    );

    await loopWithTransitionTiming(
      (double curveT) {
        userScaleFactor = startZoom + (targetZoom - startZoom) * curveT;
        translate = startOffset +
            (targetOffset - startOffset) *
                targetZoom /
                userScaleFactor *
                curveT;
      },
      mounted: mounted,
      duration: cropRotateEditorConfigs.animationDuration,
      transitionFunction: Curves.decelerate.transform,
    );

    userScaleFactor = targetZoom;
    translate = targetOffset;
    _setOffsetLimits();
    addHistory();
    _blockInteraction = false;
  }

  void _setOffsetLimits({Rect? rect}) {
    Rect r = rect ?? _viewRect;

    double cropWidth = r.width;
    double cropHeight = r.height;

    double minX =
        (_renderedImgConstraints.maxWidth * userScaleFactor - cropWidth) /
            2 /
            userScaleFactor;
    double minY =
        (_renderedImgConstraints.maxHeight * userScaleFactor - cropHeight) /
            2 /
            userScaleFactor;

    Offset offset = translate;

    if (offset.dx > minX) {
      translate = Offset(minX, translate.dy);
    }
    if (offset.dx < -minX) {
      translate = Offset(-minX, translate.dy);
    }
    if (offset.dy > minY) {
      translate = Offset(translate.dx, minY);
    }
    if (offset.dy < -minY) {
      translate = Offset(translate.dx, -minY);
    }
  }

  void _mouseScroll(PointerSignalEvent event) async {
    // Check if interaction is blocked
    if (_blockInteraction) return;

    if (event is PointerScrollEvent) {
      // Define zoom factor and extract vertical scroll delta
      double factor = cropRotateEditorConfigs.mouseScaleFactor *
          (event.scrollDelta.dy / 50).abs().clamp(0.5, 2);

      double deltaY = event.scrollDelta.dy *
          (cropRotateEditorConfigs.reverseMouseScroll ? -1 : 1);

      double startZoom = userScaleFactor;
      double newZoom = userScaleFactor;
      // Adjust zoom based on scroll direction
      if (deltaY > 0) {
        newZoom -= factor;
        newZoom = max(1, newZoom);
      } else if (deltaY < 0) {
        newZoom += factor;
        newZoom = min(cropRotateEditorConfigs.maxScale, newZoom);
      }

      // Calculate the center offset point from the old zoomed view
      Offset centerOffset = translate +
          _getRealHitPoint(zoom: startZoom, position: event.localPosition) /
              startZoom;
      // Calculate the center offset point from the new zoomed view
      Offset centerZoomOffset = centerOffset * startZoom / newZoom;

      // Update translation and zoom values
      translate -= centerOffset - centerZoomOffset;
      userScaleFactor = newZoom;

      // Set offset limits and trigger widget rebuild
      _setOffsetLimits();
      _setMouseCursor();
      _scrollHistoryDebounce(() {
        addHistory();
        cropRotateEditorCallbacks?.handleScale();
        cropPainterKey.currentState!.setForegroundPainter(cropPainter);
      });
    }
  }

  void _setMouseCursor() {
    SystemMouseCursor getCornerCursor(int cursorNo) {
      int no = cursorNo;

      if (flipX && !flipY) {
        no += cursorNo == 0 || cursorNo == 2 ? 1 : -1;
      } else if (!flipX && flipY) {
        no -= cursorNo == 0 || cursorNo == 2 ? 1 : -1;
      } else if (flipX && flipY) {
        no += cursorNo == 0 || cursorNo == 2 ? 2 : -2;
      }

      RotateAngleSide angle = getRotateAngleSide(rotateAnimation.value);
      if (angle == RotateAngleSide.left) {
        no--;
      } else if (angle == RotateAngleSide.bottom) {
        no -= 2;
      } else if (angle == RotateAngleSide.right) {
        no -= 3;
      }

      switch (no % 4) {
        case 0:
          return SystemMouseCursors.resizeDownRight;
        case 1:
          return SystemMouseCursors.resizeDownLeft;
        case 2:
          return SystemMouseCursors.resizeUpLeft;
        case 3:
          return SystemMouseCursors.resizeUpRight;
        default:
          if (kDebugMode) {
            throw ArgumentError('Invalid cursor number!');
          } else {
            debugPrint('Invalid cursor number!');
            return SystemMouseCursors.basic;
          }
      }
    }

    SystemMouseCursor getSideCursor(int cursorNo) {
      int no = cursorNo;

      if (flipX && !flipY) {
        no += cursorNo == 0 || cursorNo == 2 ? 2 : 0;
      } else if (!flipX && flipY) {
        no -= cursorNo == 0 || cursorNo == 2 ? 0 : 2;
      } else if (flipX && flipY) {
        no += cursorNo == 0 || cursorNo == 2 ? 2 : -2;
      }

      RotateAngleSide angle = getRotateAngleSide(rotateAnimation.value);
      if (angle == RotateAngleSide.left) {
        no--;
      } else if (angle == RotateAngleSide.bottom) {
        no -= 2;
      } else if (angle == RotateAngleSide.right) {
        no -= 3;
      }

      switch (no % 4) {
        case 0:
          return SystemMouseCursors.resizeRight;
        case 1:
          return SystemMouseCursors.resizeDown;
        case 2:
          return SystemMouseCursors.resizeLeft;
        case 3:
          return SystemMouseCursors.resizeUp;
        default:
          if (kDebugMode) {
            throw ArgumentError('Invalid cursor number!');
          } else {
            debugPrint('Invalid cursor number!');
            return SystemMouseCursors.basic;
          }
      }
    }

    int cursorNumber = -1;

    switch (_currentCropAreaPart) {
      case CropAreaPart.topLeft:
        cursorNumber = 0;
        break;
      case CropAreaPart.topRight:
        cursorNumber = 1;
        break;
      case CropAreaPart.bottomRight:
        cursorNumber = 2;
        break;
      case CropAreaPart.bottomLeft:
        cursorNumber = 3;
        break;
      case CropAreaPart.left:
        cursorNumber = 4;
        break;
      case CropAreaPart.top:
        cursorNumber = 5;
        break;
      case CropAreaPart.right:
        cursorNumber = 6;
        break;
      case CropAreaPart.bottom:
        cursorNumber = 7;
        break;
      case CropAreaPart.inside:
      case CropAreaPart.none:
        if (userScaleFactor > 1 ||
            cropRect.size.aspectRatio.toStringAsFixed(3) !=
                (_rotated90deg
                        ? 1 / _renderedImgSize.aspectRatio
                        : _renderedImgSize.aspectRatio)
                    .toStringAsFixed(3)) {
          _cursor = SystemMouseCursors.move;
        } else {
          _cursor = SystemMouseCursors.basic;
        }
        return;
      default:
        _cursor = SystemMouseCursors.basic;
        return;
    }

    _cursor = cursorNumber <= 3
        ? getCornerCursor(cursorNumber)
        : getSideCursor(cursorNumber - 4);
  }

  Offset _getRealHitPoint({
    required double zoom,
    required Offset position,
  }) {
    double imgW = _renderedImgConstraints.maxWidth;
    double imgH = _renderedImgConstraints.maxHeight;

    // Calculate the transformed local position of the pointer
    Offset transformedLocalPosition = position * zoom;
    // Calculate the size of the transformed image
    Size transformedImgSize = Size(imgW, imgH) * zoom;

    // Calculate the center offset point from the old zoomed view
    return Offset(
      transformedLocalPosition.dx - transformedImgSize.width / 2,
      transformedLocalPosition.dy - transformedImgSize.height / 2,
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: cropRotateEditorConfigs.safeArea.top,
      bottom: cropRotateEditorConfigs.safeArea.bottom,
      left: cropRotateEditorConfigs.safeArea.left,
      right: cropRotateEditorConfigs.safeArea.right,
      child: RecordInvisibleWidget(
        controller: screenshotCtrl,
        child: ExtendedPopScope(
          onPopInvokedWithResult: (didPop, _) {
            _showFakeHero = true;
            _updateAllStates();
          },
          child: LayoutBuilder(builder: (context, constraints) {
            return AnnotatedRegion<SystemUiOverlayStyle>(
              value: imageEditorTheme.uiOverlayStyle,
              child: Theme(
                data: theme.copyWith(
                    tooltipTheme:
                        theme.tooltipTheme.copyWith(preferBelow: true)),
                child: Scaffold(
                  resizeToAvoidBottomInset: false,
                  backgroundColor: imageEditorTheme.cropRotateEditor.background,
                  appBar: _buildAppBar(constraints),
                  body: _buildBody(),
                  bottomNavigationBar: _buildBottomAppBar(),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }

  /// Builds the app bar for the editor, including buttons for actions such as
  /// back, rotate, aspect ratio, and done.
  PreferredSizeWidget? _buildAppBar(BoxConstraints constraints) {
    if (customWidgets.cropRotateEditor.appBar != null) {
      var customToolbar = customWidgets.cropRotateEditor.appBar!
          .call(this, rebuildController.stream);
      _hasToolbar = customToolbar != null;
      return customToolbar;
    }
    _hasToolbar = true;
    return AppBar(
      automaticallyImplyLeading: false,
      backgroundColor: imageEditorTheme.cropRotateEditor.appBarBackgroundColor,
      foregroundColor: imageEditorTheme.cropRotateEditor.appBarForegroundColor,
      actions: [
        IconButton(
          tooltip: i18n.cropRotateEditor.back,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          icon: Icon(icons.backButton),
          onPressed: close,
        ),
        const Spacer(),
        IconButton(
          tooltip: i18n.cropRotateEditor.undo,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          icon: Icon(
            icons.undoAction,
            color: canUndo ? Colors.white : Colors.white.withAlpha(80),
          ),
          onPressed: undoAction,
        ),
        IconButton(
          tooltip: i18n.cropRotateEditor.redo,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          icon: Icon(
            icons.redoAction,
            color: canRedo ? Colors.white : Colors.white.withAlpha(80),
          ),
          onPressed: redoAction,
        ),
        _buildDoneBtn(),
      ],
    );
  }

  Widget? _buildBottomAppBar() {
    if (customWidgets.cropRotateEditor.bottomBar != null) {
      return customWidgets.cropRotateEditor.bottomBar!
          .call(this, rebuildController.stream);
    }

    return cropRotateEditorConfigs.canRotate ||
            cropRotateEditorConfigs.canFlip ||
            cropRotateEditorConfigs.canChangeAspectRatio ||
            cropRotateEditorConfigs.canReset
        ? Theme(
            data: theme,
            child: Scrollbar(
              controller: _bottomBarScrollCtrl,
              scrollbarOrientation: ScrollbarOrientation.top,
              thickness: isDesktop ? null : 0,
              child: BottomAppBar(
                height: kToolbarHeight,
                color:
                    imageEditorTheme.cropRotateEditor.bottomBarBackgroundColor,
                padding: EdgeInsets.zero,
                child: Center(
                  child: SingleChildScrollView(
                    controller: _bottomBarScrollCtrl,
                    scrollDirection: Axis.horizontal,
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minWidth: min(MediaQuery.of(context).size.width, 500),
                        maxWidth: 500,
                      ),
                      child: Builder(builder: (context) {
                        Color foregroundColor = imageEditorTheme
                            .cropRotateEditor.appBarForegroundColor;
                        return Wrap(
                          direction: Axis.horizontal,
                          alignment: WrapAlignment.spaceAround,
                          children: <Widget>[
                            if (cropRotateEditorConfigs.canRotate)
                              FlatIconTextButton(
                                key: const ValueKey(
                                    'crop-rotate-editor-rotate-btn'),
                                label: Text(
                                  i18n.cropRotateEditor.rotate,
                                  style: TextStyle(
                                      fontSize: 10.0, color: foregroundColor),
                                ),
                                icon: Icon(icons.cropRotateEditor.rotate,
                                    color: foregroundColor),
                                onPressed: rotate,
                              ),
                            if (cropRotateEditorConfigs.canFlip)
                              FlatIconTextButton(
                                key: const ValueKey(
                                    'crop-rotate-editor-flip-btn'),
                                label: Text(
                                  i18n.cropRotateEditor.flip,
                                  style: TextStyle(
                                      fontSize: 10.0, color: foregroundColor),
                                ),
                                icon: Icon(icons.cropRotateEditor.flip,
                                    color: foregroundColor),
                                onPressed: flip,
                              ),
                            if (cropRotateEditorConfigs.canChangeAspectRatio)
                              FlatIconTextButton(
                                key: const ValueKey(
                                    'crop-rotate-editor-ratio-btn'),
                                label: Text(
                                  i18n.cropRotateEditor.ratio,
                                  style: TextStyle(
                                      fontSize: 10.0, color: foregroundColor),
                                ),
                                icon: Icon(icons.cropRotateEditor.aspectRatio,
                                    color: foregroundColor),
                                onPressed: openAspectRatioOptions,
                              ),
                            if (cropRotateEditorConfigs.canReset)
                              FlatIconTextButton(
                                key: const ValueKey(
                                    'crop-rotate-editor-reset-btn'),
                                label: Text(
                                  i18n.cropRotateEditor.reset,
                                  style: TextStyle(
                                      fontSize: 10.0, color: foregroundColor),
                                ),
                                icon: Icon(icons.cropRotateEditor.reset,
                                    color: foregroundColor),
                                onPressed: reset,
                              ),
                          ],
                        );
                      }),
                    ),
                  ),
                ),
              ),
            ),
          )
        : null;
  }

  Widget _buildBody() {
    return SafeArea(
      child: ScreenResizeDetector(
        onResizeUpdate: (event) {
          if (editorBodySize != event.newContentSize) {
            editorBodySize = event.newContentSize;
            cropPainterKey.currentState?.setForegroundPainter(cropPainter);
          }
          cropEditorScreenRatio = Size(
            editorBodySize.width - _screenPadding * 2,
            editorBodySize.height - _screenPadding * 2,
          ).aspectRatio;
        },
        onResizeEnd: (event) {
          if (_imageNeedDecode) _decodeImage();

          WidgetsBinding.instance.addPostFrameCallback((_) async {
            _setCropRectBounding();
            _updateAllStates();
          });
        },
        child: Stack(
          children: [
            if (_showFakeHero)
              _buildFakeHero()
            else if (!_imageSizeIsDecoded && initConfigs.convertToUint8List)
              Align(
                alignment: Alignment.center,
                child: SizedBox(
                  width: 60,
                  height: 60,
                  child: FittedBox(
                    child: PlatformCircularProgressIndicator(configs: configs),
                  ),
                ),
              ),
            AnimatedOpacity(
              duration: !initConfigs.convertToUint8List
                  ? Duration.zero
                  : const Duration(milliseconds: 160),
              opacity: _showFakeHero || !_imageSizeIsDecoded ? 0 : 1,
              child: HeroMode(
                enabled: false,
                child: _buildMouseCursor(
                  child: DeferredPointerHandler(
                    child: _buildRotationTransform(
                      child: _buildFlipTransform(
                        child: _buildRotationScaleTransform(
                          child: _buildPaintContainer(
                            child: _buildCropPainter(
                              child: _buildUserScaleTransform(
                                child: _buildTranslate(
                                  child: DeferPointer(
                                    child: _buildEventListener(
                                      child: _buildGestureDetector(
                                        child: _buildImage(),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            if (customWidgets.cropRotateEditor.bodyItems != null)
              ...customWidgets.cropRotateEditor.bodyItems!(
                  this, rebuildController.stream),
          ],
        ),
      ),
    );
  }

  Widget _buildMouseCursor({required Widget child}) {
    return ExtendedMouseRegion(
      key: _mouseCursorsKey,
      initCursor: _cursor,
      child: child,
    );
  }

  Widget _buildEventListener({required Widget child}) {
    /// Control the GestureDetector directly from this OutsideListener that
    /// both listeners can't block the events between them
    return OutsideListener(
      behavior: OutsideHitTestBehavior.all,
      onPointerDown: (event) {
        _gestureKey.currentState!.rawKey.currentState!.handlePointerDown(event);
        if (_activePointers == 0) _scaleStartZoomHelper = userScaleFactor;
        _activePointers++;
      },
      onPointerUp: (event) {
        _activePointers--;
      },
      onPointerPanZoomStart: (event) {
        _gestureKey.currentState!.rawKey.currentState!
            .handlePointerPanZoomStart(event);
      },
      onPointerSignal: isDesktop ? _mouseScroll : null,
      onPointerHover: isDesktop
          ? (event) {
              var area = _determineCropAreaPart(event.localPosition);
              if (area != _currentCropAreaPart) {
                _currentCropAreaPart = area;
                _setMouseCursor();
              }
            }
          : null,
      child: child,
    );
  }

  Widget _buildGestureDetector({required Widget child}) {
    return CropRotateGestureDetector(
      key: _gestureKey,
      onScaleStart: _onScaleStart,
      onScaleEnd: _onScaleEnd,
      onScaleUpdate: _onScaleUpdate,
      onDoubleTapDown: _handleDoubleTapDown,
      onDoubleTap: _handleDoubleTap,
      child: child,
    );
  }

  AnimatedBuilder _buildRotationTransform({required Widget child}) {
    return AnimatedBuilder(
      animation: rotateAnimation,
      builder: (context, child) => Transform.rotate(
        angle: rotateAnimation.value,
        alignment: Alignment.center,
        child: child,
      ),
      child: child,
    );
  }

  Transform _buildFlipTransform({required Widget child}) {
    return Transform.flip(
      flipX: flipX,
      flipY: flipY,
      child: child,
    );
  }

  Widget _buildUserScaleTransform({required Widget child}) {
    return ExtendedTransformScale(
      key: userScaleKey,
      initScale: userScaleFactor,
      alignment: Alignment.center,
      child: child,
    );
  }

  Widget _buildTranslate({required Widget child}) {
    return ExtendedTransformTranslate(
      key: translateKey,
      initOffset: translate,
      child: child,
    );
  }

  Widget _buildRotationScaleTransform({required Widget child}) {
    return AnimatedBuilder(
      animation: scaleAnimation,
      builder: (context, child) => Transform.scale(
        scale: scaleAnimation.value,
        alignment: Alignment.center,
        child: child,
      ),
      child: child,
    );
  }

  Widget _buildCropPainter({required Widget child}) {
    return ExtendedCustomPaint(
      key: cropPainterKey,
      initIsComplex: showWidgets,
      initWillChange: showWidgets,
      initForegroundPainter: cropPainter?.copy(),
      child: child,
    );
  }

  Widget _buildPaintContainer({required Widget child}) {
    return Align(
      alignment: Alignment.center,
      child: Padding(
        padding: EdgeInsets.all(_screenPadding),
        child: child,
      ),
    );
  }

  Widget _buildImage() {
    double maxWidth =
        _imgWidth / _imgHeight * (editorBodySize.height - _screenPadding * 2);
    double maxHeight =
        (editorBodySize.width - _screenPadding * 2) * _imgHeight / _imgWidth;
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxWidth: maxWidth.isNaN ? _imgWidth : maxWidth,
        maxHeight: maxHeight.isNaN ? _imgHeight : maxHeight,
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          _renderedImgConstraints = constraints;
          originalSize = constraints.biggest;
          return Stack(
            fit: StackFit.expand,
            alignment: Alignment.center,
            children: [
              FilteredImage(
                filters: appliedFilters,
                tuneAdjustments: appliedTuneAdjustments,
                blurFactor: appliedBlurFactor,
                configs: configs,
                width: _imgWidth,
                height: _imgHeight,
                image: editorImage,
              ),
              if (cropRotateEditorConfigs.transformLayers && layers != null)
                ClipRRect(
                  clipBehavior: Clip.hardEdge,
                  child: LayerStack(
                    cutOutsideImageArea: false,
                    transformHelper: TransformHelper(
                      /// set size to zero that no scale factor will be applied
                      mainBodySize: Size.zero,
                      mainImageSize: Size.zero,
                      editorBodySize: originalSize,
                    ),
                    configs: configs,
                    layers: _rawLayers,
                    clipBehavior: Clip.none,
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildFakeHero() {
    return Padding(
      padding: EdgeInsets.all(_screenPadding),
      child: LayoutBuilder(builder: (context, constraints) {
        return Stack(
          alignment: Alignment.center,
          fit: StackFit.expand,
          children: [
            Hero(
              tag: heroTag,
              createRectTween: (begin, end) =>
                  RectTween(begin: begin, end: end),
              child: TransformedContentGenerator(
                transformConfigs: _fakeHeroTransformConfigs,
                configs: configs,
                child: FilteredImage(
                  width: _mainImageSize.width,
                  height: _mainImageSize.height,
                  configs: configs,
                  image: editorImage,
                  filters: appliedFilters,
                  tuneAdjustments: appliedTuneAdjustments,
                  blurFactor: appliedBlurFactor,
                ),
              ),
            ),
            if (filterEditorConfigs.showLayers && layers != null)
              LayerStack(
                transformHelper: TransformHelper(
                  mainBodySize: (mainBodySize ?? editorBodySize),
                  mainImageSize: _mainImageSize,
                  editorBodySize: constraints.biggest,
                  transformConfigs: initialTransformConfigs,
                ),
                configs: configs,
                layers: _layers,
                clipBehavior: Clip.none,
              ),
          ],
        );
      }),
    );
  }

  /// Builds and returns an IconButton for applying changes.
  Widget _buildDoneBtn() {
    return IconButton(
      tooltip: i18n.cropRotateEditor.done,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      icon: Icon(icons.applyChanges),
      iconSize: 28,
      onPressed: done,
    );
  }

  Widget _screenshotWidget(TransformConfigs transformC) {
    Size size =
        _rotated90deg ? imageInfos!.rawSize.flipped : imageInfos!.rawSize;

    double w = size.width;
    double h = size.height;
    return SizedBox(
      width: w,
      height: h,
      child: TransformedContentGenerator(
        transformConfigs: transformC,
        configs: configs,
        child: FilteredImage(
          width: w,
          height: h,
          configs: configs,
          image: editorImage,
          filters: appliedFilters,
          tuneAdjustments: appliedTuneAdjustments,
          blurFactor: appliedBlurFactor,
        ),
      ),
    );
  }
}
