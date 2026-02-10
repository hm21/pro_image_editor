import 'package:flutter/widgets.dart';

import '../../enums/paint_editor_enum.dart';
import 'path_builder_base.dart';

/// Builds a freestyle path using strokes and isolated dot points.
class PathBuilderFreestyle extends PathBuilderBase {
  /// Creates a freestyle path builder with the given item and scale.
  PathBuilderFreestyle({
    required super.item,
    required super.scale,
    required super.paintEditorConfigs,
  });

  @override
  Path build() {
    if (offsets.isEmpty) return path;

    final bool hasArrowStart = item.mode == PaintMode.freeStyleArrowStart ||
        item.mode == PaintMode.freeStyleArrowStartEnd;
    final bool hasArrowEnd = item.mode == PaintMode.freeStyleArrowEnd ||
        item.mode == PaintMode.freeStyleArrowStartEnd;

    final double dotRadius = painter.strokeWidth / 2;

    final scaled = List<Offset?>.generate(
      offsets.length,
      (i) => offsets[i] == null
          ? null
          : Offset(offsets[i]!.dx * scale, offsets[i]!.dy * scale),
      growable: false,
    );

    for (int i = 0; i < scaled.length - 1; i++) {
      final a = scaled[i];
      final b = scaled[i + 1];

      if (a != null && b != null) {
        path
          ..moveTo(a.dx, a.dy)
          ..lineTo(b.dx, b.dy);
      } else if (a != null && b == null) {
        // Add tiny circle at the dot point
        path.addOval(Rect.fromCircle(center: a, radius: dotRadius));
      }
    }

    // Add arrowheads if needed
    if (hasArrowStart || hasArrowEnd) {
      final pathOffset = 1.0 * scale;
      // Minimum distance for stable direction calculation
      final minDistance = 20.0 * scale;

      if (hasArrowStart) {
        final (startPoint, directionPoint) =
            _findPointsWithMinDistance(scaled, minDistance, fromStart: true);
        if (startPoint != null && directionPoint != null) {
          _addArrowHead(startPoint, directionPoint, pathOffset);
        }
      }

      if (hasArrowEnd) {
        final (endPoint, directionPoint) =
            _findPointsWithMinDistance(scaled, minDistance, fromStart: false);
        if (endPoint != null && directionPoint != null) {
          _addArrowHead(endPoint, directionPoint, pathOffset);
        }
      }
    }

    painter.strokeCap = StrokeCap.round;

    return path;
  }

  /// Finds two points with a minimum distance for stable direction calculation.
  ///
  /// If [fromStart] is true, searches from the beginning of the list.
  /// Returns a tuple of (anchor point, direction point).
  (Offset?, Offset?) _findPointsWithMinDistance(
    List<Offset?> points,
    double minDistance, {
    required bool fromStart,
  }) {
    Offset? anchorPoint;
    Offset? directionPoint;

    if (fromStart) {
      // Find first non-null point as anchor
      for (int i = 0; i < points.length; i++) {
        if (points[i] != null) {
          anchorPoint = points[i];
          // Find a point with sufficient distance
          for (int j = i + 1; j < points.length; j++) {
            if (points[j] != null) {
              final distance = (points[j]! - anchorPoint!).distance;
              if (distance >= minDistance) {
                directionPoint = points[j];
                break;
              }
              // Keep updating to at least have the furthest point found
              directionPoint = points[j];
            }
          }
          break;
        }
      }
    } else {
      // Find last non-null point as anchor
      for (int i = points.length - 1; i >= 0; i--) {
        if (points[i] != null) {
          anchorPoint = points[i];
          // Find a point with sufficient distance
          for (int j = i - 1; j >= 0; j--) {
            if (points[j] != null) {
              final distance = (points[j]! - anchorPoint!).distance;
              if (distance >= minDistance) {
                directionPoint = points[j];
                break;
              }
              // Keep updating to at least have the furthest point found
              directionPoint = points[j];
            }
          }
          break;
        }
      }
    }

    return (anchorPoint, directionPoint);
  }

  /// Adds an arrowhead at [anchorPoint] pointing away from [directionPoint].
  void _addArrowHead(
      Offset anchorPoint, Offset directionPoint, double pathOffset) {
    // Open arrowhead (two lines instead of closed triangle)
    final arrowHead = Path()
      ..moveTo(-20 * pathOffset, 20 * pathOffset)
      ..lineTo(0, 0)
      ..lineTo(-20 * pathOffset, -20 * pathOffset);

    // Direction points from directionPoint to anchorPoint
    final direction = (anchorPoint - directionPoint).direction;
    final transform = Matrix4.identity()
      ..translateByDouble(anchorPoint.dx, anchorPoint.dy, 0.0, 1.0)
      ..rotateZ(direction);

    path.addPath(arrowHead.transform(transform.storage), Offset.zero);
  }
}
