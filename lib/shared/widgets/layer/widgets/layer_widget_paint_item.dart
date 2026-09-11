import 'package:flutter/foundation.dart';
import 'package:material_ui/material_ui.dart';

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
    this.skipPaint = false,
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

  /// Whether the strokes are painted by a cached raster elsewhere, so the
  /// painters here only serve hit-testing. See [DrawPaintItem.skipPaint].
  final bool skipPaint;

  /// Configuration settings for the paint editor.
  final PaintEditorConfigs paintEditorConfigs;

  /// Callback function that is triggered when a hit status changes.
  ///
  /// The [onHitChanged] function takes a boolean parameter [hasHit] which
  /// indicates whether a hit has occurred (true) or not (false).
  final Function(bool hasHit)? onHitChanged;

  @override
  Widget build(BuildContext context) {
    final items = layer.items;

    if (items.length == 1) {
      // Fast path for the common single-stroke layer, where the layer opacity
      // is the only one that applies.
      return _buildItem(items.first, opacity: layer.opacity);
    }

    // Merged layer: stack every baked-in stroke, each with its own opacity.
    final Widget child = Stack(
      children: [
        for (final item in items) _buildItem(item, opacity: item.opacity),
      ],
    );

    // The strokes of a merged layer overlap each other, so a layer opacity
    // below 1 has to fade the composed stack rather than each stroke on its
    // own. Merged layers keep an opacity of `1.0` and carry the fading in the
    // strokes themselves, so this stays unused in practice.
    if (layer.opacity >= 1.0) return child;

    return Opacity(opacity: layer.opacity, child: child);
  }

  /// Builds a single stroke painter sized to the layer.
  ///
  /// [opacity] is handed to the painter, which multiplies it into the stroke
  /// color instead of wrapping the item in an `Opacity`. That widget renders
  /// the layer into an offscreen buffer on every frame - the most expensive
  /// primitive on mobile GPUs - while the painted result is identical for a
  /// single draw call. A custom path builder may issue several draw calls that
  /// would then blend against each other, so those keep the wrapper.
  Widget _buildItem(PaintedModel item, {required double opacity}) {
    final bool canBakeOpacity = !paintEditorConfigs.customPathBuilders
        .containsKey(item.mode);

    Widget painter = CustomPaint(
      size: layer.size,
      willChange: willChange,
      isComplex: item.mode.isFreeStyleMode,
      painter: DrawPaintItem(
        item: item,
        scale: layer.scale,
        opacity: canBakeOpacity ? opacity : 1.0,
        skipPaint: skipPaint,
        selected: isSelected,
        enabledHitDetection: enableHitDetection,
        onHitChanged: onHitChanged,
        paintEditorConfigs: paintEditorConfigs,
      ),
    );

    if (!canBakeOpacity && opacity < 1.0) {
      painter = Opacity(opacity: opacity, child: painter);
    }

    return painter;
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    layer.debugFillProperties(properties);
  }
}
