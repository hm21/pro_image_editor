import 'package:flutter/widgets.dart';

import 'path_builder_base.dart';

/// Builds a polygon path from a list of connected offset points.
class PathBuilderPolygon extends PathBuilderBase {
  /// Creates a polygon path builder using the given item and scale factor.
  PathBuilderPolygon({
    required super.item,
    required super.scale,
    required super.paintEditorConfigs,
  });

  @override
  Path build() {
    if (offsets.isEmpty || offsets.any((o) => o == null)) return path;

    final points = offsets.whereType<Offset>().map((o) => o * scale).toList();

    if (points.length < 2) return path;

    path.moveTo(points.first.dx, points.first.dy);

    for (var i = 1; i < points.length; i++) {
      path.lineTo(points[i].dx, points[i].dy);
    }

    // Close the path only if the first and last points are (almost) equal
    const double threshold = 0.5; // tweak as needed
    if ((points.first - points.last).distance < threshold) {
      path.close();
    }

    painter.style = offsets.first == offsets.last && item.fill
        ? PaintingStyle.fill
        : PaintingStyle.stroke;

    return path;
  }

  @override
  bool hitTest(Offset position) {
    return hitTestFillableObject(position);
  }
}
