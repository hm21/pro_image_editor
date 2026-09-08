import 'dart:ui';

import '/core/models/editor_configs/paint_editor/paint_editor_configs.dart';
import '../enums/paint_editor_enum.dart';

/// A manager class responsible for handling hit testing of paint items
/// within the paint editor feature. This class provides functionality
/// to determine whether a specific paint item has been interacted with
/// (e.g., tapped or selected) based on user input or other criteria.
class PaintItemHitTestManager {
  /// Performs a hit test to determine if a given point intersects with a
  /// paint item.
  bool hitTest({
    required PaintedModel item,
    required Offset position,
    bool enabledHitDetection = true,
    bool isSelected = false,
    bool isRoundCensorArea = false,
    required double scaleFactor,
    required PaintEditorConfigs paintEditorConfigs,
  }) {
    if (!enabledHitDetection) {
      return true;
    } else if (isSelected) {
      item.hit = true;
      return true;
    }

    switch (item.mode) {
      case PaintMode.blur:
      case PaintMode.pixelate:
        item.hit = _detectCensorAreaHit(
          item: item,
          scaleFactor: scaleFactor,
          position: position,
          isRoundArea: isRoundCensorArea,
        );
      default:
        if (!_isInsideBounds(
          item: item,
          position: position,
          scaleFactor: scaleFactor,
          paintEditorConfigs: paintEditorConfigs,
        )) {
          item.hit = false;
          return false;
        }

        final builder = PathBuilderBase.fromMode(
          item: item,
          scale: scaleFactor,
          paintEditorConfigs: paintEditorConfigs,
        );

        item.hit = builder.hitTest(position);
    }

    return item.hit;
  }

  /// Cheap rejection test against the item's bounding box.
  ///
  /// Building the path and walking it is `O(path length)` and runs once per
  /// paint layer for every pointer hit test - while a mouse is connected
  /// Flutter repeats that hit test after every frame. Most layers are nowhere
  /// near the pointer, so the box check removes nearly all of that work.
  ///
  /// Custom path builders may draw outside the item's points, so the box
  /// cannot be trusted for them and the full test always runs.
  bool _isInsideBounds({
    required PaintedModel item,
    required Offset position,
    required double scaleFactor,
    required PaintEditorConfigs paintEditorConfigs,
  }) {
    if (paintEditorConfigs.customPathBuilders.containsKey(item.mode)) {
      return true;
    }

    final bounds = item.bounds;
    return Rect.fromPoints(
      bounds.topLeft * scaleFactor,
      bounds.bottomRight * scaleFactor,
    ).contains(position);
  }

  bool _detectCensorAreaHit({
    required PaintedModel item,
    required double scaleFactor,
    required Offset position,
    required bool isRoundArea,
  }) {
    final start = item.offsets[0]! * scaleFactor;
    final end = item.offsets[1]! * scaleFactor;

    final rect = Rect.fromPoints(start, end);
    if (isRoundArea) {
      final path = Path()..addOval(rect);
      return path.contains(position);
    } else {
      return rect.contains(position);
    }
  }
}
