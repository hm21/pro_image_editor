import 'package:flutter/widgets.dart';

import 'path_builder_base.dart';

/// Builds a dashed line path between the start and end offsets.
class PathBuilderDashLine extends PathBuilderBase {
  /// Creates a dashed line path builder using the given item and scale.
  PathBuilderDashLine({
    required super.item,
    required super.scale,
    required super.paintEditorConfigs,
  });

  @override
  Path build() {
    final width = painter.strokeWidth;
    final dashWidth = paintEditorConfigs.dashLineWidthFactor * width;
    final dashSpace = paintEditorConfigs.dashLineSpacingFactor * width;
    var distance = 0.0;

    final segmentPath = Path()
      ..moveTo(start.dx, start.dy)
      ..lineTo(end.dx, end.dy);
    final metrics = segmentPath.computeMetrics();

    for (final metric in metrics) {
      while (distance < metric.length) {
        final extracted = metric.extractPath(
          distance,
          (distance + dashWidth).clamp(0.0, metric.length),
        );
        path.addPath(extracted, Offset.zero);
        distance += dashWidth + dashSpace;
      }
    }

    return path;
  }

  @override
  bool hitTest(Offset position) {
    return super.hitTestLine(position);
  }
}
