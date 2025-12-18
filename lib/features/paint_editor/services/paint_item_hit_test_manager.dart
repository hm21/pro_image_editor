import 'dart:ui';

import '/core/models/editor_configs/paint_editor/paint_editor_configs.dart';
import '../enums/paint_editor_enum.dart';
import '../models/painted_model.dart';
import '../models/path_builder/path_builder_base.dart';

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
        final builder = PathBuilderBase.fromMode(
          item: item,
          scale: scaleFactor,
          paintEditorConfigs: paintEditorConfigs,
        );

        item.hit = builder.hitTest(position);
    }

    return item.hit;
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
