import 'package:flutter/foundation.dart';
import 'package:material_ui/material_ui.dart';

import '/core/models/editor_configs/paint_editor/paint_editor_configs.dart';
import '/core/models/layers/paint_layer.dart';
import '/features/paint_editor/widgets/draw_paint_item.dart';

/// A widget representing a paint layer in the sticker editor.
///
/// A layer with a `LayerAnimationType.drawOn` animation draws as much of its
/// strokes as [playTimeNotifier] has reached, see
/// [PaintLayer.drawnFractionAt]. Without a notifier it shows them whole.
class LayerWidgetPaintItem extends StatefulWidget {
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
    this.playTimeNotifier,
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

  /// The current playback position of a video, which decides how far a
  /// layer that draws itself has drawn its strokes.
  final ValueListenable<Duration>? playTimeNotifier;

  @override
  State<LayerWidgetPaintItem> createState() => _LayerWidgetPaintItemState();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    layer.debugFillProperties(properties);
  }
}

class _LayerWidgetPaintItemState extends State<LayerWidgetPaintItem> {
  /// How far the strokes are drawn, or `null` when they show whole.
  double? _drawnFraction;

  @override
  void initState() {
    super.initState();
    widget.playTimeNotifier?.addListener(_onPlayTimeChanged);
    _drawnFraction = _resolveDrawnFraction();
  }

  @override
  void didUpdateWidget(covariant LayerWidgetPaintItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.playTimeNotifier != widget.playTimeNotifier) {
      oldWidget.playTimeNotifier?.removeListener(_onPlayTimeChanged);
      widget.playTimeNotifier?.addListener(_onPlayTimeChanged);
    }
    _drawnFraction = _resolveDrawnFraction();
  }

  @override
  void dispose() {
    widget.playTimeNotifier?.removeListener(_onPlayTimeChanged);
    super.dispose();
  }

  /// The playback position moves every frame, while a layer outside its
  /// draw-on window shows the same whole drawing, so this only rebuilds when
  /// the drawn part changes.
  void _onPlayTimeChanged() {
    final drawn = _resolveDrawnFraction();
    if (drawn != _drawnFraction) setState(() => _drawnFraction = drawn);
  }

  double? _resolveDrawnFraction() {
    final playTime = widget.playTimeNotifier;
    if (playTime == null || !widget.layer.drawsOn) return null;
    return widget.layer.drawnFractionAt(playTime.value);
  }

  @override
  Widget build(BuildContext context) {
    final layer = widget.layer;
    final items = layer.items;
    final drawnFraction = _drawnFraction;
    final drawn = drawnFraction == null
        ? null
        : layer.drawnItemsAt(
            drawnFraction,
            paintEditorConfigs: widget.paintEditorConfigs,
          );
    // Keyframes carry the opacity of a layer that has them, applied around
    // the whole layer (see [LayerTimelineVisibility]).
    final layerOpacity = layer.hasKeyframes ? 1.0 : layer.opacity;

    if (items.length == 1) {
      // Fast path for the common single-stroke layer, where the layer opacity
      // is the only one that applies.
      return _PaintItem(
        layer: layer,
        item: items.first,
        drawn: drawn == null ? items.first : drawn.first,
        opacity: layerOpacity,
        host: widget,
      );
    }

    // Merged layer: stack every baked-in stroke, each with its own opacity.
    final Widget child = Stack(
      children: [
        for (final (index, item) in items.indexed)
          _PaintItem(
            layer: layer,
            item: item,
            drawn: drawn == null ? item : drawn[index],
            opacity: item.opacity,
            host: widget,
          ),
      ],
    );

    // The strokes of a merged layer overlap each other, so a layer opacity
    // below 1 has to fade the composed stack rather than each stroke on its
    // own. Merged layers keep an opacity of `1.0` and carry the fading in the
    // strokes themselves, so this stays unused in practice.
    if (layerOpacity >= 1.0) return child;

    return Opacity(opacity: layerOpacity, child: child);
  }
}

/// A single stroke painter sized to the layer.
///
/// [opacity] is handed to the painter, which multiplies it into the stroke
/// color instead of wrapping the item in an `Opacity`. That widget renders
/// the layer into an offscreen buffer on every frame - the most expensive
/// primitive on mobile GPUs - while the painted result is identical for a
/// single draw call. A custom path builder may issue several draw calls that
/// would then blend against each other, so those keep the wrapper.
///
/// [drawn] is as much of [item] as a draw-on animation has drawn, [item]
/// itself when it shows whole, or `null` when none of it shows yet; the
/// painter hit-tests [item] either way.
class _PaintItem extends StatelessWidget {
  const _PaintItem({
    required this.layer,
    required this.item,
    required this.drawn,
    required this.opacity,
    required this.host,
  });

  final PaintLayer layer;
  final PaintedModel item;
  final PaintedModel? drawn;
  final double opacity;

  /// The widget whose settings the stroke is painted with.
  final LayerWidgetPaintItem host;

  @override
  Widget build(BuildContext context) {
    final paintEditorConfigs = host.paintEditorConfigs;
    final drawn = this.drawn;
    final bool canBakeOpacity = !paintEditorConfigs.customPathBuilders
        .containsKey((drawn ?? item).mode);

    Widget painter = CustomPaint(
      size: layer.size,
      willChange: host.willChange,
      isComplex: paintEditorConfigs.isFreeStyleMode(item.mode),
      painter: DrawPaintItem(
        item: item,
        paintedItem: identical(drawn, item) ? null : drawn,
        scale: layer.scale,
        opacity: canBakeOpacity ? opacity : 1.0,
        skipPaint: host.skipPaint || drawn == null,
        selected: host.isSelected,
        enabledHitDetection: host.enableHitDetection,
        onHitChanged: host.onHitChanged,
        paintEditorConfigs: paintEditorConfigs,
      ),
    );

    if (!canBakeOpacity && opacity < 1.0) {
      painter = Opacity(opacity: opacity, child: painter);
    }

    return painter;
  }
}
