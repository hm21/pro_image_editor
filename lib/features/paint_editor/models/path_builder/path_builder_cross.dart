import 'dart:math';

import 'package:flutter/widgets.dart';

import 'path_builder_base.dart';

/// Builds a path representing a cross.
class PathBuilderCross extends PathBuilderBase {
  /// Creates a cross path builder using the given item and scale factor.
  PathBuilderCross({required super.item, required super.scale});

  @override
  Path build() {
    // Normalize to a top/left anchored box (handles any drag direction)
    final double left = min(start.dx, end.dx);
    final double right = max(start.dx, end.dx);
    final double top = min(start.dy, end.dy);
    final double bottom = max(start.dy, end.dy);

    final double width = right - left;
    final double height = bottom - top;

    // --- Proportions (tweak as you like) ---
    final double crossWidth = width * 0.2; // bar thickness
    final double crossWidthHalf = crossWidth / 2.0;
    final double crossTopHeight = height * 0.28; // top stem above the crossbar
    final double crossBottomHeight =
        height - crossTopHeight - crossWidth; // bottom stem

    // Guard: if the box is too small, just return an empty path
    if (crossBottomHeight <= 0 || crossWidth <= 0) return path;

    // Stem center X
    final double cx = left + width / 2.0;

    // X extents
    final double stemLeft = cx - crossWidthHalf;
    final double stemRight = cx + crossWidthHalf;
    final double armLeft = left;
    final double armRight = right;

    // Y levels
    final double yTop = top;
    final double yCrossTop = top + crossTopHeight;
    final double yCrossBot = yCrossTop + crossWidth;
    final double yBottom = bottom;

    // --- Single closed outline (one path) ---
    path
      ..moveTo(stemLeft, yTop) // top-left of stem
      ..lineTo(stemRight, yTop) // top-right of stem
      ..lineTo(stemRight, yCrossTop) // down to top of crossbar
      ..lineTo(armRight, yCrossTop) // right arm tip (top edge)
      ..lineTo(armRight, yCrossBot) // down crossbar thickness
      ..lineTo(stemRight, yCrossBot) // back to stem right
      ..lineTo(stemRight, yBottom) // down stem to bottom
      ..lineTo(stemLeft, yBottom) // bottom to stem left
      ..lineTo(stemLeft, yCrossBot) // up to crossbar bottom
      ..lineTo(armLeft, yCrossBot) // left arm tip (bottom edge)
      ..lineTo(armLeft, yCrossTop) // up to crossbar top
      ..lineTo(stemLeft, yCrossTop) // back to stem left
      ..close();

    return path;
  }

  @override
  bool hitTest(Offset position) {
    return hitTestFillableObject(position);
  }
}
