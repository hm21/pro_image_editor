import 'package:flutter/widgets.dart';

import '../../../../core/models/editor_configs/paint_editor/paint_editor_configs.dart';
import '../../enums/paint_editor_enum.dart';
import '../painted_model.dart';
import 'path_builder_arrow.dart';
import 'path_builder_circle.dart';
import 'path_builder_dash_line.dart';
import 'path_builder_freestyle.dart';
import 'path_builder_line.dart';
import 'path_builder_polygon.dart';
import 'path_builder_rectangular.dart';

/// Base class for building drawable paths for various paint modes.
abstract class PathBuilderBase {
  /// Creates a path builder with the given item and scale factor.
  PathBuilderBase({
    required this.item,
    required this.scale,
  }) : painter = Paint()
          ..color = item.paint.color
          ..style = item.paint.style
          ..strokeWidth = item.paint.strokeWidth * scale;

  /// Factory that returns the appropriate PathBuilder for a given PaintMode
  factory PathBuilderBase.fromMode({
    required PaintedModel item,
    required double scale,
  }) {
    switch (item.mode) {
      case PaintMode.line:
        return PathBuilderLine(item: item, scale: scale);
      case PaintMode.arrow:
        return PathBuilderArrow(item: item, scale: scale);
      case PaintMode.dashLine:
        return PathBuilderDashLine(item: item, scale: scale);
      case PaintMode.rect:
        return PathBuilderRectangular(item: item, scale: scale);
      case PaintMode.circle:
        return PathBuilderCircle(item: item, scale: scale);
      case PaintMode.polygon:
        return PathBuilderPolygon(item: item, scale: scale);
      case PaintMode.freeStyle:
        return PathBuilderFreestyle(item: item, scale: scale);
      default:
        throw ArgumentError('${item.mode} is not a valid PaintMode');
    }
  }

  /// The painted item model.
  final PaintedModel item;

  /// The scale factor applied to all positions and stroke width.
  final double scale;

  /// The painter used to draw the path.
  final Paint painter;

  /// The list of scaled offset points.
  List<Offset?> get offsets => item.offsets;

  /// The scaled start point of the path.
  Offset get start => (offsets[0] ?? Offset.zero) * scale;

  /// The scaled end point of the path.
  Offset get end => (offsets[1] ?? Offset.zero) * scale;

  /// The path being constructed.
  final path = Path();

  /// Builds and returns the path.
  Path build();

  /// Draws the built path to the given canvas using the current painter.
  void draw({
    required Canvas canvas,
    required Size size,
    required PaintEditorConfigs configs,
  }) {
    if (offsets.length <= 1) return;
    build();

    final eraserMode = configs.eraserMode;
    final eraserSize = configs.eraserSize;

    if (eraserMode == EraserMode.object || item.erasedOffsets.isEmpty) {
      canvas.drawPath(path, painter);
      return;
    }

    final strokeWidth = item.strokeWidth;
    final doubleStrokeWidth = item.strokeWidth * 2;
    canvas
      ..saveLayer(
        Rect.fromLTWH(
          -strokeWidth,
          -strokeWidth,
          size.width + doubleStrokeWidth,
          size.height + doubleStrokeWidth,
        ),
        Paint(),
      )
      ..drawPath(path, painter);

    // build erase path from offsets
    final erasePaint = Paint()
      ..blendMode = BlendMode.clear
      ..isAntiAlias = true;

    final erasePath = Path();
    for (final o in item.erasedOffsets) {
      erasePath.addOval(
        Rect.fromCircle(
          center: o * scale,
          // eraser size
          radius: eraserSize * scale,
        ),
      );
    }

    // apply erase
    canvas
      ..drawPath(erasePath, erasePaint)
      ..restore();
  }

  /// Performs hit testing.
  bool hitTest(Offset position) {
    build();
    return hitTestWithStroke(position);
  }

  /// Performs hit testing for paths including the stroke-width.
  @protected
  bool hitTestWithStroke(Offset position) {
    // smaller values = more precise, but slower
    const resolution = 1.0;
    final halfStroke = painter.strokeWidth / 2;

    for (final metric in path.computeMetrics()) {
      for (double d = 0.0; d < metric.length; d += resolution) {
        final tangent = metric.getTangentForOffset(d);
        if (tangent == null) continue;

        final point = tangent.position;
        if ((point - position).distance <= halfStroke) {
          return true;
        }
      }
    }
    return false;
  }

  /// Performs hit testing for filled shapes or falls back to stroke hit test.
  @protected
  bool hitTestFillableObject(Offset position) {
    build();

    if (item.fill) return path.contains(position);

    return hitTestWithStroke(position);
  }

  /// Performs hit testing for a single stroked line segment.
  @protected
  bool hitTestLine(Offset position) {
    final vector = end - start;
    final normalizedVector = vector / vector.distance;
    final perpendicularVector =
        Offset(-normalizedVector.dy, normalizedVector.dx);

    final strokeHalfWidth = painter.strokeWidth / 2;
    double x = perpendicularVector.dx * strokeHalfWidth;
    double y = perpendicularVector.dy * strokeHalfWidth;

    final path = Path()
      ..moveTo(
        start.dx + x,
        start.dy + y,
      )
      ..lineTo(
        end.dx + x,
        end.dy + y,
      )
      ..lineTo(
        end.dx - x,
        end.dy - y,
      )
      ..lineTo(
        start.dx - x,
        start.dy - y,
      )
      ..close();

    // Check if the position is inside the stroke path
    return path.contains(position);
  }
}
