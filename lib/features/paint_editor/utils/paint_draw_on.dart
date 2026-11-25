import 'dart:math' as math;
import 'dart:ui';

import '/core/models/editor_configs/paint_editor/paint_editor_configs.dart';
import '../enums/paint_editor_enum.dart';

/// How far apart the points lie that trace the outline of a shape while it
/// is being drawn, in the stroke's own unscaled coordinates.
const double _outlineStep = 2;

/// [items], the strokes of a drawing in the order they were drawn, as far as
/// a pen moving at an even pace along all of them together has come at
/// [fraction] of their total length.
///
/// Returns one entry per item, in the same order: the item itself once it is
/// drawn whole, a copy cut off where the pen is while it is being drawn, and
/// `null` before the pen reaches it. Nothing is drawn at a [fraction] of `0`
/// and everything from `1` on.
///
/// A freehand stroke is cut along its points, so a custom path builder draws
/// the part as it draws the whole stroke, and a line or an arrow grows from
/// its start towards its end. A shape, such as a rectangle or a circle, is
/// outlined along its path with a freehand stroke of the same look and only
/// shows as itself, filled if it is, once its outline is complete. A stroke
/// with no length, such as a dot, shows as soon as the pen reaches it; in a
/// drawing of nothing but dots each one takes the same share. Erased parts
/// stay erased throughout, as every part keeps the erased spots of its
/// stroke.
///
/// [paintEditorConfigs] supplies the custom path builders a shape's outline
/// is measured with and the custom modes that draw freehand.
List<PaintedModel?> drawnPaintStrokes(
  List<PaintedModel> items,
  double fraction, {
  PaintEditorConfigs paintEditorConfigs = const PaintEditorConfigs(),
}) {
  if (fraction >= 1) return List<PaintedModel?>.of(items);
  if (items.isEmpty || fraction <= 0) {
    return List<PaintedModel?>.filled(items.length, null);
  }

  final lengths = [
    for (final item in items)
      paintStrokeLength(item, paintEditorConfigs: paintEditorConfigs),
  ];
  final total = lengths.fold<double>(0, (sum, length) => sum + length);
  if (total <= 0) {
    // The tolerance keeps a dot whose share is exactly used up from rounding
    // into the next one.
    final shown = (fraction * items.length - 1e-9).ceil();
    return [
      for (final (index, item) in items.indexed) index < shown ? item : null,
    ];
  }

  var remaining = fraction * total;
  final drawn = <PaintedModel?>[];
  for (final (index, item) in items.indexed) {
    final length = lengths[index];
    if (remaining <= 0) {
      drawn.add(null);
    } else if (remaining >= length) {
      drawn.add(item);
      remaining -= length;
    } else {
      // The pen stops in this stroke; nothing after it is drawn.
      drawn.add(
        _cutStroke(
          item,
          length: remaining,
          strokeLength: length,
          paintEditorConfigs: paintEditorConfigs,
        ),
      );
      remaining = 0;
    }
  }
  return drawn;
}

/// The length of the line a pen draws [item] along, in the stroke's own
/// unscaled coordinates: the sum of its segments for a freehand stroke, the
/// distance between its ends for a line or an arrow, and the length of the
/// outline for a shape. A stroke that draws nothing has no length.
///
/// The result is kept until the stroke's points are replaced.
double paintStrokeLength(
  PaintedModel item, {
  PaintEditorConfigs paintEditorConfigs = const PaintEditorConfigs(),
}) {
  final cached = _strokeLengths[item];
  if (cached != null &&
      identical(cached.offsets, item.offsets) &&
      cached.mode == item.mode) {
    return cached.length;
  }
  final length = switch (_shapeOf(item, paintEditorConfigs)) {
    _StrokeShape.freehand => _polylineLength(item.offsets),
    _StrokeShape.line => _lineLength(item.offsets),
    _StrokeShape.outline => _outlineLength(item, paintEditorConfigs),
    _StrokeShape.none => 0.0,
  };
  _strokeLengths[item] = (
    offsets: item.offsets,
    mode: item.mode,
    length: length,
  );
  return length;
}

final _strokeLengths =
    Expando<({List<Offset?> offsets, PaintMode mode, double length})>(
      'paintStrokeLength',
    );

/// How a pen draws a stroke, which decides how it is measured and cut.
enum _StrokeShape {
  /// Along its points, one after the other.
  freehand,

  /// Straight from its first point to its second.
  line,

  /// Along the outline of the shape its points describe.
  outline,

  /// Not at all: the stroke has nothing to draw.
  none,
}

_StrokeShape _shapeOf(PaintedModel item, PaintEditorConfigs configs) {
  final mode = item.mode;
  if (configs.isFreeStyleMode(mode)) return _StrokeShape.freehand;
  switch (mode) {
    case PaintMode.line:
    case PaintMode.arrow:
    case PaintMode.dashLine:
    case PaintMode.dashDotLine:
      return _StrokeShape.line;
    case PaintMode.rect:
    case PaintMode.circle:
    case PaintMode.hexagon:
    case PaintMode.polygon:
      return _StrokeShape.outline;
    case PaintMode.custom1:
    case PaintMode.custom2:
    case PaintMode.custom3:
      return configs.customPathBuilders.containsKey(mode)
          ? _StrokeShape.outline
          : _StrokeShape.none;
    case PaintMode.moveAndZoom:
    case PaintMode.eraser:
    case PaintMode.blur:
    case PaintMode.pixelate:
    // Handled by isFreeStyleMode above.
    case PaintMode.freeStyle:
    case PaintMode.freeStyleArrowStart:
    case PaintMode.freeStyleArrowEnd:
    case PaintMode.freeStyleArrowStartEnd:
      return _StrokeShape.none;
  }
}

double _polylineLength(List<Offset?> offsets) {
  var length = 0.0;
  Offset? previous;
  for (final point in offsets) {
    if (point != null && previous != null) {
      length += (point - previous).distance;
    }
    previous = point;
  }
  return length;
}

double _lineLength(List<Offset?> offsets) {
  if (offsets.length < 2) return 0;
  final start = offsets[0];
  final end = offsets[1];
  if (start == null || end == null) return 0;
  return (end - start).distance;
}

double _outlineLength(PaintedModel item, PaintEditorConfigs configs) {
  if (item.offsets.length <= 1) return 0;
  var length = 0.0;
  for (final metric in _outlineOf(item, configs).computeMetrics()) {
    length += metric.length;
  }
  return length;
}

Path _outlineOf(PaintedModel item, PaintEditorConfigs configs) =>
    PathBuilderBase.fromMode(
      item: item,
      scale: 1,
      paintEditorConfigs: configs,
    ).build();

/// [item] drawn along the first [length] of its [strokeLength].
PaintedModel _cutStroke(
  PaintedModel item, {
  required double length,
  required double strokeLength,
  required PaintEditorConfigs paintEditorConfigs,
}) {
  switch (_shapeOf(item, paintEditorConfigs)) {
    case _StrokeShape.freehand:
      return _partOf(item, offsets: _cutPolyline(item.offsets, length));
    case _StrokeShape.line:
      final start = item.offsets[0]!;
      final end = item.offsets[1]!;
      return _partOf(
        item,
        offsets: [start, Offset.lerp(start, end, length / strokeLength)],
      );
    case _StrokeShape.outline:
      return _partOf(
        item,
        mode: PaintMode.freeStyle,
        offsets: _traceOutline(_outlineOf(item, paintEditorConfigs), length),
      );
    case _StrokeShape.none:
      return item;
  }
}

/// A stroke drawn like [item] along [offsets], keeping its erased spots.
PaintedModel _partOf(
  PaintedModel item, {
  required List<Offset?> offsets,
  PaintMode? mode,
}) {
  return PaintedModel(
    mode: mode ?? item.mode,
    offsets: offsets,
    erasedOffsets: item.erasedOffsets,
    color: item.color,
    strokeWidth: item.strokeWidth,
    opacity: item.opacity,
    // An outline is filled once it is complete, when the stroke itself shows.
    fill: mode == null && item.fill,
    censorStrength: item.censorStrength,
  );
}

/// The points of [offsets] up to [length] along them, ending exactly there.
///
/// A segment the pen has not reached yet is left out entirely, so its first
/// point does not show as a dot.
List<Offset?> _cutPolyline(List<Offset?> offsets, double length) {
  final cut = <Offset?>[];
  var travelled = 0.0;
  Offset? previous;
  for (final point in offsets) {
    if (point == null) {
      cut.add(null);
      previous = null;
      continue;
    }
    if (previous == null) {
      if (travelled >= length) break;
      cut.add(point);
      previous = point;
      continue;
    }
    final step = (point - previous).distance;
    if (travelled + step >= length) {
      cut.add(
        step <= 0
            ? point
            : Offset.lerp(previous, point, (length - travelled) / step),
      );
      break;
    }
    cut.add(point);
    travelled += step;
    previous = point;
  }
  return cut;
}

/// Points along the first [length] of [outline], every [_outlineStep] and at
/// the exact end, with a `null` between its separate contours.
List<Offset?> _traceOutline(Path outline, double length) {
  final points = <Offset?>[];
  var remaining = length;
  for (final metric in outline.computeMetrics()) {
    if (remaining <= 0) break;
    final end = math.min(metric.length, remaining);
    if (points.isNotEmpty) points.add(null);
    for (var distance = 0.0; distance < end; distance += _outlineStep) {
      final tangent = metric.getTangentForOffset(distance);
      if (tangent != null) points.add(tangent.position);
    }
    final last = metric.getTangentForOffset(end);
    if (last != null) points.add(last.position);
    remaining -= metric.length;
  }
  return points;
}
