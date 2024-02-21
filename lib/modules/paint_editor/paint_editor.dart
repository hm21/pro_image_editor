import 'dart:io';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../models/custom_widgets.dart';
import '../../models/editor_configs/paint_editor_configs.dart';
import '../../models/editor_image.dart';
import '../../models/filter_state_history.dart';
import '../../models/paint_editor/paint_bottom_bar_item.dart';
import '../../models/theme/theme.dart';
import '../../models/i18n/i18n.dart';
import '../../models/icons/icons.dart';
import '../../models/layer.dart';
import '../../utils/design_mode.dart';
import '../../utils/theme_functions.dart';
import '../../widgets/color_picker/bar_color_picker.dart';
import '../../widgets/color_picker/color_picker_configs.dart';
import '../../widgets/flat_icon_text_button.dart';
import '../../widgets/layer_widget.dart';
import '../../widgets/platform_popup_menu.dart';
import '../../widgets/pro_image_editor_desktop_mode.dart';
import '../filter_editor/widgets/image_with_multiple_filters.dart';
import 'painting_canvas.dart';
import 'utils/paint_editor_enum.dart';

/// A StatefulWidget that represents an image editor with painting capabilities.
class PaintingEditor extends StatefulWidget {
  /// A Uint8List representing the image data in memory.
  final Uint8List? byteArray;

  /// The asset path of the image.
  final String? assetPath;

  /// The network URL of the image.
  final String? networkUrl;

  /// A File representing the image file.
  final File? file;

  /// A list of Layer objects representing image layers.
  final List<Layer>? layers;

  /// The overall theme for the editor, including colors and styles.
  final ThemeData theme;

  /// Custom widget overrides for the editor.
  final ImageEditorCustomWidgets customWidgets;

  /// Internationalization settings for text localization.
  final I18n i18n;

  /// The size of the image.
  final Size imageSize;

  /// Icons used within the editor.
  final ImageEditorIcons icons;

  /// The design mode of the editor (e.g., material or custom).
  final ImageEditorDesignModeE designMode;

  /// The theme specific to the painting editor.
  final ImageEditorTheme imageEditorTheme;

  /// Configuration options for the painting editor.
  final PaintEditorConfigs configs;

  /// Additional padding for the editor.
  final EdgeInsets? paddingHelper;

  /// The font size for text layers within the editor.
  final double layerFontSize;

  /// The initial width of the stickers in the editor.
  final double stickerInitWidth;

  /// Custom emoji text style to apply to emoji characters in the grid.
  final TextStyle emojiTextStyle;

  /// A callback function that can be used to update the UI from custom widgets.
  final Function? onUpdateUI;

  /// A list of applied filters to the editor.
  final List<FilterStateHistory> filters;

  /// Constructs a PaintingEditor instance.
  ///
  /// The `PaintingEditor._` constructor should not be directly used. Instead, use one of the factory constructors.
  const PaintingEditor._({
    super.key,
    this.byteArray,
    this.assetPath,
    this.networkUrl,
    this.file,
    required this.theme,
    this.imageEditorTheme = const ImageEditorTheme(),
    this.configs = const PaintEditorConfigs(),
    this.i18n = const I18n(),
    this.customWidgets = const ImageEditorCustomWidgets(),
    this.icons = const ImageEditorIcons(),
    required this.imageSize,
    this.layers,
    this.onUpdateUI,
    this.emojiTextStyle = const TextStyle(),
    this.paddingHelper,
    this.layerFontSize = 24,
    this.stickerInitWidth = 100,
    this.designMode = ImageEditorDesignModeE.material,
    required this.filters,
  }) : assert(
          byteArray != null ||
              file != null ||
              networkUrl != null ||
              assetPath != null,
          'At least one of bytes, file, networkUrl, or assetPath must not be null.',
        );

  ///Constructor for loading image from memory.
  factory PaintingEditor.memory(
    Uint8List byteArray, {
    Key? key,
    required ThemeData theme,
    I18n i18n = const I18n(),
    ImageEditorCustomWidgets customWidgets = const ImageEditorCustomWidgets(),
    ImageEditorIcons icons = const ImageEditorIcons(),
    ImageEditorDesignModeE designMode = ImageEditorDesignModeE.material,
    ImageEditorTheme imageEditorTheme = const ImageEditorTheme(),
    PaintEditorConfigs configs = const PaintEditorConfigs(),
    required Size imageSize,
    List<Layer>? layers,
    EdgeInsets? paddingHelper,
    double layerFontSize = 24.0,
    double stickerInitWidth = 100.0,
    TextStyle emojiTextStyle = const TextStyle(),
    Function? onUpdateUI,
    List<FilterStateHistory>? filters,
  }) {
    return PaintingEditor._(
      key: key,
      byteArray: byteArray,
      onUpdateUI: onUpdateUI,
      theme: theme,
      i18n: i18n,
      customWidgets: customWidgets,
      stickerInitWidth: stickerInitWidth,
      icons: icons,
      designMode: designMode,
      imageEditorTheme: imageEditorTheme,
      imageSize: imageSize,
      layers: layers,
      paddingHelper: paddingHelper,
      configs: configs,
      layerFontSize: layerFontSize,
      emojiTextStyle: emojiTextStyle,
      filters: filters ?? [],
    );
  }

  /// Constructor for loading image from [File].
  factory PaintingEditor.file(
    File file, {
    Key? key,
    required ThemeData theme,
    I18n i18n = const I18n(),
    ImageEditorCustomWidgets customWidgets = const ImageEditorCustomWidgets(),
    ImageEditorIcons icons = const ImageEditorIcons(),
    ImageEditorDesignModeE designMode = ImageEditorDesignModeE.material,
    ImageEditorTheme imageEditorTheme = const ImageEditorTheme(),
    PaintEditorConfigs configs = const PaintEditorConfigs(),
    required Size imageSize,
    List<Layer>? layers,
    EdgeInsets? paddingHelper,
    double layerFontSize = 24.0,
    double stickerInitWidth = 100.0,
    TextStyle emojiTextStyle = const TextStyle(),
    Function? onUpdateUI,
    List<FilterStateHistory>? filters,
  }) {
    return PaintingEditor._(
      key: key,
      file: file,
      theme: theme,
      i18n: i18n,
      customWidgets: customWidgets,
      stickerInitWidth: stickerInitWidth,
      icons: icons,
      designMode: designMode,
      imageEditorTheme: imageEditorTheme,
      imageSize: imageSize,
      layers: layers,
      paddingHelper: paddingHelper,
      configs: configs,
      onUpdateUI: onUpdateUI,
      filters: filters ?? [],
    );
  }

  /// Constructor for loading image from assetPath.
  factory PaintingEditor.asset(
    String assetPath, {
    Key? key,
    required ThemeData theme,
    I18n i18n = const I18n(),
    ImageEditorCustomWidgets customWidgets = const ImageEditorCustomWidgets(),
    ImageEditorIcons icons = const ImageEditorIcons(),
    ImageEditorDesignModeE designMode = ImageEditorDesignModeE.material,
    ImageEditorTheme imageEditorTheme = const ImageEditorTheme(),
    PaintEditorConfigs configs = const PaintEditorConfigs(),
    required Size imageSize,
    List<Layer>? layers,
    EdgeInsets? paddingHelper,
    double layerFontSize = 24.0,
    double stickerInitWidth = 100.0,
    TextStyle emojiTextStyle = const TextStyle(),
    Function? onUpdateUI,
    List<FilterStateHistory>? filters,
  }) {
    return PaintingEditor._(
      key: key,
      assetPath: assetPath,
      theme: theme,
      i18n: i18n,
      customWidgets: customWidgets,
      stickerInitWidth: stickerInitWidth,
      icons: icons,
      designMode: designMode,
      imageEditorTheme: imageEditorTheme,
      imageSize: imageSize,
      layers: layers,
      paddingHelper: paddingHelper,
      configs: configs,
      onUpdateUI: onUpdateUI,
      filters: filters ?? [],
    );
  }

  /// Constructor for loading image from network url.
  factory PaintingEditor.network(
    String networkUrl, {
    Key? key,
    required ThemeData theme,
    I18n i18n = const I18n(),
    ImageEditorCustomWidgets customWidgets = const ImageEditorCustomWidgets(),
    ImageEditorIcons icons = const ImageEditorIcons(),
    ImageEditorDesignModeE designMode = ImageEditorDesignModeE.material,
    ImageEditorTheme imageEditorTheme = const ImageEditorTheme(),
    PaintEditorConfigs configs = const PaintEditorConfigs(),
    required Size imageSize,
    List<Layer>? layers,
    EdgeInsets? paddingHelper,
    double layerFontSize = 24.0,
    double stickerInitWidth = 100.0,
    TextStyle emojiTextStyle = const TextStyle(),
    Function? onUpdateUI,
    List<FilterStateHistory>? filters,
  }) {
    return PaintingEditor._(
      key: key,
      networkUrl: networkUrl,
      theme: theme,
      i18n: i18n,
      customWidgets: customWidgets,
      stickerInitWidth: stickerInitWidth,
      icons: icons,
      designMode: designMode,
      imageEditorTheme: imageEditorTheme,
      imageSize: imageSize,
      layers: layers,
      paddingHelper: paddingHelper,
      configs: configs,
      onUpdateUI: onUpdateUI,
      filters: filters ?? [],
    );
  }

  /// Constructor for automatic source selection based on properties
  factory PaintingEditor.autoSource({
    Key? key,
    required ThemeData theme,
    I18n i18n = const I18n(),
    ImageEditorCustomWidgets customWidgets = const ImageEditorCustomWidgets(),
    ImageEditorIcons icons = const ImageEditorIcons(),
    ImageEditorDesignModeE designMode = ImageEditorDesignModeE.material,
    ImageEditorTheme imageEditorTheme = const ImageEditorTheme(),
    PaintEditorConfigs configs = const PaintEditorConfigs(),
    required Size imageSize,
    Uint8List? byteArray,
    File? file,
    String? assetPath,
    String? networkUrl,
    List<Layer>? layers,
    EdgeInsets? paddingHelper,
    double layerFontSize = 24.0,
    double stickerInitWidth = 100.0,
    TextStyle emojiTextStyle = const TextStyle(),
    Function? onUpdateUI,
    List<FilterStateHistory>? filters,
  }) {
    if (byteArray != null) {
      return PaintingEditor.memory(
        byteArray,
        key: key,
        theme: theme,
        i18n: i18n,
        customWidgets: customWidgets,
        stickerInitWidth: stickerInitWidth,
        icons: icons,
        designMode: designMode,
        imageEditorTheme: imageEditorTheme,
        imageSize: imageSize,
        layers: layers,
        paddingHelper: paddingHelper,
        configs: configs,
        onUpdateUI: onUpdateUI,
        filters: filters,
      );
    } else if (file != null) {
      return PaintingEditor.file(
        file,
        key: key,
        theme: theme,
        i18n: i18n,
        customWidgets: customWidgets,
        stickerInitWidth: stickerInitWidth,
        icons: icons,
        designMode: designMode,
        imageEditorTheme: imageEditorTheme,
        imageSize: imageSize,
        layers: layers,
        paddingHelper: paddingHelper,
        configs: configs,
        onUpdateUI: onUpdateUI,
        filters: filters,
      );
    } else if (networkUrl != null) {
      return PaintingEditor.network(
        networkUrl,
        key: key,
        theme: theme,
        i18n: i18n,
        customWidgets: customWidgets,
        stickerInitWidth: stickerInitWidth,
        icons: icons,
        designMode: designMode,
        imageEditorTheme: imageEditorTheme,
        imageSize: imageSize,
        layers: layers,
        paddingHelper: paddingHelper,
        configs: configs,
        onUpdateUI: onUpdateUI,
        filters: filters,
      );
    } else if (assetPath != null) {
      return PaintingEditor.asset(
        assetPath,
        key: key,
        theme: theme,
        i18n: i18n,
        customWidgets: customWidgets,
        stickerInitWidth: stickerInitWidth,
        icons: icons,
        designMode: designMode,
        imageEditorTheme: imageEditorTheme,
        imageSize: imageSize,
        layers: layers,
        paddingHelper: paddingHelper,
        configs: configs,
        onUpdateUI: onUpdateUI,
        filters: filters,
      );
    } else {
      throw ArgumentError(
          "Either 'byteArray', 'file', 'networkUrl' or 'assetPath' must be provided.");
    }
  }

  @override
  State<PaintingEditor> createState() => PaintingEditorState();
}

class PaintingEditorState extends State<PaintingEditor> {
  /// A global key for accessing the state of the PaintingCanvas widget.
  final _imageKey = GlobalKey<PaintingCanvasState>();

  /// A global key for accessing the state of the Scaffold widget.
  final _key = GlobalKey<ScaffoldState>();

  /// An instance of the EditorImage class representing the image to be edited.
  late EditorImage _editorImage;

  /// A ScrollController for controlling the scrolling behavior of the bottom navigation bar.
  late ScrollController _bottomBarScrollCtrl;

  /// A boolean flag representing whether the fill mode is enabled or disabled.
  bool _fill = false;

  @override
  void initState() {
    _fill = widget.configs.initialFill;
    _bottomBarScrollCtrl = ScrollController();

    _editorImage = EditorImage(
      assetPath: widget.assetPath,
      byteArray: widget.byteArray,
      file: widget.file,
      networkUrl: widget.networkUrl,
    );

    /// Important to set state after view init to set action icons
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      setState(() {});
      widget.onUpdateUI?.call();
    });
    super.initState();
  }

  @override
  void dispose() {
    _bottomBarScrollCtrl.dispose();
    super.dispose();
  }

  /// A list of [PaintModeBottomBarItem] representing the available drawing modes in the painting editor.
  /// The list is dynamically generated based on the configuration settings in the [PaintEditorConfigs] object.
  List<PaintModeBottomBarItem> get paintModes => [
        if (widget.configs.hasOptionFreeStyle)
          PaintModeBottomBarItem(
            mode: PaintModeE.freeStyle,
            icon: widget.icons.paintingEditor.freeStyle,
            label: widget.i18n.paintEditor.freestyle,
          ),
        if (widget.configs.hasOptionArrow)
          PaintModeBottomBarItem(
            mode: PaintModeE.arrow,
            icon: widget.icons.paintingEditor.arrow,
            label: widget.i18n.paintEditor.arrow,
          ),
        if (widget.configs.hasOptionLine)
          PaintModeBottomBarItem(
            mode: PaintModeE.line,
            icon: widget.icons.paintingEditor.line,
            label: widget.i18n.paintEditor.line,
          ),
        if (widget.configs.hasOptionRect)
          PaintModeBottomBarItem(
            mode: PaintModeE.rect,
            icon: widget.icons.paintingEditor.rectangle,
            label: widget.i18n.paintEditor.rectangle,
          ),
        if (widget.configs.hasOptionCircle)
          PaintModeBottomBarItem(
            mode: PaintModeE.circle,
            icon: widget.icons.paintingEditor.circle,
            label: widget.i18n.paintEditor.circle,
          ),
        if (widget.configs.hasOptionDashLine)
          PaintModeBottomBarItem(
            mode: PaintModeE.dashLine,
            icon: widget.icons.paintingEditor.dashLine,
            label: widget.i18n.paintEditor.dashLine,
          ),
      ];

  /// Opens a bottom sheet to adjust the line weight when drawing.
  void openLineWeightBottomSheet() {
    _imageKey.currentState!.showRangeSlider();
  }

  /// Sets the fill mode for drawing elements.
  /// When the `fill` parameter is `true`, drawing elements will be filled; otherwise, they will be outlined.
  void setFill(bool fill) {
    _imageKey.currentState?.setFill(fill);
    setState(() {});
    widget.onUpdateUI?.call();
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
    widget.onUpdateUI?.call();
  }

  /// Undoes the last action performed in the painting editor.
  void undoAction() {
    _imageKey.currentState!.undo();
    setState(() {});
    widget.onUpdateUI?.call();
  }

  /// Redoes the previously undone action in the painting editor.
  void redoAction() {
    _imageKey.currentState!.redo();
    setState(() {});
    widget.onUpdateUI?.call();
  }

  /// Closes the editor without applying changes.
  void close() {
    Navigator.pop(context);
  }

  /// Finishes editing in the painting editor and returns the painted items as a result.
  /// If no changes have been made, it closes the editor without returning any changes.
  void done() async {
    if (!_imageKey.currentState!.canUndo) return Navigator.pop(context);
    Navigator.of(context).pop(_imageKey.currentState?.exportPaintedItems());
  }

  /// Determines whether undo actions can be performed on the current state.
  bool get canUndo => _imageKey.currentState?.canUndo == true;

  /// Determines whether redo actions can be performed on the current state.
  bool get canRedo => _imageKey.currentState?.canRedo == true;

  /// Get the current PaintMode from the ImageKey's currentState.
  PaintModeE? get paintMode => _imageKey.currentState?.mode;

  /// Get the current PaintMode.
  PaintModeE? get mode => _imageKey.currentState?.mode;

  /// Get the fillBackground status.
  bool get fillBackground => _fill;

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: widget.imageEditorTheme.uiOverlayStyle,
      child: Theme(
        data: widget.theme.copyWith(
            tooltipTheme:
                widget.theme.tooltipTheme.copyWith(preferBelow: true)),
        child: LayoutBuilder(builder: (context, constraints) {
          return Scaffold(
            resizeToAvoidBottomInset: false,
            extendBodyBehindAppBar: true,
            backgroundColor: widget.imageEditorTheme.paintingEditor.background,
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
  PreferredSizeWidget _buildAppBar(BoxConstraints constraints) {
    return widget.customWidgets.appBarPaintingEditor ??
        AppBar(
          automaticallyImplyLeading: false,
          backgroundColor:
              widget.imageEditorTheme.paintingEditor.appBarBackgroundColor,
          foregroundColor:
              widget.imageEditorTheme.paintingEditor.appBarForegroundColor,
          actions: [
            IconButton(
              tooltip: widget.i18n.paintEditor.back,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              icon: Icon(widget.icons.backButton),
              onPressed: close,
            ),
            if (_imageKey.currentState != null) ...[
              if (constraints.maxWidth >= 300) ...[
                if (constraints.maxWidth >= 380) const SizedBox(width: 80),
                const Spacer(),
                if (widget.configs.canChangeLineWidth)
                  IconButton(
                    tooltip: widget.i18n.paintEditor.lineWidth,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    icon: Icon(
                      widget.icons.paintingEditor.lineWeight,
                      color: Colors.white,
                    ),
                    onPressed: openLineWeightBottomSheet,
                  ),
                if (widget.configs.canToggleFill)
                  IconButton(
                    tooltip: widget.i18n.paintEditor.toggleFill,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    icon: Icon(
                      !_fill
                          ? widget.icons.paintingEditor.noFill
                          : widget.icons.paintingEditor.fill,
                      color: Colors.white,
                    ),
                    onPressed: toggleFill,
                  ),
                if (constraints.maxWidth >= 380) const Spacer(),
                IconButton(
                  tooltip: widget.i18n.paintEditor.undo,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  icon: Icon(
                    widget.icons.undoAction,
                    color: canUndo ? Colors.white : Colors.white.withAlpha(80),
                  ),
                  onPressed: undoAction,
                ),
                IconButton(
                  tooltip: widget.i18n.paintEditor.redo,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  icon: Icon(
                    widget.icons.redoAction,
                    color: canRedo ? Colors.white : Colors.white.withAlpha(80),
                  ),
                  onPressed: redoAction,
                ),
                _buildDoneBtn(),
              ] else ...[
                const Spacer(),
                _buildDoneBtn(),
                PlatformPopupBtn(
                  designMode: widget.designMode,
                  title: widget.i18n.paintEditor.smallScreenMoreTooltip,
                  options: [
                    if (widget.configs.canChangeLineWidth)
                      PopupMenuOption(
                        label: widget.i18n.paintEditor.lineWidth,
                        icon: Icon(
                          widget.icons.paintingEditor.lineWeight,
                        ),
                        onTap: openLineWeightBottomSheet,
                      ),
                    if (widget.configs.canToggleFill)
                      PopupMenuOption(
                        label: widget.i18n.paintEditor.toggleFill,
                        icon: Icon(
                          !_fill
                              ? widget.icons.paintingEditor.noFill
                              : widget.icons.paintingEditor.fill,
                        ),
                        onTap: () {
                          _fill = !_fill;
                          setFill(_fill);
                          if (widget.designMode ==
                              ImageEditorDesignModeE.cupertino) {
                            Navigator.pop(context);
                          }
                        },
                      ),
                    if (_imageKey.currentState!.canUndo)
                      PopupMenuOption(
                        label: widget.i18n.paintEditor.undo,
                        icon: Icon(
                          widget.icons.undoAction,
                        ),
                        onTap: undoAction,
                      ),
                    if (_imageKey.currentState!.canRedo)
                      PopupMenuOption(
                        label: widget.i18n.paintEditor.redo,
                        icon: Icon(
                          widget.icons.redoAction,
                        ),
                        onTap: redoAction,
                      ),
                  ],
                ),
              ],
            ],
          ],
        );
  }

  /// Builds and returns an IconButton for applying changes.
  Widget _buildDoneBtn() {
    return IconButton(
      tooltip: widget.i18n.paintEditor.done,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      icon: Icon(widget.icons.applyChanges),
      iconSize: 28,
      onPressed: done,
    );
  }

  /// Builds the main body of the painting editor.
  /// Returns a [Widget] representing the editor's body.
  Widget _buildBody() {
    return SafeArea(
      child: Theme(
        data: widget.theme,
        child: Material(
          color: Colors.transparent,
          textStyle: platformTextStyle(context, widget.designMode),
          child: Stack(
            alignment: Alignment.center,
            clipBehavior: Clip.none,
            children: [
              ImageWithMultipleFilters(
                width: widget.imageSize.width,
                height: widget.imageSize.height,
                designMode: widget.designMode,
                image: EditorImage(
                  assetPath: widget.assetPath,
                  byteArray: widget.byteArray,
                  file: widget.file,
                  networkUrl: widget.networkUrl,
                ),
                filters: widget.filters,
              ),
              if (widget.layers != null) _buildLayerStack(),
              _buildPainter(),
              if (widget.configs.showColorPicker) _buildColorPicker(),
            ],
          ),
        ),
      ),
    );
  }

  /// Builds the bottom navigation bar of the painting editor.
  /// Returns a [Widget] representing the bottom navigation bar.
  Widget _buildBottomBar() {
    if (paintModes.length <= 1) return const SizedBox.shrink();
    return widget.customWidgets.bottomBarPaintingEditor ??
        Theme(
          data: widget.theme,
          child: Scrollbar(
            controller: _bottomBarScrollCtrl,
            scrollbarOrientation: ScrollbarOrientation.top,
            thickness: isDesktop ? null : 0,
            child: BottomAppBar(
              height: kToolbarHeight,
              color: widget.imageEditorTheme.paintingEditor.bottomBarColor,
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
                    child: Wrap(
                      direction: Axis.horizontal,
                      alignment: WrapAlignment.spaceAround,
                      children: <Widget>[
                        ...List.generate(
                          paintModes.length,
                          (index) => Builder(
                            builder: (_) {
                              var item = paintModes[index];
                              var color =
                                  _imageKey.currentState?.mode == item.mode
                                      ? widget.imageEditorTheme.paintingEditor
                                          .bottomBarActiveItemColor
                                      : widget.imageEditorTheme.paintingEditor
                                          .bottomBarInactiveItemColor;

                              return FlatIconTextButton(
                                label: Text(
                                  item.label,
                                  style:
                                      TextStyle(fontSize: 10.0, color: color),
                                ),
                                icon: Icon(item.icon, color: color),
                                onPressed: () {
                                  setMode(item.mode);
                                  setState(() {});
                                  widget.onUpdateUI?.call();
                                },
                              );
                            },
                          ),
                        ),
                      ],
                    ),
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
    return PaintingCanvas.autoSource(
      key: _imageKey,
      file: _editorImage.file,
      networkUrl: _editorImage.networkUrl,
      byteArray: _editorImage.byteArray,
      assetPath: _editorImage.assetPath,
      i18n: widget.i18n,
      icons: widget.icons,
      theme: widget.theme,
      designMode: widget.designMode,
      imageSize: widget.imageSize,
      imageEditorTheme: widget.imageEditorTheme,
      configs: widget.configs,
      onUpdate: () {
        setState(() {});
        widget.onUpdateUI?.call();
      },
    );
  }

  /// Builds the color picker widget for selecting colors while painting.
  /// Returns a [Widget] representing the color picker.
  Widget _buildColorPicker() {
    return Positioned(
      top: 10,
      right: 0,
      child: BarColorPicker(
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
        initialColor: widget.configs.initialColor,
        colorListener: (int value) {
          _imageKey.currentState?.setColor(value);
        },
      ),
    );
  }

  /// Builds the stack of layers for the painting editor.
  /// Returns a [Widget] representing the layer stack.
  Widget _buildLayerStack() {
    return IgnorePointer(
      child: Stack(
          fit: StackFit.expand,
          children: widget.layers!.map((layerItem) {
            return LayerWidget(
              designMode: widget.designMode,
              layerHoverCursor: widget.imageEditorTheme.layerHoverCursor,
              padding: widget.paddingHelper ?? EdgeInsets.zero,
              layerData: layerItem,
              textFontSize: widget.layerFontSize,
              emojiTextStyle: widget.emojiTextStyle,
              stickerInitWidth: widget.stickerInitWidth,
              onTap: (layerData) async {},
              onTapUp: () {},
              onTapDown: () {},
              onRemoveTap: () {},
              i18n: widget.i18n,
              enabledHitDetection: false,
              freeStyleHighPerformanceScaling: false,
              freeStyleHighPerformanceMoving: false,
            );
          }).toList()),
    );
  }
}
