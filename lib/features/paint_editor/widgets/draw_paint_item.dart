// Flutter imports:
import 'package:flutter/material.dart';

import '/core/models/editor_configs/paint_editor/paint_editor_configs.dart';
import '../models/painted_model.dart';
import '../models/path_builder/path_builder_base.dart';
import '../services/paint_item_hit_test_manager.dart';

/// Handles the paint ongoing on the canvas.
class DrawPaintItem extends CustomPainter {
  /// Constructor for the canvas.
  DrawPaintItem({
    this.selected = false,
    required this.item,
    this.paintEditorConfigs = const PaintEditorConfigs(),
    this.onHitChanged,
    this.scale = 1,
    this.enabledHitDetection = false,
  });

  /// The model containing information about the painting.
  final PaintedModel item;

  /// The scaling factor applied to the canvas.
  final double scale;

  /// The current erasing behavior applied by the tool.
  final PaintEditorConfigs paintEditorConfigs;

  /// Enables or disables hit detection.
  /// When `true`, allows detecting user interactions with the interface.
  bool enabledHitDetection = true;

  /// Indicates whether the layer is currently selected.
  bool selected = true;

  /// Callback function that is triggered when a hit status changes.
  ///
  /// The [onHitChanged] function takes a boolean parameter [hasHit] which
  /// indicates whether a hit has occurred (true) or not (false).
  final Function(bool hasHit)? onHitChanged;

  final _hitTestManager = PaintItemHitTestManager();

  @override
  void paint(Canvas canvas, Size size) {
    PathBuilderBase.fromMode(
      item: item,
      scale: scale,
      paintEditorConfigs: paintEditorConfigs,
    ).draw(canvas: canvas, size: size);
  }

  @override
  bool shouldRepaint(DrawPaintItem oldDelegate) {
    return oldDelegate.item != item;
  }

  @override
  bool hitTest(Offset position) {
    bool hasHit = _hitTestManager.hitTest(
      item: item,
      position: position,
      enabledHitDetection: enabledHitDetection,
      isSelected: selected,
      scaleFactor: scale,
      paintEditorConfigs: paintEditorConfigs,
    );
    onHitChanged?.call(hasHit);
    return hasHit;
  }
}
