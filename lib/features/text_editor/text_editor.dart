// Dart imports:
import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

import '/core/mixins/converted_callbacks.dart';
import '/core/mixins/converted_configs.dart';
import '/core/mixins/editor_configs_mixin.dart';
import '/plugins/rounded_background_text/src/rounded_background_text_field.dart';
import '/pro_image_editor.dart';
import '/shared/extensions/color_extension.dart';
import '/shared/styles/platform_text_styles.dart';
import '/shared/widgets/bottom_sheets_header_row.dart';
import '/shared/widgets/platform/platform_popup_menu.dart';
import 'widgets/text_editor_bottom_bar.dart';

/// A StatefulWidget that provides a text editing interface for adding and
/// editing text layers.
class TextEditor extends StatefulWidget with SimpleConfigsAccess {
  /// Creates a `TextEditor` widget.
  ///
  /// The [heroTag], [layer], [i18n], [customWidgets], and [imageEditorTheme]
  /// parameters are required.
  const TextEditor({
    super.key,
    this.heroTag,
    this.layer,
    this.callbacks = const ProImageEditorCallbacks(),
    this.configs = const ProImageEditorConfigs(),
    required this.theme,
  });
  @override
  final ProImageEditorConfigs configs;

  @override
  final ProImageEditorCallbacks callbacks;

  /// A unique hero tag for the image.
  final String? heroTag;

  /// The theme configuration for the editor.
  final ThemeData theme;

  /// The text layer data to be edited, if any.
  final TextLayerData? layer;

  @override
  createState() => TextEditorState();
}

/// The state class for the `TextEditor` widget.
class TextEditorState extends State<TextEditor>
    with
        ImageEditorConvertedConfigs,
        ImageEditorConvertedCallbacks,
        SimpleConfigsAccessState {
  late final StreamController<void> _rebuildController;

  /// Controller for managing text input.
  final TextEditingController textCtrl = TextEditingController();

  /// Node for managing focus on the text input.
  final FocusNode focusNode = FocusNode();

  /// Alignment of the text.
  late TextAlign align;

  /// Style applied to the selected text.
  late TextStyle selectedTextStyle;

  /// Mode for managing the background color of the text layer.
  late LayerBackgroundMode backgroundColorMode;

  /// Position of the color picker.
  double colorPosition = 0;

  /// Represents the dimensions of the body.
  Size editorBodySize = Size.infinite;

  late double _fontScale;

  Color _primaryColor = Colors.black;

  /// Gets the primary color.
  Color get primaryColor => _primaryColor;

  /// Sets the primary color.
  set primaryColor(Color color) {
    setState(() {
      _primaryColor = color;
      textEditorCallbacks?.handleColorChanged(color.toHex());
    });
  }

  Color? _secondaryColor;

  /// Gets the secondary color.
  Color get secondaryColor => _secondaryColor ?? getContrastColor(primaryColor);

  /// Sets the secondary color.
  set secondaryColor(Color color) {
    setState(() {
      _secondaryColor = color;
    });
  }

  @override
  void initState() {
    super.initState();
    _rebuildController = StreamController.broadcast();
    align = textEditorConfigs.initialTextAlign;
    _fontScale = textEditorConfigs.initFontScale;
    backgroundColorMode = textEditorConfigs.initialBackgroundColorMode;

    selectedTextStyle = widget.layer?.textStyle ??
        textEditorConfigs.customTextStyles?.first ??
        const TextStyle();
    _initializeFromLayer();
    _setupTextControllerListener();

    textEditorCallbacks?.onInit?.call();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      textEditorCallbacks?.onAfterViewInit?.call();
    });
  }

  @override
  void dispose() {
    _rebuildController.close();
    textCtrl.dispose();
    focusNode.dispose();
    super.dispose();
  }

  @override
  void setState(void Function() fn) {
    _rebuildController.add(null);
    super.setState(fn);
  }

  /// Initializes the text editor from the provided text layer data.
  void _initializeFromLayer() {
    if (widget.layer != null) {
      textCtrl.text = widget.layer!.text;
      align = widget.layer!.align;
      _fontScale = widget.layer!.fontScale;
      backgroundColorMode = widget.layer!.colorMode!;
      if (widget.layer!.customSecondaryColor) {
        _primaryColor = widget.layer!.color;
        _secondaryColor = widget.layer!.background;
      } else {
        _primaryColor = backgroundColorMode == LayerBackgroundMode.background
            ? widget.layer!.background
            : widget.layer!.color;
      }
      colorPosition = widget.layer!.colorPickerPosition ?? 0;
    }
  }

  /// Sets up a listener to update the number of lines when text changes.
  void _setupTextControllerListener() {
    textCtrl.addListener(() {
      setState(() {
        textEditorCallbacks?.handleUpdateUI();
      });
    });
  }

  /// Calculates the contrast color for a given color.
  Color getContrastColor(Color color) {
    int d = color.computeLuminance() > 0.5 ? 0 : 255;

    return Color.fromRGBO(
      d,
      d,
      d,
      color.a,
    );
  }

  /// Gets the text color based on the selected color mode.
  Color get _textColor {
    switch (backgroundColorMode) {
      case LayerBackgroundMode.onlyColor:
      case LayerBackgroundMode.backgroundAndColor:
        return primaryColor;
      case LayerBackgroundMode.background:
        return secondaryColor;
      default:
        return primaryColor;
    }
  }

  /// Gets the background color based on the selected color mode.
  Color get _backgroundColor {
    switch (backgroundColorMode) {
      case LayerBackgroundMode.onlyColor:
        return Colors.transparent;
      case LayerBackgroundMode.backgroundAndColor:
        return secondaryColor;
      case LayerBackgroundMode.background:
        return primaryColor;
      default:
        return secondaryColor.withValues(alpha: 0.5);
    }
  }

  /// Gets the text font size based on the selected font scale.
  double get _textFontSize {
    return textEditorConfigs.initFontSize * _fontScale;
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
    textEditorCallbacks?.handleTextAlignChanged(align);
  }

  /// Toggles the background mode between various color modes.
  void toggleBackgroundMode() {
    setState(() {
      backgroundColorMode = backgroundColorMode == LayerBackgroundMode.onlyColor
          ? LayerBackgroundMode.backgroundAndColor
          : backgroundColorMode == LayerBackgroundMode.backgroundAndColor
              ? LayerBackgroundMode.background
              : backgroundColorMode == LayerBackgroundMode.background
                  ? LayerBackgroundMode.backgroundAndColorWithOpacity
                  : LayerBackgroundMode.onlyColor;
    });
    textEditorCallbacks?.handleBackgroundModeChanged(backgroundColorMode);
  }

  /// Gets the current font scale.
  double get fontScale => _fontScale;

  /// Sets the font scale to a new value.
  ///
  /// The new value is adjusted to one decimal place before being set.
  /// After setting the new value, the state is updated and the
  /// [textEditorCallbacks] are notified of the change.
  ///
  /// [value] - The new font scale value.
  set fontScale(double value) {
    _fontScale = (value * 10).ceilToDouble() / 10;
    setState(() {});
    textEditorCallbacks?.handleFontScaleChanged(value);
  }

  /// Displays a range slider for adjusting the line width of the paint tool.
  ///
  /// This method shows a range slider in a modal bottom sheet for adjusting the
  /// line width of the paint tool.
  void openFontScaleBottomSheet() {
    final presetFontScale = _fontScale;
    showModalBottomSheet(
      context: context,
      backgroundColor: textEditorConfigs.style.fontScaleBottomSheetBackground,
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
                  fontScale = value;
                  setState(() {});
                }

                return Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    BottomSheetHeaderRow(
                      title: '${i18n.textEditor.fontScale} ${_fontScale}x',
                      theme: widget.theme,
                      textStyle:
                          textEditorConfigs.style.fontSizeBottomSheetTitle,
                      closeButton:
                          textEditorConfigs.widgets.fontSizeCloseButton != null
                              ? (fn) => textEditorConfigs
                                  .widgets.fontSizeCloseButton!(this, fn)
                              : null,
                    ),
                    textEditorConfigs.widgets.sliderFontSize?.call(
                          this,
                          _rebuildController.stream,
                          _fontScale,
                          updateFontScaleScale,
                          (onChangedEnd) {},
                        ) ??
                        Row(
                          children: [
                            Expanded(
                              child: Slider.adaptive(
                                max: textEditorConfigs.maxFontScale,
                                min: textEditorConfigs.minFontScale,
                                divisions: (textEditorConfigs.maxFontScale -
                                        textEditorConfigs.minFontScale) ~/
                                    0.1,
                                value: _fontScale,
                                onChanged: updateFontScaleScale,
                              ),
                            ),
                            const SizedBox(width: 8),
                            IconTheme(
                              data: Theme.of(context).primaryIconTheme,
                              child: AnimatedSwitcher(
                                duration: const Duration(milliseconds: 150),
                                child: _fontScale != presetFontScale
                                    ? IconButton(
                                        onPressed: () {
                                          updateFontScaleScale(presetFontScale);
                                        },
                                        icon: Icon(textEditorConfigs
                                            .icons.resetFontScale),
                                      )
                                    : IconButton(
                                        key: UniqueKey(),
                                        color: Colors.transparent,
                                        onPressed: null,
                                        icon: Icon(textEditorConfigs
                                            .icons.resetFontScale),
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
      textEditorCallbacks?.handleUpdateUI();
    });
  }

  /// Closes the editor without applying changes.
  void close() {
    Navigator.pop(context);
    textEditorCallbacks?.handleCloseEditor();
  }

  /// Handles the "Done" action, either by applying changes or closing the
  /// editor.
  void done() {
    if (textCtrl.text.trim().isNotEmpty) {
      Navigator.of(context).pop(
        TextLayerData(
          text: textCtrl.text.trim(),
          background: _backgroundColor,
          color: _textColor,
          align: align,
          fontScale: _fontScale,
          colorMode: backgroundColorMode,
          colorPickerPosition: colorPosition,
          textStyle: selectedTextStyle,
          customSecondaryColor: _secondaryColor != null,
        ),
      );
    } else {
      Navigator.of(context).pop();
    }
    textEditorCallbacks?.handleDone();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return ExtendedPopScope(
          child: Theme(
            data: widget.theme.copyWith(
                tooltipTheme:
                    widget.theme.tooltipTheme.copyWith(preferBelow: true)),
            child: SafeArea(
              top: textEditorConfigs.safeArea.top,
              bottom: textEditorConfigs.safeArea.bottom,
              left: textEditorConfigs.safeArea.left,
              right: textEditorConfigs.safeArea.right,
              child: Scaffold(
                backgroundColor: textEditorConfigs.style.background,
                appBar: _buildAppBar(constraints),
                body: _buildBody(),
                bottomNavigationBar: _buildBottomBar(),
              ),
            ),
          ),
        );
      },
    );
  }

  /// Builds the app bar for the text editor.
  PreferredSizeWidget? _buildAppBar(BoxConstraints constraints) {
    if (textEditorConfigs.widgets.appBar != null) {
      return textEditorConfigs.widgets.appBar!
          .call(this, _rebuildController.stream);
    }

    const int defaultIconButtonSize = 48;
    final List<IconButton> configButtons = _getConfigButtons();

    // Taking into account the back and done button
    final iconButtonsSize = (2 + configButtons.length) * defaultIconButtonSize;

    return AppBar(
      automaticallyImplyLeading: false,
      backgroundColor: textEditorConfigs.style.appBarBackground,
      foregroundColor: textEditorConfigs.style.appBarColor,
      actions: [
        IconButton(
          tooltip: i18n.textEditor.back,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          icon: Icon(textEditorConfigs.icons.backButton),
          onPressed: close,
        ),
        const Spacer(),
        if (constraints.maxWidth >= iconButtonsSize) ...[
          ...configButtons,
          const Spacer(),
          _buildDoneBtn(),
        ] else ...[
          _buildDoneBtn(),
          PlatformPopupBtn(
            designMode: designMode,
            title: i18n.textEditor.smallScreenMoreTooltip,
            options: [
              if (textEditorConfigs.canToggleTextAlign)
                PopupMenuOption(
                  label: i18n.textEditor.textAlign,
                  icon: Icon(align == TextAlign.left
                      ? textEditorConfigs.icons.alignLeft
                      : align == TextAlign.right
                          ? textEditorConfigs.icons.alignRight
                          : textEditorConfigs.icons.alignCenter),
                  onTap: () {
                    toggleTextAlign();
                    if (designMode == ImageEditorDesignMode.cupertino) {
                      Navigator.pop(context);
                    }
                  },
                ),
              if (textEditorConfigs.canChangeFontScale)
                PopupMenuOption(
                  label: i18n.textEditor.fontScale,
                  icon: Icon(textEditorConfigs.icons.fontScale),
                  onTap: () {
                    openFontScaleBottomSheet();
                    if (designMode == ImageEditorDesignMode.cupertino) {
                      Navigator.pop(context);
                    }
                  },
                ),
              if (textEditorConfigs.canToggleBackgroundMode)
                PopupMenuOption(
                  label: i18n.textEditor.backgroundMode,
                  icon: Icon(textEditorConfigs.icons.backgroundMode),
                  onTap: () {
                    toggleBackgroundMode();
                    if (designMode == ImageEditorDesignMode.cupertino) {
                      Navigator.pop(context);
                    }
                  },
                ),
            ],
          ),
        ],
      ],
    );
  }

  /// Builds the bottom navigation bar of the paint editor.
  /// Returns a [Widget] representing the bottom navigation bar.
  Widget? _buildBottomBar() {
    if (textEditorConfigs.widgets.bottomBar != null) {
      return textEditorConfigs.widgets.bottomBar!
          .call(this, _rebuildController.stream);
    }

    if (isDesktop &&
        widget.configs.textEditor.customTextStyles?.isNotEmpty == false) {
      return const SizedBox(height: kBottomNavigationBarHeight);
    }

    return null;
  }

  /// Builds the body of the text editor.
  Widget _buildBody() {
    return LayoutBuilder(builder: (_, constraints) {
      editorBodySize = constraints.biggest;

      return GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: done,
        child: Stack(
          children: [
            if (textEditorConfigs.widgets.bodyItems != null)
              ...textEditorConfigs.widgets.bodyItems!(
                this,
                _rebuildController.stream,
              ),
            _buildTextField(),
            _buildColorPicker(),
            if (textEditorConfigs.showSelectFontStyleBottomBar)
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                height: kBottomNavigationBarHeight,
                child: TextEditorBottomBar(
                  configs: widget.configs,
                  selectedStyle: selectedTextStyle,
                  onFontChange: setTextStyle,
                ),
              ),
          ],
        ),
      );
    });
  }

  List<IconButton> _getConfigButtons() => [
        if (textEditorConfigs.canToggleTextAlign)
          IconButton(
            key: const ValueKey('TextAlignIconButton'),
            tooltip: i18n.textEditor.textAlign,
            onPressed: toggleTextAlign,
            icon: Icon(align == TextAlign.left
                ? textEditorConfigs.icons.alignLeft
                : align == TextAlign.right
                    ? textEditorConfigs.icons.alignRight
                    : textEditorConfigs.icons.alignCenter),
          ),
        if (textEditorConfigs.canChangeFontScale)
          IconButton(
            key: const ValueKey('BackgroundModeFontScaleButton'),
            tooltip: i18n.textEditor.fontScale,
            onPressed: openFontScaleBottomSheet,
            icon: Icon(textEditorConfigs.icons.fontScale),
          ),
        if (textEditorConfigs.canToggleBackgroundMode)
          IconButton(
            key: const ValueKey('BackgroundModeColorIconButton'),
            tooltip: i18n.textEditor.backgroundMode,
            onPressed: toggleBackgroundMode,
            icon: Icon(textEditorConfigs.icons.backgroundMode),
          ),
      ];

  /// Builds and returns an IconButton for applying changes.
  Widget _buildDoneBtn() {
    return IconButton(
      key: const ValueKey('TextEditorDoneButton'),
      tooltip: i18n.textEditor.done,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      icon: Icon(textEditorConfigs.icons.applyChanges),
      iconSize: 28,
      onPressed: done,
    );
  }

  Widget _buildColorPicker() {
    if (textEditorConfigs.widgets.colorPicker != null) {
      return textEditorConfigs.widgets.colorPicker!.call(
            this,
            _rebuildController.stream,
            selectedTextStyle.color ?? primaryColor,
            (color) {
              primaryColor = color;
            },
          ) ??
          const SizedBox.shrink();
    }
    return Align(
      alignment: Alignment.topRight,
      child: Container(
        margin: null,
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: BarColorPicker(
          configs: widget.configs,
          length: min(
            350,
            MediaQuery.of(context).size.height -
                MediaQuery.of(context).viewInsets.bottom -
                kToolbarHeight -
                kBottomNavigationBarHeight -
                10 * 2 -
                MediaQuery.of(context).padding.top,
          ),
          onPositionChange: (value) {
            colorPosition = value;
          },
          initPosition: colorPosition,
          initialColor: primaryColor,
          horizontal: false,
          thumbColor: Colors.white,
          cornerRadius: 10,
          pickMode: PickMode.color,
          colorListener: (int value) {
            primaryColor = Color(value);
          },
        ),
      ),
    );
  }

  /// Builds the text field for text input.
  Widget _buildTextField() {
    return Center(
      ///  TODO: remove `IntrinsicWidth` after updating
      /// `RoundedBackgroundTextField` code
      child: IntrinsicWidth(
        child: Padding(
          padding: textEditorConfigs.style.textFieldMargin,
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Hero(
                flightShuttleBuilder: ((
                  flightContext,
                  animation,
                  flightDirection,
                  fromHeroContext,
                  toHeroContext,
                ) {
                  if (flightDirection == HeroFlightDirection.pop) {
                    return fromHeroContext.widget;
                  }

                  void animationStatusListener(AnimationStatus status) {
                    if (status == AnimationStatus.completed) {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        focusNode.requestFocus();
                      });
                      animation.removeStatusListener(animationStatusListener);
                    }
                  }

                  animation.addStatusListener(animationStatusListener);

                  return toHeroContext.widget;
                }),
                tag: widget.heroTag ?? 'Text-Image-Editor-Empty-Hero',
                createRectTween: (begin, end) =>
                    RectTween(begin: begin, end: end),
                child: RoundedBackgroundTextField(
                  key: const ValueKey('rounded-background-text-editor-field'),
                  heroTag: widget.heroTag ?? 'Text-Image-Editor-Empty-Hero',
                  controller: textCtrl,
                  focusNode: focusNode,
                  onChanged: textEditorCallbacks?.handleChanged,
                  onEditingComplete: textEditorCallbacks?.handleEditingComplete,
                  onSubmitted: textEditorCallbacks?.handleSubmitted,
                  autocorrect: textEditorConfigs.autocorrect,
                  enableSuggestions: textEditorConfigs.enableSuggestions,
                  keyboardType: TextInputType.multiline,
                  textInputAction: TextInputAction.newline,
                  textCapitalization: TextCapitalization.sentences,
                  textAlign: textCtrl.text.isEmpty ? TextAlign.center : align,
                  maxLines: null,
                  cursorColor: textEditorConfigs.style.inputCursorColor,
                  cursorHeight: _textFontSize * 1.2,
                  scrollPhysics: const NeverScrollableScrollPhysics(),
                  hint: textCtrl.text.isEmpty
                      ? i18n.textEditor.inputHintText
                      : '',
                  hintStyle: selectedTextStyle.copyWith(
                    color: textEditorConfigs.style.inputHintColor,
                    fontSize: _textFontSize,
                    height: 1.35,
                    shadows: [],
                  ),
                  backgroundColor: _backgroundColor,
                  style: selectedTextStyle.copyWith(
                    color: _textColor,
                    fontSize: _textFontSize,
                    height: 1.35,
                    letterSpacing: 0,
                    decoration: TextDecoration.none,
                    shadows: [],
                  ),

                  /// If we edit an layer we focus to the textfield after the
                  /// hero animation is done
                  autofocus: widget.layer == null,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
