import 'dart:math';

import 'package:flutter/material.dart';
import 'package:pro_image_editor/designs/whatsapp/whatsapp_text_appbar.dart';
import 'package:pro_image_editor/models/editor_configs/pro_image_editor_configs.dart';
import 'package:pro_image_editor/models/theme/theme.dart';
import 'package:pro_image_editor/utils/design_mode.dart';
import 'package:pro_image_editor/mixins/converted_configs.dart';
import 'package:rounded_background_text/rounded_background_text.dart';

import '../../models/layer.dart';
import '../../mixins/editor_configs_mixin.dart';
import '../../utils/theme_functions.dart';
import '../../widgets/bottom_sheets_header_row.dart';
import '../../widgets/color_picker/bar_color_picker.dart';
import '../../widgets/color_picker/color_picker_configs.dart';
import '../../widgets/layer_widget.dart';
import '../../widgets/platform_popup_menu.dart';
import 'widgets/text_editor_bottom_bar.dart';

/// A StatefulWidget that provides a text editing interface for adding and editing text layers.
class TextEditor extends StatefulWidget with SimpleConfigsAccess {
  @override
  final ProImageEditorConfigs configs;

  /// A unique hero tag for the image.
  final String? heroTag;

  /// The theme configuration for the editor.
  final ThemeData theme;

  /// The text layer data to be edited, if any.
  final TextLayerData? layer;

  /// A callback function that can be used to update the UI from custom widgets.
  final Function? onUpdateUI;

  /// Creates a `TextEditor` widget.
  ///
  /// The [heroTag], [layer], [i18n], [customWidgets], and [imageEditorTheme] parameters are required.
  const TextEditor({
    super.key,
    this.heroTag,
    this.layer,
    this.onUpdateUI,
    this.configs = const ProImageEditorConfigs(),
    required this.theme,
  });

  @override
  createState() => TextEditorState();
}

/// The state class for the `TextEditor` widget.
class TextEditorState extends State<TextEditor>
    with ImageEditorConvertedConfigs, SimpleConfigsAccessState {
  final TextEditingController _textCtrl = TextEditingController();
  final FocusNode _focus = FocusNode();
  Color _primaryColor = Colors.black;
  late TextAlign align;
  late LayerBackgroundColorModeE backgroundColorMode;
  late double fontScale;
  late TextStyle selectedTextStyle;
  int _numLines = 0;
  double _colorPosition = 0;

  @override
  void initState() {
    super.initState();
    align = textEditorConfigs.initialTextAlign;
    fontScale = textEditorConfigs.initFontScale;
    backgroundColorMode = textEditorConfigs.initialBackgroundColorMode;

    selectedTextStyle = widget.layer?.textStyle ??
        textEditorConfigs.customTextStyles?.first ??
        const TextStyle();
    _initializeFromLayer();
    _setupTextControllerListener();
  }

  @override
  void dispose() {
    _textCtrl.dispose();
    _focus.dispose();
    super.dispose();
  }

  /// Initializes the text editor from the provided text layer data.
  void _initializeFromLayer() {
    if (widget.layer != null) {
      _textCtrl.text = widget.layer!.text;
      align = widget.layer!.align;
      fontScale = widget.layer!.fontScale;
      backgroundColorMode = widget.layer!.colorMode!;
      _primaryColor =
          backgroundColorMode == LayerBackgroundColorModeE.background
              ? widget.layer!.background
              : widget.layer!.color;
      _numLines = '\n'.allMatches(_textCtrl.text).length + 1;
      _colorPosition = widget.layer!.colorPickerPosition ?? 0;
    }
  }

  /// Sets up a listener to update the number of lines when text changes.
  void _setupTextControllerListener() {
    _textCtrl.addListener(() {
      setState(() {
        _numLines = '\n'.allMatches(_textCtrl.text).length + 1;
      });
      widget.onUpdateUI?.call();
    });
  }

  /// Calculates the contrast color for a given color.
  Color _getContrastColor(Color color) {
    int d = color.computeLuminance() > 0.5 ? 0 : 255;

    return Color.fromARGB(color.alpha, d, d, d);
  }

  /// Gets the text color based on the selected color mode.
  Color get _getTextColor {
    return backgroundColorMode == LayerBackgroundColorModeE.onlyColor
        ? _primaryColor
        : backgroundColorMode == LayerBackgroundColorModeE.backgroundAndColor
            ? _primaryColor
            : backgroundColorMode == LayerBackgroundColorModeE.background
                ? _getContrastColor(_primaryColor)
                : _primaryColor;
  }

  /// Gets the background color based on the selected color mode.
  Color get _getBackgroundColor {
    return backgroundColorMode == LayerBackgroundColorModeE.onlyColor
        ? Colors.transparent
        : backgroundColorMode == LayerBackgroundColorModeE.backgroundAndColor
            ? _getContrastColor(_primaryColor)
            : backgroundColorMode == LayerBackgroundColorModeE.background
                ? _primaryColor
                : _getContrastColor(_primaryColor).withOpacity(0.5);
  }

  /// Gets the text font size based on the selected font scale.
  double get _getTextFontSize {
    return textEditorConfigs.initFontSize * fontScale;
  }

  /// Toggles the text alignment between left, center, and right.
  void toggleTextAlign() {
    setState(() {
      align = align == TextAlign.left
          ? TextAlign.center
          : align == TextAlign.center
              ? TextAlign.right
              : TextAlign.left;
    });
    widget.onUpdateUI?.call();
  }

  /// Toggles the background mode between various color modes.
  void toggleBackgroundMode() {
    setState(() {
      backgroundColorMode = backgroundColorMode ==
              LayerBackgroundColorModeE.onlyColor
          ? LayerBackgroundColorModeE.backgroundAndColor
          : backgroundColorMode == LayerBackgroundColorModeE.backgroundAndColor
              ? LayerBackgroundColorModeE.background
              : backgroundColorMode == LayerBackgroundColorModeE.background
                  ? LayerBackgroundColorModeE.backgroundAndColorWithOpacity
                  : LayerBackgroundColorModeE.onlyColor;
    });
    widget.onUpdateUI?.call();
  }

  /// Displays a range slider for adjusting the line width of the painting tool.
  ///
  /// This method shows a range slider in a modal bottom sheet for adjusting the line width of the painting tool.
  void openFontScaleBottomSheet() {
    final presetFontScale = fontScale;
    showModalBottomSheet(
      context: context,
      backgroundColor:
          imageEditorTheme.paintingEditor.lineWidthBottomSheetColor,
      builder: (BuildContext context) {
        return Material(
          color: Colors.transparent,
          textStyle: platformTextStyle(context, designMode),
          child: SingleChildScrollView(
            physics: const ClampingScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: StatefulBuilder(builder: (context, setState) {
                void updateFontScaleScale(double value) {
                  fontScale = (value * 10).ceilToDouble() / 10;
                  setState(() {});
                  this.setState(() {});
                }

                return Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    BottomSheetHeaderRow(
                      title: '${i18n.textEditor.fontScale} ${fontScale}x',
                      theme: widget.theme,
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: Slider.adaptive(
                            max: textEditorConfigs.maxFontScale,
                            min: textEditorConfigs.minFontScale,
                            divisions: (textEditorConfigs.maxFontScale -
                                    textEditorConfigs.minFontScale) ~/
                                0.1,
                            value: fontScale,
                            onChanged: updateFontScaleScale,
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconTheme(
                          data: Theme.of(context).primaryIconTheme,
                          child: IconButton(
                            onPressed: fontScale != presetFontScale
                                ? () {
                                    updateFontScaleScale(presetFontScale);
                                  }
                                : null,
                            icon: Icon(
                              icons.textEditor.resetFontScale,
                            ),
                          ),
                        ),
                        const SizedBox(width: 2),
                      ],
                    ),
                  ],
                );
              }),
            ),
          ),
        );
      },
    );
  }

  /// Update the current text style.
  void setTextStyle(TextStyle style) {
    setState(() {
      selectedTextStyle = style;
      widget.onUpdateUI?.call();
    });
  }

  /// Closes the editor without applying changes.
  void close() {
    Navigator.pop(context);
  }

  /// Handles the "Done" action, either by applying changes or closing the editor.
  void done() {
    if (_textCtrl.text.trim().isNotEmpty) {
      Navigator.of(context).pop(
        TextLayerData(
          text: _textCtrl.text.trim(),
          background: _getBackgroundColor,
          color: _getTextColor,
          align: align,
          fontScale: fontScale,
          colorMode: backgroundColorMode,
          colorPickerPosition: _colorPosition,
          textStyle: selectedTextStyle,
          // fontFamily: 'Roboto',
        ),
      );
    } else {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Theme(
          data: widget.theme.copyWith(
              tooltipTheme:
                  widget.theme.tooltipTheme.copyWith(preferBelow: true)),
          child: Scaffold(
            backgroundColor: imageEditorTheme.textEditor.background,
            appBar: _buildAppBar(constraints),
            body: _buildBody(),
          ),
        );
      },
    );
  }

  /// Builds the app bar for the text editor.
  PreferredSizeWidget? _buildAppBar(BoxConstraints constraints) {
    return customWidgets.appBarTextEditor ??
        (imageEditorTheme.editorMode == ThemeEditorMode.simple
            ? AppBar(
                automaticallyImplyLeading: false,
                backgroundColor:
                    imageEditorTheme.textEditor.appBarBackgroundColor,
                foregroundColor:
                    imageEditorTheme.textEditor.appBarForegroundColor,
                actions: [
                  IconButton(
                    tooltip: i18n.textEditor.back,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    icon: Icon(icons.backButton),
                    onPressed: close,
                  ),
                  const Spacer(),
                  if (constraints.maxWidth >= 300) ...[
                    if (textEditorConfigs.canToggleTextAlign)
                      IconButton(
                        key: const ValueKey('TextAlignIconButton'),
                        tooltip: i18n.textEditor.textAlign,
                        onPressed: toggleTextAlign,
                        icon: Icon(align == TextAlign.left
                            ? icons.textEditor.alignLeft
                            : align == TextAlign.right
                                ? icons.textEditor.alignRight
                                : icons.textEditor.alignCenter),
                      ),
                    if (textEditorConfigs.canChangeFontScale)
                      IconButton(
                        key: const ValueKey('BackgroundModeFontScaleButton'),
                        tooltip: i18n.textEditor.fontScale,
                        onPressed: openFontScaleBottomSheet,
                        icon: Icon(icons.textEditor.fontScale),
                      ),
                    if (textEditorConfigs.canToggleBackgroundMode)
                      IconButton(
                        key: const ValueKey('BackgroundModeColorIconButton'),
                        tooltip: i18n.textEditor.backgroundMode,
                        onPressed: toggleBackgroundMode,
                        icon: Icon(icons.textEditor.backgroundMode),
                      ),
                    const Spacer(),
                    _buildDoneBtn(),
                  ] else ...[
                    const Spacer(),
                    _buildDoneBtn(),
                    PlatformPopupBtn(
                      designMode: designMode,
                      title: i18n.textEditor.smallScreenMoreTooltip,
                      options: [
                        if (textEditorConfigs.canToggleTextAlign)
                          PopupMenuOption(
                            label: i18n.textEditor.textAlign,
                            icon: Icon(align == TextAlign.left
                                ? icons.textEditor.alignLeft
                                : align == TextAlign.right
                                    ? icons.textEditor.alignRight
                                    : icons.textEditor.alignCenter),
                            onTap: () {
                              toggleTextAlign();
                              if (designMode ==
                                  ImageEditorDesignModeE.cupertino) {
                                Navigator.pop(context);
                              }
                            },
                          ),
                        if (textEditorConfigs.canChangeFontScale)
                          PopupMenuOption(
                            label: i18n.textEditor.fontScale,
                            icon: Icon(icons.textEditor.fontScale),
                            onTap: () {
                              openFontScaleBottomSheet();
                              if (designMode ==
                                  ImageEditorDesignModeE.cupertino) {
                                Navigator.pop(context);
                              }
                            },
                          ),
                        if (textEditorConfigs.canToggleBackgroundMode)
                          PopupMenuOption(
                            label: i18n.textEditor.backgroundMode,
                            icon: Icon(icons.textEditor.backgroundMode),
                            onTap: () {
                              toggleBackgroundMode();
                              if (designMode ==
                                  ImageEditorDesignModeE.cupertino) {
                                Navigator.pop(context);
                              }
                            },
                          ),
                      ],
                    ),
                  ],
                ],
              )
            : null);
  }

  /// Builds and returns an IconButton for applying changes.
  Widget _buildDoneBtn() {
    return IconButton(
      key: const ValueKey('TextEditorDoneButton'),
      tooltip: i18n.textEditor.done,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      icon: Icon(icons.applyChanges),
      iconSize: 28,
      onPressed: done,
    );
  }

  /// Builds the body of the text editor.
  Widget _buildBody() {
    double barPickerPadding =
        imageEditorTheme.editorMode == ThemeEditorMode.simple ? 10 : 60;

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: done,
      child: Stack(
        children: [
          _buildTextField(),
          Align(
            alignment: Alignment.topRight,
            child: Padding(
              padding: EdgeInsets.symmetric(
                vertical: barPickerPadding,
              ),
              child: BarColorPicker(
                configs: widget.configs,
                length: min(
                  imageEditorTheme.editorMode == ThemeEditorMode.simple
                      ? 350
                      : 200,
                  MediaQuery.of(context).size.height -
                      MediaQuery.of(context).viewInsets.bottom -
                      kToolbarHeight -
                      kBottomNavigationBarHeight -
                      barPickerPadding * 2 -
                      MediaQuery.of(context).padding.top,
                ),
                onPositionChange: (value) {
                  _colorPosition = value;
                },
                initPosition: _colorPosition,
                initialColor: _primaryColor,
                horizontal: false,
                thumbColor: Colors.white,
                cornerRadius: 10,
                pickMode: PickMode.color,
                colorListener: (int value) {
                  setState(() {
                    _primaryColor = Color(value);
                  });
                  widget.onUpdateUI?.call();
                },
              ),
            ),
          ),
          customWidgets.bottomBarTextEditor ??
              TextEditorBottomBar(
                configs: widget.configs,
                selectedStyle: selectedTextStyle,
                onFontChange: setTextStyle,
              ),
          if (imageEditorTheme.editorMode == ThemeEditorMode.whatsapp)
            WhatsAppTextAppBar(
              configs: widget.configs,
              align: align,
              onDone: done,
              onAlignChange: toggleTextAlign,
              onBackgroundModeChange: toggleBackgroundMode,
            ),
        ],
      ),
    );
  }

  /// Builds the text field for text input.
  Widget _buildTextField() {
    return Align(
      alignment: Alignment.center,
      child: Padding(
        padding: EdgeInsets.only(
            bottom: imageEditorTheme.editorMode == ThemeEditorMode.simple &&
                    textEditorConfigs.customTextStyles != null
                ? kBottomNavigationBarHeight
                : 0),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: SizedBox(
              height: _getTextFontSize * _numLines * 1.35 + 15,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Hero(
                    tag: widget.heroTag ?? 'Text-Image-Editor-Empty-Hero',
                    createRectTween: (begin, end) =>
                        RectTween(begin: begin, end: end),
                    child: RoundedBackgroundText(
                      _textCtrl.text,
                      backgroundColor: _getBackgroundColor,
                      textAlign: align,
                      style: selectedTextStyle.copyWith(
                        color: _getTextColor,
                        fontSize: _getTextFontSize,
                        fontWeight: FontWeight.w400,
                        height: 1.35,
                        letterSpacing: 0,
                      ),
                    ),
                  ),
                  IntrinsicWidth(
                    child: TextField(
                      controller: _textCtrl,
                      focusNode: _focus,
                      keyboardType: TextInputType.multiline,
                      textInputAction: TextInputAction.newline,
                      textCapitalization: TextCapitalization.sentences,
                      textAlign:
                          _textCtrl.text.isEmpty ? TextAlign.center : align,
                      maxLines: null,
                      cursorColor: imageEditorTheme.textEditor.inputCursorColor,
                      cursorHeight: _getTextFontSize * 1.2,
                      scrollPhysics: const NeverScrollableScrollPhysics(),
                      decoration: InputDecoration(
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.fromLTRB(
                              12, _numLines <= 1 ? 4 : 0, 12, 0),
                          hintText: _textCtrl.text.isEmpty
                              ? i18n.textEditor.inputHintText
                              : '',
                          hintStyle: selectedTextStyle.copyWith(
                            color: imageEditorTheme.textEditor.inputHintColor,
                            fontSize: _getTextFontSize,
                            fontWeight: FontWeight.w400,
                            height: 1.35,
                          )),
                      style: selectedTextStyle.copyWith(
                        color: Colors.transparent,
                        fontSize: _getTextFontSize,
                        fontWeight: FontWeight.w400,
                        height: 1.35,
                        letterSpacing: 0,
                      ),
                      autofocus: true,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
