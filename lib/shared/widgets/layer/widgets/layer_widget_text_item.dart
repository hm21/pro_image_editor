import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:material_ui/material_ui.dart';

import '/core/models/editor_configs/text_editor_configs.dart';
import '/core/models/layers/text_layer.dart';
import '../../../../features/text_editor/widgets/rounded_background_text/rounded_background_text.dart';

/// A widget representing a text layer in the sticker editor.
class LayerWidgetTextItem extends StatefulWidget {
  /// Creates a [LayerWidgetTextItem] with the given text layer and editor
  /// configurations.
  const LayerWidgetTextItem({
    super.key,
    required this.layer,
    required this.textEditorConfigs,
    required this.showMoveCursor,
    required this.onHitChanged,
    this.playTimeNotifier,
    this.mainBodySize = Size.zero,
    this.mainEditorLayer,
  });

  /// The text layer represented by this widget.
  final TextLayer layer;

  /// Configuration settings for the text editor.
  final TextEditorConfigs textEditorConfigs;

  /// Notifies whether the move cursor should be shown.
  final ValueNotifier<bool> showMoveCursor;

  /// Callback function that is triggered when a hit status changes.
  ///
  /// The [onHitChanged] function takes a boolean parameter [hasHit] which
  /// indicates whether a hit has occurred (true) or not (false).
  final Function(bool hasHit) onHitChanged;

  /// The video playback position, which decides the active entry of
  /// [TextLayer.highlights]. Without it no highlight is shown.
  final ValueListenable<Duration>? playTimeNotifier;

  /// The size of the main editor's body, which
  /// [TextEditorConfigs.layerBounds] derives the area the layer stays inside
  /// from. An empty size sets no limit.
  final Size mainBodySize;

  /// The layer [layer] was copied from, as the main editor places it in
  /// [mainBodySize], when [layer] is drawn in another space, such as the
  /// crop editor's preview of the uncropped image.
  ///
  /// The lines then wrap where they wrap in the main editor. Defaults to
  /// [layer].
  final TextLayer? mainEditorLayer;

  /// Renders [layer] laid out at [size] with the entry of
  /// [TextLayer.highlights] at [highlightIndex] active, or with none when
  /// [highlightIndex] is `null`.
  ///
  /// This is what a capture reads instead of the on-screen boundary, which
  /// shows whichever highlight the playback position happens to be on.
  static Future<ui.Image> renderContent(
    BuildContext context, {
    required TextLayer layer,
    required TextEditorConfigs textEditorConfigs,
    required Size size,
    required double pixelRatio,
    Size mainBodySize = Size.zero,
    TextLayer? mainEditorLayer,
    int? highlightIndex,
  }) {
    return _buildText(
      layer: layer,
      textEditorConfigs: textEditorConfigs,
      mainBodySize: mainBodySize,
      mainEditorLayer: mainEditorLayer,
      highlightIndex: highlightIndex,
    ).toImage(context, size: size, pixelRatio: pixelRatio);
  }

  /// How wide [layer] may be within [TextEditorConfigs.layerBounds].
  ///
  /// `max` is the longest line the bounds hold along the text, `soft` the
  /// room around the center of the layer before its lines reach an edge.
  /// Both are measured on [mainEditorLayer] in [mainBodySize] and are
  /// [double.infinity] when nothing limits the layer.
  static ({double max, double soft}) _widthLimits(
    TextLayer layer,
    TextEditorConfigs textEditorConfigs,
    Size mainBodySize,
    TextLayer? mainEditorLayer,
  ) {
    final layerBounds = textEditorConfigs.layerBounds;
    // The body has no size before its first layout.
    if (layerBounds == null || mainBodySize.isEmpty || !mainBodySize.isFinite) {
      return (max: double.infinity, soft: double.infinity);
    }
    final placed = mainEditorLayer ?? layer;
    // A copy drawn in another space is scaled along with its widths.
    final copyScale = placed.scale == 0 ? 1.0 : layer.scale / placed.scale;
    final bounds = layerBounds(mainBodySize);
    return (
      max: _lineLength(bounds, bounds.center, placed.rotation) * copyScale,
      soft:
          _lineLength(
            bounds,
            mainBodySize.center(placed.offset),
            placed.rotation,
          ) *
          copyScale,
    );
  }

  /// The longest line at [angle] that is centered on [point] and stays
  /// inside [bounds], or `0` when [point] lies outside them.
  static double _lineLength(Rect bounds, Offset point, double angle) {
    final cosine = cos(angle).abs();
    final sine = sin(angle).abs();
    var halfLength = double.infinity;
    // A line parallel to an axis never reaches the edges across it.
    if (cosine > precisionErrorTolerance) {
      final room = min(point.dx - bounds.left, bounds.right - point.dx);
      halfLength = min(halfLength, room / cosine);
    }
    if (sine > precisionErrorTolerance) {
      final room = min(point.dy - bounds.top, bounds.bottom - point.dy);
      halfLength = min(halfLength, room / sine);
    }
    return max(0.0, halfLength * 2);
  }

  static RoundedBackgroundText _buildText({
    required TextLayer layer,
    required TextEditorConfigs textEditorConfigs,
    required Size mainBodySize,
    required TextLayer? mainEditorLayer,
    required int? highlightIndex,
    Function(bool hasHit)? onHitTestResult,
  }) {
    var fontSize = textEditorConfigs.initFontSize * layer.scale;
    var style = TextStyle(
      fontSize: fontSize * layer.fontScale,
      color: layer.color,
      overflow: TextOverflow.ellipsis,
    );

    final maxTextWidth = layer.maxTextWidth;
    final widthLimits = _widthLimits(
      layer,
      textEditorConfigs,
      mainBodySize,
      mainEditorLayer,
    );

    // Shadows and the outline are measured at the unscaled font size, so they
    // grow with the text when the layer is scaled.
    final effectScale = layer.scale * layer.fontScale;

    // Get the full style including shadows
    TextStyle finalStyle;
    if (layer.textStyle != null) {
      finalStyle = layer.textStyle!.copyWith(
        fontSize: style.fontSize,
        fontWeight: layer.textStyle!.fontWeight ?? style.fontWeight,
        color: style.color,
        fontFamily: layer.textStyle!.fontFamily ?? style.fontFamily,
        shadows: layer.textStyle!.shadows
            ?.map((shadow) => shadow.scale(effectScale))
            .toList(),
      );
    } else {
      finalStyle = style;
    }

    return RoundedBackgroundText.rich(
      enableHitBoxCorrection: true,
      maxTextWidth: maxTextWidth == null
          ? double.infinity
          : maxTextWidth * layer.scale,
      maxWidth: widthLimits.max,
      softMaxWidth: widthLimits.soft,
      onHitTestResult: onHitTestResult,
      text: _highlightedSpan(layer, finalStyle, highlightIndex),
      backgroundColor: layer.background,
      textAlign: layer.align,
      leadingDistribution: textEditorConfigs.style.leadingDistribution,
      outlineWidth: layer.outlineWidth * effectScale,
      outlineColor: layer.outlineColor,
      reserveEffectSpace: true,
    );
  }

  /// The text of [layer] in [style], with the highlight at [highlightIndex]
  /// drawn in [TextLayer.highlightColor].
  ///
  /// Only the color changes, so the layout, and with it the layer's size, is
  /// the same whichever highlight is active.
  static TextSpan _highlightedSpan(
    TextLayer layer,
    TextStyle style,
    int? highlightIndex,
  ) {
    final text = layer.text;
    if (highlightIndex == null || highlightIndex >= layer.highlights.length) {
      return TextSpan(text: text, style: style);
    }

    final highlight = layer.highlights[highlightIndex];
    final start = highlight.start.clamp(0, text.length);
    final end = highlight.end.clamp(start, text.length);
    if (start == end) return TextSpan(text: text, style: style);

    return TextSpan(
      style: style,
      children: [
        TextSpan(text: text.substring(0, start)),
        TextSpan(
          text: text.substring(start, end),
          style: TextStyle(color: layer.highlightColor),
        ),
        TextSpan(text: text.substring(end)),
      ],
    );
  }

  @override
  State<LayerWidgetTextItem> createState() => _LayerWidgetTextItemState();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    layer.debugFillProperties(properties);
  }
}

class _LayerWidgetTextItemState extends State<LayerWidgetTextItem> {
  int? _highlightIndex;

  @override
  void initState() {
    super.initState();
    widget.playTimeNotifier?.addListener(_onPlayTimeChanged);
    _highlightIndex = _resolveHighlightIndex();
  }

  @override
  void didUpdateWidget(covariant LayerWidgetTextItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.playTimeNotifier != widget.playTimeNotifier) {
      oldWidget.playTimeNotifier?.removeListener(_onPlayTimeChanged);
      widget.playTimeNotifier?.addListener(_onPlayTimeChanged);
    }
    _highlightIndex = _resolveHighlightIndex();
  }

  @override
  void dispose() {
    widget.playTimeNotifier?.removeListener(_onPlayTimeChanged);
    super.dispose();
  }

  /// The playback position moves every frame while a highlight stays on for a
  /// whole word, so this only rebuilds when the active highlight changes.
  void _onPlayTimeChanged() {
    final index = _resolveHighlightIndex();
    if (index != _highlightIndex) setState(() => _highlightIndex = index);
  }

  int? _resolveHighlightIndex() {
    final playTime = widget.playTimeNotifier;
    if (playTime == null) return null;
    return widget.layer.highlightIndexAt(playTime.value);
  }

  void _handleLayerHit(bool hasHit) {
    final layer = widget.layer;
    final showMoveCursor = widget.showMoveCursor;
    // Update hit detection and cursor visibility state.
    if (layer.hit != hasHit || showMoveCursor.value != hasHit) {
      layer.hit = hasHit;
      showMoveCursor.value = hasHit;
    }
    layer.hit = hasHit;
    widget.onHitChanged(hasHit);
  }

  @override
  Widget build(BuildContext context) {
    return LayerWidgetTextItem._buildText(
      layer: widget.layer,
      textEditorConfigs: widget.textEditorConfigs,
      mainBodySize: widget.mainBodySize,
      mainEditorLayer: widget.mainEditorLayer,
      highlightIndex: _highlightIndex,
      onHitTestResult: _handleLayerHit,
    );
  }
}
