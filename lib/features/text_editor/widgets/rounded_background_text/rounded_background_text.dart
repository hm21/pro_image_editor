import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:material_ui/material_ui.dart';

import '/core/models/layers/text_gradient.dart';
import '/core/models/layers/text_layer_box.dart';
import '../../utils/rounded_background_painter.dart';

/// Creates a [RoundedBackgroundText] widget with plain text and optional
/// styling.
///
/// The [text] parameter is a simple `String` which will be wrapped in a
/// [TextSpan].
class RoundedBackgroundText extends StatelessWidget {
  /// Creates a [RoundedBackgroundText] widget from a plain [String] with
  /// optional styling.
  ///
  /// This constructor converts the [text] into a [TextSpan] using the
  /// provided [style].
  ///
  /// Use this constructor when you don't need rich text formatting.
  RoundedBackgroundText(
    String text, {
    super.key,
    TextStyle? style,
    this.textAlign,
    this.backgroundColor,
    this.onHitTestResult,
    required this.maxTextWidth,
    this.maxWidth = double.infinity,
    this.softMaxWidth = double.infinity,
    this.cursorWidth = 0,
    this.enableHitBoxCorrection = false,
    this.leadingDistribution = TextLeadingDistribution.proportional,
    this.outlineWidth = 0,
    this.outlineColor = const Color(0xFF000000),
    this.reserveEffectSpace = false,
    this.paintShadows = true,
    this.visibleLength,
    this.box,
    this.gradient,
  }) : text = TextSpan(text: text, style: style);

  /// Creates a [RoundedBackgroundText] widget with rich text using
  /// [InlineSpan].
  ///
  /// Use this constructor when you want to provide styled or nested spans via
  /// the [text] parameter.
  const RoundedBackgroundText.rich({
    super.key,
    required this.text,
    this.backgroundColor,
    this.textAlign,
    this.onHitTestResult,
    required this.maxTextWidth,
    this.maxWidth = double.infinity,
    this.softMaxWidth = double.infinity,
    this.cursorWidth = 0,
    this.enableHitBoxCorrection = false,
    this.leadingDistribution = TextLeadingDistribution.proportional,
    this.outlineWidth = 0,
    this.outlineColor = const Color(0xFF000000),
    this.reserveEffectSpace = false,
    this.paintShadows = true,
    this.visibleLength,
    this.box,
    this.gradient,
  });

  /// A flag to enable or disable hitBox correction for the text.
  final bool enableHitBoxCorrection;

  /// The text content to be displayed, supporting rich formatting through
  /// [InlineSpan].
  final InlineSpan text;

  /// How the text should be aligned horizontally within its container.
  final TextAlign? textAlign;

  /// The optional background color behind the text.
  final Color? backgroundColor;

  /// The maximum width the text is allowed to occupy. If null, the text can
  /// expand freely.
  final double maxTextWidth;

  /// The widest the drawn text may be: its glyphs with their outline, and
  /// its background with the padding around the text when [backgroundColor]
  /// shows.
  ///
  /// Lines wrap to keep that within this width, and a word wider than this
  /// is broken. The widget itself may be wider by the transparent space it
  /// reserves for the hit box correction and the effects, and the fading
  /// edge of a shadow may reach past it, so text without a background can
  /// reach right up to this width. [maxTextWidth] still applies when it is
  /// narrower. Defaults to [double.infinity], which sets no limit.
  final double maxWidth;

  /// The widest this widget should lay out, measured like [maxWidth], as
  /// long as that keeps its words whole.
  ///
  /// Lines wrap between words to stay within this width, but the widget
  /// never gets narrower than its longest word for it; only [maxWidth]
  /// breaks a word. Defaults to [double.infinity], which sets no limit.
  final double softMaxWidth;

  /// The width of the text cursor when displayed.
  final double cursorWidth;

  /// Controls how extra leading is distributed above and below the text.
  ///
  /// Defaults to [TextLeadingDistribution.proportional].
  /// Set to [TextLeadingDistribution.even] to visually centre glyphs inside
  /// their rounded background rects when [TextStyle.height] > 1.0.
  final TextLeadingDistribution leadingDistribution;

  /// Callback function triggered with the result of a hit test.
  final Function(bool hasHit)? onHitTestResult;

  /// The thickness of the outline drawn around each glyph, measured outward
  /// from the glyph edge. `0` draws no outline.
  ///
  /// While an outline is drawn, the shadows of the text style are cast by
  /// the outlined glyphs rather than the bare ones.
  final double outlineWidth;

  /// The color of the outline.
  final Color outlineColor;

  /// Whether the widget grows by the space its outline and shadows paint
  /// beyond the glyphs, so a capture of its bounds does not cut them off.
  ///
  /// The space is added on both sides, so the text keeps its center.
  final bool reserveEffectSpace;

  /// Whether the shadows of [text] are painted.
  ///
  /// When this is `false` those shadows still reserve their space, so the
  /// text shrinks and sits where it would with them drawn, but this painter
  /// draws none of them. An outline still casts its own. Defaults to `true`.
  final bool paintShadows;

  /// How many UTF-16 code units of [text], counted from its start, are
  /// painted, or `null` to paint all of it.
  ///
  /// The rest is laid out as if it were there, so the widget keeps its size
  /// and its line breaks while it draws nothing of the hidden part — no
  /// glyphs, no outline, no shadows and no background behind it. A text that
  /// types itself out shows that way, its background growing with it.
  final int? visibleLength;

  /// A fixed box to lay the text out in, its size in logical pixels, or
  /// `null` to size the widget to its text.
  ///
  /// The widget then takes the size of the box, the text wraps at its width
  /// (less the padding and effect space) instead of [maxTextWidth],
  /// [maxWidth] and [softMaxWidth], and [backgroundColor] fills the whole
  /// box as one rectangle, which is also what hit testing reads. Text taller
  /// than the box is clipped or shrunk, as [TextLayerBox.overflow] says.
  final TextLayerBox? box;

  /// A color gradient that fills the glyphs in place of the color of the
  /// text style, or `null` to fill them with that color.
  ///
  /// It runs across the box around all the lines of [text], hidden ones
  /// included (see [visibleLength]), so a text that types itself out keeps
  /// each letter in the color it has once the whole text shows. Parts of
  /// [text] whose own style sets a color keep it, and the outline and the
  /// shadows are not filled. A gradient that is not [TextGradient.isValid] is
  /// ignored.
  final TextGradient? gradient;

  bool get _hasOutline => outlineWidth > 0 && outlineColor.a > 0;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final layout = _layout(context, constraints);
        return CustomPaint(
          isComplex: true,
          painter: layout.painter,
          size: layout.size,
        );
      },
    );
  }

  /// Paints this text into an image the way it paints on screen when laid
  /// out at [size], at [pixelRatio] device pixels per logical pixel.
  ///
  /// [context] supplies the inherited text style and direction, exactly as it
  /// does in [build], so it must be a context the widget could be built in.
  /// The result matches what `RenderRepaintBoundary.toImage` reads from a
  /// boundary directly around this widget, without the widget having to be
  /// on screen in that state.
  ///
  /// [bounds] is the part of the text the image holds, in the coordinates
  /// of [size], such as one grown by lines a [box] shows past itself.
  /// Defaults to `Offset.zero & size`.
  Future<ui.Image> toImage(
    BuildContext context, {
    required Size size,
    required double pixelRatio,
    Rect? bounds,
  }) async {
    final area = bounds ?? Offset.zero & size;
    final painter = _layout(context, BoxConstraints.loose(size)).painter;
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder)
      ..scale(pixelRatio)
      ..translate(-area.left, -area.top);
    painter.paint(canvas, size);

    final picture = recorder.endRecording();
    try {
      return await picture.toImage(
        (area.width * pixelRatio).ceil(),
        (area.height * pixelRatio).ceil(),
      );
    } finally {
      picture.dispose();
      _disposeTextPainters(painter);
    }
  }

  /// Whether [maxWidth] or [softMaxWidth] wrap the text onto more lines than
  /// it takes without them.
  ///
  /// [context] supplies the inherited text style and direction, as it does
  /// for [toImage]. Text in a [box] wraps at the box, so neither width ever
  /// wraps it.
  bool wrapsAtMaxWidth(BuildContext context) {
    if (box != null) return false;
    if (maxWidth == double.infinity && softMaxWidth == double.infinity) {
      return false;
    }
    const constraints = BoxConstraints();
    final limited = _layout(context, constraints).painter;
    final unlimited = _layout(
      context,
      constraints,
      applyWidthLimits: false,
    ).painter;
    try {
      return limited.painter.computeLineMetrics().length >
          unlimited.painter.computeLineMetrics().length;
    } finally {
      _disposeTextPainters(limited);
      _disposeTextPainters(unlimited);
    }
  }

  static void _disposeTextPainters(RoundedBackgroundTextPainter painter) {
    painter.painter.dispose();
    painter.outlinePainter?.dispose();
    for (final silhouette in painter.silhouettePainters) {
      silhouette.dispose();
    }
  }

  /// Lays the text out within [constraints] and returns the painter that
  /// draws it together with the size it paints at.
  ///
  /// Without [applyWidthLimits], [maxWidth] and [softMaxWidth] are ignored.
  ({RoundedBackgroundTextPainter painter, Size size}) _layout(
    BuildContext context,
    BoxConstraints constraints, {
    bool applyWidthLimits = true,
  }) {
    final defaultTextStyle = DefaultTextStyle.of(context);
    final style = text.style ?? defaultTextStyle.style;
    final align = textAlign ?? defaultTextStyle.textAlign ?? TextAlign.start;
    final rootStyle = TextStyle(
      leadingDistribution: leadingDistribution,
    ).merge(style);
    final shadows = style.shadows ?? const <Shadow>[];
    final hasOutline = _hasOutline;

    // Below 1 while a box shrinks its text to fit, which the outline and the
    // shadows follow.
    var textScale = 1.0;

    InlineSpan buildSpan(
      TextStyle Function(TextStyle style)? restyle, {
      Paint? fill,
    }) {
      var content = restyle == null ? text : _restyleSpan(text, restyle);
      var root = restyle == null ? rootStyle : restyle(rootStyle);
      if (fill != null) {
        content = _fillWith(content, fill);
        root = root.copyWith(foreground: fill);
      }
      // Hidden last, so no pass, the outline's included, paints that part.
      if (visibleLength case final visible?) {
        content = _hideAfter(content, visible);
      }
      return TextSpan(children: [content], style: root);
    }

    TextPainter createPainter(TextStyle Function(TextStyle style)? restyle) {
      return TextPainter(
        text: buildSpan(restyle),
        textDirection: Directionality.maybeOf(context) ?? TextDirection.ltr,
        maxLines: defaultTextStyle.maxLines,
        textAlign: align,
        textWidthBasis: defaultTextStyle.textWidthBasis,
        textHeightBehavior: defaultTextStyle.textHeightBehavior,
        textScaler: textScale == 1
            ? TextScaler.noScaling
            : TextScaler.linear(textScale),
      );
    }

    TextStyle Function(TextStyle style) paintWith(Paint paint) {
      return (style) => style.copyWith(
        foreground: paint,
        shadows: const [],
        decoration: TextDecoration.none,
      );
    }

    Paint strokePaint(Color color) => Paint()
      ..style = PaintingStyle.stroke
      // Half of the stroke lies inside the glyph, under the fill.
      ..strokeWidth = outlineWidth * 2 * textScale
      ..strokeJoin = StrokeJoin.round
      ..strokeCap = StrokeCap.round
      ..color = color;

    final effectSpace = reserveEffectSpace
        ? _effectSpace(
            outlineWidth: hasOutline ? outlineWidth : 0,
            shadows: shadows,
          )
        : Offset.zero;

    final box = this.box;
    if (box != null && box.overflow == TextLayerBoxOverflow.shrink) {
      textScale = _shrinkFactor(createPainter(null), box.size, effectSpace);
    }
    List<Shadow>? scaleShadows(List<Shadow>? shadows) => textScale == 1
        ? shadows
        : shadows?.map((shadow) => shadow.scale(textScale)).toList();

    // With an outline, the shadows are cast by the outlined glyphs, which the
    // painter draws from opaque silhouettes; the passes themselves draw none.
    // [paintShadows] keeps the same space while leaving the drawing to a
    // caller that paints the shadows itself.
    final TextStyle Function(TextStyle style)? fillRestyle =
        hasOutline || !paintShadows
        ? (style) => style.copyWith(shadows: const [])
        : textScale == 1
        ? null
        : (style) => style.copyWith(shadows: scaleShadows(style.shadows));
    final painter = createPainter(fillRestyle);

    // The gradient runs across the lines, which are only known once the text
    // is laid out. Only the paint changes, so the layout is kept.
    void fillWithGradient(double minWidth, double maxWidth) {
      final gradient = this.gradient;
      if (gradient == null || !gradient.isValid) return;
      final shader = gradient.createShader(_linesBounds(painter));
      painter
        ..text = buildSpan(fillRestyle, fill: Paint()..shader = shader)
        ..layout(minWidth: minWidth, maxWidth: maxWidth);
    }

    final outlinePainter = hasOutline
        ? createPainter(paintWith(strokePaint(outlineColor)))
        : null;
    final hasOutlineShadows = hasOutline && shadows.isNotEmpty;
    final silhouettePainters = hasOutlineShadows
        ? [
            createPainter(paintWith(strokePaint(const Color(0xFF000000)))),
            createPainter(paintWith(Paint()..color = const Color(0xFF000000))),
          ]
        : const <TextPainter>[];

    double height = painter.preferredLineHeight;

    double horizontalSpace = enableHitBoxCorrection ? height * 0.3 : 0;
    double verticalSpace = enableHitBoxCorrection ? height * 0.1 : 0;

    final overflowsBox = box?.overflow == TextLayerBoxOverflow.visible;
    RoundedBackgroundTextPainter createBackgroundPainter(
      Offset textOffset, {
      Size? boxSize,
    }) {
      return RoundedBackgroundTextPainter(
        backgroundColor: backgroundColor ?? Colors.transparent,
        painter: painter,
        outlinePainter: outlinePainter,
        outlineWidth: hasOutline ? outlineWidth : 0,
        outlineColor: outlineColor,
        silhouettePainters: silhouettePainters,
        silhouetteShadows: hasOutlineShadows
            ? scaleShadows(shadows)!
            : const [],
        onHitTestResult: onHitTestResult,
        textAlign: align,
        cursorWidth: cursorWidth,
        textDirection: Directionality.of(context),
        hitBoxCorrectionOffset: textOffset,
        visibleLength: visibleLength,
        boxSize: boxSize,
        clipToBox: !overflowsBox,
        effectSpace: overflowsBox
            ? _effectSpace(
                outlineWidth: hasOutline ? outlineWidth : 0,
                shadows: shadows,
              )
            : Offset.zero,
      );
    }

    if (box != null) {
      final inset = Offset(horizontalSpace, verticalSpace) + effectSpace;
      final room = _boxRoom(box.size, inset);
      final textPainters = [painter, ?outlinePainter, ...silhouettePainters];
      for (final textPainter in textPainters) {
        textPainter.layout(minWidth: room.width, maxWidth: room.width);
      }
      fillWithGradient(room.width, room.width);
      final freeHeight = max(0.0, room.height - painter.height);
      final textOffset = inset.translate(
        0,
        freeHeight * box.verticalAlign.factor,
      );
      return (
        painter: createBackgroundPainter(textOffset, boxSize: box.size),
        size: constraints.constrain(box.size),
      );
    }

    // Only what shows counts against maxWidth: the background's padding,
    // which RoundedBackgroundTextPainter makes 0.3 lines wide, or else the
    // outline. The hit box padding and the effect space are transparent.
    final hasBackground = (backgroundColor?.a ?? 0) > 0;
    final drawnMargin = max(
      hasBackground ? height * 0.3 : 0.0,
      hasOutline ? outlineWidth : 0.0,
    );
    final maxWidth = applyWidthLimits ? this.maxWidth : double.infinity;
    final softMaxWidth = applyWidthLimits ? this.softMaxWidth : double.infinity;
    var textMaxWidth = min(maxTextWidth, max(0.0, maxWidth - drawnMargin * 2));
    final textSoftMaxWidth = max(0.0, softMaxWidth - drawnMargin * 2);
    if (textSoftMaxWidth < textMaxWidth) {
      // The longest word only reads after a layout; rounding up keeps it on
      // one line when the text is laid out at exactly that width.
      painter.layout();
      final longestWord = painter.minIntrinsicWidth.ceilToDouble();
      textMaxWidth = min(textMaxWidth, max(textSoftMaxWidth, longestWord));
    }
    painter.layout(maxWidth: textMaxWidth);
    fillWithGradient(0, textMaxWidth);
    outlinePainter?.layout(maxWidth: textMaxWidth);
    for (final silhouette in silhouettePainters) {
      silhouette.layout(maxWidth: textMaxWidth);
    }

    return (
      painter: createBackgroundPainter(
        Offset(horizontalSpace, verticalSpace) + effectSpace,
      ),
      size: Size(
        painter.width.clamp(0, constraints.maxWidth) +
            (horizontalSpace + effectSpace.dx) * 2,
        painter.height.clamp(0, constraints.maxHeight) +
            (verticalSpace + effectSpace.dy) * 2,
      ),
    );
  }

  /// The room a box of [size] leaves for its text inside [inset] on every
  /// side.
  static Size _boxRoom(Size size, Offset inset) {
    return Size(
      max(0.0, size.width - inset.dx * 2),
      max(0.0, size.height - inset.dy * 2),
    );
  }

  /// How far an outline of [outlineWidth] and [shadows] paint beyond the
  /// glyphs on each axis.
  static Offset effectExtent({
    required double outlineWidth,
    required List<Shadow> shadows,
  }) {
    return _effectSpace(outlineWidth: outlineWidth, shadows: shadows);
  }

  /// The scale at which [text] in [style] fits a box of [boxSize], down to
  /// [TextLayerBox.minShrinkFactor], matching what this widget paints for
  /// [TextLayerBoxOverflow.shrink].
  static double scaleForBox({
    required InlineSpan text,
    required TextStyle style,
    required Size boxSize,
    required bool enableHitBoxCorrection,
    double outlineWidth = 0,
    TextAlign textAlign = TextAlign.start,
    TextLeadingDistribution leadingDistribution =
        TextLeadingDistribution.proportional,
    TextDirection textDirection = TextDirection.ltr,
  }) {
    final effectSpace = _effectSpace(
      outlineWidth: outlineWidth,
      shadows: style.shadows ?? const <Shadow>[],
    );
    final painter = TextPainter(
      text: TextSpan(
        children: [text],
        style: TextStyle(leadingDistribution: leadingDistribution).merge(style),
      ),
      textAlign: textAlign,
      textDirection: textDirection,
    );
    return shrinkToBox(
      probe: painter,
      boxSize: boxSize,
      effectSpace: effectSpace,
      enableHitBoxCorrection: enableHitBoxCorrection,
    );
  }

  /// The largest text scale, down to [TextLayerBox.minShrinkFactor], at
  /// which the text of [probe] fits a box of [boxSize] whose text keeps
  /// [effectSpace] to its edges. Disposes [probe].
  static double shrinkToBox({
    required TextPainter probe,
    required Size boxSize,
    required Offset effectSpace,
    required bool enableHitBoxCorrection,
  }) {
    bool fits(double factor) {
      probe.textScaler = TextScaler.linear(factor);
      // The padding follows the line height, which shrinks with the text.
      final lineHeight = probe.preferredLineHeight;
      final inset = enableHitBoxCorrection
          ? Offset(lineHeight * 0.3, lineHeight * 0.1) + effectSpace
          : effectSpace;
      final room = _boxRoom(boxSize, inset);
      probe.layout(maxWidth: room.width);
      return probe.height <= room.height;
    }

    try {
      if (fits(1)) return 1;
      var low = TextLayerBox.minShrinkFactor;
      if (!fits(low)) return low;
      var high = 1.0;
      // Ten halvings settle the size within a thousandth of the range.
      for (var i = 0; i < 10; i++) {
        final middle = (low + high) / 2;
        if (fits(middle)) {
          low = middle;
        } else {
          high = middle;
        }
      }
      return low;
    } finally {
      probe.dispose();
    }
  }

  /// The largest text scale, down to [TextLayerBox.minShrinkFactor], at
  /// which the text of [probe] fits a box of [boxSize] whose text keeps
  /// [effectSpace] to its edges. Disposes [probe].
  double _shrinkFactor(TextPainter probe, Size boxSize, Offset effectSpace) {
    return shrinkToBox(
      probe: probe,
      boxSize: boxSize,
      effectSpace: effectSpace,
      enableHitBoxCorrection: enableHitBoxCorrection,
    );
  }

  /// How far the outline and the shadows paint beyond the glyphs on each
  /// axis.
  static Offset _effectSpace({
    required double outlineWidth,
    required List<Shadow> shadows,
  }) {
    double dx = outlineWidth;
    double dy = outlineWidth;
    for (final shadow in shadows) {
      // A gaussian blur fades out within three sigma.
      final blur = shadow.blurRadius > 0
          ? Shadow.convertRadiusToSigma(shadow.blurRadius) * 3
          : 0.0;
      dx = max(dx, outlineWidth + shadow.offset.dx.abs() + blur);
      dy = max(dy, outlineWidth + shadow.offset.dy.abs() + blur);
    }
    return Offset(dx.ceilToDouble(), dy.ceilToDouble());
  }

  /// The box around the lines [painter] laid out: from the left edge of the
  /// line that starts furthest left to the right edge of the one that ends
  /// furthest right, over the full height of the text.
  ///
  /// Empty lines are left out. Without any glyphs, the box is the size of
  /// [painter].
  static Rect _linesBounds(TextPainter painter) {
    var left = double.infinity;
    var right = double.negativeInfinity;
    for (final line in painter.computeLineMetrics()) {
      if (line.width <= 0) continue;
      left = min(left, line.left);
      right = max(right, line.left + line.width);
    }
    if (right <= left) return Offset.zero & painter.size;
    return Rect.fromLTRB(left, 0, right, painter.height);
  }

  /// A copy of [span] filled with [paint]: its own style takes [paint] as its
  /// foreground, which every descendant inherits unless it sets a color of
  /// its own.
  ///
  /// Such a color is turned into a foreground as well, because a foreground
  /// set on an ancestor would otherwise paint over it.
  static InlineSpan _fillWith(InlineSpan span, Paint paint) {
    if (span is! TextSpan) return span;

    TextStyle keepOwnColor(TextStyle style) {
      final color = style.color;
      if (color == null || style.foreground != null) return style;
      return style.copyWith(foreground: Paint()..color = color);
    }

    return TextSpan(
      text: span.text,
      style: (span.style ?? const TextStyle()).copyWith(foreground: paint),
      children: span.children
          ?.map((child) => _restyleSpan(child, keepOwnColor))
          .toList(),
      recognizer: span.recognizer,
      mouseCursor: span.mouseCursor,
      onEnter: span.onEnter,
      onExit: span.onExit,
      semanticsLabel: span.semanticsLabel,
      semanticsIdentifier: span.semanticsIdentifier,
      locale: span.locale,
      spellOut: span.spellOut,
    );
  }

  /// The style a hidden part of the text is laid out in: it keeps every
  /// metric of the style it is merged into and paints nothing.
  static final TextStyle _hiddenStyle = TextStyle(
    foreground: Paint()..color = const Color(0x00000000),
    background: Paint()..color = const Color(0x00000000),
    shadows: const [],
    decoration: TextDecoration.none,
  );

  /// A copy of [span] whose text after the first [visible] UTF-16 code units
  /// is laid out in [_hiddenStyle].
  ///
  /// The hidden style is merged into the style of every span it reaches,
  /// however deep, because a child's own paint would otherwise win over a
  /// parent's. A placeholder counts as one code unit and is left as it is.
  static InlineSpan _hideAfter(InlineSpan span, int visible) {
    var remaining = visible;

    TextStyle hidden(TextStyle? style) =>
        (style ?? const TextStyle()).merge(_hiddenStyle);

    InlineSpan walk(InlineSpan span) {
      if (span is! TextSpan) {
        remaining -= 1;
        return span;
      }
      final text = span.text ?? '';
      final children = span.children;
      if (remaining >= text.length && (children == null || children.isEmpty)) {
        remaining -= text.length;
        return span;
      }

      final parts = <InlineSpan>[];
      if (text.isNotEmpty) {
        if (remaining >= text.length) {
          parts.add(TextSpan(text: text));
        } else if (remaining <= 0) {
          parts.add(TextSpan(text: text, style: hidden(span.style)));
        } else {
          parts
            ..add(TextSpan(text: text.substring(0, remaining)))
            ..add(
              TextSpan(
                text: text.substring(remaining),
                style: hidden(span.style),
              ),
            );
        }
        remaining -= text.length;
      }
      for (final child in children ?? const <InlineSpan>[]) {
        parts.add(walk(child));
      }
      return TextSpan(
        style: span.style,
        children: parts,
        recognizer: span.recognizer,
        mouseCursor: span.mouseCursor,
        onEnter: span.onEnter,
        onExit: span.onExit,
        semanticsLabel: span.semanticsLabel,
        semanticsIdentifier: span.semanticsIdentifier,
        locale: span.locale,
        spellOut: span.spellOut,
      );
    }

    return walk(span);
  }

  /// A copy of [span] whose own styles, where set, are passed through
  /// [restyle], so a paint applied to the root reaches spans that set their
  /// own color.
  static InlineSpan _restyleSpan(
    InlineSpan span,
    TextStyle Function(TextStyle style) restyle,
  ) {
    if (span is! TextSpan) return span;
    return TextSpan(
      text: span.text,
      style: span.style == null ? null : restyle(span.style!),
      children: span.children
          ?.map((child) => _restyleSpan(child, restyle))
          .toList(),
      recognizer: span.recognizer,
      mouseCursor: span.mouseCursor,
      onEnter: span.onEnter,
      onExit: span.onExit,
      semanticsLabel: span.semanticsLabel,
      semanticsIdentifier: span.semanticsIdentifier,
      locale: span.locale,
      spellOut: span.spellOut,
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);

    properties
      ..add(DiagnosticsProperty<InlineSpan>('text', text))
      ..add(EnumProperty<TextAlign>('textAlign', textAlign, defaultValue: null))
      ..add(
        ColorProperty('backgroundColor', backgroundColor, defaultValue: null),
      )
      ..add(DoubleProperty('maxTextWidth', maxTextWidth))
      ..add(DoubleProperty('maxWidth', maxWidth, defaultValue: double.infinity))
      ..add(
        DoubleProperty(
          'softMaxWidth',
          softMaxWidth,
          defaultValue: double.infinity,
        ),
      )
      ..add(DoubleProperty('cursorWidth', cursorWidth, defaultValue: 0))
      ..add(
        FlagProperty(
          'enableHitBoxCorrection',
          value: enableHitBoxCorrection,
          ifTrue: 'hitBoxCorrection enabled',
        ),
      )
      ..add(
        FlagProperty(
          'hasOnHitTestResult',
          value: onHitTestResult != null,
          ifTrue: 'callback set',
        ),
      )
      ..add(
        EnumProperty<TextLeadingDistribution>(
          'leadingDistribution',
          leadingDistribution,
          defaultValue: TextLeadingDistribution.proportional,
        ),
      )
      ..add(DoubleProperty('outlineWidth', outlineWidth, defaultValue: 0))
      ..add(ColorProperty('outlineColor', outlineColor))
      ..add(IntProperty('visibleLength', visibleLength, defaultValue: null))
      ..add(
        DiagnosticsProperty<TextGradient>(
          'gradient',
          gradient,
          defaultValue: null,
        ),
      )
      ..add(
        FlagProperty(
          'reserveEffectSpace',
          value: reserveEffectSpace,
          ifTrue: 'effect space reserved',
        ),
      )
      ..add(
        FlagProperty(
          'paintShadows',
          value: paintShadows,
          ifFalse: 'shadows not painted',
          defaultValue: true,
        ),
      );
  }
}
