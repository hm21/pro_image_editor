import 'package:flutter/widgets.dart';

import 'path_builder_base.dart';

/// Builds a dashed–dot line path between the start and end offsets.
class PathBuilderDashDotLine extends PathBuilderBase {
  /// Creates an dash-dot path builder using the given item and scale factor.
  PathBuilderDashDotLine({
    required super.item,
    required super.scale,
    required super.paintEditorConfigs,
  });

  @override
  Path build() {
    final width = painter.strokeWidth;
    final dashWidth = paintEditorConfigs.dashDotLineWidthFactor * width;
    final spaceWidth = paintEditorConfigs.dashDotLineSpacingFactor * width;

    var distance = 0.0;
    final segmentPath = Path()
      ..moveTo(start.dx, start.dy)
      ..lineTo(end.dx, end.dy);
    final metrics = segmentPath.computeMetrics();

    for (final metric in metrics) {
      while (distance < metric.length) {
        // Draw one dash
        final endDistance = (distance + dashWidth).clamp(0.0, metric.length);
        final extracted = metric.extractPath(distance, endDistance);
        path.addPath(extracted, Offset.zero);

        // Move distance: dash + space + dot + space
        distance = endDistance + spaceWidth * 2;
      }
    }

    return path;
  }

  @override
  Path buildSecond() {
    final width = painter.strokeWidth;
    final dashWidth = paintEditorConfigs.dashDotLineWidthFactor * width;
    final dotRadius = width / 2;
    final spaceWidth = paintEditorConfigs.dashDotLineSpacingFactor * width;

    var distance = 0.0;
    final dotPath = Path();

    final segmentPath = Path()
      ..moveTo(start.dx, start.dy)
      ..lineTo(end.dx, end.dy);
    final metrics = segmentPath.computeMetrics();

    for (final metric in metrics) {
      while (distance < metric.length) {
        final dashEnd = (distance + dashWidth).clamp(0.0, metric.length);
        final nextDashStart = dashEnd + spaceWidth * 2;
        final dotCenter = dashEnd + (nextDashStart - dashEnd) / 2;

        if (dotCenter < metric.length) {
          final tangent = metric.getTangentForOffset(dotCenter);
          if (tangent != null) {
            dotPath.addOval(Rect.fromCircle(
              center: tangent.position,
              radius: dotRadius,
            ));
          }
        }

        distance = nextDashStart;
      }
    }

    return dotPath;
  }

  @override
  bool hitTest(Offset position) => super.hitTestLine(position);
}
