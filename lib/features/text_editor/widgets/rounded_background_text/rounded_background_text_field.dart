import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:material_ui/material_ui.dart';

import '/core/models/editor_configs/pro_image_editor_configs.dart';
import '/core/models/layers/text_gradient.dart';
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
    this.gradient,
    this.textWrapWidth,
  });

  /// Where the lines wrap, measured the way a painted layer wraps them: the
  /// width of the glyphs, without the background padding around them.
  ///
  /// When set, the field lays its text out at exactly this width and sizes
  /// itself with the padding added, so editing a layer keeps its line
  /// breaks. [maxTextWidth] is then not used. Without a [box] only.
  final double? textWrapWidth;

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

  /// A color gradient that fills the glyphs in place of the color of
  /// [style], or `null` to fill them with that color.
  final TextGradient? gradient;

  bool get _hasOutline => outlineWidth > 0 && outlineColor.a > 0;

  bool get _hasGradient => gradient?.isValid ?? false;

  /// Whether the background text paints the shadows, which it does whenever
  /// it paints something the shadows must fall under: an outline or the
  /// gradient glyphs.
  bool get _backgroundPaintsShadows => _hasOutline || _hasGradient;

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
      max(0.0, lineHeight * 0.3 + effect.dx - _caretMargin),
      lineHeight * 0.1 + effect.dy,
    );
    // An outline casts the shadows itself, and gradient glyphs are drawn
    // beneath the field, which would otherwise cast its shadows over them.
    // Otherwise the field paints them, scaled with the font the way
    // RoundedBackgroundText does.
    List<Shadow>? fieldShadows;
    if (widget._backgroundPaintsShadows) {
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
      // The gradient glyphs beneath show through.
      color: widget._hasGradient ? const Color(0x00000000) : null,
    );
    final vertical = switch (box.verticalAlign) {
      TextLayerBoxVerticalAlign.top => TextAlignVertical.top,
      TextLayerBoxVerticalAlign.center => TextAlignVertical.center,
      TextLayerBoxVerticalAlign.bottom => TextAlignVertical.bottom,
    };
    // Text taller than the box shows past it, as the painted layer draws
    // it: the field grows with its lines instead of scrolling inside the box.
    final visible = box.overflow == TextLayerBoxOverflow.visible;

    Widget textField = Material(
      type: MaterialType.transparency,
      child: TextField(
        controller: _textController,
        focusNode: widget.focusNode,
        autofocus: widget.autofocus,
        expands: !visible,
        maxLines: null,
        textAlignVertical: visible ? null : vertical,
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
        spellCheckConfiguration: widget.configs.spellCheckConfiguration,
        clipBehavior: visible ? Clip.none : Clip.hardEdge,
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
    );
    if (visible) {
      textField = CustomSingleChildLayout(
        delegate: _OverflowBelowLayout(box.verticalAlign.factor),
        child: textField,
      );
    }

    final stack = Stack(
      clipBehavior: visible ? Clip.none : Clip.hardEdge,
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
              // Under gradient glyphs, which the field cannot draw.
              paintShadows: widget._hasGradient,
              outlineWidth: widget.outlineWidth,
              outlineColor: widget.outlineColor,
              gradient: widget.gradient,
            ),
          ),
        ),
        Positioned.fill(
          child: Padding(padding: inset, child: textField),
        ),
      ],
    );
    final boxed = SizedBox(
      width: box.size.width,
      height: box.size.height,
      child: visible ? stack : ClipRect(child: stack),
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
    final wrapWidth = widget.textWrapWidth;

    Widget field = Stack(
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
          _buildBackgroundText(
            hitBoxHorizontal: hitBoxHorizontal,
            wrapWidth: wrapWidth,
          ),
        _buildEditableText(
          fontSize: fontSize,
          hitBoxHorizontal: hitBoxHorizontal,
          hitBoxVertical: hitBoxVertical,
        ),
      ],
    );
    if (wrapWidth != null) {
      // The editable glyphs get the wrap width: the field adds the padding
      // on both sides, minus the caret room it gives back on the right,
      // which the text field keeps inside.
      field = ConstrainedBox(
        constraints: BoxConstraints(maxWidth: wrapWidth + hitBoxHorizontal * 2),
        child: field,
      );
    }

    return MediaQuery(
      data: MediaQuery.of(context).copyWith(textScaler: TextScaler.noScaling),
      child: field,
    );
  }

  /// The room a text field keeps after each line for its caret, which the
  /// laid-out layer does not have. Flutter's `RenderEditable` reserves the
  /// cursor width plus a one pixel gap.
  double get _caretMargin => widget.cursorWidth + 1;

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
      // A layer's own line height, as the painted layer uses it.
      height: style.height ?? widget.configs.style.textHeight,
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

  Widget _buildBackgroundText({
    required double hitBoxHorizontal,
    double? wrapWidth,
  }) {
    // The editable text paints the glyphs and, without an outline, their
    // shadows. With an outline, the outline has to sit under the glyphs and
    // cast the shadows, so this background text paints both instead. A
    // gradient is laid across the lines this text knows, so it fills the
    // glyphs here as well; the editable glyphs stay clear, and the shadows
    // move here so they fall under the gradient glyphs rather than over them.
    final style = _glyphStyle.copyWith(
      color: Colors.transparent,
      leadingDistribution: widget.configs.style.leadingDistribution,
      shadows: widget._backgroundPaintsShadows ? null : const [],
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
              wrapWidth ??
              widget.maxTextWidth - widget.cursorWidth - 2 * hitBoxHorizontal,
          cursorWidth: widget.cursorWidth,
          textAlign: widget.textAlign,
          backgroundColor: widget.backgroundColor,
          // Match the finished layer (LayerWidgetTextItem) so the rounded
          // background reserves symmetric padding while editing.
          enableHitBoxCorrection: true,
          outlineWidth: widget.outlineWidth,
          outlineColor: widget.outlineColor,
          gradient: widget.gradient,
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
      // and aligns with the finished layer. The field keeps room for the
      // caret at the end of each line, taken from the padding on that side.
      padding: EdgeInsets.fromLTRB(
        hitBoxHorizontal,
        hitBoxVertical,
        max(0.0, hitBoxHorizontal - _caretMargin),
        hitBoxVertical,
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
            shadows: widget._backgroundPaintsShadows ? const [] : null,
            color: widget._hasGradient ? Colors.transparent : null,
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
      ..add(
        DiagnosticsProperty<TextGradient>(
          'gradient',
          widget.gradient,
          defaultValue: null,
        ),
      )
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

/// Lays the field of a box whose text shows past it out at the box width
/// and as tall as its lines, placed like the painted layer places its text:
/// shorter text by the box's vertical alignment, taller text from the top.
class _OverflowBelowLayout extends SingleChildLayoutDelegate {
  const _OverflowBelowLayout(this.alignFactor);

  final double alignFactor;

  @override
  BoxConstraints getConstraintsForChild(BoxConstraints constraints) {
    return BoxConstraints.tightFor(width: constraints.maxWidth);
  }

  @override
  Offset getPositionForChild(Size size, Size childSize) {
    return Offset(0, max(0.0, size.height - childSize.height) * alignFactor);
  }

  @override
  bool shouldRelayout(_OverflowBelowLayout oldDelegate) =>
      oldDelegate.alignFactor != alignFactor;
}
