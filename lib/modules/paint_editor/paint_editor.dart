// Dart imports:
import 'dart:async';
import 'dart:io';
import 'dart:math';

// Flutter imports:
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Project imports:
import 'package:pro_image_editor/designs/whatsapp/whatsapp_painting_appbar.dart';
import 'package:pro_image_editor/designs/whatsapp/whatsapp_painting_bottombar.dart';
import 'package:pro_image_editor/mixins/converted_callbacks.dart';
import 'package:pro_image_editor/models/theme/theme.dart';
import 'package:pro_image_editor/utils/content_recorder.dart/content_recorder.dart';
import 'package:pro_image_editor/widgets/auto_image.dart';
import 'package:pro_image_editor/widgets/layer_stack.dart';
import '../../utils/transparent_image_bytes.dart';
import '../filter_editor/widgets/filtered_image.dart';
import '/mixins/converted_configs.dart';
import '/mixins/standalone_editor.dart';
import '/models/crop_rotate_editor/transform_factors.dart';
import '/models/editor_configs/paint_editor_configs.dart';
import '/models/editor_image.dart';
import '/models/init_configs/paint_editor_init_configs.dart';
import '/models/layer/layer.dart';
import '/models/paint_editor/paint_bottom_bar_item.dart';
import '/models/paint_editor/painted_model.dart';
import '/models/transform_helper.dart';
import '/utils/design_mode.dart';
import '/utils/pro_image_editor_mode.dart';
import '/utils/theme_functions.dart';
import '/widgets/bottom_sheets_header_row.dart';
import '/widgets/color_picker/bar_color_picker.dart';
import '/widgets/color_picker/color_picker_configs.dart';
import '/widgets/flat_icon_text_button.dart';
import '/widgets/platform_popup_menu.dart';
import '/widgets/transform/transformed_content_generator.dart';
import 'utils/paint_controller.dart';
import 'utils/paint_desktop_interaction_manager.dart';
import 'utils/paint_editor_enum.dart';
import 'widgets/painting_canvas.dart';

export './utils/paint_editor_enum.dart';
export './widgets/draw_painting.dart';
export '/models/paint_editor/paint_bottom_bar_item.dart';

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
  /// Controller for managing painting operations within the widget's context.
  late final PaintingController _paintCtrl;

  /// Update the color picker.
  late final StreamController _uiPickerStream;

  /// Update the appbar icons.
  late final StreamController _uiAppbarIconsStream;

  /// A ScrollController for controlling the scrolling behavior of the bottom navigation bar.
  late ScrollController _bottomBarScrollCtrl;

  /// A boolean flag representing whether the fill mode is enabled or disabled.
  bool _fill = false;

  /// Get the fillBackground status.
  bool get fillBackground => _fill;

  /// Determines whether undo actions can be performed on the current state.
  bool get canUndo => _paintCtrl.canUndo;

  /// Determines whether redo actions can be performed on the current state.
  bool get canRedo => _paintCtrl.canRedo;

  /// Manager class for handling desktop interactions.
  late final PaintDesktopInteractionManager _desktopInteractionManager;

  /// Get the current PaintMode.
  PaintModeE get paintMode => _paintCtrl.mode;

  /// Get the current strokeWidth.
  double get strokeWidth => _paintCtrl.strokeWidth;

  /// Get the active selected color.
  Color get activeColor => _paintCtrl.color;

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
      ];

  /// The Uint8List from the fake hero image, which is drawed when finish editing.
  Uint8List? _fakeHeroBytes;

  @override
  void initState() {
    super.initState();
    _paintCtrl = PaintingController(
      fill: paintEditorConfigs.initialFill,
      mode: paintEditorConfigs.initialPaintMode,
      strokeWidth: paintEditorConfigs.initialStrokeWidth,
      color: paintEditorConfigs.initialColor,
      strokeMultiplier: 1,
    );

    _fill = paintEditorConfigs.initialFill;
    _uiPickerStream = StreamController.broadcast();
    _uiAppbarIconsStream = StreamController.broadcast();
    _bottomBarScrollCtrl = ScrollController();
    _desktopInteractionManager =
        PaintDesktopInteractionManager(context: context);
    ServicesBinding.instance.keyboard.addHandler(_onKeyEvent);

    /// Important to set state after view init to set action icons
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      setState(() {});
      paintEditorCallbacks?.handleUpdateUI();
    });
  }

  @override
  void dispose() {
    _paintCtrl.dispose();
    _bottomBarScrollCtrl.dispose();
    _uiPickerStream.close();
    _uiAppbarIconsStream.close();
    ServicesBinding.instance.keyboard.removeHandler(_onKeyEvent);
    super.dispose();
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
                      theme: widget.initConfigs.theme,
                    ),
                    StatefulBuilder(builder: (context, setState) {
                      return Slider.adaptive(
                        max: 40,
                        min: 2,
                        divisions: 19,
                        value: _paintCtrl.strokeWidth,
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

  /// Sets the fill mode for drawing elements.
  /// When the `fill` parameter is `true`, drawing elements will be filled; otherwise, they will be outlined.
  void setFill(bool fill) {
    _paintCtrl.setFill(fill);
    _uiAppbarIconsStream.add(null);
    paintEditorCallbacks?.handleToggleFill(fill);
  }

  /// Toggles the fill mode.
  void toggleFill() {
    _fill = !_fill;
    setFill(_fill);
  }

  /// Set the PaintMode for the current state and trigger an update if provided.
  void setMode(PaintModeE mode) {
    _paintCtrl.setMode(mode);
    paintEditorCallbacks?.handlePaintModeChanged(mode);
  }

  /// Undoes the last action performed in the painting editor.
  void undoAction() {
    if (canUndo) screenshotHistoryPosition--;
    _paintCtrl.undo();
    _uiAppbarIconsStream.add(null);
    if (isWhatsAppDesign) {
      _uiPickerStream.add(null);
    }
    setState(() {});
    paintEditorCallbacks?.handleUndo();
  }

  /// Redoes the previously undone action in the painting editor.
  void redoAction() {
    if (canRedo) screenshotHistoryPosition++;
    _paintCtrl.redo();
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
    return _paintCtrl.activePaintings.map((e) {
      PaintedModel layer = PaintedModel(
        mode: e.mode,
        offsets: [...e.offsets],
        color: e.color,
        strokeWidth: e.strokeWidth,
        fill: e.fill,
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
        offset: finalOffset,
      );
    }).toList();
  }

  /// Set the stroke width.
  void setStrokeWidth(double value) {
    _paintCtrl.setStrokeWidth(value);
    callbacks.paintEditorCallbacks?.handleLineWidthChanged(value);
    setState(() {});
  }

  /// Handles changes in the selected color.
  void _colorChanged(Color color) {
    _paintCtrl.setColor(color);
    _uiPickerStream.add(null);
    paintEditorCallbacks?.handleColorChanged();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: imageEditorTheme.uiOverlayStyle,
      child: Theme(
        data: theme.copyWith(
            tooltipTheme: theme.tooltipTheme.copyWith(preferBelow: true)),
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
    );
  }

  /// Builds the app bar for the painting editor.
  /// Returns a [PreferredSizeWidget] representing the app bar.
  PreferredSizeWidget? _buildAppBar(BoxConstraints constraints) {
    return customWidgets.appBarPaintingEditor ??
        (!isWhatsAppDesign
            ? AppBar(
                automaticallyImplyLeading: false,
                backgroundColor:
                    imageEditorTheme.paintingEditor.appBarBackgroundColor,
                foregroundColor:
                    imageEditorTheme.paintingEditor.appBarForegroundColor,
                actions: [
                  IconButton(
                    tooltip: i18n.paintEditor.back,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    icon: Icon(icons.backButton),
                    onPressed: close,
                  ),
                  ...[
                    if (constraints.maxWidth >= 300) ...[
                      if (constraints.maxWidth >= 380)
                        const SizedBox(width: 80),
                      const Spacer(),
                      if (paintEditorConfigs.canChangeLineWidth)
                        StreamBuilder(
                            stream: _uiAppbarIconsStream.stream,
                            builder: (context, snapshot) {
                              return IconButton(
                                tooltip: i18n.paintEditor.lineWidth,
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 8),
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
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 8),
                                icon: Icon(
                                  !_fill
                                      ? icons.paintingEditor.noFill
                                      : icons.paintingEditor.fill,
                                  color: Colors.white,
                                ),
                                onPressed: toggleFill,
                              );
                            }),
                      if (constraints.maxWidth >= 380) const Spacer(),
                      StreamBuilder(
                          stream: _uiAppbarIconsStream.stream,
                          builder: (context, snapshot) {
                            return IconButton(
                              tooltip: i18n.paintEditor.undo,
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8),
                              icon: Icon(
                                icons.undoAction,
                                color: canUndo
                                    ? Colors.white
                                    : Colors.white.withAlpha(80),
                              ),
                              onPressed: undoAction,
                            );
                          }),
                      StreamBuilder(
                          stream: _uiAppbarIconsStream.stream,
                          builder: (context, snapshot) {
                            return IconButton(
                              tooltip: i18n.paintEditor.redo,
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8),
                              icon: Icon(
                                icons.redoAction,
                                color: canRedo
                                    ? Colors.white
                                    : Colors.white.withAlpha(80),
                              ),
                              onPressed: redoAction,
                            );
                          }),
                      _buildDoneBtn(),
                    ] else ...[
                      const Spacer(),
                      _buildDoneBtn(),
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
                                if (designMode ==
                                    ImageEditorDesignModeE.cupertino) {
                                  Navigator.pop(context);
                                }
                              },
                            ),
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
                        ],
                      ),
                    ],
                  ],
                ],
              )
            : null);
  }

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
                          designMode: designMode,
                        ),
                      ),
                    ]
                  : [
                      ContentRecorder(
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
                                  designMode: designMode,
                                  image: editorImage,
                                  filters: appliedFilters,
                                  blurFactor: appliedBlurFactor,
                                ),
                              )
                            else
                              SizedBox(
                                width: configs
                                    .imageGenerationConfigs.maxOutputSize.width,
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
                      if (paintEditorConfigs.showColorPicker &&
                          (!isMaterial ||
                              imageEditorTheme.editorMode ==
                                  ThemeEditorMode.simple))
                        _buildColorPicker(),
                      if (imageEditorTheme.editorMode ==
                          ThemeEditorMode.whatsapp) ...[
                        WhatsAppPaintBottomBar(
                          configs: configs,
                          strokeWidth: _paintCtrl.strokeWidth,
                          initColor: _paintCtrl.color,
                          onColorChanged: (color) {
                            _paintCtrl.setColor(color);
                            _uiPickerStream.add(null);
                            paintEditorCallbacks?.handleColorChanged();
                          },
                          onSetLineWidth: (val) {
                            setStrokeWidth(val);
                          },
                        ),
                        StreamBuilder(
                            stream: _uiPickerStream.stream,
                            builder: (context, snapshot) {
                              return WhatsAppPaintAppBar(
                                configs: configs,
                                canUndo: canUndo,
                                onDone: done,
                                onTapUndo: undoAction,
                                onClose: close,
                                activeColor: activeColor,
                              );
                            }),
                      ],
                      if (customWidgets.paintEditorBodyItem != null)
                        customWidgets.paintEditorBodyItem!
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
    if (paintModes.length <= 1) return const SizedBox.shrink();
    return customWidgets.bottomBarPaintingEditor ??
        (!isWhatsAppDesign
            ? Theme(
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
                            minWidth:
                                min(MediaQuery.of(context).size.width, 500),
                            maxWidth: 500,
                          ),
                          child: StatefulBuilder(
                              builder: (context, setStateBottomBar) {
                            return Wrap(
                              direction: Axis.horizontal,
                              alignment: WrapAlignment.spaceAround,
                              children: <Widget>[
                                ...List.generate(
                                  paintModes.length,
                                  (index) => Builder(
                                    builder: (_) {
                                      PaintModeBottomBarItem item =
                                          paintModes[index];
                                      Color color = paintMode == item.mode
                                          ? imageEditorTheme.paintingEditor
                                              .bottomBarActiveItemColor
                                          : imageEditorTheme.paintingEditor
                                              .bottomBarInactiveItemColor;

                                      return FlatIconTextButton(
                                        label: Text(
                                          item.label,
                                          style: TextStyle(
                                              fontSize: 10.0, color: color),
                                        ),
                                        icon: Icon(item.icon, color: color),
                                        onPressed: () {
                                          setMode(item.mode);
                                          setStateBottomBar(() {});
                                        },
                                      );
                                    },
                                  ),
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
            : null);
  }

  /// Builds the painting canvas for the editor.
  /// Returns a [Widget] representing the painting canvas.
  Widget _buildPainter() {
    return PaintingCanvas(
      paintCtrl: _paintCtrl,
      drawAreaSize: mainBodySize ?? editorBodySize,
      onCreatedPainting: () {
        _uiAppbarIconsStream.add(null);
        if (isWhatsAppDesign) {
          _uiPickerStream.add(null);
        }
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
    return Positioned(
      top: isWhatsAppDesign ? 60 : 10,
      right: isWhatsAppDesign ? 16 : 0,
      child: StreamBuilder(
          stream: _uiPickerStream.stream,
          builder: (context, snapshot) {
            return customWidgets.colorPickerPaintEditor?.call(_colorChanged) ??
                BarColorPicker(
                  configs: configs,
                  length: min(
                    !isWhatsAppDesign ? 350 : 200,
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
                  initialColor: paintEditorConfigs.initialColor,
                  colorListener: (int value) {
                    _colorChanged(Color(value));
                  },
                );
          }),
    );
  }
}
