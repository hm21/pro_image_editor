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
import 'package:pro_image_editor/models/init_configs/paint_canvas_init_configs.dart';
import 'package:pro_image_editor/models/theme/theme.dart';
import 'package:pro_image_editor/utils/content_recorder.dart/content_recorder.dart';
import 'package:pro_image_editor/widgets/auto_image.dart';
import 'package:pro_image_editor/widgets/layer_stack.dart';
import '../../mixins/converted_configs.dart';
import '../../mixins/standalone_editor.dart';
import '../../models/crop_rotate_editor/transform_factors.dart';
import '../../models/editor_configs/paint_editor_configs.dart';
import '../../models/editor_image.dart';
import '../../models/init_configs/paint_editor_init_configs.dart';
import '../../models/paint_editor/paint_bottom_bar_item.dart';
import '../../models/transform_helper.dart';
import '../../utils/design_mode.dart';
import '../../utils/theme_functions.dart';
import '../../widgets/color_picker/bar_color_picker.dart';
import '../../widgets/color_picker/color_picker_configs.dart';
import '../../widgets/flat_icon_text_button.dart';
import '../../widgets/platform_popup_menu.dart';
import '../../widgets/pro_image_editor_desktop_mode.dart';
import '../../widgets/transform/transformed_content_generator.dart';
import '../filter_editor/widgets/image_with_filters.dart';
import 'painting_canvas.dart';
import 'utils/paint_desktop_interaction_manager.dart';
import 'utils/paint_editor_enum.dart';

/// The `PaintingEditor` widget allows users to editing images with painting tools.
///
/// You can create a `PaintingEditor` using one of the factory methods provided:
/// - `PaintingEditor.file`: Loads an image from a file.
/// - `PaintingEditor.asset`: Loads an image from an asset.
/// - `PaintingEditor.network`: Loads an image from a network URL.
/// - `PaintingEditor.memory`: Loads an image from memory as a `Uint8List`.
/// - `PaintingEditor.autoSource`: Automatically selects the source based on provided parameters.
class PaintingEditor extends StatefulWidget
    with StandaloneEditor<PaintEditorInitConfigs> {
  @override
  final PaintEditorInitConfigs initConfigs;
  @override
  final EditorImage editorImage;

  /// Constructs a `PaintingEditor` widget.
  ///
  /// The [key] parameter is used to provide a key for the widget.
  /// The [editorImage] parameter specifies the image to be edited.
  /// The [initConfigs] parameter specifies the initialization configurations for the editor.
  const PaintingEditor._({
    super.key,
    required this.editorImage,
    required this.initConfigs,
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
        StandaloneEditorState<PaintingEditor, PaintEditorInitConfigs> {
  /// A global key for accessing the state of the PaintingCanvas widget.
  final _imageKey = GlobalKey<PaintingCanvasState>();

  /// A global key for accessing the state of the Scaffold widget.
  final _key = GlobalKey<ScaffoldState>();

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
  bool get canUndo => _imageKey.currentState?.canUndo == true;

  /// Determines whether redo actions can be performed on the current state.
  bool get canRedo => _imageKey.currentState?.canRedo == true;

  /// Manager class for handling desktop interactions.
  late final PaintDesktopInteractionManager _desktopInteractionManager;

  /// Get the current PaintMode from the ImageKey's currentState.
  PaintModeE? get paintMode => _imageKey.currentState?.mode;

  /// Get the current PaintMode.
  PaintModeE? get mode => _imageKey.currentState?.mode;

  /// Get the active selected color.
  Color get activeColor =>
      _imageKey.currentState?.activeColor ?? Colors.black38;

  /// A list of [PaintModeBottomBarItem] representing the available drawing modes in the painting editor.
  /// The list is dynamically generated based on the configuration settings in the [PaintEditorConfigs] object.
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
      onUpdateUI?.call();
    });
  }

  @override
  void dispose() {
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
    _imageKey.currentState!.showRangeSlider();
  }

  /// Sets the fill mode for drawing elements.
  /// When the `fill` parameter is `true`, drawing elements will be filled; otherwise, they will be outlined.
  void setFill(bool fill) {
    _imageKey.currentState?.setFill(fill);
    _uiAppbarIconsStream.add(null);
    onUpdateUI?.call();
  }

  /// Toggles the fill mode.
  void toggleFill() {
    _fill = !_fill;
    setFill(_fill);
  }

  /// Set the PaintMode for the current state and trigger an update if provided.
  void setMode(PaintModeE mode) {
    if (_imageKey.currentState != null) {
      _imageKey.currentState!.mode = mode;
    }
    onUpdateUI?.call();
  }

  /// Undoes the last action performed in the painting editor.
  void undoAction() {
    if (_imageKey.currentState!.canUndo) historyPosition--;
    _imageKey.currentState!.undo();
    _uiAppbarIconsStream.add(null);
    if (imageEditorTheme.editorMode == ThemeEditorMode.whatsapp) {
      _uiPickerStream.add(null);
    }
    onUpdateUI?.call();
  }

  /// Redoes the previously undone action in the painting editor.
  void redoAction() {
    if (_imageKey.currentState!.canRedo) historyPosition++;
    _imageKey.currentState!.redo();
    _uiAppbarIconsStream.add(null);
    onUpdateUI?.call();
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
          if (!_imageKey.currentState!.canUndo) return Navigator.pop(context);
          Navigator.of(context).pop(
            _imageKey.currentState?.exportPaintedItems(editorBodySize),
          );
        });
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
            key: _key,
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
        (imageEditorTheme.editorMode == ThemeEditorMode.simple
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
                  if (_imageKey.currentState != null) ...[
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
                          if (_imageKey.currentState!.canUndo)
                            PopupMenuOption(
                              label: i18n.paintEditor.undo,
                              icon: Icon(
                                icons.undoAction,
                              ),
                              onTap: undoAction,
                            ),
                          if (_imageKey.currentState!.canRedo)
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
            color: Colors.transparent,
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
                            TransformedContentGenerator(
                              configs: configs,
                              transformConfigs:
                                  transformConfigs ?? TransformConfigs.empty(),
                              child: ImageWithFilters(
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
                      if (paintEditorConfigs.showColorPicker)
                        _buildColorPicker(),
                      if (imageEditorTheme.editorMode ==
                          ThemeEditorMode.whatsapp) ...[
                        WhatsAppPaintBottomBar(
                          configs: configs,
                          strokeWidth:
                              _imageKey.currentState?.strokeWidth ?? 0.0,
                          onSetLineWidth: (val) {
                            setState(() {
                              _imageKey.currentState!.setStrokeWidth(val);
                            });
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
        (imageEditorTheme.editorMode == ThemeEditorMode.simple
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
                                      var item = paintModes[index];
                                      var color =
                                          _imageKey.currentState?.mode ==
                                                  item.mode
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
                                          onUpdateUI?.call();
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
    return PaintingCanvas.autoSource(
      key: _imageKey,
      file: widget.editorImage.file,
      networkUrl: widget.editorImage.networkUrl,
      byteArray: widget.editorImage.byteArray,
      assetPath: widget.editorImage.assetPath,
      initConfigs: PaintCanvasInitConfigs(
        i18n: i18n,
        icons: icons,
        theme: theme,
        designMode: designMode,
        drawAreaSize: mainBodySize ?? editorBodySize,
        imageEditorTheme: imageEditorTheme,
        configs: paintEditorConfigs,
        onUpdateDone: () {
          _uiAppbarIconsStream.add(null);
          if (imageEditorTheme.editorMode == ThemeEditorMode.whatsapp) {
            _uiPickerStream.add(null);
          }
          onUpdateUI?.call();
          WidgetsBinding.instance.addPostFrameCallback((_) async {
            takeScreenshot();
          });
        },
      ),
    );
  }

  /// Builds the color picker widget for selecting colors while painting.
  /// Returns a [Widget] representing the color picker.
  Widget _buildColorPicker() {
    return Positioned(
      top: imageEditorTheme.editorMode == ThemeEditorMode.simple ? 10 : 60,
      right: 0,
      child: StreamBuilder(
          stream: _uiPickerStream.stream,
          builder: (context, snapshot) {
            return BarColorPicker(
              configs: configs,
              length: min(
                imageEditorTheme.editorMode == ThemeEditorMode.simple
                    ? 350
                    : 200,
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
                _imageKey.currentState?.setColor(value);
                _uiPickerStream.add(null);
              },
            );
          }),
    );
  }
}
