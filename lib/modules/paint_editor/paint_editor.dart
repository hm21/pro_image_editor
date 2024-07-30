// Dart imports:
import 'dart:async';
import 'dart:io';
import 'dart:math';

// Flutter imports:
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// Project imports:
import 'package:pro_image_editor/mixins/converted_callbacks.dart';
import 'package:pro_image_editor/pro_image_editor.dart';
import 'package:pro_image_editor/utils/content_recorder.dart/content_recorder.dart';
import 'package:pro_image_editor/utils/content_recorder.dart/utils/record_invisible_widget.dart';
import 'package:pro_image_editor/widgets/auto_image.dart';
import 'package:pro_image_editor/widgets/extended/extended_interactive_viewer.dart';
import 'package:pro_image_editor/widgets/layer_stack.dart';

import '/mixins/converted_configs.dart';
import '/mixins/standalone_editor.dart';
import '/models/crop_rotate_editor/transform_factors.dart';
import '/models/paint_editor/painted_model.dart';
import '/models/transform_helper.dart';
import '/utils/theme_functions.dart';
import '/widgets/bottom_sheets_header_row.dart';
import '/widgets/platform_popup_menu.dart';
import '/widgets/transform/transformed_content_generator.dart';
import '../../utils/transparent_image_bytes.dart';
import '../filter_editor/widgets/filtered_image.dart';
import 'utils/paint_controller.dart';
import 'utils/paint_desktop_interaction_manager.dart';
import 'widgets/painting_canvas.dart';

export '/models/paint_editor/paint_bottom_bar_item.dart';
export './utils/paint_editor_enum.dart';
export './widgets/draw_painting.dart';

/// The `PaintingEditor` widget allows users to editing images with painting
/// tools.
///
/// You can create a `PaintingEditor` using one of the factory methods provided:
/// - `PaintingEditor.file`: Loads an image from a file.
/// - `PaintingEditor.asset`: Loads an image from an asset.
/// - `PaintingEditor.network`: Loads an image from a network URL.
/// - `PaintingEditor.memory`: Loads an image from memory as a `Uint8List`.
/// - `PaintingEditor.autoSource`: Automatically selects the source based on
/// provided parameters.
class PaintingEditor extends StatefulWidget
    with StandaloneEditor<PaintEditorInitConfigs> {
  @override
  final PaintEditorInitConfigs initConfigs;
  @override
  final EditorImage editorImage;

  /// A flag indicating whether only painting operations are allowed.
  final bool paintingOnly;

  /// Constructs a `PaintingEditor` widget.
  ///
  /// The [key] parameter is used to provide a key for the widget.
  /// The [editorImage] parameter specifies the image to be edited.
  /// The [initConfigs] parameter specifies the initialization configurations for the editor.
  const PaintingEditor._({
    super.key,
    required this.editorImage,
    required this.initConfigs,
    this.paintingOnly = false,
  });

  /// Constructs a `PaintingEditor` widget with image data loaded from memory.
  factory PaintingEditor.memory(
    Uint8List byteArray, {
    Key? key,
    required PaintEditorInitConfigs initConfigs,
  }) {
    return PaintingEditor._(
      key: key,
      editorImage: EditorImage(byteArray: byteArray),
      initConfigs: initConfigs,
    );
  }

  /// Constructs a `PaintingEditor` widget with an image loaded from a file.
  factory PaintingEditor.file(
    File file, {
    Key? key,
    required PaintEditorInitConfigs initConfigs,
  }) {
    return PaintingEditor._(
      key: key,
      editorImage: EditorImage(file: file),
      initConfigs: initConfigs,
    );
  }

  /// Constructs a `PaintingEditor` widget with an image loaded from an asset.
  factory PaintingEditor.asset(
    String assetPath, {
    Key? key,
    required PaintEditorInitConfigs initConfigs,
  }) {
    return PaintingEditor._(
      key: key,
      editorImage: EditorImage(assetPath: assetPath),
      initConfigs: initConfigs,
    );
  }

  /// Constructs a `PaintingEditor` widget with an image loaded from a network URL.
  factory PaintingEditor.network(
    String networkUrl, {
    Key? key,
    required PaintEditorInitConfigs initConfigs,
  }) {
    return PaintingEditor._(
      key: key,
      editorImage: EditorImage(networkUrl: networkUrl),
      initConfigs: initConfigs,
    );
  }

  /// Constructs a `PaintingEditor` widget optimized for drawing purposes.
  factory PaintingEditor.drawing({
    Key? key,
    required PaintEditorInitConfigs initConfigs,
  }) {
    return PaintingEditor._(
      key: key,
      editorImage: EditorImage(byteArray: transparentBytes),
      initConfigs: initConfigs,
      paintingOnly: true,
    );
  }

  /// Constructs a `PaintingEditor` widget with an image loaded automatically based on the provided source.
  ///
  /// Either [byteArray], [file], [networkUrl], or [assetPath] must be provided.
  factory PaintingEditor.autoSource({
    Key? key,
    Uint8List? byteArray,
    File? file,
    String? assetPath,
    String? networkUrl,
    required PaintEditorInitConfigs initConfigs,
  }) {
    if (byteArray != null) {
      return PaintingEditor.memory(
        byteArray,
        key: key,
        initConfigs: initConfigs,
      );
    } else if (file != null) {
      return PaintingEditor.file(
        file,
        key: key,
        initConfigs: initConfigs,
      );
    } else if (networkUrl != null) {
      return PaintingEditor.network(
        networkUrl,
        key: key,
        initConfigs: initConfigs,
      );
    } else if (assetPath != null) {
      return PaintingEditor.asset(
        assetPath,
        key: key,
        initConfigs: initConfigs,
      );
    } else {
      throw ArgumentError(
          "Either 'byteArray', 'file', 'networkUrl' or 'assetPath' must be provided.");
    }
  }

  @override
  State<PaintingEditor> createState() => PaintingEditorState();
}

class PaintingEditorState extends State<PaintingEditor>
    with
        ImageEditorConvertedConfigs,
        ImageEditorConvertedCallbacks,
        StandaloneEditorState<PaintingEditor, PaintEditorInitConfigs> {
  final _paintingCanvas = GlobalKey<PaintingCanvasState>();
  final _interactiveViewer = GlobalKey<ExtendedInteractiveViewerState>();

  /// Controller for managing painting operations within the widget's context.
  late final PaintingController paintCtrl;

  /// Update the color picker.
  late final StreamController uiPickerStream;

  /// Update the appbar icons.
  late final StreamController _uiAppbarIconsStream;

  /// A ScrollController for controlling the scrolling behavior of the bottom navigation bar.
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

  /// Determines whether the user painting.
  bool get activePainting => paintCtrl.busy;

  /// Manager class for handling desktop interactions.
  late final PaintDesktopInteractionManager _desktopInteractionManager;

  /// Get the current PaintMode.
  PaintModeE get paintMode => paintCtrl.mode;

  /// Get the current strokeWidth.
  double get strokeWidth => paintCtrl.strokeWidth;

  /// Get the active selected color.
  Color get activeColor => paintCtrl.color;

  /// A list of [PaintModeBottomBarItem] representing the available drawing
  /// modes in the painting editor.
  /// The list is dynamically generated based on the configuration settings in
  /// the [PaintEditorConfigs] object.
  List<PaintModeBottomBarItem> get paintModes => [
        if (paintEditorConfigs.hasOptionFreeStyle)
          PaintModeBottomBarItem(
            mode: PaintModeE.freeStyle,
            icon: icons.paintingEditor.freeStyle,
            label: i18n.paintEditor.freestyle,
          ),
        if (paintEditorConfigs.hasOptionArrow)
          PaintModeBottomBarItem(
            mode: PaintModeE.arrow,
            icon: icons.paintingEditor.arrow,
            label: i18n.paintEditor.arrow,
          ),
        if (paintEditorConfigs.hasOptionLine)
          PaintModeBottomBarItem(
            mode: PaintModeE.line,
            icon: icons.paintingEditor.line,
            label: i18n.paintEditor.line,
          ),
        if (paintEditorConfigs.hasOptionRect)
          PaintModeBottomBarItem(
            mode: PaintModeE.rect,
            icon: icons.paintingEditor.rectangle,
            label: i18n.paintEditor.rectangle,
          ),
        if (paintEditorConfigs.hasOptionCircle)
          PaintModeBottomBarItem(
            mode: PaintModeE.circle,
            icon: icons.paintingEditor.circle,
            label: i18n.paintEditor.circle,
          ),
        if (paintEditorConfigs.hasOptionDashLine)
          PaintModeBottomBarItem(
            mode: PaintModeE.dashLine,
            icon: icons.paintingEditor.dashLine,
            label: i18n.paintEditor.dashLine,
          ),
        if (paintEditorConfigs.hasOptionEraser)
          PaintModeBottomBarItem(
            mode: PaintModeE.eraser,
            icon: icons.paintingEditor.eraser,
            label: i18n.paintEditor.eraser,
          ),
      ];

  /// The Uint8List from the fake hero image, which is drawed when finish editing.
  Uint8List? _fakeHeroBytes;

  @override
  void initState() {
    super.initState();
    paintCtrl = PaintingController(
      fill: paintEditorConfigs.initialFill,
      mode: paintEditorConfigs.initialPaintMode,
      strokeWidth: imageEditorTheme.paintingEditor.initialStrokeWidth,
      color: imageEditorTheme.paintingEditor.initialColor,
      opacity: imageEditorTheme.paintingEditor.initialOpacity,
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
      backgroundColor:
          imageEditorTheme.paintingEditor.lineWidthBottomSheetColor,
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
                      textStyle: imageEditorTheme
                          .paintingEditor.lineWidthBottomSheetTitle,
                      closeButton:
                          customWidgets.paintEditor.lineWidthCloseButton != null
                              ? (fn) => customWidgets
                                  .paintEditor.lineWidthCloseButton!(this, fn)
                              : null,
                    ),
                    StatefulBuilder(builder: (context, setState) {
                      if (customWidgets.paintEditor.sliderLineWidth != null) {
                        return customWidgets.paintEditor.sliderLineWidth!(
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
      backgroundColor: imageEditorTheme.paintingEditor.opacityBottomSheetColor,
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
                      textStyle: imageEditorTheme
                          .paintingEditor.opacityBottomSheetTitle,
                      closeButton:
                          customWidgets.paintEditor.changeOpacityCloseButton !=
                                  null
                              ? (fn) => customWidgets.paintEditor
                                  .changeOpacityCloseButton!(this, fn)
                              : null,
                    ),
                    StatefulBuilder(builder: (context, setState) {
                      if (customWidgets.paintEditor.sliderChangeOpacity !=
                          null) {
                        return customWidgets.paintEditor.sliderChangeOpacity!(
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
  /// When the `fill` parameter is `true`, drawing elements will be filled; otherwise, they will be outlined.
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
  void setMode(PaintModeE mode) {
    paintCtrl.setMode(mode);
    paintEditorCallbacks?.handlePaintModeChanged(mode);
    rebuildController.add(null);
    _interactiveViewer.currentState?.setEnableInteraction(
      mode == PaintModeE.moveAndZoom,
    );
    _paintingCanvas.currentState?.setState(() {});
  }

  /// Undoes the last action performed in the painting editor.
  void undoAction() {
    if (canUndo) screenshotHistoryPosition--;
    paintCtrl.undo();
    _uiAppbarIconsStream.add(null);
    setState(() {});
    paintEditorCallbacks?.handleUndo();
  }

  /// Redoes the previously undone action in the painting editor.
  void redoAction() {
    if (canRedo) screenshotHistoryPosition++;
    paintCtrl.redo();
    _uiAppbarIconsStream.add(null);
    setState(() {});
    paintEditorCallbacks?.handleRedo();
  }

  /// Finishes editing in the painting editor and returns the painted items as a result.
  /// If no changes have been made, it closes the editor without returning any changes.
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

  /// Exports the painted items as a list of [PaintingLayerData].
  ///
  /// This method converts the painting history into a list of [PaintingLayerData] representing the painted items.
  ///
  /// Example:
  /// ```dart
  /// List<PaintingLayerData> layers = exportPaintedItems();
  /// ```
  List<PaintingLayerData> _exportPaintedItems(Size editorSize) {
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
    return paintCtrl.activePaintings.map((e) {
      PaintedModel layer = PaintedModel(
        mode: e.mode,
        offsets: [...e.offsets],
        color: e.color,
        strokeWidth: e.strokeWidth,
        fill: e.fill,
        opacity: e.opacity,
      );

      // Find extreme points of the painting layer
      Rect? layerRect = findRenderedLayerRect(e.offsets);

      Size size = layerRect.size;

      bool onlyStrokeMode = e.mode == PaintModeE.freeStyle ||
          e.mode == PaintModeE.line ||
          e.mode == PaintModeE.dashLine ||
          e.mode == PaintModeE.arrow ||
          ((e.mode == PaintModeE.rect || e.mode == PaintModeE.circle) &&
              !e.fill);

      // Scale and offset the offsets of the painting layer
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

      // Calculate the final offset of the painting layer
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

      // Create and return a PaintingLayerData instance for the exported layer
      return PaintingLayerData(
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
      value: imageEditorTheme.uiOverlayStyle,
      child: Theme(
        data: theme.copyWith(
            tooltipTheme: theme.tooltipTheme.copyWith(preferBelow: true)),
        child: RecordInvisibleWidget(
          controller: screenshotCtrl,
          child: LayoutBuilder(builder: (context, constraints) {
            return Scaffold(
              resizeToAvoidBottomInset: false,
              backgroundColor: imageEditorTheme.paintingEditor.background,
              appBar: _buildAppBar(constraints),
              body: _buildBody(),
              bottomNavigationBar: _buildBottomBar(),
            );
          }),
        ),
      ),
    );
  }

  /// Builds the app bar for the painting editor.
  /// Returns a [PreferredSizeWidget] representing the app bar.
  PreferredSizeWidget? _buildAppBar(BoxConstraints constraints) {
    if (customWidgets.paintEditor.appBar != null) {
      return customWidgets.paintEditor.appBar!
          .call(this, rebuildController.stream);
    }

    return AppBar(
      automaticallyImplyLeading: false,
      backgroundColor: imageEditorTheme.paintingEditor.appBarBackgroundColor,
      foregroundColor: imageEditorTheme.paintingEditor.appBarForegroundColor,
      actions: _buildAction(constraints),
    );
  }

  /// Builds an action bar depending on the allowed space
  List<Widget> _buildAction(BoxConstraints constraints) {
    const int defaultIconButtonSize = 48;
    final List<StreamBuilder> configButtons = _getConfigButtons();
    final List<Widget> actionButtons = _getActionButtons();

    // Taking into account the back button
    final expandedIconButtonsSize =
        (1 + configButtons.length + actionButtons.length) *
            defaultIconButtonSize;

    return [
      IconButton(
        tooltip: i18n.paintEditor.back,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        icon: Icon(icons.backButton),
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
                icons.paintingEditor.lineWeight,
              ),
              onTap: openLineWeightBottomSheet,
            ),
          if (paintEditorConfigs.canToggleFill)
            PopupMenuOption(
              label: i18n.paintEditor.toggleFill,
              icon: Icon(
                !_fill
                    ? icons.paintingEditor.noFill
                    : icons.paintingEditor.fill,
              ),
              onTap: () {
                _fill = !_fill;
                setFill(_fill);
                if (designMode == ImageEditorDesignModeE.cupertino) {
                  Navigator.pop(context);
                }
              },
            ),
          if (paintEditorConfigs.canChangeOpacity)
            PopupMenuOption(
              label: i18n.paintEditor.changeOpacity,
              icon: Icon(
                icons.paintingEditor.changeOpacity,
              ),
              onTap: openOpacityBottomSheet,
            ),
          if (!hasEnoughSpace) ...[
            if (canUndo)
              PopupMenuOption(
                label: i18n.paintEditor.undo,
                icon: Icon(
                  icons.undoAction,
                ),
                onTap: undoAction,
              ),
            if (canRedo)
              PopupMenuOption(
                label: i18n.paintEditor.redo,
                icon: Icon(
                  icons.redoAction,
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
  List<StreamBuilder> _getConfigButtons() => [
        if (paintEditorConfigs.canChangeLineWidth)
          StreamBuilder(
              stream: _uiAppbarIconsStream.stream,
              builder: (context, snapshot) {
                return IconButton(
                  tooltip: i18n.paintEditor.lineWidth,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  icon: Icon(
                    icons.paintingEditor.lineWeight,
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
                        ? icons.paintingEditor.noFill
                        : icons.paintingEditor.fill,
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
                    icons.paintingEditor.changeOpacity,
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
                  icons.undoAction,
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
                  icons.redoAction,
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
      icon: Icon(icons.applyChanges),
      iconSize: 28,
      onPressed: done,
    );
  }

  /// Builds the main body of the painting editor.
  /// Returns a [Widget] representing the editor's body.
  Widget _buildBody() {
    return SafeArea(
      child: LayoutBuilder(builder: (context, constraints) {
        editorBodySize = constraints.biggest;
        return Theme(
          data: theme,
          child: Material(
            color: initConfigs.convertToUint8List
                ? imageEditorTheme.background
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
                        editorIsZoomable: paintEditorConfigs.editorIsZoomable,
                        minScale: paintEditorConfigs.editorMinScale,
                        maxScale: paintEditorConfigs.editorMaxScale,
                        enableInteraction: paintMode == PaintModeE.moveAndZoom,
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
                              if (!widget.paintingOnly)
                                TransformedContentGenerator(
                                  configs: configs,
                                  transformConfigs: transformConfigs ??
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
                                    blurFactor: appliedBlurFactor,
                                  ),
                                )
                              else
                                SizedBox(
                                  width: configs.imageGenerationConfigs
                                      .maxOutputSize.width,
                                  height: configs.imageGenerationConfigs
                                      .maxOutputSize.height,
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
                                    transformConfigs: transformConfigs,
                                  ),
                                ),
                              _buildPainter(),
                            ],
                          ),
                        ),
                      ),
                      _buildColorPicker(),
                      if (customWidgets.paintEditor.bodyItems != null)
                        ...customWidgets.paintEditor.bodyItems!(
                            this, rebuildController.stream),
                    ],
            ),
          ),
        );
      }),
    );
  }

  /// Builds the bottom navigation bar of the painting editor.
  /// Returns a [Widget] representing the bottom navigation bar.
  Widget? _buildBottomBar() {
    if (customWidgets.paintEditor.bottomBar != null) {
      return customWidgets.paintEditor.bottomBar!
          .call(this, rebuildController.stream);
    }

    if (paintModes.length <= 1) return const SizedBox.shrink();

    double minWidth = min(MediaQuery.of(context).size.width, 600);
    double maxWidth = max(
        (paintModes.length + (paintEditorConfigs.editorIsZoomable ? 1 : 0)) *
            80,
        minWidth);
    return Theme(
      data: theme,
      child: Scrollbar(
        controller: _bottomBarScrollCtrl,
        scrollbarOrientation: ScrollbarOrientation.top,
        thickness: isDesktop ? null : 0,
        child: BottomAppBar(
          height: kToolbarHeight,
          color: imageEditorTheme.paintingEditor.bottomBarColor,
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
                  Color getColor(PaintModeE mode) {
                    return paintMode == mode
                        ? imageEditorTheme
                            .paintingEditor.bottomBarActiveItemColor
                        : imageEditorTheme
                            .paintingEditor.bottomBarInactiveItemColor;
                  }

                  return Wrap(
                    direction: Axis.horizontal,
                    alignment: WrapAlignment.spaceAround,
                    runAlignment: WrapAlignment.spaceAround,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: <Widget>[
                      if (paintEditorConfigs.editorIsZoomable) ...[
                        FlatIconTextButton(
                          label: Text(
                            i18n.paintEditor.moveAndZoom,
                            style: TextStyle(
                              fontSize: 10.0,
                              color: getColor(PaintModeE.moveAndZoom),
                            ),
                          ),
                          icon: Icon(
                            icons.paintingEditor.moveAndZoom,
                            color: getColor(PaintModeE.moveAndZoom),
                          ),
                          onPressed: () {
                            setMode(PaintModeE.moveAndZoom);
                            setStateBottomBar(() {});
                          },
                        ),
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          height: kBottomNavigationBarHeight - 14,
                          width: 1,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(2),
                            color: imageEditorTheme
                                .paintingEditor.bottomBarInactiveItemColor,
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

  /// Builds the painting canvas for the editor.
  /// Returns a [Widget] representing the painting canvas.
  Widget _buildPainter() {
    return PaintingCanvas(
      key: _paintingCanvas,
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
      onStartPainting: () {
        rebuildController.add(null);
      },
      onCreatedPainting: () {
        _uiAppbarIconsStream.add(null);
        uiPickerStream.add(null);
        paintEditorCallbacks?.handleDrawingDone();
        WidgetsBinding.instance.addPostFrameCallback((_) async {
          takeScreenshot();
        });
      },
    );
  }

  /// Builds the color picker widget for selecting colors while painting.
  /// Returns a [Widget] representing the color picker.
  Widget _buildColorPicker() {
    if (customWidgets.paintEditor.colorPicker != null) {
      return customWidgets.paintEditor.colorPicker!.call(
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
            initialColor: imageEditorTheme.paintingEditor.initialColor,
            colorListener: (int value) {
              colorChanged(Color(value));
            },
          );
        },
      ),
    );
  }
}
