import 'package:flutter/widgets.dart';

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

    painter.strokeCap = StrokeCap.round;

    return path;
  }
}
