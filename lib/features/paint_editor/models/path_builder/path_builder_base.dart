import 'package:flutter/widgets.dart';

import '/core/models/editor_configs/paint_editor/paint_editor_configs.dart';
import '../../enums/paint_editor_enum.dart';
import '../painted_model.dart';
import 'path_builder_arrow.dart';
import 'path_builder_circle.dart';
import 'path_builder_dash_dot_line.dart';
import 'path_builder_dash_line.dart';
import 'path_builder_freestyle.dart';
import 'path_builder_hexagon.dart';
import 'path_builder_line.dart';
import 'path_builder_polygon.dart';
import 'path_builder_rectangular.dart';

/// Base class for building drawable paths for various paint modes.
abstract class PathBuilderBase {
  /// Creates a path builder with the given item and scale factor.
  PathBuilderBase({
    required this.paintEditorConfigs,
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
    required PaintEditorConfigs paintEditorConfigs,
  }) {
    switch (item.mode) {
      case PaintMode.line:
        return PathBuilderLine(
          paintEditorConfigs: paintEditorConfigs,
          item: item,
          scale: scale,
        );
      case PaintMode.arrow:
        return PathBuilderArrow(
          paintEditorConfigs: paintEditorConfigs,
          item: item,
          scale: scale,
        );
      case PaintMode.dashLine:
        return PathBuilderDashLine(
          paintEditorConfigs: paintEditorConfigs,
          item: item,
          scale: scale,
        );
      case PaintMode.dashDotLine:
        return PathBuilderDashDotLine(
          paintEditorConfigs: paintEditorConfigs,
          item: item,
          scale: scale,
        );
      case PaintMode.rect:
        return PathBuilderRectangular(
          paintEditorConfigs: paintEditorConfigs,
          item: item,
          scale: scale,
        );
      case PaintMode.circle:
        return PathBuilderCircle(
          paintEditorConfigs: paintEditorConfigs,
          item: item,
          scale: scale,
        );

      case PaintMode.hexagon:
        return PathBuilderHexagon(
          paintEditorConfigs: paintEditorConfigs,
          item: item,
          scale: scale,
        );

      case PaintMode.polygon:
        return PathBuilderPolygon(
          paintEditorConfigs: paintEditorConfigs,
          item: item,
          scale: scale,
        );
      case PaintMode.freeStyle:
      case PaintMode.freeStyleArrowStart:
      case PaintMode.freeStyleArrowEnd:
      case PaintMode.freeStyleArrowStartEnd:
        return PathBuilderFreestyle(
          paintEditorConfigs: paintEditorConfigs,
          item: item,
          scale: scale,
        );
      case PaintMode.moveAndZoom:
      case PaintMode.eraser:
      case PaintMode.blur:
      case PaintMode.pixelate:
        throw ArgumentError('${item.mode} is not a valid PaintMode');
    }
  }

  /// The painted item model.
  final PaintedModel item;

  /// Configuration options for a paint editor.
  final PaintEditorConfigs paintEditorConfigs;

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

  /// Builds and returns the path.
  Path? buildSecond() => null;

  /// Draws the built path to the given canvas using the current painter.
  void draw({required Canvas canvas, required Size size}) {
    if (offsets.length <= 1) return;
    // Build both paths
    build();
    final Path? secondPath = buildSecond();

    if (item.erasedOffsets.isEmpty) {
      // First draw stroke path
      canvas.drawPath(path, painter);

      // Then draw second path (fill) if present
      if (secondPath != null) {
        final fillPaint = Paint()
          ..color = painter.color
          ..style = PaintingStyle.fill;
        canvas.drawPath(secondPath, fillPaint);
      }
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

    // Fill path (second)
    if (secondPath != null) {
      final fillPaint = Paint()
        ..color = painter.color
        ..style = PaintingStyle.fill;
      canvas.drawPath(secondPath, fillPaint);
    }

    // Build erase path
    final erasePaint = Paint()
      ..blendMode = BlendMode.clear
      ..isAntiAlias = true;

    final erasePath = Path();
    for (final item in item.erasedOffsets) {
      erasePath.addOval(
        Rect.fromCircle(
          center: item.offset * scale,
          // eraser size
          radius: item.radius * scale,
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
