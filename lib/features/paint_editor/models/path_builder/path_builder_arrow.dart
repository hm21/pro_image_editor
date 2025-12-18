import 'package:flutter/widgets.dart';

import 'path_builder_base.dart';

/// Builds a path representing an arrow with a line and arrowhead.
class PathBuilderArrow extends PathBuilderBase {
  /// Creates an arrow path builder using the given item and scale factor.
  PathBuilderArrow({
    required super.item,
    required super.scale,
    required super.paintEditorConfigs,
  });

  @override
  Path build() {
    // Add the main line
    path
      ..moveTo(start.dx, start.dy)
      ..lineTo(end.dx, end.dy);

    // Define the arrowhead (before transformation)
    final pathOffset = 1.0 * scale; // this can be adjusted based on strokeWidth
    final arrowHead = Path()
      ..moveTo(0, 0)
      ..lineTo(-15 * pathOffset, 10 * pathOffset)
      ..lineTo(-15 * pathOffset, -10 * pathOffset)
      ..close();

    // Create transform to rotate + translate the arrowhead to the end point
    final direction = (end - start).direction;
    final transform = Matrix4.identity()
      ..translateByDouble(end.dx, end.dy, 0.0, 1.0)
      ..rotateZ(direction);

    // Apply transformation and add to main path
    final transformedArrow = arrowHead.transform(transform.storage);
    path.addPath(transformedArrow, Offset.zero);

    return path;
  }

  @override
  bool hitTest(Offset position) {
    return super.hitTestLine(position);
  }
}
