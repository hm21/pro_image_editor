// Dart imports:
import 'dart:async';
import 'dart:io';
import 'dart:math';

// Flutter imports:
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '/core/constants/image_constants.dart';
import '/core/mixins/converted_callbacks.dart';
import '/core/mixins/converted_configs.dart';
import '/core/mixins/standalone_editor.dart';
import '/core/models/paint_editor/painted_model.dart';
import '/core/models/transform_helper.dart';
import '/pro_image_editor.dart';
import '/shared/services/content_recorder/widgets/content_recorder.dart';
import '/shared/styles/platform_text_styles.dart';
import '/shared/widgets/auto_image.dart';
import '/shared/widgets/bottom_sheets_header_row.dart';
import '/shared/widgets/extended/extended_interactive_viewer.dart';
import '/shared/widgets/layer/layer_stack.dart';
import '/shared/widgets/platform/platform_popup_menu.dart';
import '/shared/widgets/transform/transformed_content_generator.dart';
import '../filter_editor/widgets/filtered_image.dart';
import 'controllers/paint_controller.dart';
import 'services/paint_desktop_interaction_manager.dart';
import 'widgets/paint_canvas.dart';

export '/core/models/paint_editor/paint_bottom_bar_item.dart';
export 'enums/paint_editor_enum.dart';
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
  /// The [initConfigs] parameter specifies the initialization configurations
  /// for the editor.
  const PaintEditor._({
    super.key,
    required this.editorImage,
    required this.initConfigs,
    this.paintOnly = false,
  });

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
    File file, {
    Key? key,
    required PaintEditorInitConfigs initConfigs,
  }) {
    return PaintEditor._(
      key: key,
      editorImage: EditorImage(file: file),
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
    File? file,
    String? assetPath,
    String? networkUrl,
    required PaintEditorInitConfigs initConfigs,
  }) {
    if (byteArray != null) {
      return PaintEditor.memory(
        byteArray,
        key: key,
        initConfigs: initConfigs,
      );
    } else if (file != null) {
      return PaintEditor.file(
        file,
        key: key,
        initConfigs: initConfigs,
      );
    } else if (networkUrl != null) {
      return PaintEditor.network(
        networkUrl,
        key: key,
        initConfigs: initConfigs,
      );
    } else if (assetPath != null) {
      return PaintEditor.asset(
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
  final PaintEditorInitConfigs initConfigs;
  @override
  final EditorImage editorImage;

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
        StandaloneEditorState<PaintEditor, PaintEditorInitConfigs> {
  final _paintCanvas = GlobalKey<PaintCanvasState>();
  final _interactiveViewer = GlobalKey<ExtendedInteractiveViewerState>();

  /// Controller for managing paint operations within the widget's context.
  late final PaintController paintCtrl;

  /// Update the color picker.
  late final StreamController<void> uiPickerStream;

  /// Update the appbar icons.
  late final StreamController<void> _uiAppbarIconsStream;

  /// A ScrollController for controlling the scrolling behavior of the bottom
  /// navigation bar.
  late ScrollController _bottomBarScrollCtrl;

  /// A boolean flag representing whether the fill mode is enabled or disabled.
  bool _fill = false;

  /// Controls high-performance for free-style drawing.
  bool _freeStyleHighPerformance = false;

  /// Get the fillBackground status.
  bool get fillBackground => _fill;

  /// Determines whether undo actions can be performed on the current state.
  bool get canUndo => paintCtrl.canUndo;

  /// Determines whether redo actions can be performed on the current state.
  bool get canRedo => paintCtrl.canRedo;

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
        if (paintEditorConfigs.hasOptionFreeStyle)
          PaintModeBottomBarItem(
            mode: PaintMode.freeStyle,
            icon: paintEditorConfigs.icons.freeStyle,
            label: i18n.paintEditor.freestyle,
          ),
        if (paintEditorConfigs.hasOptionArrow)
          PaintModeBottomBarItem(
            mode: PaintMode.arrow,
            icon: paintEditorConfigs.icons.arrow,
            label: i18n.paintEditor.arrow,
          ),
        if (paintEditorConfigs.hasOptionLine)
          PaintModeBottomBarItem(
            mode: PaintMode.line,
            icon: paintEditorConfigs.icons.line,
            label: i18n.paintEditor.line,
          ),
        if (paintEditorConfigs.hasOptionRect)
          PaintModeBottomBarItem(
            mode: PaintMode.rect,
            icon: paintEditorConfigs.icons.rectangle,
            label: i18n.paintEditor.rectangle,
          ),
        if (paintEditorConfigs.hasOptionCircle)
          PaintModeBottomBarItem(
            mode: PaintMode.circle,
            icon: paintEditorConfigs.icons.circle,
            label: i18n.paintEditor.circle,
          ),
        if (paintEditorConfigs.hasOptionDashLine)
          PaintModeBottomBarItem(
            mode: PaintMode.dashLine,
            icon: paintEditorConfigs.icons.dashLine,
            label: i18n.paintEditor.dashLine,
          ),
        if (paintEditorConfigs.hasOptionEraser)
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

  @override
  void initState() {
    super.initState();
    paintCtrl = PaintController(
      fill: paintEditorConfigs.initialFill,
      mode: paintEditorConfigs.initialPaintMode,
      strokeWidth: paintEditorConfigs.style.initialStrokeWidth,
      color: paintEditorConfigs.style.initialColor,
      opacity: paintEditorConfigs.style.initialOpacity,
      strokeMultiplier: 1,
    );

    _fill = paintEditorConfigs.initialFill;

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
  }

  @override
  void dispose() {
    paintCtrl.dispose();
    _bottomBarScrollCtrl.dispose();
    uiPickerStream.close();
    _uiAppbarIconsStream.close();
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
    _uiAppbarIconsStream = StreamController.broadcast();

    uiPickerStream.stream.listen((_) => rebuildController.add(null));
    _uiAppbarIconsStream.stream.listen((_) => rebuildController.add(null));
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
  void openLineWeightBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: paintEditorConfigs.style.lineWidthBottomSheetBackground,
      builder: (BuildContext context) {
        return StatefulBuilder(builder: (context, setState) {
          return Material(
            color: Colors.transparent,
            textStyle: platformTextStyle(context, designMode),
            child: SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    BottomSheetHeaderRow(
                      title: i18n.paintEditor.lineWidth,
                      theme: initConfigs.theme,
                      textStyle:
                          paintEditorConfigs.style.lineWidthBottomSheetTitle,
                      closeButton:
                          paintEditorConfigs.widgets.lineWidthCloseButton !=
                                  null
                              ? (fn) => paintEditorConfigs
                                  .widgets.lineWidthCloseButton!(this, fn)
                              : null,
                    ),
                    StatefulBuilder(builder: (context, setState) {
                      if (paintEditorConfigs.widgets.sliderLineWidth != null) {
                        return paintEditorConfigs.widgets.sliderLineWidth!(
                          this,
                          rebuildController.stream,
                          paintCtrl.strokeWidth,
                          (value) {
                            setStrokeWidth(value);
                            setState(() {});
                          },
                          (onChangedEnd) {},
                        );
                      }

                      return Slider.adaptive(
                        max: 40,
                        min: 2,
                        divisions: 19,
                        value: paintCtrl.strokeWidth,
                        onChanged: (value) {
                          setStrokeWidth(value);
                          setState(() {});
                        },
                      );
                    }),
                  ],
                ),
              ),
            ),
          );
        });
      },
    );
  }

  /// Opens a bottom sheet to adjust the opacity when drawing.
  void openOpacityBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: paintEditorConfigs.style.opacityBottomSheetBackground,
      builder: (BuildContext context) {
        return StatefulBuilder(builder: (context, setState) {
          return Material(
            color: Colors.transparent,
            textStyle: platformTextStyle(context, designMode),
            child: SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    BottomSheetHeaderRow(
                      title: i18n.paintEditor.changeOpacity,
                      theme: initConfigs.theme,
                      textStyle:
                          paintEditorConfigs.style.opacityBottomSheetTitle,
                      closeButton:
                          paintEditorConfigs.widgets.changeOpacityCloseButton !=
                                  null
                              ? (fn) => paintEditorConfigs
                                  .widgets.changeOpacityCloseButton!(this, fn)
                              : null,
                    ),
                    StatefulBuilder(builder: (context, setState) {
                      if (paintEditorConfigs.widgets.sliderChangeOpacity !=
                          null) {
                        return paintEditorConfigs.widgets.sliderChangeOpacity!(
                          this,
                          rebuildController.stream,
                          paintCtrl.opacity,
                          (value) {
                            setOpacity(value);
                            setState(() {});
                          },
                          (onChangedEnd) {},
                        );
                      }

                      return Slider.adaptive(
                        max: 1,
                        min: 0,
                        divisions: 100,
                        value: paintCtrl.opacity,
                        onChanged: (value) {
                          setOpacity(value);
                          setState(() {});
                        },
                      );
                    }),
                  ],
                ),
              ),
            ),
          );
        });
      },
    );
  }

  /// Sets the fill mode for drawing elements.
  /// When the `fill` parameter is `true`, drawing elements will be filled;
  /// otherwise, they will be outlined.
  void setFill(bool fill) {
    paintCtrl.setFill(fill);
    _uiAppbarIconsStream.add(null);
    paintEditorCallbacks?.handleToggleFill(fill);
  }

  /// Sets the opacity for drawing elements.
  ///
  /// The opacity must be between 0 and 1.
  void setOpacity(double value) {
    paintCtrl.setOpacity(value);
    _uiAppbarIconsStream.add(null);
    paintEditorCallbacks?.handleOpacity(value);
  }

  /// Toggles the fill mode.
  void toggleFill() {
    _fill = !_fill;
    setFill(_fill);
    rebuildController.add(null);
  }

  /// Set the PaintMode for the current state and trigger an update if provided.
  void setMode(PaintMode mode) {
    paintCtrl.setMode(mode);
    paintEditorCallbacks?.handlePaintModeChanged(mode);
    rebuildController.add(null);
    _interactiveViewer.currentState?.setEnableInteraction(
      mode == PaintMode.moveAndZoom,
    );
    _paintCanvas.currentState?.setState(() {});
  }

  /// Undoes the last action performed in the paint editor.
  void undoAction() {
    if (canUndo) screenshotHistoryPosition--;
    paintCtrl.undo();
    _uiAppbarIconsStream.add(null);
    setState(() {});
    paintEditorCallbacks?.handleUndo();
  }

  /// Redoes the previously undone action in the paint editor.
  void redoAction() {
    if (canRedo) screenshotHistoryPosition++;
    paintCtrl.redo();
    _uiAppbarIconsStream.add(null);
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
          Navigator.of(context).pop(
            _exportPaintedItems(editorBodySize),
          );
        });
    paintEditorCallbacks?.handleDone();
  }

  /// Exports the painted items as a list of [PaintLayerData].
  ///
  /// This method converts the paint history into a list of
  /// [PaintLayerData] representing the painted items.
  ///
  /// Example:
  /// ```dart
  /// List<PaintLayerData> layers = exportPaintedItems();
  /// ```
  List<PaintLayerData> _exportPaintedItems(Size editorSize) {
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

    // Convert to free positions
    return paintCtrl.activePaintItemList.map((e) {
      PaintedModel layer = PaintedModel(
        mode: e.mode,
        offsets: [...e.offsets],
        color: e.color,
        strokeWidth: e.strokeWidth,
        fill: e.fill,
        opacity: e.opacity,
      );

      // Find extreme points of the paint layer
      Rect? layerRect = findRenderedLayerRect(e.offsets);

      Size size = layerRect.size;

      bool onlyStrokeMode = e.mode == PaintMode.freeStyle ||
          e.mode == PaintMode.line ||
          e.mode == PaintMode.dashLine ||
          e.mode == PaintMode.arrow ||
          ((e.mode == PaintMode.rect || e.mode == PaintMode.circle) && !e.fill);

      // Scale and offset the offsets of the paint layer
      double strokeHelperWidth = onlyStrokeMode ? e.strokeWidth : 0;

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
        layerRect.center.dx - editorSize.width / 2,
        layerRect.center.dy - editorSize.height / 2,
      );

      if (onlyStrokeMode) {
        size = Size(
          size.width + strokeHelperWidth,
          size.height + strokeHelperWidth,
        );
      }

      // Create and return a PaintLayerData instance for the exported layer
      return PaintLayerData(
        item: layer.copy(),
        rawSize: Size(
          max(size.width, layer.strokeWidth),
          max(size.height, layer.strokeWidth),
        ),
        opacity: layer.opacity,
        offset: finalOffset,
      );
    }).toList();
  }

  /// Set the stroke width.
  void setStrokeWidth(double value) {
    paintCtrl.setStrokeWidth(value);
    rebuildController.add(null);
    callbacks.paintEditorCallbacks?.handleLineWidthChanged(value);
    setState(() {});
  }

  /// Handles changes in the selected color.
  void colorChanged(Color color) {
    paintCtrl.setColor(color);
    uiPickerStream.add(null);
    paintEditorCallbacks?.handleColorChanged();
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

    return AppBar(
      automaticallyImplyLeading: false,
      backgroundColor: paintEditorConfigs.style.appBarBackground,
      foregroundColor: paintEditorConfigs.style.appBarColor,
      actions: _buildAction(constraints),
    );
  }

  /// Builds an action bar depending on the allowed space
  List<Widget> _buildAction(BoxConstraints constraints) {
    const int defaultIconButtonSize = 48;
    final List<StreamBuilder<void>> configButtons = _getConfigButtons();
    final List<Widget> actionButtons = _getActionButtons();

    // Taking into account the back button
    final expandedIconButtonsSize =
        (1 + configButtons.length + actionButtons.length) *
            defaultIconButtonSize;

    return [
      IconButton(
        tooltip: i18n.paintEditor.back,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        icon: Icon(paintEditorConfigs.icons.backButton),
        onPressed: close,
      ),
      const Spacer(),
      ...[
        if (constraints.maxWidth >= expandedIconButtonsSize) ...[
          ...configButtons,
          if (constraints.maxWidth >= 640) const Spacer(),
          ...actionButtons,
        ] else ...[
          ..._buildShortActionBar(
            constraints,
            actionButtons,
            defaultIconButtonSize,
          ),
        ],
      ],
    ];
  }

  /// Builds an action bar with limited number of quick actions
  List<Widget> _buildShortActionBar(
    BoxConstraints constraints,
    List<Widget> actionButtons,
    int defaultIconButtonSize,
  ) {
    final shrunkIconButtonsSize =
        (1 + actionButtons.length) * defaultIconButtonSize;
    final bool hasEnoughSpace = constraints.maxWidth >= shrunkIconButtonsSize;

    return [
      if (hasEnoughSpace) ...[
        ...actionButtons,
      ] else ...[
        _buildDoneBtn(),
      ],
      PlatformPopupBtn(
        designMode: designMode,
        title: i18n.paintEditor.smallScreenMoreTooltip,
        options: [
          if (paintEditorConfigs.canChangeLineWidth)
            PopupMenuOption(
              label: i18n.paintEditor.lineWidth,
              icon: Icon(
                paintEditorConfigs.icons.lineWeight,
              ),
              onTap: openLineWeightBottomSheet,
            ),
          if (paintEditorConfigs.canToggleFill)
            PopupMenuOption(
              label: i18n.paintEditor.toggleFill,
              icon: Icon(
                !_fill
                    ? paintEditorConfigs.icons.noFill
                    : paintEditorConfigs.icons.fill,
              ),
              onTap: () {
                _fill = !_fill;
                setFill(_fill);
                if (designMode == ImageEditorDesignMode.cupertino) {
                  Navigator.pop(context);
                }
              },
            ),
          if (paintEditorConfigs.canChangeOpacity)
            PopupMenuOption(
              label: i18n.paintEditor.changeOpacity,
              icon: Icon(
                paintEditorConfigs.icons.changeOpacity,
              ),
              onTap: openOpacityBottomSheet,
            ),
          if (!hasEnoughSpace) ...[
            if (canUndo)
              PopupMenuOption(
                label: i18n.paintEditor.undo,
                icon: Icon(
                  paintEditorConfigs.icons.undoAction,
                ),
                onTap: undoAction,
              ),
            if (canRedo)
              PopupMenuOption(
                label: i18n.paintEditor.redo,
                icon: Icon(
                  paintEditorConfigs.icons.redoAction,
                ),
                onTap: redoAction,
              ),
          ]
        ],
      )
    ];
  }

  /// Builds and returns a list of IconButton to change the line width /
  /// toggle fill or un-fill / change the opacity.
  List<StreamBuilder<void>> _getConfigButtons() => [
        if (paintEditorConfigs.canChangeLineWidth)
          StreamBuilder(
              stream: _uiAppbarIconsStream.stream,
              builder: (context, snapshot) {
                return IconButton(
                  tooltip: i18n.paintEditor.lineWidth,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  icon: Icon(
                    paintEditorConfigs.icons.lineWeight,
                    color: Colors.white,
                  ),
                  onPressed: openLineWeightBottomSheet,
                );
              }),
        if (paintEditorConfigs.canToggleFill)
          StreamBuilder(
              stream: _uiAppbarIconsStream.stream,
              builder: (context, snapshot) {
                return IconButton(
                  tooltip: i18n.paintEditor.toggleFill,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  icon: Icon(
                    !_fill
                        ? paintEditorConfigs.icons.noFill
                        : paintEditorConfigs.icons.fill,
                    color: Colors.white,
                  ),
                  onPressed: toggleFill,
                );
              }),
        if (paintEditorConfigs.canChangeOpacity)
          StreamBuilder(
              stream: _uiAppbarIconsStream.stream,
              builder: (context, snapshot) {
                return IconButton(
                  tooltip: i18n.paintEditor.changeOpacity,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  icon: Icon(
                    paintEditorConfigs.icons.changeOpacity,
                    color: Colors.white,
                  ),
                  onPressed: openOpacityBottomSheet,
                );
              }),
      ];

  /// Builds and returns a list of IconButton to undo / redo / apply changes.
  List<Widget> _getActionButtons() => [
        StreamBuilder(
            stream: _uiAppbarIconsStream.stream,
            builder: (context, snapshot) {
              return IconButton(
                tooltip: i18n.paintEditor.undo,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                icon: Icon(
                  paintEditorConfigs.icons.undoAction,
                  color: canUndo ? Colors.white : Colors.white.withAlpha(80),
                ),
                onPressed: undoAction,
              );
            }),
        StreamBuilder(
            stream: _uiAppbarIconsStream.stream,
            builder: (context, snapshot) {
              return IconButton(
                tooltip: i18n.paintEditor.redo,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                icon: Icon(
                  paintEditorConfigs.icons.redoAction,
                  color: canRedo ? Colors.white : Colors.white.withAlpha(80),
                ),
                onPressed: redoAction,
              );
            }),
        _buildDoneBtn(),
      ];

  /// Builds and returns an IconButton for applying changes.
  Widget _buildDoneBtn() {
    return IconButton(
      tooltip: i18n.paintEditor.done,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      icon: Icon(paintEditorConfigs.icons.applyChanges),
      iconSize: 28,
      onPressed: done,
    );
  }

  /// Builds the main body of the paint editor.
  /// Returns a [Widget] representing the editor's body.
  Widget _buildBody() {
    return SafeArea(
      child: LayoutBuilder(builder: (context, constraints) {
        editorBodySize = constraints.biggest;
        return Theme(
          data: theme,
          child: Material(
            color: initConfigs.convertToUint8List
                ? paintEditorConfigs.style.background
                : Colors.transparent,
            textStyle: platformTextStyle(context, designMode),
            child: Stack(
              alignment: Alignment.center,
              fit: StackFit.expand,
              children: _fakeHeroBytes != null
                  ? [
                      Hero(
                        tag: configs.heroTag,
                        child: AutoImage(
                          EditorImage(byteArray: _fakeHeroBytes),
                          configs: configs,
                        ),
                      ),
                    ]
                  : [
                      ExtendedInteractiveViewer(
                        key: _interactiveViewer,
                        enableZoom: _enableZoom,
                        boundaryMargin: paintEditorConfigs.boundaryMargin,
                        minScale: paintEditorConfigs.editorMinScale,
                        maxScale: paintEditorConfigs.editorMaxScale,
                        enableInteraction: paintMode == PaintMode.moveAndZoom,
                        onInteractionStart: (details) {
                          _freeStyleHighPerformance = (paintEditorConfigs
                                      .freeStyleHighPerformanceMoving ??
                                  !isDesktop) ||
                              (paintEditorConfigs
                                      .freeStyleHighPerformanceScaling ??
                                  !isDesktop);

                          callbacks.paintEditorCallbacks?.onEditorZoomScaleStart
                              ?.call(details);
                          setState(() {});
                        },
                        onInteractionUpdate: callbacks
                            .paintEditorCallbacks?.onEditorZoomScaleUpdate,
                        onInteractionEnd: (details) {
                          _freeStyleHighPerformance = false;
                          callbacks.paintEditorCallbacks?.onEditorZoomScaleEnd
                              ?.call(details);
                          setState(() {});
                        },
                        child: ContentRecorder(
                          autoDestroyController: false,
                          controller: screenshotCtrl,
                          child: Stack(
                            alignment: Alignment.center,
                            fit: StackFit.expand,
                            children: [
                              if (!widget.paintOnly)
                                TransformedContentGenerator(
                                  configs: configs,
                                  transformConfigs: initialTransformConfigs ??
                                      TransformConfigs.empty(),
                                  child: FilteredImage(
                                    width: getMinimumSize(
                                            mainImageSize, editorBodySize)
                                        .width,
                                    height: getMinimumSize(
                                            mainImageSize, editorBodySize)
                                        .height,
                                    configs: configs,
                                    image: editorImage,
                                    filters: appliedFilters,
                                    tuneAdjustments: appliedTuneAdjustments,
                                    blurFactor: appliedBlurFactor,
                                  ),
                                )
                              else
                                SizedBox(
                                  width: configs
                                      .imageGeneration.maxOutputSize.width,
                                  height: configs
                                      .imageGeneration.maxOutputSize.height,
                                ),
                              if (layers != null)
                                LayerStack(
                                  configs: configs,
                                  layers: layers!,
                                  transformHelper: TransformHelper(
                                    mainBodySize: getMinimumSize(
                                        mainBodySize, editorBodySize),
                                    mainImageSize: getMinimumSize(
                                        mainImageSize, editorBodySize),
                                    editorBodySize: editorBodySize,
                                    transformConfigs: initialTransformConfigs,
                                  ),
                                ),
                              _buildPainter(),
                              if (paintEditorConfigs
                                      .widgets.bodyItemsRecorded !=
                                  null)
                                ...paintEditorConfigs
                                        .widgets.bodyItemsRecorded!(
                                    this, rebuildController.stream),
                            ],
                          ),
                        ),
                      ),
                      _buildColorPicker(),
                      if (paintEditorConfigs.widgets.bodyItems != null)
                        ...paintEditorConfigs.widgets.bodyItems!(
                            this, rebuildController.stream),
                    ],
            ),
          ),
        );
      }),
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

    double minWidth = min(MediaQuery.of(context).size.width, 600);
    double maxWidth =
        max((paintModes.length + (_enableZoom ? 1 : 0)) * 80, minWidth);
    return Theme(
      data: theme,
      child: Scrollbar(
        controller: _bottomBarScrollCtrl,
        scrollbarOrientation: ScrollbarOrientation.top,
        thickness: isDesktop ? null : 0,
        child: BottomAppBar(
          height: kToolbarHeight,
          color: paintEditorConfigs.style.bottomBarBackground,
          padding: EdgeInsets.zero,
          child: Center(
            child: SingleChildScrollView(
              controller: _bottomBarScrollCtrl,
              scrollDirection: Axis.horizontal,
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minWidth: minWidth,
                  maxWidth: MediaQuery.of(context).size.width > 660
                      ? maxWidth
                      : double.infinity,
                ),
                child: StatefulBuilder(builder: (context, setStateBottomBar) {
                  Color getColor(PaintMode mode) {
                    return paintMode == mode
                        ? paintEditorConfigs.style.bottomBarActiveItemColor
                        : paintEditorConfigs.style.bottomBarInactiveItemColor;
                  }

                  return Wrap(
                    direction: Axis.horizontal,
                    alignment: WrapAlignment.spaceAround,
                    runAlignment: WrapAlignment.spaceAround,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: <Widget>[
                      if (_enableZoom) ...[
                        FlatIconTextButton(
                          label: Text(
                            i18n.paintEditor.moveAndZoom,
                            style: TextStyle(
                              fontSize: 10.0,
                              color: getColor(PaintMode.moveAndZoom),
                            ),
                          ),
                          icon: Icon(
                            paintEditorConfigs.icons.moveAndZoom,
                            color: getColor(PaintMode.moveAndZoom),
                          ),
                          onPressed: () {
                            setMode(PaintMode.moveAndZoom);
                            setStateBottomBar(() {});
                          },
                        ),
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          height: kBottomNavigationBarHeight - 14,
                          width: 1,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(2),
                            color: paintEditorConfigs
                                .style.bottomBarInactiveItemColor,
                          ),
                        )
                      ],
                      ...List.generate(
                        paintModes.length,
                        (index) {
                          PaintModeBottomBarItem item = paintModes[index];
                          Color color = getColor(item.mode);
                          return FlatIconTextButton(
                            label: Text(
                              item.label,
                              style: TextStyle(fontSize: 10.0, color: color),
                            ),
                            icon: Icon(item.icon, color: color),
                            onPressed: () {
                              setMode(item.mode);
                              setStateBottomBar(() {});
                            },
                          );
                        },
                      ),
                    ],
                  );
                }),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Builds the paint canvas for the editor.
  /// Returns a [Widget] representing the paint canvas.
  Widget _buildPainter() {
    return PaintCanvas(
      key: _paintCanvas,
      paintCtrl: paintCtrl,
      drawAreaSize: mainBodySize ?? editorBodySize,
      freeStyleHighPerformance: _freeStyleHighPerformance,
      onRemoveLayer: (idList) {
        paintCtrl.removeLayers(idList);
        setState(() {});
        WidgetsBinding.instance.addPostFrameCallback((_) async {
          takeScreenshot();
        });
      },
      onStart: () {
        rebuildController.add(null);
      },
      onCreated: () {
        _uiAppbarIconsStream.add(null);
        uiPickerStream.add(null);
        paintEditorCallbacks?.handleDrawingDone();
        WidgetsBinding.instance.addPostFrameCallback((_) async {
          takeScreenshot();
        });
      },
    );
  }

  /// Builds the color picker widget for selecting colors while paint.
  /// Returns a [Widget] representing the color picker.
  Widget _buildColorPicker() {
    if (paintEditorConfigs.widgets.colorPicker != null) {
      return paintEditorConfigs.widgets.colorPicker!.call(
            this,
            rebuildController.stream,
            paintCtrl.color,
            colorChanged,
          ) ??
          const SizedBox.shrink();
    }

    return Positioned(
      top: 10,
      right: 0,
      child: StreamBuilder(
        stream: uiPickerStream.stream,
        builder: (context, snapshot) {
          return BarColorPicker(
            configs: configs,
            length: min(
              350,
              MediaQuery.of(context).size.height -
                  MediaQuery.of(context).viewInsets.bottom -
                  kToolbarHeight -
                  kBottomNavigationBarHeight -
                  MediaQuery.of(context).padding.top -
                  30,
            ),
            horizontal: false,
            thumbColor: Colors.white,
            cornerRadius: 10,
            pickMode: PickMode.color,
            initialColor: paintEditorConfigs.style.initialColor,
            colorListener: (int value) {
              colorChanged(Color(value));
            },
          );
        },
      ),
    );
  }
}
