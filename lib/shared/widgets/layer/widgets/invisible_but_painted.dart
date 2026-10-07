import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

/// Renders its child into the render tree (so [RepaintBoundary.toImage] works)
/// but displays nothing on screen.
///
/// Unlike [Opacity] with alpha 0, which skips painting entirely, this widget
/// uses [PaintingContext.pushOpacity] directly which always paints the child
/// into an [OpacityLayer].
class InvisibleButPainted extends SingleChildRenderObjectWidget {
  /// Creates an [InvisibleButPainted].
  const InvisibleButPainted({super.key, required super.child});

  @override
  RenderObject createRenderObject(BuildContext context) =>
      _RenderInvisibleButPainted();
}

class _RenderInvisibleButPainted extends RenderProxyBox {
  @override
  bool get alwaysNeedsCompositing => true;

  @override
  void paint(PaintingContext context, Offset offset) {
    if (child == null) return;
    context.pushOpacity(offset, 0, super.paint);
  }
}
