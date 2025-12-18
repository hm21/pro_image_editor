import 'package:flutter/widgets.dart';

import 'path_builder_base.dart';

/// Builds a straight line path from the start to the end offset.
class PathBuilderLine extends PathBuilderBase {
  /// Creates a line path builder using the given item and scale factor.
  PathBuilderLine({
    required super.item,
    required super.scale,
    required super.paintEditorConfigs,
  });

  @override
  Path build() {
    path
      ..moveTo(start.dx, start.dy)
      ..lineTo(end.dx, end.dy);

    return path;
  }

  @override
  bool hitTest(Offset position) {
    return super.hitTestLine(position);
  }
}
