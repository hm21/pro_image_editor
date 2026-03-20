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

    final bool hasArrowStart =
        item.mode == PaintMode.freeStyleArrowStart ||
        item.mode == PaintMode.freeStyleArrowStartEnd;
    final bool hasArrowEnd =
        item.mode == PaintMode.freeStyleArrowEnd ||
        item.mode == PaintMode.freeStyleArrowStartEnd;

    final double dotRadius = painter.strokeWidth / 2;
    final int len = offsets.length;

    // Build path with minimal moveTo calls by tracking continuous segments.
    // Only emit moveTo at the start of each segment, then lineTo for the rest.
    bool needsMoveTo = true;

    for (int i = 0; i < len; i++) {
      final raw = offsets[i];
      if (raw == null) {
        needsMoveTo = true;
        continue;
      }

      final double sx = raw.dx * scale;
      final double sy = raw.dy * scale;

      if (needsMoveTo) {
        // Isolated dot: point at end of list or followed by null
        if (i + 1 >= len || offsets[i + 1] == null) {
          path.addOval(
            Rect.fromCircle(center: Offset(sx, sy), radius: dotRadius),
          );
        } else {
          path.moveTo(sx, sy);
          needsMoveTo = false;
        }
      } else {
        path.lineTo(sx, sy);
      }
    }

    // Add arrowheads if needed
    if (hasArrowStart || hasArrowEnd) {
      final strokeFactor = painter.strokeWidth / 2;
      // Use squared distance to avoid sqrt in comparisons
      final minDistanceSq = 400.0 * scale * scale;

      if (hasArrowStart) {
        final (startPoint, directionPoint) = _findPointsWithMinDistance(
          minDistanceSq,
          fromStart: true,
        );
        if (startPoint != null && directionPoint != null) {
          _addArrowHead(startPoint, directionPoint, strokeFactor);
        }
      }

      if (hasArrowEnd) {
        final (endPoint, directionPoint) = _findPointsWithMinDistance(
          minDistanceSq,
          fromStart: false,
        );
        if (endPoint != null && directionPoint != null) {
          _addArrowHead(endPoint, directionPoint, strokeFactor);
        }
      }
    }

    painter.strokeCap = StrokeCap.round;
    painter.strokeJoin = StrokeJoin.round;

    return path;
  }

  /// Finds two points with a minimum distance for stable direction calculation.
  ///
  /// Uses squared distance to avoid sqrt. Scales offsets inline to avoid
  /// allocating a separate scaled list.
  /// If [fromStart] is true, searches from the beginning of the list.
  /// Returns a tuple of (anchor point, direction point).
  (Offset?, Offset?) _findPointsWithMinDistance(
    double minDistanceSq, {
    required bool fromStart,
  }) {
    Offset? anchorPoint;
    Offset? directionPoint;
    final points = offsets;

    if (fromStart) {
      for (int i = 0; i < points.length; i++) {
        if (points[i] != null) {
          anchorPoint = points[i]! * scale;
          for (int j = i + 1; j < points.length; j++) {
            if (points[j] != null) {
              final scaled = points[j]! * scale;
              if ((scaled - anchorPoint).distanceSquared >= minDistanceSq) {
                directionPoint = scaled;
                break;
              }
              directionPoint = scaled;
            }
          }
          break;
        }
      }
    } else {
      for (int i = points.length - 1; i >= 0; i--) {
        if (points[i] != null) {
          anchorPoint = points[i]! * scale;
          for (int j = i - 1; j >= 0; j--) {
            if (points[j] != null) {
              final scaled = points[j]! * scale;
              if ((scaled - anchorPoint).distanceSquared >= minDistanceSq) {
                directionPoint = scaled;
                break;
              }
              directionPoint = scaled;
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
    Offset anchorPoint,
    Offset directionPoint,
    double strokeFactor,
  ) {
    // Open arrowhead (two lines instead of closed triangle)
    // Size is proportional to strokeWidth for consistent look
    final arrowHead = Path()
      ..moveTo(-4 * strokeFactor, 4 * strokeFactor)
      ..lineTo(0, 0)
      ..lineTo(-4 * strokeFactor, -4 * strokeFactor);

    // Direction points from directionPoint to anchorPoint
    final direction = (anchorPoint - directionPoint).direction;
    final transform = Matrix4.identity()
      ..translateByDouble(anchorPoint.dx, anchorPoint.dy, 0.0, 1.0)
      ..rotateZ(direction);

    path.addPath(arrowHead.transform(transform.storage), Offset.zero);
  }
}
