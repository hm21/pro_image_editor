import 'dart:async';
import 'dart:math';

// Flutter imports:
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '/core/constants/image_constants.dart';
import '/core/mixins/converted_callbacks.dart';
import '/core/mixins/converted_configs.dart';
import '/core/mixins/standalone_editor.dart';
import '/core/models/transform_helper.dart';
import '/core/utils/size_utils.dart';
import '/features/paint_editor/widgets/paint_editor_appbar.dart';
import '/features/paint_editor/widgets/paint_editor_bottombar.dart';
import '/features/paint_editor/widgets/paint_editor_color_picker.dart';
import '/pro_image_editor.dart';
import '/shared/mixins/editor_zoom.mixin.dart';
import '/shared/services/content_recorder/widgets/content_recorder.dart';
import '/shared/services/shader_manager.dart';
import '/shared/styles/platform_text_styles.dart';
import '/shared/utils/file_constructor_utils.dart';
import '/shared/widgets/auto_image.dart';
import '/shared/widgets/extended/interactive_viewer/extended_interactive_viewer.dart';
import '/shared/widgets/layer/layer_stack.dart';
import '/shared/widgets/slider_bottom_sheet.dart';
import '/shared/widgets/transform/transformed_content_generator.dart';
import '../filter_editor/widgets/filtered_widget.dart';
import '../main_editor/services/layer_copy_manager.dart';
import 'controllers/paint_controller.dart';
import 'models/paint_editor_response_model.dart';
import 'services/paint_desktop_interaction_manager.dart';
import 'widgets/paint_canvas.dart';

export 'enums/paint_editor_enum.dart';
export 'models/paint_bottom_bar_item.dart';
export 'models/painted_model.dart';
export 'widgets/draw_paint_item.dart';

/// The `PaintEditor` widget allows users to editing images with paint
/// tools.
///
/// You can create a `PaintEditor` using one of the factory methods provided:
/// - `PaintEditor.file`: Loads an image from a file.
/// - `PaintEditor.asset`: Loads an image from an asset.
/// - `PaintEditor.network`: Loads an image from a network URL.
/// - `PaintEditor.memory`: Loads an image from memory as a `Uint8List`.
/// - `PaintEditor.autoSource`: Automatically selects the source based on
/// provided parameters.
class PaintEditor extends StatefulWidget
    with StandaloneEditor<PaintEditorInitConfigs> {
  /// Constructs a `PaintEditor` widget.
  ///
  /// The [key] parameter is used to provide a key for the widget.
  /// The [editorImage] parameter specifies the image to be edited.
  /// The [videoController] parameter specifies the video to be edited.
  /// The [initConfigs] parameter specifies the initialization configurations
  /// for the editor.
  const PaintEditor._({
    super.key,
    required this.initConfigs,
    this.paintOnly = false,
    this.editorImage,
    this.videoController,
  }) : assert(editorImage != null || videoController != null,
            'Either editorImage or videoController must be provided.');

  /// Constructs a `PaintEditor` widget with image data loaded from memory.
  factory PaintEditor.memory(
    Uint8List byteArray, {
    Key? key,
    required PaintEditorInitConfigs initConfigs,
  }) {
    return PaintEditor._(
      key: key,
      editorImage: EditorImage(byteArray: byteArray),
      initConfigs: initConfigs,
    );
  }

  /// Constructs a `PaintEditor` widget with an image loaded from a file.
  factory PaintEditor.file(
    dynamic file, {
    Key? key,
    required PaintEditorInitConfigs initConfigs,
  }) {
    return PaintEditor._(
      key: key,
      editorImage: EditorImage(file: ensureFileInstance(file)),
      initConfigs: initConfigs,
    );
  }

  /// Constructs a `PaintEditor` widget with an image loaded from an asset.
  factory PaintEditor.asset(
    String assetPath, {
    Key? key,
    required PaintEditorInitConfigs initConfigs,
  }) {
    return PaintEditor._(
      key: key,
      editorImage: EditorImage(assetPath: assetPath),
      initConfigs: initConfigs,
    );
  }

  /// Constructs a `PaintEditor` widget with an image loaded from a network
  /// URL.
  factory PaintEditor.network(
    String networkUrl, {
    Key? key,
    required PaintEditorInitConfigs initConfigs,
  }) {
    return PaintEditor._(
      key: key,
      editorImage: EditorImage(networkUrl: networkUrl),
      initConfigs: initConfigs,
    );
  }

  /// Constructs a `PaintEditor` widget optimized for drawing purposes.
  factory PaintEditor.drawing({
    Key? key,
    required PaintEditorInitConfigs initConfigs,
  }) {
    assert(
      !initConfigs.configs.imageGeneration.cropToImageBounds,
      '`cropToImageBounds` must be set to false in `imageGeneration` when '
      'using `PaintEditor.drawing`.',
    );

    return PaintEditor._(
      key: key,
      editorImage: EditorImage(byteArray: kImageEditorTransparentBytes),
      initConfigs: initConfigs,
      paintOnly: true,
    );
  }

  /// Constructs a `PaintEditor` widget with an image loaded automatically
  /// based on the provided source.
  ///
  /// Either [byteArray], [file], [networkUrl], or [assetPath] must be provided.
  factory PaintEditor.autoSource({
    Key? key,
    Uint8List? byteArray,
    dynamic file,
    String? assetPath,
    String? networkUrl,
    EditorImage? editorImage,
    ProVideoController? videoController,
    required PaintEditorInitConfigs initConfigs,
  }) {
    return PaintEditor._(
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

  /// Constructs a `PaintEditor` widget with an video player.
  factory PaintEditor.video(
    ProVideoController videoController, {
    Key? key,
    required PaintEditorInitConfigs initConfigs,
  }) {
    return PaintEditor._(
      key: key,
      videoController: videoController,
      initConfigs: initConfigs,
    );
  }

  @override
  final PaintEditorInitConfigs initConfigs;
  @override
  final EditorImage? editorImage;
  @override
  final ProVideoController? videoController;

  /// A flag indicating whether only paint operations are allowed.
  final bool paintOnly;

  @override
  State<PaintEditor> createState() => PaintEditorState();
}

/// State class for managing the paint editor, handling user interactions
/// and paint operations.
class PaintEditorState extends State<PaintEditor>
    with
        ImageEditorConvertedConfigs,
        ImageEditorConvertedCallbacks,
        StandaloneEditorState<PaintEditor, PaintEditorInitConfigs>,
        EditorZoomMixin {
  final _paintCanvas = GlobalKey<PaintCanvasState>();
  @override
  final interactiveViewer = GlobalKey<ExtendedInteractiveViewerState>();

  /// Controller for managing paint operations within the widget's context.
  late final PaintController paintCtrl;

  /// Update the color picker.
  late final StreamController<void> uiPickerStream;

  /// Update the appbar icons.
  late final StreamController<void> _uiAppbarStream;

  /// Update the layer stack.
  late final StreamController<void> _layerStackStream;

  /// A ScrollController for controlling the scrolling behavior of the bottom
  /// navigation bar.
  late ScrollController _bottomBarScrollCtrl;

  /// A boolean flag representing whether the fill mode is enabled or disabled.
  bool _isFillMode = false;

  /// Get the fillBackground status.
  bool get fillBackground => _isFillMode;

  /// Determines whether the user draw something.
  bool get isActive => paintCtrl.busy;

  /// Manager class for handling desktop interactions.
  late final PaintDesktopInteractionManager _desktopInteractionManager;

  /// Get the current PaintMode.
  PaintMode get paintMode => paintCtrl.mode;

  /// Get the current strokeWidth.
  double get strokeWidth => paintCtrl.strokeWidth;

  /// Get the active selected color.
  Color get activeColor => paintCtrl.color;

  /// A list of [PaintModeBottomBarItem] representing the available drawing
  /// modes in the paint editor.
  /// The list is dynamically generated based on the configuration settings in
  /// the [PaintEditorConfigs] object.
  List<PaintModeBottomBarItem> get paintModes => [
        if (paintEditorConfigs.enableModeFreeStyle)
          PaintModeBottomBarItem(
            mode: PaintMode.freeStyle,
            icon: paintEditorConfigs.icons.freeStyle,
            label: i18n.paintEditor.freestyle,
          ),
        if (paintEditorConfigs.enableModeArrow)
          PaintModeBottomBarItem(
            mode: PaintMode.arrow,
            icon: paintEditorConfigs.icons.arrow,
            label: i18n.paintEditor.arrow,
          ),
        if (paintEditorConfigs.enableModeLine)
          PaintModeBottomBarItem(
            mode: PaintMode.line,
            icon: paintEditorConfigs.icons.line,
            label: i18n.paintEditor.line,
          ),
        if (paintEditorConfigs.enableModeRect)
          PaintModeBottomBarItem(
            mode: PaintMode.rect,
            icon: paintEditorConfigs.icons.rectangle,
            label: i18n.paintEditor.rectangle,
          ),
        if (paintEditorConfigs.enableModeCircle)
          PaintModeBottomBarItem(
            mode: PaintMode.circle,
            icon: paintEditorConfigs.icons.circle,
            label: i18n.paintEditor.circle,
          ),
        if (paintEditorConfigs.enableModeDashLine)
          PaintModeBottomBarItem(
            mode: PaintMode.dashLine,
            icon: paintEditorConfigs.icons.dashLine,
            label: i18n.paintEditor.dashLine,
          ),
        if (paintEditorConfigs.enableModePolygon)
          PaintModeBottomBarItem(
            mode: PaintMode.polygon,
            icon: paintEditorConfigs.icons.polygon,
            label: i18n.paintEditor.polygon,
          ),
        if (paintEditorConfigs.enableModePixelate &&
            ShaderManager.instance.isShaderFilterSupported)
          PaintModeBottomBarItem(
            mode: PaintMode.pixelate,
            icon: paintEditorConfigs.icons.pixelate,
            label: i18n.paintEditor.pixelate,
          ),
        if (paintEditorConfigs.enableModeBlur)
          PaintModeBottomBarItem(
            mode: PaintMode.blur,
            icon: paintEditorConfigs.icons.blur,
            label: i18n.paintEditor.blur,
          ),
        if (paintEditorConfigs.enableModeEraser)
          PaintModeBottomBarItem(
            mode: PaintMode.eraser,
            icon: paintEditorConfigs.icons.eraser,
            label: i18n.paintEditor.eraser,
          ),
      ];

  /// The Uint8List from the fake hero image, which is drawn when finish
  /// editing.
  Uint8List? _fakeHeroBytes;

  /// Indicates whether the editor supports zoom functionality.
  bool get _enableZoom => paintEditorConfigs.enableZoom;

  /// A pointer to track the current position in the history stack.
  /// This is used to manage undo and redo operations in the paint editor.
  int historyPointer = 0;

  /// A list that maintains the history of layer states in the paint editor.
  ///
  /// This list is initialized with the current layers if
  /// `paintEditorConfigs.showLayers` is true; otherwise, it starts as an
  ///  empty list. Each entry in the list represents a snapshot of the layer
  /// states at a specific point in time.
  late final List<PaintEditorResponse> stateHistory = [
    PaintEditorResponse(
      layers: paintEditorConfigs.showLayers ? [...(layers ?? [])] : [],
      removedLayers: [],
    ),
  ];

  /// A getter that retrieves the list of active layers from the current state
  /// in the history stack, based on the current `historyPointer`.
  ///
  /// The `_stateHistory` is a list of states, where each state contains a list
  /// of `Layer` objects. The `historyPointer` determines which state in the
  /// history is currently active.
  PaintEditorResponse get activeHistory => stateHistory[historyPointer];

  /// Determines whether undo can be performed on the current state.
  bool get canUndo => historyPointer > 0;

  /// Determines whether redo can be performed on the current state.
  bool get canRedo => historyPointer + 1 < stateHistory.length;

  @override
  void initState() {
    super.initState();
    paintCtrl = PaintController(
      fill: paintEditorConfigs.isInitiallyFilled,
      mode: paintEditorConfigs.initialPaintMode,
      strokeWidth: paintEditorConfigs.style.initialStrokeWidth,
      color: paintEditorConfigs.style.initialColor,
      opacity: paintEditorConfigs.style.initialOpacity,
      strokeMultiplier: 1,
    );

    _isFillMode = paintEditorConfigs.isInitiallyFilled;

    initStreamControllers();

    _bottomBarScrollCtrl = ScrollController();
    _desktopInteractionManager =
        PaintDesktopInteractionManager(context: context);
    ServicesBinding.instance.keyboard.addHandler(_onKeyEvent);

    /// Important to set state after view init to set action icons
    paintEditorCallbacks?.onInit?.call();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      paintEditorCallbacks?.onAfterViewInit?.call();
      setState(() {});
      paintEditorCallbacks?.handleUpdateUI();
    });

    /// Preload pixelate shader if enabled and supported
    if (paintEditorConfigs.enableModePixelate &&
        ShaderManager.instance.isShaderFilterSupported) {
      ShaderManager.instance.loadShader(ShaderMode.pixelate);
    }
  }

  @override
  void dispose() {
    paintCtrl.dispose();
    _bottomBarScrollCtrl.dispose();
    uiPickerStream.close();
    _uiAppbarStream.close();
    _layerStackStream.close();
    screenshotCtrl.destroy();
    ServicesBinding.instance.keyboard.removeHandler(_onKeyEvent);
    super.dispose();
  }

  @override
  void setState(void Function() fn) {
    rebuildController.add(null);
    super.setState(fn);
  }

  /// Initializes stream controllers for managing UI updates.
  void initStreamControllers() {
    uiPickerStream = StreamController.broadcast();
    _uiAppbarStream = StreamController.broadcast();
    _layerStackStream = StreamController.broadcast();

    uiPickerStream.stream.listen((_) => rebuildController.add(null));
    _uiAppbarStream.stream.listen((_) => rebuildController.add(null));
    _layerStackStream.stream.listen((_) => rebuildController.add(null));
  }

  /// Handle keyboard events
  bool _onKeyEvent(KeyEvent event) {
    return _desktopInteractionManager.onKey(
      event,
      onUndoRedo: (undo) {
        if (undo) {
          undoAction();
        } else {
          redoAction();
        }
      },
    );
  }

  /// Opens a bottom sheet to adjust the line weight when drawing.
  void openLinWidthBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: paintEditorConfigs.style.lineWidthBottomSheetBackground,
      builder: (BuildContext context) => SliderBottomSheet<PaintEditorState>(
        title: i18n.paintEditor.lineWidth,
        headerTextStyle: paintEditorConfigs.style.lineWidthBottomSheetTitle,
        max: configs.paintEditor.maxStrokeWidth,
        min: configs.paintEditor.minStrokeWidth,
        divisions: configs.paintEditor.divisionsStrokeWidth,
        closeButton: paintEditorConfigs.widgets.lineWidthCloseButton,
        customSlider: paintEditorConfigs.widgets.sliderLineWidth,
        state: this,
        value: paintCtrl.strokeWidth,
        designMode: designMode,
        theme: theme,
        rebuildController: rebuildController,
        onValueChanged: (value) {
          setStrokeWidth(value);
        },
      ),
    );
  }

  /// Opens a bottom sheet to adjust the opacity when drawing.
  void openOpacityBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: paintEditorConfigs.style.opacityBottomSheetBackground,
      builder: (BuildContext context) => SliderBottomSheet<PaintEditorState>(
        title: i18n.paintEditor.changeOpacity,
        headerTextStyle: paintEditorConfigs.style.opacityBottomSheetTitle,
        max: paintEditorConfigs.maxOpacity,
        min: paintEditorConfigs.minOpacity,
        divisions: paintEditorConfigs.divisionsOpacity,
        closeButton: paintEditorConfigs.widgets.changeOpacityCloseButton,
        customSlider: paintEditorConfigs.widgets.sliderChangeOpacity,
        state: this,
        value: paintCtrl.opacity,
        designMode: designMode,
        theme: theme,
        rebuildController: rebuildController,
        onValueChanged: (value) {
          setOpacity(value);
        },
      ),
    );
  }

  /// Sets the fill mode for drawing elements.
  /// When the `fill` parameter is `true`, drawing elements will be filled;
  /// otherwise, they will be outlined.
  void setFill(bool fill) {
    _isFillMode = fill;
    paintCtrl.setFill(fill);
    _uiAppbarStream.add(null);
    paintEditorCallbacks?.handleToggleFill(fill);
  }

  /// Sets the opacity for drawing elements.
  ///
  /// The opacity must be between 0 and 1.
  void setOpacity(double value) {
    paintCtrl.setOpacity(value);
    _uiAppbarStream.add(null);
    paintEditorCallbacks?.handleOpacity(value);
  }

  /// Gets the current opacity value from the paint controller.
  double get opacity => paintCtrl.opacity;

  /// Sets the opacity value using the [setOpacity] method.
  ///
  /// The [value] parameter specifies the new opacity to be set.
  set opacity(double value) => setOpacity(value);

  /// Toggles the fill mode.
  void toggleFill() {
    _isFillMode = !_isFillMode;
    setFill(_isFillMode);
    rebuildController.add(null);
  }

  /// Set the PaintMode for the current state and trigger an update if provided.
  void setMode(PaintMode mode) {
    paintCtrl.setMode(mode);
    paintEditorCallbacks?.handlePaintModeChanged(mode);
    rebuildController.add(null);
    interactiveViewer.currentState?.setEnableInteraction(
      mode == PaintMode.moveAndZoom,
    );
    _paintCanvas.currentState?.setState(() {});
    setState(() {});
  }

  /// Undoes the last action performed in the paint editor.
  void undoAction() {
    if (canUndo) {
      screenshotHistoryPosition--;
      historyPointer--;
    }
    _uiAppbarStream.add(null);
    setState(() {});
    paintEditorCallbacks?.handleUndo();
  }

  /// Redoes the previously undone action in the paint editor.
  void redoAction() {
    if (canRedo) {
      screenshotHistoryPosition++;
      historyPointer++;
    }
    _uiAppbarStream.add(null);
    setState(() {});
    paintEditorCallbacks?.handleRedo();
  }

  /// Finishes editing in the paint editor and returns the painted items as
  /// a result.
  /// If no changes have been made, it closes the editor without returning any
  /// changes.
  void done() async {
    doneEditing(
      editorImage: widget.editorImage,
      onSetFakeHero: (bytes) {
        if (initConfigs.enableFakeHero) {
          setState(() {
            _fakeHeroBytes = bytes;
          });
        }
      },
      onCloseWithValue: () {
        if (!canUndo) return Navigator.pop(context);

        final scale = _layerStackTransformHelper.scale;

        final originalLayers =
            (widget.initConfigs.layers ?? []).whereType<PaintLayer>().toList();
        final newLayers =
            activeHistory.layers.whereType<PaintLayer>().where((layer) {
          return originalLayers.indexWhere(
                (el) =>
                    el.id == layer.id &&
                    listEquals(el.item.erasedOffsets, layer.item.erasedOffsets),
              ) <
              0;
        });
        final transformedLayers = newLayers.map((layer) {
          return layer
            ..offset *= scale
            ..scale *= scale;
        }).toList();
        Navigator.of(context).pop(PaintEditorResponse(
          layers: transformedLayers,
          removedLayers: activeHistory.removedLayers,
        ));
      },
      blur: appliedBlurFactor,
      matrixFilterList: appliedFilters,
      matrixTuneAdjustmentsList:
          appliedTuneAdjustments.map((item) => item.matrix).toList(),
      transform: initialTransformConfigs,
    );
    paintEditorCallbacks?.handleDone();
  }

  /// Adds a painted model as a new layer to the editor.
  ///
  /// Transforms the given [item] into a layer and adds it to the editor.
  void addPainting(PaintedModel item) {
    addLayer(_transformPaintedModelToLayer(item));
  }

  /// Adds a new layer to the active layers and updates the state history.
  /// Clears any redo history before adding the new layer.
  ///
  /// [layer] The layer to be added.
  void addLayer(Layer layer) {
    while (canRedo) {
      stateHistory.removeLast();
    }

    stateHistory.add(
      PaintEditorResponse(
        layers: [...activeHistory.layers, layer],
        removedLayers: [...activeHistory.removedLayers],
      ),
    );
    historyPointer++;
    _layerStackStream.add(null);
  }

  TransformHelper get _layerStackTransformHelper {
    return TransformHelper(
      mainBodySize: getValidSizeOrDefault(mainBodySize, editorBodySize),
      mainImageSize: getValidSizeOrDefault(mainImageSize, editorBodySize),
      editorBodySize: editorBodySize,
      transformConfigs: initialTransformConfigs,
    );
  }

  PaintLayer _transformPaintedModelToLayer(PaintedModel rawLayer) {
    Rect findRenderedLayerRect(List<Offset?> points) {
      if (points.isEmpty) return Rect.zero;

      double leftmostX = double.infinity;
      double topmostY = double.infinity;
      double rightmostX = double.negativeInfinity;
      double bottommostY = double.negativeInfinity;

      for (final point in points) {
        if (point != null) {
          if (point.dx < leftmostX) {
            leftmostX = point.dx;
          }
          if (point.dy < topmostY) {
            topmostY = point.dy;
          }
          if (point.dx > rightmostX) {
            rightmostX = point.dx;
          }
          if (point.dy > bottommostY) {
            bottommostY = point.dy;
          }
        }
      }

      return Rect.fromPoints(
        Offset(leftmostX, topmostY),
        Offset(rightmostX, bottommostY),
      );
    }

    final mainEditorSizeFactor = 1 / _layerStackTransformHelper.scale;

    PaintedModel layer = PaintedModel(
      mode: rawLayer.mode,
      offsets: [...rawLayer.offsets],
      erasedOffsets: [...rawLayer.erasedOffsets],
      color: rawLayer.color,
      strokeWidth: rawLayer.strokeWidth,
      fill: rawLayer.fill,
      opacity: rawLayer.opacity,
    );

    // Find extreme points of the paint layer
    Rect? layerRect = findRenderedLayerRect(rawLayer.offsets);

    Size size = layerRect.size;

    bool onlyStrokeMode = rawLayer.mode == PaintMode.freeStyle ||
        rawLayer.mode == PaintMode.line ||
        rawLayer.mode == PaintMode.dashLine ||
        rawLayer.mode == PaintMode.arrow ||
        ((rawLayer.mode == PaintMode.polygon ||
                rawLayer.mode == PaintMode.rect ||
                rawLayer.mode == PaintMode.circle) &&
            !rawLayer.fill);

    // Scale and offset the offsets of the paint layer
    double strokeHelperWidth = onlyStrokeMode ? rawLayer.strokeWidth : 0;

    for (int i = 0; i < layer.offsets.length; i++) {
      Offset? point = layer.offsets[i];
      if (point != null) {
        layer.offsets[i] = Offset(
          point.dx - layerRect.left + strokeHelperWidth / 2,
          point.dy - layerRect.top + strokeHelperWidth / 2,
        );
      }
    }

    // Calculate the final offset of the paint layer
    Offset finalOffset = Offset(
      layerRect.center.dx - editorBodySize.width / 2,
      layerRect.center.dy - editorBodySize.height / 2,
    );

    if (onlyStrokeMode) {
      size = Size(
        size.width + strokeHelperWidth,
        size.height + strokeHelperWidth,
      );
    }

    // Create and return a PaintLayer instance for the exported layer
    return PaintLayer(
      id: layer.id,
      item: layer.copy(),
      rawSize: Size(
        max(size.width, layer.strokeWidth),
        max(size.height, layer.strokeWidth),
      ),
      opacity: layer.opacity,
      offset: finalOffset * mainEditorSizeFactor,
      scale: mainEditorSizeFactor,
    );
  }

  /// Set the stroke width.
  void setStrokeWidth(double value) {
    paintCtrl.setStrokeWidth(value);
    rebuildController.add(null);
    callbacks.paintEditorCallbacks?.handleLineWidthChanged(value);
    setState(() {});
  }

  /// Handles changes in the selected color.
  @Deprecated('Use [setColor] instead')
  void colorChanged(Color color) {
    setColor(color);
  }

  /// Sets the current color for the paint editor.
  ///
  /// This method updates the color in the paint controller, triggers the
  /// UI picker stream to notify listeners, and invokes the callback
  /// for handling color changes if it is defined.
  ///
  /// - Parameters:
  ///   - color: The new color to be set.
  void setColor(Color color) {
    paintCtrl.setColor(color);
    uiPickerStream.add(null);
    paintEditorCallbacks?.handleColorChanged();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: paintEditorConfigs.style.uiOverlayStyle,
      child: ExtendedPopScope(
        child: Theme(
          data: theme.copyWith(
              tooltipTheme: theme.tooltipTheme.copyWith(preferBelow: true)),
          child: SafeArea(
            top: paintEditorConfigs.safeArea.top,
            bottom: paintEditorConfigs.safeArea.bottom,
            left: paintEditorConfigs.safeArea.left,
            right: paintEditorConfigs.safeArea.right,
            child: RecordInvisibleWidget(
              controller: screenshotCtrl,
              child: LayoutBuilder(builder: (context, constraints) {
                return Scaffold(
                  resizeToAvoidBottomInset: false,
                  backgroundColor: paintEditorConfigs.style.background,
                  appBar: _buildAppBar(constraints),
                  body: _buildBody(),
                  bottomNavigationBar: _buildBottomBar(),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }

  /// Builds the app bar for the paint editor.
  /// Returns a [PreferredSizeWidget] representing the app bar.
  PreferredSizeWidget? _buildAppBar(BoxConstraints constraints) {
    if (paintEditorConfigs.widgets.appBar != null) {
      return paintEditorConfigs.widgets.appBar!
          .call(this, rebuildController.stream);
    }

    return ReactiveAppbar(
      stream: _uiAppbarStream.stream,
      builder: (context) => PaintEditorAppBar(
        paintEditorConfigs: paintEditorConfigs,
        i18n: i18n.paintEditor,
        constraints: constraints,
        onUndo: undoAction,
        onRedo: redoAction,
        onToggleFill: toggleFill,
        onTapMenuFill: () {
          _isFillMode = !_isFillMode;
          setFill(_isFillMode);
          if (designMode == ImageEditorDesignMode.cupertino) {
            Navigator.pop(context);
          }
        },
        onDone: done,
        onClose: close,
        canRedo: canRedo,
        canUndo: canUndo,
        isFillMode: _isFillMode,
        onOpenOpacityBottomSheet: openOpacityBottomSheet,
        onOpenLineWeightBottomSheet: openLinWidthBottomSheet,
        designMode: designMode,
      ),
    );
  }

  /// Builds the main body of the paint editor.
  /// Returns a [Widget] representing the editor's body.
  Widget _buildBody() {
    return LayoutBuilder(builder: (context, constraints) {
      editorBodySize = constraints.biggest;
      return Theme(
        data: theme,
        child: Material(
          color:
              initConfigs.convertToUint8List && initConfigs.convertToUint8List
                  ? paintEditorConfigs.style.background
                  : Colors.transparent,
          textStyle: platformTextStyle(context, designMode),
          child: Stack(
            alignment: Alignment.center,
            fit: StackFit.expand,
            children: _fakeHeroBytes != null
                ? _buildFakeHero()
                : _buildInteractiveContent(),
          ),
        ),
      );
    });
  }

  List<Widget> _buildFakeHero() {
    return [
      Hero(
        tag: configs.heroTag,
        child: AutoImage(
          EditorImage(byteArray: _fakeHeroBytes),
          configs: configs,
        ),
      ),
    ];
  }

  List<Widget> _buildInteractiveContent() {
    return [
      Listener(
        behavior: HitTestBehavior.translucent,
        onPointerDown: (details) {
          bool isDoubleTap = detectDoubleTap(details);
          if (!isDoubleTap) return;

          handleDoubleTap(context, details, paintEditorConfigs);
          paintEditorCallbacks?.onDoubleTap?.call();
        },
        onPointerUp: onPointerUp,
        child: ExtendedInteractiveViewer(
          key: interactiveViewer,
          initialMatrix4: paintEditorConfigs.enableShareZoomMatrix
              ? initConfigs.initialZoomMatrix
              : null,
          zoomConfigs: paintEditorConfigs,
          enableInteraction: paintMode == PaintMode.moveAndZoom,
          onInteractionStart: (details) {
            callbacks.paintEditorCallbacks?.onEditorZoomScaleStart
                ?.call(details);
            setState(() {});
          },
          onInteractionUpdate:
              callbacks.paintEditorCallbacks?.onEditorZoomScaleUpdate,
          onInteractionEnd: (details) {
            callbacks.paintEditorCallbacks?.onEditorZoomScaleEnd?.call(details);
            setState(() {});
          },
          onMatrix4Change:
              callbacks.paintEditorCallbacks?.onEditorZoomMatrix4Change,
          child: Stack(
            alignment: Alignment.center,
            fit: StackFit.expand,
            children: [
              if (initConfigs.convertToUint8List && isVideoEditor)
                _buildBackground(),
              ContentRecorder(
                autoDestroyController: false,
                controller: screenshotCtrl,
                child: Stack(
                  alignment: Alignment.center,
                  fit: StackFit.expand,
                  children: [
                    if (!widget.paintOnly)
                      if (!initConfigs.convertToUint8List || !isVideoEditor)
                        _buildBackground()
                      else
                        SizedBox(
                          width: configs.imageGeneration.maxOutputSize.width,
                          height: configs.imageGeneration.maxOutputSize.height,
                        ),

                    /// Build layers

                    StreamBuilder(
                      stream: _layerStackStream.stream,
                      builder: (context, asyncSnapshot) {
                        if (!paintEditorConfigs.showLayers ||
                            activeHistory.layers.isEmpty) {
                          return const SizedBox.shrink();
                        }

                        return LayerStack(
                          configs: configs,
                          layers: activeHistory.layers,
                          transformHelper: _layerStackTransformHelper,
                          overlayColor: paintEditorConfigs.style.background,
                          clipBehavior: Clip.none,
                          enableLayerKey: true,
                        );
                      },
                    ),
                    _buildPainter(),
                    if (paintEditorConfigs.widgets.bodyItemsRecorded != null)
                      ...paintEditorConfigs.widgets.bodyItemsRecorded!(
                          this, rebuildController.stream),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),

      /// Build Color picker
      PaintEditorColorPicker(
        state: this,
        configs: configs,
        rebuildController: rebuildController,
      ),
      if (paintEditorConfigs.widgets.bodyItems != null)
        ...paintEditorConfigs.widgets.bodyItems!(
            this, rebuildController.stream),
    ];
  }

  Widget _buildBackground() {
    return TransformedContentGenerator(
      isVideoPlayer: videoController != null,
      configs: configs,
      transformConfigs: initialTransformConfigs ?? TransformConfigs.empty(),
      child: FilteredWidget(
        width: getValidSizeOrDefault(mainImageSize, editorBodySize).width,
        height: getValidSizeOrDefault(mainImageSize, editorBodySize).height,
        configs: configs,
        image: editorImage,
        videoPlayer: videoController?.videoPlayer,
        filters: appliedFilters,
        tuneAdjustments: appliedTuneAdjustments,
        blurFactor: appliedBlurFactor,
      ),
    );
  }

  /// Builds the bottom navigation bar of the paint editor.
  /// Returns a [Widget] representing the bottom navigation bar.
  Widget? _buildBottomBar() {
    if (paintEditorConfigs.widgets.bottomBar != null) {
      return paintEditorConfigs.widgets.bottomBar!
          .call(this, rebuildController.stream);
    }

    if (paintModes.length <= 1) return const SizedBox.shrink();

    return PaintEditorBottombar(
      configs: configs.paintEditor,
      paintMode: paintMode,
      i18n: i18n.paintEditor,
      theme: theme,
      enableZoom: _enableZoom,
      paintModes: paintModes,
      setMode: setMode,
      bottomBarScrollCtrl: _bottomBarScrollCtrl,
    );
  }

  /// Builds the paint canvas for the editor.
  /// Returns a [Widget] representing the paint canvas.
  Widget _buildPainter() {
    return PaintCanvas(
      key: _paintCanvas,
      paintCtrl: paintCtrl,
      paintEditorConfigs: paintEditorConfigs,
      drawAreaSize: mainBodySize ?? editorBodySize,
      editorBodySize: editorBodySize,
      layerStackScaleFactor: _layerStackTransformHelper.scale,
      layers: activeHistory.layers,
      onTap: (details) =>
          callbacks.paintEditorCallbacks?.onTap?.call(this, details),
      onRemoveLayer: (removeIdList) {
        final removeIdSet = removeIdList.toSet();
        final updatedList = <Layer>[];
        final removedLayers = <Layer>[];

        for (final layer in activeHistory.layers) {
          if (removeIdSet.contains(layer.id)) {
            removedLayers.add(layer);
          } else {
            updatedList.add(layer);
          }
        }

        if (updatedList.length == activeHistory.layers.length) return;

        while (canRedo) {
          stateHistory.removeLast();
        }

        stateHistory.add(PaintEditorResponse(
          layers: [...updatedList],
          removedLayers: [...activeHistory.removedLayers, ...removedLayers],
        ));
        historyPointer++;
        setState(() {});

        WidgetsBinding.instance.addPostFrameCallback((_) async {
          takeScreenshot();
        });
      },
      onRemovePartialStart: () {
        LayerCopyManager copyManager = LayerCopyManager();

        final updatedList =
            activeHistory.layers.whereType<PaintLayer>().map((layer) {
          return copyManager.createCopyPaintLayer(layer);
        });

        while (canRedo) {
          stateHistory.removeLast();
        }
        stateHistory.add(PaintEditorResponse(
          layers: [...updatedList],
          removedLayers: [...activeHistory.removedLayers],
        ));
        historyPointer++;
        setState(() {});
        WidgetsBinding.instance.drawFrame();
      },
      onRemovePartialEnd: (hasRemovedAreas) {
        if (!hasRemovedAreas) {
          historyPointer--;
          stateHistory.removeLast();
          return;
        }
        WidgetsBinding.instance.addPostFrameCallback((_) async {
          takeScreenshot();
        });
      },
      onRefresh: () {
        rebuildController.add(null);
        _layerStackStream.add(null);
      },
      onCreated: (rawLayer) {
        _uiAppbarStream.add(null);
        uiPickerStream.add(null);
        paintEditorCallbacks?.handleDrawingDone();

        final layer = _transformPaintedModelToLayer(rawLayer);
        addLayer(layer);

        WidgetsBinding.instance.addPostFrameCallback((_) async {
          takeScreenshot();
        });
      },
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);

    properties
      ..add(
          DiagnosticsProperty<EditorImage?>('editorImage', widget.editorImage))
      ..add(DiagnosticsProperty<ProVideoController?>(
          'videoController', widget.videoController))
      ..add(DiagnosticsProperty<PaintEditorInitConfigs>(
          'initConfigs', widget.initConfigs))
      ..add(FlagProperty('paintOnly',
          value: widget.paintOnly, ifTrue: 'paint-only mode'))
      ..add(DiagnosticsProperty<PaintController>('paintCtrl', paintCtrl))
      ..add(FlagProperty('_isFillMode',
          value: _isFillMode, ifTrue: 'fill mode enabled'))
      ..add(FlagProperty('isActive', value: isActive, ifTrue: 'drawing active'))
      ..add(EnumProperty<PaintMode>('paintMode', paintMode))
      ..add(ColorProperty('activeColor', activeColor))
      ..add(DoubleProperty('strokeWidth', strokeWidth))
      ..add(DoubleProperty('opacity', opacity))
      ..add(IntProperty('historyPointer', historyPointer))
      ..add(IntProperty('stateHistoryLength', stateHistory.length))
      ..add(FlagProperty('canUndo', value: canUndo, ifTrue: 'can undo'))
      ..add(FlagProperty('canRedo', value: canRedo, ifTrue: 'can redo'))
      ..add(FlagProperty('_enableZoom',
          value: _enableZoom, ifTrue: 'zoom enabled'))
      ..add(FlagProperty('hasFakeHeroBytes',
          value: _fakeHeroBytes != null, ifTrue: 'fake hero set'));
  }
}
