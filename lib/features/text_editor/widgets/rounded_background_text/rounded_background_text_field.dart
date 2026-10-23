import 'package:flutter/foundation.dart';
import 'package:material_ui/material_ui.dart';

import '/core/models/editor_configs/pro_image_editor_configs.dart';
import '/core/models/layers/text_layer_box.dart';
import 'rounded_background_text.dart';

/// A customizable text field widget that displays editable text over a
/// rounded background.
class RoundedBackgroundTextField extends StatefulWidget {
  /// Creates a customizable text field with rounded background support.
  ///
  /// This widget displays editable text with a background and allows
  /// customization of cursor behavior, hint styling, focus management,
  /// and more.
  const RoundedBackgroundTextField({
    super.key,
    required this.controller,
    required this.configs,
    required this.style,
    required this.backgroundColor,
    required this.textAlign,
    required this.focusNode,
    this.maxTextWidth = double.infinity,
    this.cursorWidth = 2.0,
    this.cursorHeight,
    this.cursorRadius,
    this.hint,
    this.hintStyle,
    this.autofocus = false,
    this.onChanged,
    this.onEditingComplete,
    this.onSubmitted,
    this.onTapOutside,
    this.outlineWidth = 0,
    this.outlineColor = const Color(0xFF000000),
    this.box,
  });

  /// Controls the text being edited in the text editor.
  final TextEditingController controller;

  /// Manages the focus state of the text editor.
  final FocusNode focusNode;

  /// Configuration settings for customizing text editor behavior and
  /// appearance.
  final TextEditorConfigs configs;

  /// The text style applied to the editable text.
  final TextStyle style;

  /// How the text should be aligned within the editor.
  final TextAlign textAlign;

  /// Optional placeholder text displayed when the editor is empty.
  final String? hint;

  /// Optional style to apply to the hint text.
  final TextStyle? hintStyle;

  /// {@macro rounded_background_text.background_color}
  final Color backgroundColor;

  /// {@macro flutter.widgets.editableText.autofocus}
  final bool autofocus;

  /// {@macro flutter.widgets.editableText.cursorWidth}
  final double cursorWidth;

  /// {@macro flutter.widgets.editableText.cursorHeight}
  final double? cursorHeight;

  /// The maximum width the text is allowed to occupy. If null, the text can
  /// expand freely.
  final double maxTextWidth;

  /// {@macro flutter.widgets.editableText.cursorRadius}
  final Radius? cursorRadius;

  /// {@macro flutter.widgets.editableText.onChanged}
  final ValueChanged<String>? onChanged;

  /// {@macro flutter.widgets.editableText.onEditingComplete}
  final VoidCallback? onEditingComplete;

  /// {@macro flutter.widgets.editableText.onSubmitted}
  final ValueChanged<String>? onSubmitted;

  /// Called for a pointer-down outside the field, in place of the default
  /// that takes the focus away on desktop platforms.
  final TapRegionCallback? onTapOutside;

  /// The thickness of the outline drawn around each glyph, measured outward
  /// from the glyph edge. `0` draws no outline.
  final double outlineWidth;

  /// The color of the outline.
  final Color outlineColor;

  /// A fixed box to lay the text out in, already scaled the way the layer
  /// paints it, or `null` to size the field to its text.
  ///
  /// The text wraps at the box width, and [TextLayerBox.overflow] clips or
  /// shrinks what does not fit, matching [RoundedBackgroundText].
  final TextLayerBox? box;

  bool get _hasOutline => outlineWidth > 0 && outlineColor.a > 0;

  @override
  State<RoundedBackgroundTextField> createState() =>
      _RoundedBackgroundTextFieldState();
}

class _RoundedBackgroundTextFieldState
    extends State<RoundedBackgroundTextField> {
  late final _textController = widget.controller;
  final _scrollCtrl = ScrollController();

  @override
  void initState() {
    super.initState();
    _textController.addListener(_handleTextChange);
    _scrollCtrl.addListener(_handleScrollChange);
  }

  void _handleTextChange() {
    if (mounted) setState(() {});
  }

  void _handleScrollChange() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _textController.removeListener(_handleTextChange);
    _scrollCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.box != null) return _buildBoxed(context);
    return _buildFree(context);
  }

  /// The field filling [RoundedBackgroundTextField.box], clipped to it.
  Widget _buildBoxed(BuildContext context) {
    final box = widget.box!;
    final direction = Directionality.maybeOf(context) ?? TextDirection.ltr;
    final glyph = _glyphStyle;
    final fontSize =
        glyph.fontSize ?? DefaultTextStyle.of(context).style.fontSize ?? 16;
    final leading = widget.configs.style.leadingDistribution;
    final outlined = widget._hasOutline;
    final scale = box.overflow == TextLayerBoxOverflow.shrink
        ? RoundedBackgroundText.scaleForBox(
            text: TextSpan(text: _textController.text, style: glyph),
            style: glyph,
            boxSize: box.size,
            enableHitBoxCorrection: true,
            outlineWidth: outlined ? widget.outlineWidth : 0,
            textAlign: widget.textAlign,
            leadingDistribution: leading,
            textDirection: direction,
          )
        : 1.0;
    final shrunkSize = fontSize * scale;
    final linePainter = TextPainter(
      text: TextSpan(
        text: 'A',
        style: TextStyle(
          leadingDistribution: leading,
        ).merge(glyph.copyWith(fontSize: shrunkSize)),
      ),
      textDirection: direction,
    )..layout();
    final lineHeight = linePainter.preferredLineHeight;
    linePainter.dispose();
    final effect = RoundedBackgroundText.effectExtent(
      outlineWidth: outlined ? widget.outlineWidth : 0,
      shadows: glyph.shadows ?? const <Shadow>[],
    );
    final inset = EdgeInsets.fromLTRB(
      lineHeight * 0.3 + effect.dx,
      lineHeight * 0.1 + effect.dy,
      lineHeight * 0.3 + effect.dx,
      lineHeight * 0.1 + effect.dy,
    );
    // An outline casts the shadows itself. Otherwise the field paints them,
    // scaled with the font the way RoundedBackgroundText does.
    List<Shadow>? fieldShadows;
    if (outlined) {
      fieldShadows = const <Shadow>[];
    } else if (scale != 1) {
      final shadows = glyph.shadows;
      if (shadows != null) {
        fieldShadows = [for (final shadow in shadows) shadow.scale(scale)];
      }
    }
    final fieldStyle = glyph.copyWith(
      fontSize: shrunkSize,
      leadingDistribution: leading,
      shadows: fieldShadows,
    );
    final vertical = switch (box.verticalAlign) {
      TextLayerBoxVerticalAlign.top => TextAlignVertical.top,
      TextLayerBoxVerticalAlign.center => TextAlignVertical.center,
      TextLayerBoxVerticalAlign.bottom => TextAlignVertical.bottom,
    };

    final boxed = SizedBox(
      width: box.size.width,
      height: box.size.height,
      child: ClipRect(
        child: Stack(
          children: [
            Positioned.fill(
              child: IgnorePointer(
                child: RoundedBackgroundText.rich(
                  maxTextWidth: widget.maxTextWidth,
                  // The font stays at full size so this painter shrinks it,
                  // and with it the outline and the shadows the outline
                  // casts, the way the finished layer does. The field uses
                  // the shrunk size. Bare shadows stay on the style so the
                  // box keeps their space; the field paints those.
                  text: _textController.buildTextSpan(
                    context: context,
                    withComposing: true,
                    style: glyph.copyWith(
                      color: const Color(0x00000000),
                      leadingDistribution: leading,
                    ),
                  ),
                  box: box,
                  textAlign: widget.textAlign,
                  backgroundColor: widget.backgroundColor,
                  enableHitBoxCorrection: true,
                  leadingDistribution: leading,
                  reserveEffectSpace: true,
                  paintShadows: false,
                  outlineWidth: widget.outlineWidth,
                  outlineColor: widget.outlineColor,
                ),
              ),
            ),
            Positioned.fill(
              child: Padding(
                padding: inset,
                child: Material(
                  type: MaterialType.transparency,
                  child: TextField(
                    controller: _textController,
                    focusNode: widget.focusNode,
                    autofocus: widget.autofocus,
                    expands: true,
                    maxLines: null,
                    textAlignVertical: vertical,
                    textAlign: widget.textAlign,
                    keyboardType: TextInputType.multiline,
                    textCapitalization: TextCapitalization.sentences,
                    textInputAction: TextInputAction.newline,
                    scrollPhysics: const NeverScrollableScrollPhysics(),
                    scrollPadding: EdgeInsets.zero,
                    style: fieldStyle,
                    cursorColor: widget.configs.style.inputCursorColor,
                    cursorWidth: widget.cursorWidth,
                    cursorHeight: shrunkSize,
                    cursorRadius: widget.cursorRadius,
                    enableInteractiveSelection: true,
                    showCursor: true,
                    autocorrect: widget.configs.enableAutocorrect,
                    enableSuggestions: widget.configs.enableSuggestions,
                    spellCheckConfiguration:
                        widget.configs.spellCheckConfiguration,
                    clipBehavior: Clip.hardEdge,
                    decoration: InputDecoration.collapsed(
                      hintText: _textController.text.isEmpty ? widget.hint : '',
                      hintStyle:
                          (widget.hintStyle ??
                                  TextStyle(color: Theme.of(context).hintColor))
                              .copyWith(fontSize: shrunkSize),
                    ),
                    onChanged: widget.onChanged,
                    onEditingComplete: widget.onEditingComplete,
                    onSubmitted: widget.onSubmitted,
                    onTapOutside: widget.onTapOutside,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
    // The painted text ignores the platform text scale, so the field does
    // as well.
    return MediaQuery(
      data: MediaQuery.of(context).copyWith(textScaler: TextScaler.noScaling),
      child: boxed,
    );
  }

  Widget _buildFree(BuildContext context) {
    final defaultTextStyle = DefaultTextStyle.of(context);

    final fontSize =
        (widget.style.fontSize ?? defaultTextStyle.style.fontSize ?? 16);

    // The background rectangle drawn by [RoundedBackgroundTextPainter] always
    // extends the text by these paddings (see `paddingHorizontal`/
    // `paddingVertical` there). The finished layer reserves room for them via
    // `enableHitBoxCorrection: true`; the editing preview must reserve the same
    // room so the rounded background does not visibly grow and shift the moment
    // editing completes.
    final lineHeight = _preferredLineHeight(fontSize);
    final hitBoxHorizontal = lineHeight * 0.3;
    final hitBoxVertical = lineHeight * 0.1;

    return MediaQuery(
      data: MediaQuery.of(context).copyWith(textScaler: TextScaler.noScaling),
      child: Stack(
        clipBehavior: Clip.none,
        alignment: switch (widget.textAlign) {
          TextAlign.end => AlignmentDirectional.centerEnd,
          TextAlign.start => AlignmentDirectional.centerStart,
          TextAlign.left => Alignment.centerLeft,
          TextAlign.right => Alignment.centerRight,
          TextAlign.center || _ => Alignment.topCenter,
        },
        children: [
          if (_textController.text.isNotEmpty)
            _buildBackgroundText(hitBoxHorizontal: hitBoxHorizontal),
          _buildEditableText(
            fontSize: fontSize,
            hitBoxHorizontal: hitBoxHorizontal,
            hitBoxVertical: hitBoxVertical,
          ),
        ],
      ),
    );
  }

  double? _cachedLineHeight;
  double? _cachedLineHeightFontSize;
  TextStyle? _cachedLineHeightStyle;
  TextLeadingDistribution? _cachedLineHeightLeading;
  TextDirection? _cachedLineHeightDirection;

  /// [widget.style] with the line height the editable text lays its glyphs
  /// out with. The background text uses it as well, so its rectangle and the
  /// outline it draws line up with the editable glyphs.
  ///
  /// The style does not inherit. A text field otherwise keeps the ambient
  /// text theme's letter spacing wherever this style leaves it unset, and
  /// the painted layer does not.
  TextStyle get _glyphStyle {
    final style = widget.style;
    return style.copyWith(
      inherit: false,
      textBaseline: style.textBaseline ?? TextBaseline.alphabetic,
      height: widget.configs.style.textHeight,
      letterSpacing:
          style.letterSpacing ?? widget.configs.style.inputLetterSpacing,
    );
  }

  /// The preferred line height for [_glyphStyle] at [fontSize], computed the
  /// same way [RoundedBackgroundText] lays the text out, so the hit-box padding
  /// reserved here matches the rectangle the painter draws. Memoized because
  /// [build] runs on every keystroke and scroll tick while none of the inputs
  /// change per frame.
  double _preferredLineHeight(double fontSize) {
    final style = _glyphStyle;
    final leading = widget.configs.style.leadingDistribution;
    final direction = Directionality.maybeOf(context) ?? TextDirection.ltr;
    if (_cachedLineHeight != null &&
        _cachedLineHeightFontSize == fontSize &&
        _cachedLineHeightStyle == style &&
        _cachedLineHeightLeading == leading &&
        _cachedLineHeightDirection == direction) {
      return _cachedLineHeight!;
    }

    final painter = TextPainter(
      text: TextSpan(
        style: TextStyle(
          leadingDistribution: leading,
        ).merge(style.copyWith(fontSize: fontSize)),
        text: 'A',
      ),
      textDirection: direction,
    )..layout();
    final lineHeight = painter.preferredLineHeight;
    painter.dispose();

    _cachedLineHeight = lineHeight;
    _cachedLineHeightFontSize = fontSize;
    _cachedLineHeightStyle = style;
    _cachedLineHeightLeading = leading;
    _cachedLineHeightDirection = direction;
    return lineHeight;
  }

  Widget _buildBackgroundText({required double hitBoxHorizontal}) {
    // The editable text paints the glyphs and, without an outline, their
    // shadows. With an outline, the outline has to sit under the glyphs and
    // cast the shadows, so this background text paints both instead.
    final style = _glyphStyle.copyWith(
      color: Colors.transparent,
      leadingDistribution: widget.configs.style.leadingDistribution,
      shadows: widget._hasOutline ? null : const [],
    );

    return Positioned(
      top: _scrollCtrl.hasClients ? -_scrollCtrl.position.pixels : null,
      left: 0,
      right: 0,
      child: IgnorePointer(
        child: RoundedBackgroundText.rich(
          text: _textController.buildTextSpan(
            context: context,
            withComposing: true,
            style: style,
          ),
          // Wrap at the same column as the editable text: the editable glyphs
          // are inset by `hitBoxHorizontal` on each side (see
          // `_buildEditableText`), so the background must lay its glyphs out at
          // that same reduced width. Otherwise the two disagree on the wrap
          // column and the line count changes when editing completes.
          maxTextWidth:
              widget.maxTextWidth - widget.cursorWidth - 2 * hitBoxHorizontal,
          cursorWidth: widget.cursorWidth,
          textAlign: widget.textAlign,
          backgroundColor: widget.backgroundColor,
          // Match the finished layer (LayerWidgetTextItem) so the rounded
          // background reserves symmetric padding while editing.
          enableHitBoxCorrection: true,
          outlineWidth: widget.outlineWidth,
          outlineColor: widget.outlineColor,
        ),
      ),
    );
  }

  Widget _buildEditableText({
    required double fontSize,
    required double hitBoxHorizontal,
    required double hitBoxVertical,
  }) {
    return Padding(
      // Inset the editable glyphs by the same hit-box padding the background
      // rectangle reserves, so the visible text stays centered inside the box
      // and aligns with the finished layer.
      padding: EdgeInsets.symmetric(
        horizontal: hitBoxHorizontal,
        vertical: hitBoxVertical,
      ),
      child: Material(
        type: MaterialType.transparency,
        child: TextField(
          onTap:
              _textController.text.isEmpty &&
                  View.of(context).viewInsets.bottom <= 0
              ? () {
                  FocusManager.instance.primaryFocus?.unfocus();
                  widget.focusNode.requestFocus();
                }
              : null,
          autofocus: widget.autofocus,
          controller: _textController,
          focusNode: widget.focusNode,
          scrollPhysics: const NeverScrollableScrollPhysics(),
          scrollController: _scrollCtrl,
          scrollPadding: EdgeInsets.zero,
          style: _glyphStyle.copyWith(
            fontSize: fontSize,
            leadingDistribution: widget.configs.style.leadingDistribution,
            shadows: widget._hasOutline ? const [] : null,
          ),
          spellCheckConfiguration: widget.configs.spellCheckConfiguration,
          decoration: InputDecoration.collapsed(
            hintText: _textController.text.isEmpty ? widget.hint : '',
            hintStyle:
                (widget.hintStyle ??
                        TextStyle(color: Theme.of(context).hintColor))
                    .copyWith(fontSize: fontSize),
            maintainHintSize: false,
          ),
          textAlign: widget.textAlign,
          maxLines: null,
          keyboardType: TextInputType.multiline,
          textCapitalization: TextCapitalization.sentences,
          textInputAction: TextInputAction.newline,
          cursorColor: widget.configs.style.inputCursorColor,
          cursorWidth: widget.cursorWidth,
          cursorHeight: widget.cursorHeight,
          cursorRadius: widget.cursorRadius,
          enableInteractiveSelection: true,
          showCursor: true,
          autocorrect: widget.configs.enableAutocorrect,
          smartDashesType: SmartDashesType.enabled,
          smartQuotesType: SmartQuotesType.enabled,
          enableSuggestions: widget.configs.enableSuggestions,
          clipBehavior: Clip.hardEdge,
          onChanged: widget.onChanged,
          onEditingComplete: widget.onEditingComplete,
          onSubmitted: widget.onSubmitted,
          onTapOutside: widget.onTapOutside,
        ),
      ),
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);

    properties
      ..add(DiagnosticsProperty<TextEditorConfigs>('configs', widget.configs))
      ..add(DiagnosticsProperty<TextStyle>('style', widget.style))
      ..add(EnumProperty<TextAlign>('textAlign', widget.textAlign))
      ..add(ColorProperty('backgroundColor', widget.backgroundColor))
      ..add(DoubleProperty('outlineWidth', widget.outlineWidth))
      ..add(ColorProperty('outlineColor', widget.outlineColor))
      ..add(DoubleProperty('maxTextWidth', widget.maxTextWidth))
      ..add(DoubleProperty('cursorWidth', widget.cursorWidth))
      ..add(
        DoubleProperty('cursorHeight', widget.cursorHeight, defaultValue: null),
      )
      ..add(
        DiagnosticsProperty<Radius>(
          'cursorRadius',
          widget.cursorRadius,
          defaultValue: null,
        ),
      )
      ..add(StringProperty('hint', widget.hint))
      ..add(
        DiagnosticsProperty<TextStyle>(
          'hintStyle',
          widget.hintStyle,
          defaultValue: null,
        ),
      )
      ..add(
        FlagProperty(
          'autofocus',
          value: widget.autofocus,
          ifTrue: 'autofocus enabled',
        ),
      )
      ..add(
        FlagProperty(
          'hasOnChanged',
          value: widget.onChanged != null,
          ifTrue: 'onChanged set',
        ),
      )
      ..add(
        FlagProperty(
          'hasOnEditingComplete',
          value: widget.onEditingComplete != null,
          ifTrue: 'onEditingComplete set',
        ),
      )
      ..add(
        FlagProperty(
          'hasOnSubmitted',
          value: widget.onSubmitted != null,
          ifTrue: 'onSubmitted set',
        ),
      );
  }
}
