import 'dart:math';

import 'package:material_ui/material_ui.dart';

import '/core/models/layers/text_gradient.dart';

/// Draws the glyphs of a laid out [TextPainter] from copies of its text set
/// in a smaller font, each scaled up onto the place its part of the text has
/// in that [TextPainter].
///
/// The [TextPainter] keeps deciding everything about the text: where its
/// lines break, how high they are and where every part of them sits. Only
/// the glyphs come from the copies, so the engine rasterizes them at a small
/// size. See `RoundedBackgroundText` for why large text is drawn this way.
///
/// Every line is copied in runs: emoji apart from the rest. A color emoji
/// font sets small sizes wider than large ones, so a copy of a whole line
/// would drift from the original after its first emoji; each run is
/// therefore placed where the original draws it, and emoji are copied in a
/// font large enough to keep their proportions.
class ScaledTextLines {
  ScaledTextLines._(this._runs);

  /// The font size Flutter uses for a style that sets none.
  static const double _defaultFontSize = 14;

  /// Whether the text of a [TextPainter] built from [text], [textAlign] and
  /// [maxLines] can be drawn by [create].
  ///
  /// Placeholders, justified lines, a line limit and a mask filter are drawn
  /// only by the [TextPainter] itself: a copy can neither hold the
  /// placeholder's widget nor stretch to the justified width, would drop the
  /// ellipsis, and would blur the glyphs more than the original.
  static bool canDraw(
    InlineSpan text, {
    required TextAlign textAlign,
    required int? maxLines,
  }) {
    if (textAlign == TextAlign.justify || maxLines != null) return false;
    var supported = true;
    void visit(InlineSpan span) {
      if (!supported) return;
      if (span is! TextSpan) {
        supported = false;
        return;
      }
      final style = span.style;
      if (style?.foreground?.maskFilter != null ||
          style?.background?.maskFilter != null) {
        supported = false;
        return;
      }
      span.children?.forEach(visit);
    }

    visit(text);
    return supported;
  }

  /// Copies the text of [source], which must be laid out, in a font [scale]
  /// times smaller, its emoji in one [emojiScale] times smaller, or returns
  /// `null` when a copied run does not stay on one line.
  ///
  /// [gradient] replaces every shader of the copies' paints, spread across
  /// [gradientBounds] as a shader of [source] spreads across them when
  /// [source] is painted at [Offset.zero]: a text's shader stays where it is
  /// when the text is painted elsewhere, a copy's moves with it.
  static ScaledTextLines? create(
    TextPainter source, {
    required double scale,
    required double emojiScale,
    TextGradient? gradient,
    Rect? gradientBounds,
  }) {
    final text = source.text;
    if (text == null) return null;
    final plainText = source.plainText;
    final runs = <_ScaledRun>[];

    ScaledTextLines? fail() {
      for (final run in runs) {
        run.painter.dispose();
      }
      return null;
    }

    var start = 0;
    for (final metrics in source.computeLineMetrics()) {
      // A line ended by a line break does not include it, a soft wrapped
      // one includes the whitespace it wraps after.
      final boundary = source.getLineBoundary(TextPosition(offset: start));
      final lineStart = boundary.start;
      var end = boundary.end;
      start = end < plainText.length && plainText.codeUnitAt(end) == 0x0A
          ? end + 1
          : end;
      // Trailing whitespace draws nothing.
      while (end > lineStart && _isSpace(plainText.codeUnitAt(end - 1))) {
        end--;
      }

      for (final segment in segments(plainText, lineStart, end)) {
        final run = _ScaledRun.create(
          source: source,
          text: text,
          start: segment.start,
          end: segment.end,
          line: metrics,
          scale: segment.isEmoji ? emojiScale : scale,
          gradient: gradient,
          gradientBounds: gradientBounds,
        );
        if (run.failed) return fail();
        if (run.run case final copied?) runs.add(copied);
      }
    }
    return ScaledTextLines._(runs);
  }

  final List<_ScaledRun> _runs;

  /// Draws the glyphs where the [TextPainter] they were copied from draws
  /// them when painted at [offset].
  void paint(Canvas canvas, Offset offset) {
    for (final run in _runs) {
      run.paint(canvas, offset);
    }
  }

  /// Releases the resources of the copies.
  void dispose() {
    for (final run in _runs) {
      run.painter.dispose();
    }
  }

  /// Splits [text] between the UTF-16 offsets [start] and [end] into runs of
  /// emoji and runs of everything else.
  @visibleForTesting
  static List<({int start, int end, bool isEmoji})> segments(
    String text,
    int start,
    int end,
  ) {
    final segments = <({int start, int end, bool isEmoji})>[];
    var segmentStart = start;
    bool? segmentIsEmoji;
    var index = start;
    while (index < end) {
      final codePoint = _codePointAt(text, index);
      final length = codePoint > 0xFFFF ? 2 : 1;
      final next = index + length < end
          ? _codePointAt(text, index + length)
          : null;
      final isEmoji = segmentIsEmoji == true && _joinsEmoji(codePoint)
          ? true
          : _isEmoji(codePoint) || next == 0xFE0F || next == 0x20E3;
      if (segmentIsEmoji != null && isEmoji != segmentIsEmoji) {
        segments.add((
          start: segmentStart,
          end: index,
          isEmoji: segmentIsEmoji,
        ));
        segmentStart = index;
      }
      segmentIsEmoji = isEmoji;
      index += length;
    }
    if (segmentIsEmoji != null) {
      segments.add((start: segmentStart, end: end, isEmoji: segmentIsEmoji));
    }
    return segments;
  }

  static int _codePointAt(String text, int index) {
    final unit = text.codeUnitAt(index);
    if (unit >= 0xD800 && unit <= 0xDBFF && index + 1 < text.length) {
      final low = text.codeUnitAt(index + 1);
      if (low >= 0xDC00 && low <= 0xDFFF) {
        return 0x10000 + ((unit - 0xD800) << 10) + (low - 0xDC00);
      }
    }
    return unit;
  }

  /// Whether [codePoint] is a pictograph a color emoji font draws.
  static bool _isEmoji(int codePoint) {
    return (codePoint >= 0x1F000 && codePoint <= 0x1FAFF) ||
        (codePoint >= 0x2600 && codePoint <= 0x27BF) ||
        (codePoint >= 0x2300 && codePoint <= 0x23FF) ||
        (codePoint >= 0x2B00 && codePoint <= 0x2BFF);
  }

  /// Whether [codePoint] continues the emoji before it: a joiner, a
  /// variation selector, a keycap or a tag.
  static bool _joinsEmoji(int codePoint) {
    return codePoint == 0x200D ||
        codePoint == 0xFE0F ||
        codePoint == 0x20E3 ||
        (codePoint >= 0xE0020 && codePoint <= 0xE007F);
  }

  static bool _isSpace(int codeUnit) {
    return codeUnit == 0x20 ||
        codeUnit == 0x09 ||
        codeUnit == 0x1680 ||
        (codeUnit >= 0x2000 && codeUnit <= 0x200A) ||
        codeUnit == 0x205F ||
        codeUnit == 0x3000;
  }
}

/// A run of one line, laid out alone in the smaller font.
class _ScaledRun {
  _ScaledRun({
    required this.painter,
    required this.target,
    required this.anchor,
    required this.scale,
  });

  /// Lays the part of [text] from [start] to [end], which lies on [line] of
  /// [source], out in a font [scale] times smaller, held where [source]
  /// draws it.
  ///
  /// Gives no [run] for a part that draws nothing, and [failed] when the
  /// copy does not stay on one line.
  static ({_ScaledRun? run, bool failed}) create({
    required TextPainter source,
    required InlineSpan text,
    required int start,
    required int end,
    required LineMetrics line,
    required double scale,
    required TextGradient? gradient,
    required Rect? gradientBounds,
  }) {
    final slice = _slice(text, start, end);
    if (slice == null) return (run: null, failed: false);
    final realBoxes = source.getBoxesForSelection(
      TextSelection(baseOffset: start, extentOffset: end),
    );
    if (realBoxes.isEmpty) return (run: null, failed: false);

    TextPainter layout(Shader? shader) {
      return TextPainter(
        text: _shrink(slice, scale, shader: shader, isRoot: true),
        textDirection: source.textDirection,
        textScaler: source.textScaler,
        locale: source.locale,
        textHeightBehavior: source.textHeightBehavior,
        textWidthBasis: TextWidthBasis.longestLine,
      )..layout();
    }

    var painter = layout(null);
    final lines = painter.computeLineMetrics();
    final boxes = painter.getBoxesForSelection(
      TextSelection(baseOffset: 0, extentOffset: end - start),
    );
    if (lines.length != 1 || boxes.isEmpty) {
      painter.dispose();
      return (run: null, failed: true);
    }

    // Held at the left edge of the run, which the original and the copy
    // place alike however the line is aligned, on the baseline as it is
    // drawn: a paragraph rounds it to whole units of its own, which for the
    // copy are [scale] times larger than for the original.
    final target = Offset(
      realBoxes.map((box) => box.left).reduce(min),
      _drawnBaseline(line),
    );
    final anchor = Offset(
      boxes.map((box) => box.left).reduce(min),
      _drawnBaseline(lines.single),
    );

    if (gradient != null && gradientBounds != null) {
      // Laid out once more with the gradient spread across the bounds as
      // they lie in this run's own coordinates. The layout is the same.
      Offset toRun(Offset point) => anchor + (point - target) / scale;
      final shader = gradient.createShader(
        Rect.fromPoints(
          toRun(gradientBounds.topLeft),
          toRun(gradientBounds.bottomRight),
        ),
      );
      painter.dispose();
      painter = layout(shader);
    }

    return (
      run: _ScaledRun(
        painter: painter,
        target: target,
        anchor: anchor,
        scale: scale,
      ),
      failed: false,
    );
  }

  /// The run laid out in the smaller font.
  final TextPainter painter;

  /// Where [anchor] lands in the coordinates of the original painter.
  final Offset target;

  /// The point of [painter] placed at [target]: the left edge of the run on
  /// its baseline.
  final Offset anchor;

  /// How much larger than [painter] lays it out the run is drawn.
  final double scale;

  void paint(Canvas canvas, Offset offset) {
    // Painted at the origin of its own coordinates, where its gradient was
    // spread: a shader does not move with the offset a paragraph is painted
    // at.
    canvas
      ..save()
      ..translate(offset.dx + target.dx, offset.dy + target.dy)
      ..scale(scale)
      ..translate(-anchor.dx, -anchor.dy);
    painter.paint(canvas, Offset.zero);
    canvas.restore();
  }

  /// Where a paragraph draws the glyphs of [line].
  ///
  /// SkParagraph reports the baseline below the line's top by its height,
  /// rounded to a whole unit, less its descent, but draws the glyphs below
  /// the top by the ascent, rounded on its own.
  static double _drawnBaseline(LineMetrics line) {
    final top = line.baseline - line.height + line.descent;
    return top + (line.ascent + 0.5).floorToDouble();
  }

  /// The part of [span] between the UTF-16 offsets [start] and [end], with
  /// the styles of every span on the way to it.
  static InlineSpan? _slice(InlineSpan span, int start, int end) {
    var position = 0;

    InlineSpan? walk(TextSpan span) {
      final text = span.text;
      String? kept;
      if (text != null) {
        final from = max(start - position, 0);
        final to = min(end - position, text.length);
        if (from < to) kept = text.substring(from, to);
        position += text.length;
      }
      final children = <InlineSpan>[];
      for (final child in span.children ?? const <InlineSpan>[]) {
        if (position >= end) break;
        final kept = walk(child as TextSpan);
        if (kept != null) children.add(kept);
      }
      if (kept == null && children.isEmpty) return null;
      return TextSpan(
        text: kept,
        style: span.style,
        children: children.isEmpty ? null : children,
        locale: span.locale,
        spellOut: span.spellOut,
      );
    }

    return walk(span as TextSpan);
  }

  /// A copy of [span] whose lengths are [scale] times smaller.
  ///
  /// A paint with a shader takes [shader] instead, where one is given.
  static InlineSpan _shrink(
    InlineSpan span,
    double scale, {
    required Shader? shader,
    bool isRoot = false,
  }) {
    final textSpan = span as TextSpan;
    final style = textSpan.style;
    return TextSpan(
      text: textSpan.text,
      style: style != null
          ? _shrinkStyle(style, scale, shader: shader, isRoot: isRoot)
          : isRoot
          ? TextStyle(fontSize: ScaledTextLines._defaultFontSize / scale)
          : null,
      children: textSpan.children
          ?.map((child) => _shrink(child, scale, shader: shader))
          .toList(),
      locale: textSpan.locale,
      spellOut: textSpan.spellOut,
    );
  }

  static TextStyle _shrinkStyle(
    TextStyle style,
    double scale, {
    required Shader? shader,
    required bool isRoot,
  }) {
    final fontSize = style.fontSize;
    final letterSpacing = style.letterSpacing;
    final wordSpacing = style.wordSpacing;
    final foreground = style.foreground;
    final background = style.background;
    return style.copyWith(
      // A style that does not inherit, like the root, falls back to the
      // default size, which has to shrink as well.
      fontSize: fontSize != null
          ? fontSize / scale
          : isRoot || !style.inherit
          ? ScaledTextLines._defaultFontSize / scale
          : null,
      letterSpacing: letterSpacing == null ? null : letterSpacing / scale,
      wordSpacing: wordSpacing == null ? null : wordSpacing / scale,
      shadows: style.shadows?.map((shadow) => shadow.scale(1 / scale)).toList(),
      foreground: foreground == null
          ? null
          : _shrinkPaint(foreground, scale, shader: shader),
      background: background == null
          ? null
          : _shrinkPaint(background, scale, shader: shader),
    );
  }

  /// A copy of [paint] with a stroke [scale] times thinner, and [shader] in
  /// place of its own shader when it has one.
  static Paint _shrinkPaint(
    Paint paint,
    double scale, {
    required Shader? shader,
  }) {
    return Paint()
      ..color = paint.color
      ..blendMode = paint.blendMode
      ..style = paint.style
      ..strokeWidth = paint.strokeWidth / scale
      ..strokeCap = paint.strokeCap
      ..strokeJoin = paint.strokeJoin
      ..strokeMiterLimit = paint.strokeMiterLimit
      ..isAntiAlias = paint.isAntiAlias
      ..colorFilter = paint.colorFilter
      ..shader = paint.shader == null ? null : (shader ?? paint.shader);
  }
}
