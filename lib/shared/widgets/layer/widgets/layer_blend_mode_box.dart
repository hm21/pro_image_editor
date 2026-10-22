// Flutter imports:
import 'package:flutter/widgets.dart';

/// Draws [child] onto what is painted beneath it with [blendMode], as
/// `Canvas.saveLayer` with a paint of that mode would, also when [child] holds
/// a video [Texture] or other composited layers.
///
/// A save layer only reaches the picture it is recorded in, and a texture is a
/// compositing layer of its own. A [BackdropFilter] is the compositing layer
/// that draws its content onto what lies beneath it with a blend mode: it
/// starts from that backdrop run through its filter, paints its child over
/// it, and composites the result with [BackdropFilter.blendMode]. Its filter
/// here clears the backdrop, so the child alone is composited, with
/// [blendMode].
///
/// The backdrop ends at the closest ancestor that composites into a layer of
/// its own, such as an [Opacity], a [ShaderMask] or a [ColorFiltered]: the
/// child blends with what was painted inside that layer, not with what lies
/// under it. So anything that fades or filters the child belongs inside this
/// box, between it and the child.
///
/// [BlendMode.srcOver] paints the child as it is, without a layer.
class LayerBlendModeBox extends StatelessWidget {
  /// Creates a [LayerBlendModeBox].
  const LayerBlendModeBox({
    super.key,
    required this.blendMode,
    required this.child,
  });

  /// How [child] is drawn onto what is beneath it.
  final BlendMode blendMode;

  /// The content to blend.
  final Widget child;

  /// Turns every backdrop pixel transparent: the box composites its child
  /// alone.
  static const ColorFilter _clearBackdrop = ColorFilter.mode(
    Color(0x00000000),
    BlendMode.src,
  );

  @override
  Widget build(BuildContext context) {
    if (blendMode == BlendMode.srcOver) return child;
    return BackdropFilter(
      filter: _clearBackdrop,
      blendMode: blendMode,
      child: child,
    );
  }
}
