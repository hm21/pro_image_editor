import 'package:flutter/widgets.dart';

import 'path_builder_base.dart';

/// Builds a circular path based on the item's start and end offsets.
class PathBuilderCircle extends PathBuilderBase {
  /// Creates a circle path builder using the given item and scale factor.
  PathBuilderCircle({
    required super.item,
    required super.scale,
    required super.paintEditorConfigs,
  });

  @override
  Path build() {
    var rect = Rect.fromPoints(start, end);
    path.addOval(rect);

    return path;
  }

  @override
  bool hitTest(Offset position) {
    return hitTestFillableObject(position);
  }
}
