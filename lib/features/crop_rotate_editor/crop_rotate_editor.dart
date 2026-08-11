import 'dart:math';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart' hide Image;
import 'package:flutter/services.dart';

import '/core/mixins/converted_callbacks.dart';
import '/core/mixins/converted_configs.dart';
import '/core/mixins/standalone_editor.dart';
import '/core/models/transform_helper.dart';
import '/core/platform/io/io_helper.dart';
import '/features/crop_rotate_editor/widgets/crop_editor_appbar.dart';
import '/features/crop_rotate_editor/widgets/crop_editor_bottombar.dart';
import '/features/crop_rotate_editor/widgets/outside_gestures/crop_rotate_gesture_detector.dart';
import '/features/crop_rotate_editor/widgets/outside_gestures/outside_gesture_listener.dart';
import '/plugins/defer_pointer/defer_pointer.dart';
import '/pro_image_editor.dart';
import '/shared/extensions/double_extension.dart';
import '/shared/extensions/matrix_extension.dart';
import '/shared/mixins/extended_loop.dart';
import '/shared/services/content_recorder/widgets/record_invisible_widget.dart';
import '/shared/services/layer_transform_generator.dart';
import '/shared/utils/file_constructor_utils.dart';
import '/shared/utils/transparent_image_generator_utils.dart';
import '/shared/widgets/extended/extended_custom_paint.dart';
import '/shared/widgets/extended/extended_transform_scale.dart';
import '/shared/widgets/extended/extended_transform_translate.dart';
import '/shared/widgets/extended/mouse_region/extended_rebuild_mouse_region.dart';
import '/shared/widgets/layer/layer_stack.dart';
import '/shared/widgets/screen_resize_detector.dart';
import '/shared/widgets/transform/transformed_content_generator.dart';
import 'enums/crop_area_part.dart';
import 'enums/crop_rotate_angle_side.dart';
import 'mixins/crop_area_history.dart';
import 'providers/tilt_provider.dart';
import 'services/crop_desktop_interaction_manager.dart';
import 'utils/crop_area_utils.dart';
import 'utils/crop_aspect_ratios.dart';
import 'utils/rotate_angle.dart';
import 'utils/tilt_bounds_utils.dart';
import 'widgets/crop_corner_painter.dart';
import 'widgets/outside_gestures/outside_gesture_behavior.dart';
import 'widgets/tilt/tilt_ruler_chooser.dart';

export 'enums/crop_mode.enum.dart';
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
    required this.initConfigs,
    this.editorImage,
    this.videoController,
  }) : assert(
         editorImage != null || videoController != null,
         'Either editorImage or videoController must be provided.',
       );

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
    dynamic file, {
    Key? key,
    required CropRotateEditorInitConfigs initConfigs,
  }) {
    return CropRotateEditor._(
      key: key,
      editorImage: EditorImage(file: ensureFileInstance(file)),
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
    Uint8List? byteArray,
    dynamic file,
    String? assetPath,
    String? networkUrl,
    EditorImage? editorImage,
    ProVideoController? videoController,
    required CropRotateEditorInitConfigs initConfigs,
  }) {
    return CropRotateEditor._(
      key: key,
      editorImage: videoController != null
          ? null
          : editorImage ??
                EditorImage(
                  byteArray: byteArray,
                  file: file,
                  networkUrl: networkUrl,
                  assetPath: assetPath,
                ),
      videoController: videoController,
      initConfigs: initConfigs,
    );
  }

  /// Constructs a `CropRotateEditor` widget with an video player.
  factory CropRotateEditor.video(
    ProVideoController videoController, {
    Key? key,
    required CropRotateEditorInitConfigs initConfigs,
  }) {
    return CropRotateEditor._(
      key: key,
      videoController: videoController,
      initConfigs: initConfigs,
    );
  }

  @override
  final CropRotateEditorInitConfigs initConfigs;
  @override
  final EditorImage? editorImage;
  @override
  final ProVideoController? videoController;

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
  /// A global key used to identify the editor body, the box the image and the
  /// crop overlay are laid out in.
  ///
  /// Pointer positions are converted into the coordinate space of this box, so
  /// they can be compared against [editorBodySize] no matter where the body
  /// sits on the screen (embedded editor, app-bar above it or a horizontal
  /// inset from [CropRotateEditorConfigs.maxWidthFactor]).
  final _editorContentKey = GlobalKey();

  final _mouseCursorsKey = GlobalKey<ExtendedRebuildMouseRegionState>();

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

  /// The aspect ratio currently applied to the crop area.
  ///
  /// When [CropRotateEditorConfigs.enableKeepAspectRatioOnRotate] is enabled
  /// the ratio is inverted for every 90° rotation, so the crop frame keeps the
  /// orientation the user selected (e.g. a `9:16` frame stays `9:16` instead of
  /// turning into `16:9` after a rotation). Only fixed aspect ratios are
  /// affected.
  double get _activeAspectRatio {
    if (cropRotateEditorConfigs.enableKeepAspectRatioOnRotate &&
        _rotated90deg &&
        aspectRatio > 0) {
      return 1 / aspectRatio;
    }
    return aspectRatio;
  }

  /// The ratio used for cropping, based on the aspect ratio and main image
  /// size.
  double get _ratio =>
      1 /
      (_activeAspectRatio == 0
          ? _mainImageSize.aspectRatio
          : _activeAspectRatio);

  /// Whether any perspective tilt is applied.
  ///
  /// While tilted the image no longer covers an axis-aligned rectangle, so the
  /// bounds math auto-zooms instead of only clamping the translation.
  bool get _isTilted =>
      tiltRotateAngle != 0 ||
      tiltHorizontalAngle != 0 ||
      tiltVerticalAngle != 0;

  /// The smallest zoom that still keeps [_viewRect] covered by the (possibly
  /// tilted) image.
  ///
  /// Zooming out any further would reveal empty area next to the tilted image,
  /// so [_setOffsetLimits] pushes the zoom straight back up. Callers that
  /// reduce the zoom use this as their floor instead of fighting it.
  double get _minCoveringScale {
    if (!_isTilted) return 1;

    var fit = fitCropInsideTiltedImage(
      baseTiltCorners: _baseTiltCorners(),
      cropSize: _viewRect.size,
      minScale: 1,
      maxScale: cropRotateEditorConfigs.maxScale,
      currentTranslate: translate,
    );

    /// A crop area that can't be covered at all reports the maximum scale,
    /// which is an upper bound and would turn this floor into a ceiling. The
    /// current zoom is returned instead, so callers only stop zooming out and
    /// never zoom back in through this value.
    if (!fit.fits) return userScaleFactor;

    return fit.scale;
  }

  /// Indicates whether a locked-aspect-ratio rotation animation is in progress.
  ///
  /// Used to defer the history entry to the end of the crop-area transition
  /// instead of adding it when the rotation animation completes.
  bool _lockedRotationActive = false;

  /// The opacity of the painter.
  double _painterOpacity = 0;

  /// The interaction progress for opacity.
  ///
  /// Drives how much the area outside the crop area brightens up while the user
  /// interacts with the crop frame.
  double _interactionOpacityProgress = 0;

  /// Animates [_interactionOpacityProgress].
  ///
  /// A controller is required here because the user can grab the crop frame
  /// again while it is still fading back to its idle state. Restarting the
  /// transition from `0` would make the overlay jump instead of continuing
  /// smoothly from its current brightness.
  late final AnimationController _interactionOpacityCtrl;

  /// The curved animation of [_interactionOpacityCtrl].
  late final CurvedAnimation _interactionOpacityAnimation;

  /// The padding around the screen.
  final double _screenPadding = 20;

  /// The starting scale value for pinch gestures.
  double _startingPinchScale = 1;

  /// The scale the recognizer reported on the first update of the running
  /// pinch gesture.
  ///
  /// A pinch is only recognized after the fingers moved past the gesture slop,
  /// so the first reported scale is already noticeably off `1`. Zooming
  /// relative to this baseline keeps the image from jumping when the pinch
  /// starts.
  double? _pinchScaleBaseline;

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

  /// The size of the editor body, used to compute how far the content must be
  /// scaled up to make room for the tilt ruler bar.
  Size _bodySize = Size.zero;

  /// Details of the tap down event for double-tap gestures.
  late TapDownDetails _doubleTapDetails;

  /// The current part of the crop area being interacted with.
  CropAreaPart _currentCropAreaPart = CropAreaPart.none;

  /// The distance between the pointer and the crop handle it grabbed.
  ///
  /// The handles have a generous hit area
  /// ([CropRotateEditorConfigs.mobileCornerDragArea]), so the pointer usually
  /// sits a couple of pixels next to the edge it dragged. Without compensating
  /// for that distance the handle jumps onto the pointer with the first move
  /// event before it starts following it.
  Offset _cropGrabOffset = Offset.zero;

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

  /// A flag indicating whether the screen has been resized.
  bool _isScreenResized = false;

  /// Sets the current mouse cursor and updates the widget that manages the
  /// cursor.
  set _cursor(MouseCursor cursor) {
    _mouseCursor = cursor;
    _mouseCursorsKey.currentState?.setCursor(cursor);
  }

  double _rotationScaleFactor = 1;

  /// Opacity of the whole crop overlay, used to briefly hide and show the crop
  /// frame while a locked aspect-ratio rotation runs.
  double _cropFrameOpacity = 1;

  @override
  CropCornerPainter? get cropPainter {
    return showWidgets
        ? CropCornerPainter(
            offset: translate,
            cropRect: cropRect,
            viewRect: _viewRect,
            scaleFactor: userScaleFactor,
            rotationScaleFactor: _rotationScaleFactor,
            frameOpacity: _cropFrameOpacity,
            interactionOpacity: _interactionOpacityProgress,
            screenSize: Size(editorBodySize.width, editorBodySize.height),
            fadeInOpacity: _painterOpacity,
            style: cropRotateEditorConfigs.style,
            drawCircle: cropMode == CropMode.oval,
            tiltRotate: tiltRotateAngle,
            tiltHorizontal: tiltHorizontalAngle,
            tiltVertical: tiltVerticalAngle,
          )
        : null;
  }

  /// Returns the current mouse cursor style.
  MouseCursor get _cursor => _mouseCursor;

  bool _isVideoPlayerReady = true;

  /// Whether the tilt (perspective/skew) editor bar is currently visible.
  bool _isTiltEditorActive = false;

  /// The currently active tilt mode shown in the tilt ruler.
  TiltMode _tiltMode = TiltMode.rotate;

  /// Counter incremented on every tilt reset, used to give the tilt ruler a
  /// fresh state via its [ValueKey].
  int _tiltResetCount = 0;

  /// Whether tilt controls should be offered in this editor.
  ///
  /// Perspective tilt uses non-quarter rotations which the native video export
  /// pipeline can't represent, so the tilt entry point is hidden in the video
  /// editor regardless of [TiltConfigs.showTiltButton].
  bool get _enableTilt =>
      cropRotateEditorConfigs.tiltConfigs.showTiltButton && !isVideoEditor;

  /// Defines which crop-rotate tools are available in the editor.
  late List<CropRotateTool> tools = [...cropRotateEditorConfigs.tools]
    ..removeWhere((tool) => tool == CropRotateTool.tilt && !_enableTilt);

  @override
  void initState() {
    super.initState();

    _initializeVideoEditor();
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
    _desktopInteractionManager = CropDesktopInteractionManager(
      context: context,
    );

    // Initialize image and layers
    _imageNeedDecode = mainImageSize == null;
    _imageSizeIsDecoded = !_imageNeedDecode;
    _layers = initConfigs.layers ?? [];
    _setRawLayers();

    // Initialize rotate animation
    double initAngle = initialTransformConfigs?.angle ?? 0.0;
    rotateCtrl = AnimationController(
      duration: cropRotateEditorConfigs.animationDuration,
      vsync: this,
    );
    rotateCtrl.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        /// While a locked-aspect-ratio rotation is running the crop area is
        /// still being animated, so the history entry is added once that
        /// transition finishes instead of here.
        if (!_lockedRotationActive && _blockInteraction) {
          addHistory(scaleRotation: oldScaleFactor);
          _blockInteraction = false;
        }
        cropRotateEditorCallbacks?.handleRotateEnd(rotateAnimation.value);
      }
    });
    rotateAnimation = Tween<double>(
      begin: initAngle,
      end: initAngle,
    ).animate(rotateCtrl);

    // Initialize the opacity animation of the area outside the crop area
    _interactionOpacityCtrl = AnimationController(
      duration: cropRotateEditorConfigs.opacityOutsideCropAreaDuration,
      vsync: this,
    );

    /// The same curve is used in both directions on purpose. A separate
    /// reverse curve maps the controller value to a different opacity, which
    /// makes the overlay jump as soon as a transition is reversed midway.
    _interactionOpacityAnimation =
        CurvedAnimation(
          parent: _interactionOpacityCtrl,
          curve: Curves.decelerate,
        )..addListener(() {
          _interactionOpacityProgress = _interactionOpacityAnimation.value;
          cropPainterKey.currentState?.setForegroundPainter(cropPainter);
        });

    // Initialize scale animation
    double initScale = (initialTransformConfigs?.scaleRotation ?? 1);
    scaleCtrl = AnimationController(
      duration: cropRotateEditorConfigs.animationDuration,
      vsync: this,
    );
    scaleAnimation = Tween<double>(
      begin: initScale,
      end: initScale,
    ).animate(scaleCtrl);

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
      tiltRotateAngle = initialTransformConfigs!.tiltRotate;
      tiltHorizontalAngle = initialTransformConfigs!.tiltHorizontal;
      tiltVerticalAngle = initialTransformConfigs!.tiltVertical;
      translate = initialTransformConfigs!.offset;
      userScaleFactor = initialTransformConfigs!.scaleUser;
      manualScaleFactor = initialTransformConfigs!.scaleUser;
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
    _interactionOpacityAnimation.dispose();
    _interactionOpacityCtrl.dispose();
    super.dispose();
  }

  /// Fades the area outside the crop area in or out.
  ///
  /// The duration is refreshed on every transition, so a configs change while
  /// the editor is open takes effect right away instead of keeping the value
  /// the controller was created with.
  void _animateInteractionOpacity({required bool visible}) {
    _interactionOpacityCtrl.duration =
        cropRotateEditorConfigs.opacityOutsideCropAreaDuration;

    if (visible) {
      _interactionOpacityCtrl.forward();
    } else {
      _interactionOpacityCtrl.reverse();
    }
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

  void _initializeVideoEditor() async {
    if (!isVideoEditor || !initConfigs.convertToUint8List) return;

    _isVideoPlayerReady = false;

    widget.videoController!.initialize(
      configsFunction: () => configs.videoEditor,
      callbacksAudioFunction: () =>
          callbacks.audioEditorCallbacks ?? const AudioEditorCallbacks(),
      callbacksFunction: () =>
          callbacks.videoEditorCallbacks ?? VideoEditorCallbacks(),
    );

    final resolution = widget.videoController!.initialResolution;

    videoBackgroundImage = EditorImage(
      byteArray: await createTransparentImage(resolution),
    );
    _isVideoPlayerReady = true;

    if (!mounted) return;

    setState(() {});
    await _decodeImage();
  }

  Future<void> _decodeImage() async {
    if (!_isVideoPlayerReady && isVideoEditor) return;
    _imageSizeIsDecoded = false;
    _imageNeedDecode = false;

    var decodedImage = await decodeImageFromList(
      await editorImage!.safeByteArray(context),
    );

    if (!mounted) return;
    var w = decodedImage.width;
    var h = decodedImage.height;

    var widthRatio = w.toDouble() / editorBodySize.width;
    var heightRatio = h.toDouble() / editorBodySize.height;
    var pixelRatio = max(heightRatio, widthRatio);
    var renderedSize = Size(w / pixelRatio, h / pixelRatio);

    imageInfos = ImageInfos(
      rawSize: Size(w.toDouble(), h.toDouble()),
      renderedSize: renderedSize,
      originalRenderedSize: renderedSize,
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

  @override
  bool get enableKeyboardShortcuts =>
      cropRotateEditorConfigs.enableKeyboardShortcuts;

  @override
  CropRotateEditorCallbacks? get standaloneEditorCallbacks =>
      cropRotateEditorCallbacks;

  @override
  bool onCustomKeyEvent(KeyEvent event) {
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
        double targetZoom = (userScaleFactor + scale).clamp(
          1,
          cropRotateEditorConfigs.maxScale,
        );

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
    initConfigs.callbacks.onImageEditingStarted?.call();

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
      if (cropRotateEditorConfigs.enableProvideImageInfos &&
          imageInfos == null) {
        await setImageInfos(activeHistory: activeHistory);
      }

      await initConfigs.onDone?.call(
        transformC,
        _transformHelperScale,
        imageInfos,
      );
      if (mounted && initConfigs.enablePopWhenDone) {
        Navigator.pop(context, transformC);
      }
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

      if (!mounted) return;

      var imageBytes = bytes ?? Uint8List.fromList([]);

      await initConfigs.callbacks.onImageEditingComplete?.call(imageBytes);

      if (!mounted) return;

      /// Return complete parameters if requested
      if (initConfigs.callbacks.onCompleteWithParameters != null) {
        final completeParams = await getCompleteParameters(
          imageBytes: imageBytes,
        );
        await callbacks.onCompleteWithParameters?.call(completeParams);
      }

      LoadingDialog.instance.hide();

      initConfigs.callbacks.onCloseEditor?.call(EditorMode.cropRotate);
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
            cropMode: cropMode,
          ),
        );
      }

      TransformConfigs transformC =
          !canRedo && !canUndo && initialTransformConfigs != null
          ? initialTransformConfigs!
          : activeHistory;

      await screenshotCtrl.capture(
        imageInfos: imageInfos!,
        screenshots: screenshotHistory,
        /*   targetSize: _rotated90deg
            ? imageInfos!.renderedSize.flipped
            : imageInfos!.renderedSize, */
        widget: _screenshotWidget(transformC),
      );
    });
  }

  /// Flip the image horizontally
  void flip() {
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
    /// Ignore new rotations while a locked-aspect-ratio rotation (which hides
    /// and shows the crop frame) is still running.
    if (_lockedRotationActive) return;
    _blockInteraction = true;
    var piHelper =
        cropRotateEditorConfigs.rotateDirection == RotateDirection.left
        ? -pi
        : pi;

    rotationCount++;
    rotateAnimation =
        Tween<double>(
          begin: rotateAnimation.value,
          end: rotationCount * piHelper / 2,
        ).animate(
          CurvedAnimation(
            parent: rotateCtrl,
            curve: cropRotateEditorConfigs.rotateAnimationCurve,
          ),
        );
    rotateCtrl.reset();

    if (cropRotateEditorConfigs.enableKeepAspectRatioOnRotate &&
        !cropRect.isEmpty) {
      /// The rotation is started inside the helper, after fading the frame out.
      _rotateWithLockedAspectRatio();
    } else {
      rotateCtrl.forward();
      calcFitToScreen();
    }

    cropRotateEditorCallbacks?.handleRotateStart(rotateAnimation.value);
  }

  /// Rotates while keeping the crop frame's orientation, hiding the frame
  /// during the rotation so it never appears to change its aspect ratio.
  ///
  /// Because the crop frame lives inside the rotating image transform, letting
  /// it rotate would make e.g. a `9:16` frame widen towards `1:1` half way
  /// through the 90° rotation. To avoid this the crop overlay is faded out, the
  /// image is rotated and zoomed while the frame is hidden, and the frame is
  /// then faded back in at the preserved aspect ratio. Inverting the current
  /// crop ratio works for fixed, original and free aspect ratios.
  Future<void> _rotateWithLockedAspectRatio() async {
    _lockedRotationActive = true;

    final Rect startCropRect = cropRect;
    final Rect startViewRect = _viewRect;

    /// Recalculate the crop area with the inverted aspect ratio to get the
    /// target the image is zoomed/fitted to.
    calcCropRect(newRatio: startCropRect.width / startCropRect.height);
    final Rect targetCropRect = cropRect;
    final Rect targetViewRect = _viewRect;

    /// 1) Fade the crop overlay out while the image is still static, so the
    /// user never sees the frame change its aspect ratio.
    cropRect = startCropRect;
    _viewRect = startViewRect;
    await loopWithTransitionTiming(
      (double curveT) {
        _cropFrameOpacity = 1 - curveT;
        cropPainterKey.currentState?.setForegroundPainter(cropPainter);
      },
      mounted: mounted,
      duration: cropRotateEditorConfigs.opacityOutsideCropAreaDuration,
      transitionFunction: Curves.easeOut.transform,
    );
    if (!mounted) return;
    _cropFrameOpacity = 0;

    /// 2) Switch to the target crop (still hidden) and rotate + zoom the image.
    cropRect = targetCropRect;
    _viewRect = targetViewRect;
    calcFitToScreen();
    try {
      await rotateCtrl.forward();
    } catch (_) {
      /// The ticker was canceled (e.g. the editor was disposed).
      return;
    }
    if (!mounted) return;
    _setOffsetLimits();

    /// 3) Fade the crop overlay back in at the preserved aspect ratio.
    await loopWithTransitionTiming(
      (double curveT) {
        _cropFrameOpacity = curveT;
        cropPainterKey.currentState?.setForegroundPainter(cropPainter);
      },
      mounted: mounted,
      duration: cropRotateEditorConfigs.fadeInOutsideCropAreaAnimationDuration,
      transitionFunction:
          cropRotateEditorConfigs.fadeInOutsideCropAreaAnimationCurve.transform,
    );
    if (!mounted) return;
    _cropFrameOpacity = 1;

    _lockedRotationActive = false;
    if (_blockInteraction) {
      addHistory(scaleRotation: oldScaleFactor);
      _blockInteraction = false;
    }
  }

  @override
  calcFitToScreen({Curve? curve, Size? imageSize, bool animated = true}) {
    if (!animated) scaleCtrl.duration = Duration.zero;
    Size contentSize = Size(
      editorBodySize.width - _screenPadding * 2,
      editorBodySize.height - _screenPadding * 2,
    );

    double cropSpaceHorizontal = _rotated90deg
        ? _cropSpaceVertical
        : _cropSpaceHorizontal;
    double cropSpaceVertical = _rotated90deg
        ? _cropSpaceHorizontal
        : _cropSpaceVertical;

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
          _rotationScaleFactor = lerpDouble(
            startRotateFactor,
            targetRotateFactor,
            curveT,
          )!;
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

  void _setCropRectBounding({double? oldScaleAnimationValue}) {
    if (cropRect.isEmpty) {
      return;
    }

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
      if (translate.dx.isNaN || translate.dx.isInfinite) {
        throw ArgumentError('Hmmm');
      }
      _setOffsetLimits();
    }
  }

  /// Opens a dialog to select from predefined aspect ratios.
  void openAspectRatioOptions() {
    showModalBottomSheet<double>(
      context: context,
      backgroundColor:
          cropRotateEditorConfigs.style.aspectRatioSheetBackgroundColor,
      isScrollControlled: true,
      builder: (BuildContext context) => SafeArea(
        child:
            cropRotateEditorConfigs.widgets.aspectRatioOptions?.call(
              this,
              rebuildController.stream,
              aspectRatio,
              _mainImageSize.aspectRatio,
            ) ??
            CropAspectRatioOptions(
              aspectRatio: aspectRatio,
              configs: configs,
              originalAspectRatio: _mainImageSize.aspectRatio,
            ),
      ),
    ).then((value) {
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
    aspectRatio = value;
    cropRotateEditorCallbacks?.handleRatioSelected(value);

    calcCropRect();
    calcFitToScreen();
    _setOffsetLimits();
    addHistory(scaleRotation: oldScaleFactor);
    _updateAllStates();
  }

  late CropMode _cropMode =
      widget.initConfigs.transformConfigs?.cropMode ??
      cropRotateEditorConfigs.initialCropMode;

  /// Gets the current crop mode.
  ///
  /// Returns [CropMode.circular] if the round cropper is enabled,
  /// otherwise returns [CropMode.rectangular].
  @override
  CropMode get cropMode => _cropMode;

  /// Sets the crop mode.
  ///
  /// If [value] is [CropMode.circular], it enables the round cropper,
  /// sets the aspect ratio to 1 (square), and updates the internal state.
  /// If [value] is [CropMode.rectangular], it disables the round cropper
  /// and updates the internal state accordingly.
  @override
  set cropMode(CropMode value) => setCropMode(value);

  @override
  void setCropMode(
    CropMode value, {
    bool updateStates = true,
    bool updateHistory = true,
  }) {
    _cropMode = value;
    if (updateStates) _updateAllStates();
    if (updateHistory) addHistory();
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
    return determineCropAreaPart(
      localPosition: localPosition,
      translate: translate,
      interactiveCornerArea: _interactiveCornerArea,
      userScaleFactor: userScaleFactor,
      cropRect: cropRect,
      cropMode: cropMode,
      renderedImageSize: _renderedImgConstraints.biggest,
    );
  }

  /// Updates the perspective/skew tilt value for the given [mode].
  ///
  /// - [mode]: The [TiltMode] to update (horizontal, vertical, rotate).
  /// - [value]: The new tilt value in radians.
  /// - [updateStateHistory]: If `true`, the change is added to the history.
  ///
  /// After updating the angle, `_setOffsetLimits` re-fits the view (auto-zoom
  /// and pan) so the crop selection can never end up outside the tilted image.
  /// If even the maximum zoom can't keep the selection covered the angle is
  /// clamped back to the last valid value, so the tilt smoothly "blocks" at the
  /// image border instead of revealing empty area.
  void tilt(TiltMode mode, double value, {bool updateStateHistory = true}) {
    _tiltMode = mode;

    final double previousValue = switch (mode) {
      TiltMode.horizontal => tiltHorizontalAngle,
      TiltMode.vertical => tiltVerticalAngle,
      TiltMode.rotate => tiltRotateAngle,
    };

    void applyAngle(double angle) {
      switch (mode) {
        case TiltMode.horizontal:
          tiltHorizontalAngle = angle;
          break;
        case TiltMode.vertical:
          tiltVerticalAngle = angle;
          break;
        case TiltMode.rotate:
          tiltRotateAngle = angle;
          break;
      }
    }

    applyAngle(value);

    // Re-fit the view. When the requested angle would push the selection
    // outside the image even at [maxScale], revert to the previous angle so the
    // selection always stays fully covered.
    final bool fits = _setOffsetLimits();
    if (!fits && value != previousValue) {
      applyAngle(previousValue);
      _setOffsetLimits();
    }

    if (updateStateHistory) addHistory();
    cropPainterKey.currentState?.update(
      foregroundPainter: cropPainter,
      isComplex: showWidgets,
      willChange: showWidgets,
    );
    setState(() {});
  }

  /// Updates the scale factor for the image based on a pinch gesture value.
  ///
  /// This method calculates the new zoom level by multiplying the starting
  /// pinch scale with the provided [value] and clamping it between 1.0 and
  /// the configured maximum scale. It also adjusts the translation offset to
  /// maintain the focal point at the center of the zoom operation.
  ///
  /// The method performs the following steps:
  /// 1. Calculates the new zoom level within allowed bounds
  /// 2. Computes the center offset to preserve the zoom focal point
  /// 3. Updates the translation and user scale factor
  /// 4. Applies offset limits and triggers scale callbacks
  void setScale(double value) {
    double newZoom = (_startingPinchScale * value).clamp(
      1.0,
      cropRotateEditorConfigs.maxScale,
    );

    // Calculate the center offset point from the new zoomed view
    Offset centerZoomOffset =
        _startingCenterOffset * _startingPinchScale / newZoom;

    // Update translation and zoom values
    translate = _startingTranslate - _startingCenterOffset + centerZoomOffset;
    userScaleFactor = newZoom;
    manualScaleFactor = newZoom;

    // Set offset limits and trigger widget rebuild
    _setOffsetLimits();
    cropRotateEditorCallbacks?.handleScale();
  }

  void _zoomOutside() async {
    const int frameHelper = 1000 ~/ 60;

    /// A tilted image needs a minimum zoom to keep the crop area covered.
    /// Without this floor every step is undone by [_setOffsetLimits] right
    /// away, which leaves the image jittering while the crop area is reset by
    /// [calcCropRect] on every iteration.
    final double minZoom = _minCoveringScale;

    while (userScaleFactor > minZoom && _activeScaleOut) {
      double oldZoom = userScaleFactor;

      double zoomFactor = 0.025;
      userScaleFactor = max(minZoom, userScaleFactor - zoomFactor);

      /// Zooming out is a manual zoom change, so the floor the bounds math
      /// keeps has to follow along.
      manualScaleFactor = userScaleFactor;

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
    _pinchScaleBaseline = null;
    // Calculate the center offset point from the old zoomed view
    _startingCenterOffset =
        _startingTranslate +
        _getRealHitPoint(
              position: details.localFocalPoint,
              zoom: userScaleFactor,
            ) /
            userScaleFactor;

    if (!_scaleStarted) {
      /// On desktop devices we detect always in `onPointerHover` events.
      if (!isDesktop) {
        _currentCropAreaPart = _determineCropAreaPart(details.localFocalPoint);
      }
      _animateInteractionOpacity(visible: true);
    }

    /// Recalculated on every start, not only on the first one. The recognizer
    /// restarts whenever the number of pointers changes, so this keeps the
    /// dragged handle in place when a finger is lifted from a pinch.
    _cropGrabOffset = _calcCropGrabOffset(details.localFocalPoint);

    _scaleAllowUpdateHelper = false;
    _onScaleAllowUpdateDebounce(() {
      _scaleAllowUpdateHelper = true;
    });

    _interactionActive = true;
    _scaleStarted = true;
    _blockInteraction = false;
  }

  /// Converts a global pointer position into the local coordinate space of the
  /// editor body, the box [editorBodySize] describes.
  ///
  /// The body is not aligned with the screen, it sits below the app-bar and can
  /// be inset horizontally by [CropRotateEditorConfigs.maxWidthFactor], so a
  /// raw pointer position must not be compared against [editorBodySize].
  ///
  /// Returns `null` while the body has no render object. Falling back to the
  /// raw global position would silently reintroduce that coordinate mismatch,
  /// so callers skip their check instead.
  Offset? _toEditorBodyPosition(Offset globalPosition) {
    var renderObject = _editorContentKey.currentContext?.findRenderObject();
    if (renderObject is! RenderBox) return null;

    return renderObject.globalToLocal(globalPosition);
  }

  /// Converts a pointer position from the local space of the gesture detector
  /// into the space the image occupies, measured from its center.
  Offset _toImageCenterPosition(
    Offset localPosition, {
    required double zoom,
    required Offset translateOffset,
  }) {
    return _getRealHitPoint(zoom: zoom, position: localPosition) +
        translateOffset * zoom;
  }

  /// Converts a pointer position produced by [_toImageCenterPosition] into the
  /// coordinate space of [cropRect].
  Offset _toCropHandlePosition(Offset offset) {
    double halfViewRectW = _viewRect.width / 2;
    double halfViewRectH = _viewRect.height / 2;

    double circleGapX = 0;
    double circleGapY = 0;

    if (cropMode == CropMode.oval) {
      circleGapX =
          sqrt(
            pow(halfViewRectW, 2) - pow(min(offset.dy.abs(), halfViewRectW), 2),
          ) -
          halfViewRectW;
      circleGapY =
          sqrt(
            pow(halfViewRectH, 2) - pow(min(offset.dx.abs(), halfViewRectH), 2),
          ) -
          halfViewRectH;

      circleGapX *= -offset.dx.sign;
      circleGapY *= -offset.dy.sign;
    }

    return Offset(
      offset.dx + halfViewRectW + _cropSpaceHorizontal / 2 + circleGapX,
      offset.dy + halfViewRectH + _cropSpaceVertical / 2 + circleGapY,
    );
  }

  /// Returns how far the pointer sits away from the crop handle it grabbed.
  ///
  /// See [_cropGrabOffset].
  Offset _calcCropGrabOffset(Offset localPosition) {
    if (_currentCropAreaPart == CropAreaPart.none ||
        _currentCropAreaPart == CropAreaPart.inside) {
      return Offset.zero;
    }

    Offset pointer = _toCropHandlePosition(
      _toImageCenterPosition(
        localPosition,
        zoom: _startingPinchScale,
        translateOffset: _startingTranslate,
      ),
    );

    return Offset(
      switch (_currentCropAreaPart) {
        CropAreaPart.left ||
        CropAreaPart.topLeft ||
        CropAreaPart.bottomLeft => pointer.dx - cropRect.left,
        CropAreaPart.right ||
        CropAreaPart.topRight ||
        CropAreaPart.bottomRight => pointer.dx - cropRect.right,
        _ => 0,
      },
      switch (_currentCropAreaPart) {
        CropAreaPart.top ||
        CropAreaPart.topLeft ||
        CropAreaPart.topRight => pointer.dy - cropRect.top,
        CropAreaPart.bottom ||
        CropAreaPart.bottomLeft ||
        CropAreaPart.bottomRight => pointer.dy - cropRect.bottom,
        _ => 0,
      },
    );
  }

  /// Resizes [rect] from the dragged corner while keeping the locked aspect
  /// ratio [_ratio], anchored at the opposite corner.
  ///
  /// [pointer] is projected onto the diagonal the ratio allows, so the corner
  /// follows the pointer in both directions instead of tracking its horizontal
  /// movement only.
  Rect _resizeCornerToRatio({
    required CropAreaPart part,
    required Rect rect,
    required Offset pointer,
    required Rect bounds,
    required double minSize,
  }) {
    bool isLeft =
        part == CropAreaPart.topLeft || part == CropAreaPart.bottomLeft;
    bool isTop = part == CropAreaPart.topLeft || part == CropAreaPart.topRight;

    double anchorX = isLeft ? rect.right : rect.left;
    double anchorY = isTop ? rect.bottom : rect.top;

    double pointerWidth = (pointer.dx - anchorX) * (isLeft ? -1 : 1);
    double pointerHeight = (pointer.dy - anchorY) * (isTop ? -1 : 1);

    /// Closest point on the `height == width * _ratio` diagonal.
    double width =
        (pointerWidth + pointerHeight * _ratio) / (1 + _ratio * _ratio);

    double maxWidth = min(
      isLeft ? anchorX - bounds.left : bounds.right - anchorX,
      (isTop ? anchorY - bounds.top : bounds.bottom - anchorY) / _ratio,
    );
    width = width.safeMinClamp(minSize, maxWidth);
    double height = width * _ratio;

    return Rect.fromLTRB(
      isLeft ? anchorX - width : anchorX,
      isTop ? anchorY - height : anchorY,
      isLeft ? anchorX : anchorX + width,
      isTop ? anchorY : anchorY + height,
    );
  }

  /// Restores the locked aspect ratio [_ratio] after an edge handle changed one
  /// side of [rect], growing the opposite axis around the center and keeping
  /// the result inside [bounds].
  Rect _resizeEdgeToRatio({
    required CropAreaPart part,
    required Rect rect,
    required Rect bounds,
  }) {
    bool fromWidth = part == CropAreaPart.left || part == CropAreaPart.right;

    double width = fromWidth ? rect.width : rect.height / _ratio;
    width = min(width, min(bounds.width, bounds.height / _ratio));

    Rect result = Rect.fromCenter(
      center: rect.center,
      width: width,
      height: width * _ratio,
    );

    /// Shift the rect back inside the image when the opposite axis grew over
    /// one of the edges.
    double shiftX = 0;
    double shiftY = 0;
    if (result.left < bounds.left) shiftX = bounds.left - result.left;
    if (result.right > bounds.right) shiftX = bounds.right - result.right;
    if (result.top < bounds.top) shiftY = bounds.top - result.top;
    if (result.bottom > bounds.bottom) shiftY = bounds.bottom - result.bottom;

    return result.shift(Offset(shiftX, shiftY));
  }

  void _onScaleUpdate(ScaleUpdateDetails details) {
    if (_blockInteraction ||
        details.pointerCount > 2 ||
        !_scaleAllowUpdateHelper) {
      return;
    }
    _blockInteraction = true;
    if (details.pointerCount == 2) {
      /// A degenerate span reports a scale of `0`. Latching that as the
      /// baseline would leave every following update un-normalized, so the
      /// update is skipped until the recognizer reports a usable span.
      if (details.scale > 0) {
        _pinchScaleBaseline ??= details.scale;
        setScale(details.scale / _pinchScaleBaseline!);
      }
    } else {
      if (_currentCropAreaPart != CropAreaPart.none &&
          _currentCropAreaPart != CropAreaPart.inside) {
        Offset offset = _toImageCenterPosition(
          details.localFocalPoint,
          zoom: _startingPinchScale,
          translateOffset: _startingTranslate,
        );

        double imgW = _renderedImgConstraints.maxWidth;
        double imgH = _renderedImgConstraints.maxHeight;

        double halfSpaceHorizontal = _cropSpaceHorizontal / 2;
        double halfSpaceVertical = _cropSpaceVertical / 2;

        double outsidePadding = _screenPadding * 2;
        double cornerGap =
            cropRotateEditorConfigs.style.cropCornerLength * 2.25;
        double minCornerDistance = outsidePadding + cornerGap;

        /// The position of the dragged handle. `_cropGrabOffset` keeps the
        /// handle where the pointer grabbed it instead of snapping it onto the
        /// pointer with the first move event.
        Offset handlePosition = _toCropHandlePosition(offset) - _cropGrabOffset;

        double dx = handlePosition.dx;
        double dy = handlePosition.dy;

        double maxRight = cropRect.right + outsidePadding - minCornerDistance;
        double maxBottom = cropRect.bottom + outsidePadding - minCornerDistance;

        double minLeft = halfSpaceHorizontal;
        double minRight = imgW - halfSpaceHorizontal;
        double minTop = halfSpaceVertical;
        double minBottom = imgH - halfSpaceVertical;

        bool isFreeAspectRatio = _ratio < 0;
        if (isFreeAspectRatio) {
          minLeft =
              -(imgW * userScaleFactor / 2 -
                  _viewRect.width / 2 -
                  halfSpaceHorizontal -
                  translate.dx * userScaleFactor);
          minRight =
              imgW +
              (imgW * userScaleFactor / 2 -
                  _viewRect.width / 2 -
                  halfSpaceHorizontal +
                  translate.dx * userScaleFactor);
          minTop =
              -(imgH * userScaleFactor / 2 -
                  _viewRect.height / 2 -
                  halfSpaceVertical -
                  translate.dy * userScaleFactor);
          minBottom =
              imgH +
              (imgH * userScaleFactor / 2 -
                  _viewRect.height / 2 -
                  halfSpaceVertical +
                  translate.dy * userScaleFactor);
        }

        Size realViewRectSize = _viewRect.size * scaleAnimation.value;
        if (_rotated90deg) {
          realViewRectSize = Size(
            realViewRectSize.height,
            realViewRectSize.width,
          );
        }

        double doubleInteractiveArea = _interactiveCornerArea * 2;
        double halfScreenPadding = _screenPadding / 2;

        double zoomOutHitAreaX = max(
          halfScreenPadding,
          (editorBodySize.width - realViewRectSize.width) / 2 -
              doubleInteractiveArea,
        );
        double zoomOutHitAreaY = max(
          halfScreenPadding,
          (editorBodySize.height - realViewRectSize.height) / 2 -
              doubleInteractiveArea,
        );

        /// Without a body position the pointer can't be compared against
        /// [editorBodySize], so the zoom-out is skipped rather than triggered
        /// at the wrong place.
        Offset? bodyPosition = _toEditorBodyPosition(details.focalPoint);

        bool outsideLeft =
            bodyPosition != null && bodyPosition.dx < zoomOutHitAreaX;
        bool outsideRight =
            bodyPosition != null &&
            bodyPosition.dx > editorBodySize.width - zoomOutHitAreaX;
        bool outsideTop =
            bodyPosition != null && bodyPosition.dy < zoomOutHitAreaY;
        bool outsideBottom =
            bodyPosition != null &&
            bodyPosition.dy > editorBodySize.height - zoomOutHitAreaY;

        // Scale outside when the user move outside the scale area
        bool zoomOutside =
            !isFreeAspectRatio &&
            (outsideLeft || outsideRight || outsideTop || outsideBottom);
        if (zoomOutside && !_activeScaleOut) {
          _activeScaleOut = true;
          _zoomOutside();
        }

        /// [_zoomOutside] clears the flag right away when the zoom already sits
        /// on its floor, so a crop area that can't zoom out any further keeps
        /// resizing instead of freezing while the pointer sits in the band.
        if (!_activeScaleOut ||
            (!zoomOutside &&
                offset.dx.abs() <
                    _viewRect.width / 2 - _interactiveCornerArea)) {
          _activeScaleOut = false;

          bool isCorner =
              _currentCropAreaPart == CropAreaPart.topLeft ||
              _currentCropAreaPart == CropAreaPart.topRight ||
              _currentCropAreaPart == CropAreaPart.bottomLeft ||
              _currentCropAreaPart == CropAreaPart.bottomRight;

          if (_ratio >= 0 && isCorner) {
            /// A locked ratio anchors the rect at the opposite corner and
            /// derives both sides from the pointer, so the free-form clamping
            /// in the switch below would only be overwritten again.
            cropRect = _resizeCornerToRatio(
              part: _currentCropAreaPart,
              rect: cropRect,
              pointer: Offset(dx, dy),
              bounds: Rect.fromLTRB(minLeft, minTop, minRight, minBottom),
              minSize: cornerGap,
            );
          } else {
            switch (_currentCropAreaPart) {
              case CropAreaPart.topLeft:
                cropRect = Rect.fromLTRB(
                  dx.safeMinClamp(minLeft, maxRight),
                  dy.safeMinClamp(minTop, maxBottom),
                  cropRect.right,
                  cropRect.bottom,
                );
                break;
              case CropAreaPart.topRight:
                cropRect = Rect.fromLTRB(
                  cropRect.left,
                  dy.safeMinClamp(minTop, maxBottom),
                  dx.safeMinClamp(cornerGap + cropRect.left, minRight),
                  cropRect.bottom,
                );
                break;
              case CropAreaPart.bottomLeft:
                cropRect = Rect.fromLTRB(
                  dx.safeMinClamp(minLeft, maxRight),
                  cropRect.top,
                  cropRect.right,
                  dy.safeMinClamp(cornerGap + cropRect.top, minBottom),
                );
                break;
              case CropAreaPart.bottomRight:
                cropRect = Rect.fromLTRB(
                  cropRect.left,
                  cropRect.top,
                  dx.safeMinClamp(cornerGap + cropRect.left, minRight),
                  dy.safeMinClamp(cornerGap + cropRect.top, minBottom),
                );
                break;
              case CropAreaPart.left:
                cropRect = Rect.fromLTRB(
                  dx.safeMinClamp(minLeft, maxRight),
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
                  dx.safeMinClamp(cornerGap + cropRect.left, minRight),
                  cropRect.bottom,
                );
                break;
              case CropAreaPart.top:
                cropRect = Rect.fromLTRB(
                  cropRect.left,
                  dy.safeMaxClamp(minTop, maxBottom),
                  cropRect.right,
                  cropRect.bottom,
                );
                break;
              case CropAreaPart.bottom:
                cropRect = Rect.fromLTRB(
                  cropRect.left,
                  cropRect.top,
                  cropRect.right,
                  dy.safeMinClamp(cornerGap + cropRect.top, minBottom),
                );
                break;
              default:
                break;
            }

            /// An edge handle only changed one side, so the opposite axis is
            /// grown back around the center to restore the locked ratio.
            if (_ratio >= 0) {
              switch (_currentCropAreaPart) {
                case CropAreaPart.left:
                case CropAreaPart.right:
                case CropAreaPart.top:
                case CropAreaPart.bottom:
                  cropRect = _resizeEdgeToRatio(
                    part: _currentCropAreaPart,
                    rect: cropRect,
                    bounds: Rect.fromLTRB(minLeft, minTop, minRight, minBottom),
                  );
                  break;
                default:
                  break;
              }
            }
          }
        }

        cropPainterKey.currentState!.update(foregroundPainter: cropPainter);
      } else {
        double scaleFactor = userScaleFactor / _scaleStartZoomHelper;
        translate +=
            Offset(details.focalPointDelta.dx, details.focalPointDelta.dy) /
            scaleFactor *
            (cropRotateEditorConfigs.invertDragDirection ? -1 : 1);
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

    /// [ScaleGestureRecognizer] also reports an end every time the number of
    /// pointers changes, so it fires in the middle of a pinch as soon as the
    /// second finger touches down. Finalizing the crop here would animate the
    /// selection back to the view rect and block the following
    /// [_onScaleStart], which leaves the pinch working with a stale scale
    /// baseline and makes the zoom jump.
    ///
    /// The auto zoom-out is still stopped, otherwise it keeps looping in the
    /// background and fights the pinch that follows.
    if (details.pointerCount > 0) {
      _activeScaleOut = false;
      return;
    }
    if (_blockInteraction) return;
    _blockInteraction = true;
    _interactionActive = false;

    _onScaleEndDebounce(() {
      if (_activePointers <= 0) {
        _scaleStarted = false;
        _animateInteractionOpacity(visible: false);
      }
    });

    if (cropRect != _viewRect) {
      /// A degenerate crop rect has nothing to animate back. Returning without
      /// releasing [_blockInteraction] would freeze every following gesture.
      ///
      /// Return is important for tests
      if (cropRect.isEmpty) {
        _activeScaleOut = false;
        _blockInteraction = false;
        return;
      }

      Rect initRect = Rect.fromCenter(
        center: _viewRect.center,
        width: _viewRect.width,
        height: _viewRect.height,
      );
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
      Offset targetOffset =
          startOffset -
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

          /// While tilted, [_setOffsetLimits] auto-zooms and never goes below
          /// `manualScaleFactor`. Keeping that floor in sync with the animated
          /// zoom lets the bounds only lift it further where the tilt requires
          /// it. Without this the tilt bounds overwrite the zoom on every frame
          /// and the image jumps around while the crop area animates back.
          manualScaleFactor = userScaleFactor;
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
      manualScaleFactor = targetZoom;

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
    double targetZoom = zoomInside
        ? cropRotateEditorConfigs.doubleTapScaleFactor
        : 1;
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
        translate =
            startOffset +
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
    manualScaleFactor = targetZoom;
    translate = targetOffset;
    _setOffsetLimits();
    addHistory();
    _blockInteraction = false;
  }

  /// Re-fits the view so the crop selection always stays within the (possibly
  /// perspective-tilted) image.
  ///
  /// Returns `true` when the crop selection fits — directly, after panning, or
  /// after auto-zooming up to [CropRotateEditorConfigs.maxScale]. Returns
  /// `false` only when even the maximum zoom can't keep the selection covered;
  /// [tilt] uses this to reject (clamp) the offending tilt change so the
  /// selection never reveals empty area outside the image.
  bool _setOffsetLimits({Rect? rect}) {
    final Rect r = rect ?? _viewRect;
    final double imgW = _renderedImgConstraints.maxWidth;
    final double imgH = _renderedImgConstraints.maxHeight;
    if (imgW == 0 || imgH == 0) return true;

    if (!_isTilted) {
      // Fast path: axis-aligned clamp (unchanged behavior). Keep the manual
      // zoom floor in sync so a following tilt zooms relative to it.
      _clampTranslateAxisAligned(r);
      manualScaleFactor = userScaleFactor;
      return true;
    }

    // Tilted path: keep the crop rect inside the convex, tilted image quad,
    // auto-zooming (never below the manual zoom) and panning minimally.
    final fit = fitCropInsideTiltedImage(
      baseTiltCorners: _baseTiltCorners(),
      cropSize: r.size,
      minScale: manualScaleFactor,
      maxScale: cropRotateEditorConfigs.maxScale,
      currentTranslate: translate,
    );

    userScaleFactor = fit.scale;
    if (fit.fits) translate = fit.translate;
    return fit.fits;
  }

  /// Clamps [translate] so an untilted, scaled image still fully covers the
  /// crop rect [r].
  void _clampTranslateAxisAligned(Rect r) {
    final double minX =
        (_renderedImgConstraints.maxWidth * userScaleFactor - r.width) /
        2 /
        userScaleFactor;
    final double minY =
        (_renderedImgConstraints.maxHeight * userScaleFactor - r.height) /
        2 /
        userScaleFactor;

    final Offset offset = translate;
    if (offset.dx > minX) translate = Offset(minX, translate.dy);
    if (offset.dx < -minX) translate = Offset(-minX, translate.dy);
    if (offset.dy > minY) translate = Offset(translate.dx, minY);
    if (offset.dy < -minY) translate = Offset(translate.dx, -minY);
  }

  /// Returns the four image corners after applying *only* the current tilt
  /// (relative to the screen center, at scale `1`, no translation).
  ///
  /// These mirror the tilt transform applied to the live preview and the
  /// exported render, so the bounds math operates on exactly what the user
  /// sees.
  List<Offset> _baseTiltCorners() {
    final double imgW = _renderedImgConstraints.maxWidth;
    final double imgH = _renderedImgConstraints.maxHeight;
    final Offset center = Offset(imgW / 2, imgH / 2);
    final Matrix4 tiltMatrix = Matrix4.identity().tilt(
      rotate: tiltRotateAngle,
      vertical: tiltVerticalAngle,
      horizontal: tiltHorizontalAngle,
    );
    Offset corner(Offset p) =>
        MatrixUtils.transformPoint(tiltMatrix, p - center);
    return [
      corner(const Offset(0, 0)),
      corner(Offset(imgW, 0)),
      corner(Offset(imgW, imgH)),
      corner(Offset(0, imgH)),
    ];
  }

  void _mouseScroll(PointerSignalEvent event) async {
    // Check if interaction is blocked
    if (_blockInteraction) return;

    if (event is PointerScrollEvent) {
      // Define zoom factor and extract vertical scroll delta
      double factor =
          cropRotateEditorConfigs.mouseScaleFactor *
          (event.scrollDelta.dy / 50).abs().clamp(0.5, 2);

      double deltaY =
          event.scrollDelta.dy *
          (cropRotateEditorConfigs.invertMouseScroll ? -1 : 1);

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
      Offset centerOffset =
          translate +
          _getRealHitPoint(zoom: startZoom, position: event.localPosition) /
              startZoom;
      // Calculate the center offset point from the new zoomed view
      Offset centerZoomOffset = centerOffset * startZoom / newZoom;

      // Update translation and zoom values
      translate -= centerOffset - centerZoomOffset;
      userScaleFactor = newZoom;
      manualScaleFactor = newZoom;

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
    }

    _cursor = cursorNumber <= 3
        ? getCornerCursor(cursorNumber)
        : getSideCursor(cursorNumber - 4);
  }

  Offset _getRealHitPoint({required double zoom, required Offset position}) {
    return convertCropHitPoint(
      zoom: zoom,
      position: position,
      renderedImageSize: _renderedImgConstraints.biggest,
    );
  }

  @override
  Widget build(BuildContext context) {
    return TiltProvider(
      onTiltChangeUpdate: (mode, val) =>
          tilt(mode, val, updateStateHistory: false),
      onTiltChangeEnd: tilt,
      onToggleTiltBar: (isVisible) => setState(() {
        _isTiltEditorActive = isVisible;
      }),
      onUpdateResetCount: () {
        _tiltResetCount++;
        setState(() {});
      },
      tiltResetCount: _tiltResetCount,
      tiltHorizontal: tiltHorizontalAngle,
      tiltVertical: tiltVerticalAngle,
      tiltRotate: tiltRotateAngle,
      cropRotateConfigs: cropRotateEditorConfigs,
      i18n: i18n.cropRotateEditor,
      isTiltEditorVisible: _isTiltEditorActive,
      tiltMode: _tiltMode,
      child: SafeArea(
        top: cropRotateEditorConfigs.safeArea.top,
        bottom: cropRotateEditorConfigs.safeArea.bottom,
        left: cropRotateEditorConfigs.safeArea.left,
        right: cropRotateEditorConfigs.safeArea.right,
        child: RecordInvisibleWidget(
          controller: screenshotCtrl,
          child: ExtendedPopScope(
            canPop: cropRotateEditorConfigs.enableGesturePop,
            onPopInvokedWithResult: (didPop, _) {
              _showFakeHero = true;
              _updateAllStates();
            },
            child: LayoutBuilder(
              builder: (context, constraints) {
                _bodySize = constraints.biggest;
                return AnnotatedRegion<SystemUiOverlayStyle>(
                  value: cropRotateEditorConfigs.style.uiOverlayStyle,
                  child: Theme(
                    data: theme.copyWith(
                      tooltipTheme: theme.tooltipTheme.copyWith(
                        preferBelow: true,
                      ),
                    ),
                    child: MediaQuery.removePadding(
                      context: context,
                      removeBottom: !cropRotateEditorConfigs.safeArea.bottom,
                      child: Scaffold(
                        resizeToAvoidBottomInset: false,
                        backgroundColor:
                            cropRotateEditorConfigs.style.background,
                        appBar: _buildAppBar(constraints),
                        body: Stack(
                          children: [
                            Center(
                              child: SizedBox(
                                width:
                                    constraints.maxWidth *
                                    (cropRotateEditorConfigs.maxWidthFactor ??
                                        (!kIsWeb && Platform.isAndroid
                                            ? 0.9
                                            : 1)),
                                child: _buildBody(),
                              ),
                            ),
                            const Align(
                              alignment: Alignment.bottomCenter,
                              child: TiltRulerChooser(),
                            ),
                          ],
                        ),
                        bottomNavigationBar: _buildBottomAppBar(),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  /// Builds the app bar for the editor, including buttons for actions such as
  /// back, rotate, aspect ratio, and done.
  PreferredSizeWidget? _buildAppBar(BoxConstraints constraints) {
    if (cropRotateEditorConfigs.widgets.appBar != null) {
      return cropRotateEditorConfigs.widgets.appBar!.call(
        this,
        rebuildController.stream,
      );
    }
    return CropEditorAppbar(
      configs: configs.cropRotateEditor,
      i18n: i18n.cropRotateEditor,
      enableCloseButton: initConfigs.enableCloseButton,
      canUndo: canUndo,
      canRedo: canRedo,
      onDone: done,
      onClose: close,
      onUndo: undoAction,
      onRedo: redoAction,
    );
  }

  Widget? _buildBottomAppBar() {
    if (cropRotateEditorConfigs.widgets.bottomBar != null) {
      return cropRotateEditorConfigs.widgets.bottomBar!.call(
        this,
        rebuildController.stream,
      );
    }

    return tools.isNotEmpty
        ? CropEditorBottombar(
            bottomBarScrollCtrl: _bottomBarScrollCtrl,
            i18n: i18n.cropRotateEditor,
            configs: cropRotateEditorConfigs,
            theme: theme,
            tools: tools,
            onRotate: rotate,
            onFlip: flip,
            onOpenAspectRatioOptions: openAspectRatioOptions,
            onReset: reset,
            onTilt: () => setState(() => _isTiltEditorActive = true),
          )
        : null;
  }

  Widget _buildBody() {
    return _buildTiltBarScaleHelper(
      child: SafeArea(
        child: ScreenResizeDetector(
          ignoreSafeArea: false,
          onResizeUpdate: (event) {
            if (event.oldContentSize != event.newContentSize &&
                !event.oldContentSize.isEmpty) {
              _isScreenResized = true;
            }

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
            key: _editorContentKey,
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
                      child: PlatformCircularProgressIndicator(
                        configs: configs,
                      ),
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
              if (cropRotateEditorConfigs.widgets.bodyItems != null)
                ...cropRotateEditorConfigs.widgets.bodyItems!(
                  this,
                  rebuildController.stream,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMouseCursor({required Widget child}) {
    return ExtendedRebuildMouseRegion(
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

  Widget _buildFlipTransform({required Widget child}) {
    if (!cropRotateEditorConfigs.enableFlipAnimation) {
      return Transform.flip(flipX: flipX, flipY: flipY, child: child);
    }

    return TweenAnimationBuilder<double>(
      duration: cropRotateEditorConfigs.animationDuration,
      tween: Tween<double>(begin: 1.0, end: flipX ? -1.0 : 1.0),
      curve: cropRotateEditorConfigs.flipAnimationCurve,
      builder: (context, scaleX, child) {
        return TweenAnimationBuilder<double>(
          duration: cropRotateEditorConfigs.animationDuration,
          tween: Tween<double>(begin: 1.0, end: flipY ? -1.0 : 1.0),
          curve: cropRotateEditorConfigs.flipAnimationCurve,
          builder: (context, scaleY, child) {
            return Transform(
              alignment: Alignment.center,
              transform: Matrix4.diagonal3Values(scaleX, scaleY, 1),
              child: child,
            );
          },
          child: child,
        );
      },
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

  /// Applies the perspective/skew tilt to the live editor preview.
  ///
  /// Mirrors the tilt applied by [TransformedContentGenerator] (and used by the
  /// bounds math in [_setOffsetLimits]) so the preview, the exported render and
  /// the auto-zoom limits all agree.
  Widget _buildTiltTransform({required Widget child}) {
    if (tiltRotateAngle == 0 &&
        tiltVerticalAngle == 0 &&
        tiltHorizontalAngle == 0) {
      return child;
    }
    return Transform(
      alignment: Alignment.center,
      transform: Matrix4.identity().tilt(
        rotate: tiltRotateAngle,
        horizontal: tiltHorizontalAngle,
        vertical: tiltVerticalAngle,
      ),
      child: child,
    );
  }

  /// Scales the editor body up slightly so the bottom strip stays free for the
  /// tilt ruler bar while it is visible.
  Widget _buildTiltBarScaleHelper({required Widget child}) {
    final double barHeight = cropRotateEditorConfigs.style.tiltStyle.barHeight;

    final double factor = _isTiltEditorActive && _bodySize.height > barHeight
        ? (_bodySize.height - barHeight) / _bodySize.height
        : 1.0;

    return TweenAnimationBuilder<double>(
      duration: cropRotateEditorConfigs.animationDuration,
      tween: Tween<double>(begin: 1.0, end: factor),
      curve: cropRotateEditorConfigs.scaleAnimationCurve,
      builder: (_, scale, child) => Transform.scale(
        alignment: Alignment.topCenter,
        scale: scale,
        child: child,
      ),
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
      child: Padding(padding: EdgeInsets.all(_screenPadding), child: child),
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
          return _buildTiltTransform(
            child: Stack(
              fit: StackFit.expand,
              alignment: Alignment.center,
              children: [
                FilteredWidget(
                  filters: appliedFilters,
                  tuneAdjustments: appliedTuneAdjustments,
                  blurFactor: appliedBlurFactor,
                  configs: configs,
                  width: _imgWidth,
                  height: _imgHeight,
                  image: editorImage,
                  videoPlayer: videoController?.videoPlayer,
                  blankSize: initConfigs.mainImageSize,
                ),
                if (cropRotateEditorConfigs.showLayers &&
                    cropRotateEditorConfigs.enableTransformLayers &&
                    layers != null &&
                    !_isScreenResized)
                  ClipRRect(
                    clipBehavior: Clip.hardEdge,
                    child: LayerStack(
                      cutOutsideImageArea: false,
                      transformHelper: TransformHelper(
                        // set size to zero so no scale factor is applied
                        mainBodySize: Size.zero,
                        mainImageSize: Size.zero,
                        editorBodySize: originalSize,
                      ),
                      configs: configs,
                      layers: _rawLayers,
                      clipBehavior: Clip.none,
                      overlayColor: cropRotateEditorConfigs.style.background,
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildFakeHero() {
    return Padding(
      padding: EdgeInsets.all(_screenPadding),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Stack(
            alignment: Alignment.center,
            fit: StackFit.expand,
            children: [
              Hero(
                tag: heroTag,
                createRectTween: (begin, end) =>
                    RectTween(begin: begin, end: end),
                child: TransformedContentGenerator(
                  isVideoPlayer: videoController != null,
                  transformConfigs: _fakeHeroTransformConfigs,
                  configs: configs,
                  child: FilteredWidget(
                    width: _mainImageSize.width,
                    height: _mainImageSize.height,
                    configs: configs,
                    image: editorImage,
                    videoPlayer: videoController?.videoPlayer,
                    blankSize: initConfigs.mainImageSize,
                    filters: appliedFilters,
                    tuneAdjustments: appliedTuneAdjustments,
                    blurFactor: appliedBlurFactor,
                  ),
                ),
              ),
              if (cropRotateEditorConfigs.showLayers && layers != null)
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
                  overlayColor: cropRotateEditorConfigs.style.background,
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _screenshotWidget(TransformConfigs transformC) {
    Size size = _rotated90deg
        ? imageInfos!.rawSize.flipped
        : imageInfos!.rawSize;

    double w = size.width;
    double h = size.height;
    return SizedBox(
      width: w,
      height: h,
      child: TransformedContentGenerator(
        isVideoPlayer: videoController != null,
        transformConfigs: transformC,
        configs: configs,
        child: FilteredWidget(
          width: w,
          height: h,
          configs: configs,
          image: editorImage,
          videoPlayer: isVideoEditor && initConfigs.convertToUint8List
              ? const SizedBox.shrink()
              : videoController?.videoPlayer,
          blankSize: initConfigs.mainImageSize,
          filters: appliedFilters,
          tuneAdjustments: appliedTuneAdjustments,
          blurFactor: appliedBlurFactor,
        ),
      ),
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);

    properties
      // General configuration
      ..add(
        DiagnosticsProperty<CropRotateEditorInitConfigs>(
          'initConfigs',
          widget.initConfigs,
        ),
      )
      ..add(
        DiagnosticsProperty<EditorImage?>('editorImage', widget.editorImage),
      )
      ..add(
        DiagnosticsProperty<ProVideoController?>(
          'videoController',
          widget.videoController,
        ),
      )
      // Crop/Transform state
      ..add(
        DiagnosticsProperty<TransformConfigs>('activeHistory', activeHistory),
      )
      ..add(IntProperty('rotationCount', rotationCount))
      ..add(FlagProperty('flipX', value: flipX, ifTrue: 'flipped X'))
      ..add(FlagProperty('flipY', value: flipY, ifTrue: 'flipped Y'))
      ..add(DoubleProperty('aspectRatio', aspectRatio))
      ..add(EnumProperty<CropMode>('cropMode', cropMode))
      ..add(DoubleProperty('userScaleFactor', userScaleFactor))
      ..add(DoubleProperty('oldScaleFactor', oldScaleFactor))
      ..add(DoubleProperty('rotationScaleFactor', _rotationScaleFactor))
      ..add(DiagnosticsProperty<Offset>('translate', translate))
      ..add(DiagnosticsProperty<Rect>('cropRect', cropRect))
      ..add(DiagnosticsProperty<Rect>('viewRect', _viewRect))
      // Status flags
      ..add(
        FlagProperty(
          'showFakeHero',
          value: _showFakeHero,
          ifTrue: 'showing fake hero',
        ),
      )
      ..add(
        FlagProperty(
          'enableFakeHero',
          value: enableFakeHero,
          ifTrue: 'fake hero enabled',
        ),
      )
      ..add(
        FlagProperty(
          'imageNeedDecode',
          value: _imageNeedDecode,
          ifTrue: 'image needs decode',
        ),
      )
      ..add(
        FlagProperty(
          'imageSizeIsDecoded',
          value: _imageSizeIsDecoded,
          ifTrue: 'image size decoded',
        ),
      )
      ..add(
        FlagProperty(
          'interactionActive',
          value: _interactionActive,
          ifTrue: 'interaction active',
        ),
      )
      ..add(
        FlagProperty(
          'scaleStarted',
          value: _scaleStarted,
          ifTrue: 'scale started',
        ),
      )
      // Sizes
      ..add(DiagnosticsProperty<Size>('editorBodySize', editorBodySize))
      ..add(DiagnosticsProperty<Size>('mainImageSize', _mainImageSize))
      ..add(DiagnosticsProperty<Size>('renderedImgSize', _renderedImgSize))
      ..add(
        DiagnosticsProperty<BoxConstraints>(
          'renderedImgConstraints',
          _renderedImgConstraints,
        ),
      )
      // Input
      ..add(DiagnosticsProperty<MouseCursor>('mouseCursor', _mouseCursor))
      ..add(IntProperty('activePointers', _activePointers));
  }
}
