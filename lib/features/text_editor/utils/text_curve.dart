import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/widgets.dart';

import '/core/models/layers/text_gradient.dart';
import 'scaled_text_lines.dart';

/// Bends text that a [TextPainter] laid out straight into an arc, see
/// `TextLayer.curvature`.
///
/// It maps the straight layout onto concentric circles around one center:
/// a point's distance along the line becomes an angle around the center,
/// keeping its length at the height [referenceY], which lies [radius] from
/// the center, and its height becomes a distance from the center. The column
/// at [centerX] stays where it is, so the curve grows out of the straight
/// text as it bends.
///
/// Glyphs are not warped: each [TextCurvePiece] is placed whole, turned to
/// stand upright where its baseline meets the arc (see [place]). Backgrounds,
/// which have no glyphs to keep, are warped point by point (see [warp]).
@immutable
class TextCurve {
  const TextCurve._({
    required this.curvature,
    required this.centerX,
    required this.referenceY,
    required this.radius,
  });

  /// The angle, in radians, the widest line sweeps around its circle at a
  /// curvature of `1` or `-1`: 300°, most of the way around with a gap left
  /// between the ends of the line.
  static const double maxSweep = 5 * pi / 3;

  /// The curve that bends text whose widest line is [width] wide, centered
  /// on [centerX], by [curvature], or `null` when it stays straight.
  ///
  /// The letters keep the spacing they have straight at [referenceY]: the
  /// side of the line nearest the center that its letters stand on, so
  /// that every letter spreads from there rather than crowding its
  /// neighbours. [minRadius] is how far from the center [referenceY] has to
  /// stay so nothing drawn on its far side, toward the center, reaches the
  /// center; shorter text bends less to keep it.
  static TextCurve? create({
    required double curvature,
    required double width,
    required double centerX,
    required double referenceY,
    double minRadius = 0,
  }) {
    final bend = curvature.isNaN ? 0.0 : curvature.clamp(-1.0, 1.0);
    if (bend == 0 || !(width > 0)) return null;
    final radius = max(width / (bend.abs() * maxSweep), minRadius);
    if (!radius.isFinite || radius <= 0) return null;
    return TextCurve._(
      curvature: bend,
      centerX: centerX,
      referenceY: referenceY,
      radius: radius,
    );
  }

  /// The curvature this curve bends by, from `-1` to `1`.
  final double curvature;

  /// The x position of the straight layout that stays where it is: the
  /// middle of the lines.
  final double centerX;

  /// The height of the straight layout at which the letters keep their
  /// spacing on the curve.
  final double referenceY;

  /// How far [referenceY] lies from the center of the circle.
  final double radius;

  /// `1` for an arch, whose center lies below the text, `-1` for a bowl,
  /// whose center lies above it.
  double get _side => curvature > 0 ? 1 : -1;

  /// The angle around the center a point at [x] lies at, from the column at
  /// [centerX].
  double _sweepAt(double x) => (x - centerX) / radius;

  /// How far a point at [y] lies from the center of the circle.
  double _radiusAt(double y) => radius + _side * (referenceY - y);

  /// Where [point] of the straight layout lies on the curve.
  Offset map(Offset point) {
    final sweep = _sweepAt(point.dx);
    final distance = _radiusAt(point.dy);
    final half = sin(sweep / 2);
    // `1 - cos` written as `2 sin²` stays exact for the huge radius of an
    // almost straight curve.
    return Offset(
      centerX + distance * sin(sweep),
      point.dy + _side * distance * 2 * half * half,
    );
  }

  /// How far a glyph standing at [x] of the straight layout is turned,
  /// clockwise, in radians.
  double angleAt(double x) => _side * _sweepAt(x);

  /// Where [point] of the straight layout lies once the piece of text it
  /// belongs to, which turns around [pivot], is placed on the curve.
  Offset place(Offset pivot, Offset point) {
    final angle = angleAt(pivot.dx);
    final c = cos(angle);
    final s = sin(angle);
    final d = point - pivot;
    return map(pivot) + Offset(d.dx * c - d.dy * s, d.dx * s + d.dy * c);
  }

  /// The point of the straight layout that [place] puts at [point] for a
  /// piece turning around [pivot].
  Offset unplace(Offset pivot, Offset point) {
    final angle = angleAt(pivot.dx);
    final c = cos(angle);
    final s = sin(angle);
    final d = point - map(pivot);
    return pivot + Offset(d.dx * c + d.dy * s, -d.dx * s + d.dy * c);
  }

  /// The box around [rect] of the straight layout once a piece turning
  /// around [pivot] is placed on the curve.
  Rect placeRect(Offset pivot, Rect rect) {
    final corners = [
      place(pivot, rect.topLeft),
      place(pivot, rect.topRight),
      place(pivot, rect.bottomLeft),
      place(pivot, rect.bottomRight),
    ];
    var bounds = Rect.fromPoints(corners[0], corners[3]);
    for (final corner in corners) {
      bounds = bounds.expandToInclude(Rect.fromPoints(corner, corner));
    }
    return bounds;
  }

  /// Moves [canvas] so a piece of the straight layout turning around [pivot]
  /// paints where [place] puts it.
  void transformCanvas(Canvas canvas, Offset pivot) {
    final target = map(pivot);
    canvas
      ..translate(target.dx, target.dy)
      ..rotate(angleAt(pivot.dx))
      ..translate(-pivot.dx, -pivot.dy);
  }

  /// [path] of the straight layout bent along the curve.
  ///
  /// Its outline is followed in steps short enough that the bent outline
  /// does not show its corners.
  Path warp(Path path) {
    final step = (radius * 0.05).clamp(0.5, 4.0);
    final result = Path();
    for (final contour in path.computeMetrics()) {
      final count = max(2, (contour.length / step).ceil());
      final points = <Offset>[];
      for (var i = 0; i <= count; i++) {
        final tangent = contour.getTangentForOffset(contour.length * i / count);
        if (tangent != null) points.add(map(tangent.position));
      }
      if (points.length > 1) result.addPolygon(points, contour.isClosed);
    }
    return result;
  }

  @override
  bool operator ==(Object other) {
    return other is TextCurve &&
        other.curvature == curvature &&
        other.centerX == centerX &&
        other.referenceY == referenceY &&
        other.radius == radius;
  }

  @override
  int get hashCode => Object.hash(curvature, centerX, referenceY, radius);
}

/// A part of a line a [TextCurve] places whole: a letter (grapheme
/// cluster), or a word of a script whose letters join.
@immutable
class TextCurvePiece {
  const TextCurvePiece._({
    required this.start,
    required this.end,
    required this.line,
    required this.boxes,
    required this.rect,
    required this.isEmoji,
  });

  /// Where the piece starts in the plain text, in UTF-16 code units.
  final int start;

  /// Where the piece ends in the plain text, in UTF-16 code units.
  final int end;

  /// The line the piece lies on.
  final ui.LineMetrics line;

  /// Where the straight layout draws the piece.
  final List<TextBox> boxes;

  /// The room the piece takes in the straight layout: as wide as its glyphs
  /// advance and as high as its line.
  final Rect rect;

  /// Whether the piece is an emoji.
  final bool isEmoji;

  /// The point the piece turns around: the middle of its glyphs on the
  /// baseline.
  Offset get pivot => Offset(rect.center.dx, line.baseline);

  /// Splits the lines [painter] laid out into pieces.
  ///
  /// Spaces draw nothing and are left out, unless [keepSpaces] keeps them
  /// for a decoration they draw, such as an underline.
  static List<TextCurvePiece> split(
    TextPainter painter, {
    required bool keepSpaces,
  }) {
    final plainText = painter.plainText;
    final pieces = <TextCurvePiece>[];
    var start = 0;
    for (final metrics in painter.computeLineMetrics()) {
      // A line ended by a line break does not include it, a soft wrapped
      // one includes the whitespace it wraps after.
      final boundary = painter.getLineBoundary(TextPosition(offset: start));
      final lineStart = boundary.start;
      var end = boundary.end;
      start = end < plainText.length && plainText.codeUnitAt(end) == 0x0A
          ? end + 1
          : end;
      // Trailing whitespace draws nothing, not even an underline.
      while (end > lineStart && _isSpace(plainText.codeUnitAt(end - 1))) {
        end--;
      }
      if (end <= lineStart) continue;

      final ranges = <({int start, int end, bool joins})>[];
      var offset = lineStart;
      for (final cluster in plainText.substring(lineStart, end).characters) {
        final clusterEnd = offset + cluster.length;
        final isSpace = cluster.trim().isEmpty;
        final joins = !isSpace && _joinsNeighbours(cluster.runes.first);
        if (isSpace && !keepSpaces) {
          // Nothing to draw.
        } else if (joins &&
            ranges.isNotEmpty &&
            ranges.last.joins &&
            ranges.last.end == offset) {
          // Kept with the letters it joins, so they are shaped together.
          ranges.last = (
            start: ranges.last.start,
            end: clusterEnd,
            joins: true,
          );
        } else {
          ranges.add((start: offset, end: clusterEnd, joins: joins));
        }
        offset = clusterEnd;
      }

      for (final range in ranges) {
        final boxes = painter.getBoxesForSelection(
          TextSelection(baseOffset: range.start, extentOffset: range.end),
        );
        if (boxes.isEmpty) continue;
        var left = boxes.first.left;
        var right = boxes.first.right;
        for (final box in boxes) {
          left = min(left, box.left);
          right = max(right, box.right);
        }
        final segments = ScaledTextLines.segments(
          plainText,
          range.start,
          range.end,
        );
        pieces.add(
          TextCurvePiece._(
            start: range.start,
            end: range.end,
            line: metrics,
            boxes: boxes,
            rect: Rect.fromLTRB(
              left,
              metrics.baseline - metrics.ascent,
              right,
              metrics.baseline + metrics.descent,
            ),
            isEmoji: segments.every((segment) => segment.isEmoji),
          ),
        );
      }
    }
    return pieces;
  }

  /// Whether the letter starting with [codePoint] belongs to a script whose
  /// letters join or stack across grapheme clusters, so its words are only
  /// shaped right when drawn whole.
  static bool _joinsNeighbours(int codePoint) {
    return (codePoint >= 0x0600 && codePoint <= 0x08FF) || // Arabic, Syriac…
        (codePoint >= 0x0900 && codePoint <= 0x0DFF) || // Indic scripts
        (codePoint >= 0x0F00 && codePoint <= 0x0FFF) || // Tibetan
        (codePoint >= 0x1000 && codePoint <= 0x109F) || // Myanmar
        (codePoint >= 0x1780 && codePoint <= 0x18AF) || // Khmer, Mongolian
        (codePoint >= 0xA840 && codePoint <= 0xA87F) || // Phags-pa
        (codePoint >= 0xFB50 && codePoint <= 0xFDFF) || // Arabic forms
        (codePoint >= 0xFE70 && codePoint <= 0xFEFF) ||
        (codePoint >= 0x10D00 && codePoint <= 0x10D3F) || // Hanifi Rohingya
        (codePoint >= 0x1E900 && codePoint <= 0x1E95F); // Adlam
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

/// The glyphs of one laid out [TextPainter], each [TextCurvePiece] copied
/// on its own and placed on a [TextCurve].
///
/// The copies keep the styles of the text they were cut from: a highlight's
/// color, a hidden part's clear paint, a paint's stroke. Large text is copied
/// in a smaller font and drawn scaled up, as [ScaledTextLines] draws it.
class CurvedTextRuns {
  CurvedTextRuns._(this.curve, this._runs);

  /// Copies the [pieces] of [source], which must be laid out, to place them
  /// on [curve].
  ///
  /// Each piece is copied in a font [scale] times smaller, an emoji
  /// [emojiScale] times. [gradient] replaces the shaders of the copies'
  /// paints, spread across [gradientBounds], which lie in the coordinates of
  /// the curve, so the gradient runs across the bent text as it shows.
  static CurvedTextRuns create(
    TextPainter source, {
    required TextCurve curve,
    required List<TextCurvePiece> pieces,
    double scale = 1,
    double emojiScale = 1,
    TextGradient? gradient,
    Rect? gradientBounds,
  }) {
    final text = source.text;
    final runs = <({TextCurvePiece piece, ScaledTextRun run})>[];
    if (text != null) {
      for (final piece in pieces) {
        final pivot = piece.pivot;
        final created = ScaledTextRun.create(
          source: source,
          text: text,
          start: piece.start,
          end: piece.end,
          line: piece.line,
          scale: piece.isEmoji ? emojiScale : scale,
          gradient: gradient,
          gradientBounds: gradientBounds,
          fromGradientSpace: (point) => curve.unplace(pivot, point),
          boxes: piece.boxes,
        );
        // A single letter or word always stays on one line; one that did
        // not would draw nothing rather than draw wrong.
        if (created.run case final run?) runs.add((piece: piece, run: run));
      }
    }
    return CurvedTextRuns._(curve, runs);
  }

  /// The curve the pieces are placed on.
  final TextCurve curve;

  final List<({TextCurvePiece piece, ScaledTextRun run})> _runs;

  /// Draws the pieces on [curve], moved by [offset] as they show on it.
  void paint(Canvas canvas, [Offset offset = Offset.zero]) {
    for (final (:piece, :run) in _runs) {
      canvas
        ..save()
        ..translate(offset.dx, offset.dy);
      curve.transformCanvas(canvas, piece.pivot);
      run.paint(canvas, Offset.zero);
      canvas.restore();
    }
  }

  /// Releases the resources of the copies.
  void dispose() {
    for (final (piece: _, :run) in _runs) {
      run.painter.dispose();
    }
  }
}
