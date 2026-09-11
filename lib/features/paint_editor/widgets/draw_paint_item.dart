// Flutter imports:
import 'package:flutter/material.dart';

import '/core/models/editor_configs/paint_editor/paint_editor_configs.dart';
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
    this.opacity = 1,
    this.enabledHitDetection = false,
    this.skipPaint = false,
  });

  /// The model containing information about the painting.
  final PaintedModel item;

  /// The scaling factor applied to the canvas.
  final double scale;

  /// The opacity the item is drawn with.
  ///
  /// This is baked into the paint alpha instead of being applied by an
  /// `Opacity` widget, which would push the item through an offscreen buffer
  /// on every frame. See [PathBuilderBase.draw] for when that is equivalent.
  final double opacity;

  /// The current erasing behavior applied by the tool.
  final PaintEditorConfigs paintEditorConfigs;

  /// Whether [paint] draws nothing.
  ///
  /// Set while the item's pixels come from a cached raster (see
  /// `MainEditorConfigs.enablePaintLayerRasterCache`). Hit-testing keeps
  /// working on the real path, so the layer stays selectable and draggable;
  /// only the per-frame stroking is skipped.
  final bool skipPaint;

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
    if (skipPaint) return;
    PathBuilderBase.fromMode(
        item: item,
        scale: scale,
        paintEditorConfigs: paintEditorConfigs,
      )
      ..opacity = opacity
      ..draw(canvas: canvas, size: size);
  }

  @override
  bool shouldRepaint(DrawPaintItem oldDelegate) {
    return oldDelegate.item != item ||
        oldDelegate.opacity != opacity ||
        oldDelegate.skipPaint != skipPaint;
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
