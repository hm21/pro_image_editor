import 'package:flutter/widgets.dart';

import 'path_builder_base.dart';

/// Builds a rectangular path using the start and end offsets.
class PathBuilderRectangular extends PathBuilderBase {
  /// Creates a rectangular path builder with the given item and scale.
  PathBuilderRectangular({
    required super.item,
    required super.scale,
    required super.paintEditorConfigs,
  });

  @override
  Path build() {
    var rect = Rect.fromPoints(start, end);
    path.addRect(rect);

    return path;
  }

  @override
  bool hitTest(Offset position) {
    return hitTestFillableObject(position);
  }
}
