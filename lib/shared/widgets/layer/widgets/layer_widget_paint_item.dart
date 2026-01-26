import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '/core/models/editor_configs/paint_editor/paint_editor_configs.dart';
import '/core/models/layers/paint_layer.dart';
import '/features/paint_editor/widgets/draw_paint_item.dart';

/// A widget representing a paint layer in the sticker editor.
class LayerWidgetPaintItem extends StatelessWidget {
  /// Creates a [LayerWidgetPaintItem] with the given paint layer and
  /// configuration settings.
  const LayerWidgetPaintItem({
    super.key,
    required this.layer,
    this.isSelected = false,
    this.enableHitDetection = false,
    this.willChange = false,
    this.onHitChanged,
    required this.paintEditorConfigs,
  });

  /// The paint layer represented by this widget.
  final PaintLayer layer;

  /// Whether the paint layer is currently selected.
  final bool isSelected;

  /// Indicates whether the widget will change frequently, which can be used
  /// to optimize rendering performance by enabling or disabling certain
  /// optimizations in the rendering pipeline.
  final bool willChange;

  /// Whether hit detection is enabled for this layer.
  final bool enableHitDetection;

  /// Configuration settings for the paint editor.
  final PaintEditorConfigs paintEditorConfigs;

  /// Callback function that is triggered when a hit status changes.
  ///
  /// The [onHitChanged] function takes a boolean parameter [hasHit] which
  /// indicates whether a hit has occurred (true) or not (false).
  final Function(bool hasHit)? onHitChanged;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: layer.opacity,
      child: CustomPaint(
        size: layer.size,
        willChange: willChange,
        isComplex: layer.item.mode.isFreeStyleMode,
        painter: DrawPaintItem(
          item: layer.item,
          scale: layer.scale,
          selected: isSelected,
          enabledHitDetection: enableHitDetection,
          onHitChanged: onHitChanged,
          paintEditorConfigs: paintEditorConfigs,
        ),
      ),
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    layer.debugFillProperties(properties);
  }
}
