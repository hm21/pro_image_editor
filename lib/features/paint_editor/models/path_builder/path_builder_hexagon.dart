import 'dart:math';
import 'package:flutter/widgets.dart';

import 'path_builder_base.dart';

/// Builds a regular hexagon inside the rectangle defined by start & end.
class PathBuilderHexagon extends PathBuilderBase {
  /// Creates a hexagon path builder.
  PathBuilderHexagon({
    required super.item,
    required super.scale,
    required super.paintEditorConfigs,
  });

  @override
  Path build() {
    final rect = Rect.fromPoints(start, end);

    final center = rect.center;
    final radius = min(rect.width.abs(), rect.height.abs()) / 2;

    // If user didn't drag enough, avoid weird paths.
    if (radius <= 0.0) {
      return path;
    }

    // 6 vertices (flat-top orientation).
    // Start angle -90 makes one point on top (nice look).
    const sides = 6;
    const startAngle = -pi / 2;

    path.reset();
    for (int i = 0; i < sides; i++) {
      final angle = startAngle + (2 * pi * i / sides);
      final p = Offset(
        center.dx + radius * cos(angle),
        center.dy + radius * sin(angle),
      );

      if (i == 0) {
        path.moveTo(p.dx, p.dy);
      } else {
        path.lineTo(p.dx, p.dy);
      }
    }
    path.close();

    return path;
  }

  @override
  bool hitTest(Offset position) {
    return hitTestFillableObject(position);
  }
}
