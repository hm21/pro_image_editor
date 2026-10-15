// Dart imports:
import 'dart:math' as math;
import 'dart:ui' as ui;

// Flutter imports:
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

import '/core/models/layers/layer_mask.dart';

/// Shows [child] through a [LayerMask]: only inside its shape, or fading out
/// across its soft edge.
///
/// The mask is stretched over the child's box. It applies to everything the
/// child paints, including a video [Texture] and other composited layers,
/// because it is applied by the compositor rather than on a canvas.
///
/// With [mask] `null` the child paints as it is.
class LayerMaskBox extends SingleChildRenderObjectWidget {
  /// Creates a [LayerMaskBox].
  const LayerMaskBox({super.key, required this.mask, super.child});

  /// The mask to show [child] through, or `null` to show all of it.
  final LayerMask? mask;

  @override
  RenderLayerMaskBox createRenderObject(BuildContext context) {
    return RenderLayerMaskBox(
      mask: mask,
      devicePixelRatio: MediaQuery.maybeDevicePixelRatioOf(context) ?? 1,
    );
  }

  @override
  void updateRenderObject(
    BuildContext context,
    RenderLayerMaskBox renderObject,
  ) {
    renderObject
      ..mask = mask
      ..devicePixelRatio = MediaQuery.maybeDevicePixelRatioOf(context) ?? 1;
  }
}

/// The render object of a [LayerMaskBox].
///
/// The mask is rasterized once into an image as sharp as the child is drawn
/// on screen and reused until the mask, the box size or the needed
/// resolution changes.
class RenderLayerMaskBox extends RenderProxyBox {
  /// Creates a [RenderLayerMaskBox].
  RenderLayerMaskBox({
    LayerMask? mask,
    double devicePixelRatio = 1,
    RenderBox? child,
  }) : // The setters drop the cached mask image, so the fields stay private
       // and the parameters cannot initialize them directly.
       // ignore: prefer_initializing_formals
       _mask = mask,
       // ignore: prefer_initializing_formals
       _devicePixelRatio = devicePixelRatio,
       super(child);

  /// The longest side, in pixels, a mask image is rendered at.
  ///
  /// A mask is a smooth shape, so an image of this size stays sharp on any
  /// screen while a layer zoomed far past it costs no more memory.
  static const double maxImageSide = 2048;

  LayerMask? _mask;

  /// The mask the child shows through, or `null` for none.
  LayerMask? get mask => _mask;
  set mask(LayerMask? value) {
    if (value == _mask) return;
    final hadMask = _mask != null;
    _mask = value;
    _disposeImage();
    if (hadMask != (value != null)) markNeedsCompositingBitsUpdate();
    markNeedsPaint();
  }

  double _devicePixelRatio;

  /// The device pixel ratio the mask image is sized for.
  double get devicePixelRatio => _devicePixelRatio;
  set devicePixelRatio(double value) {
    if (value == _devicePixelRatio) return;
    _devicePixelRatio = value;
    markNeedsPaint();
  }

  ui.Image? _image;
  Size _imageSize = Size.zero;
  double _imagePixelRatio = 0;

  @override
  bool get alwaysNeedsCompositing => child != null && _mask != null;

  /// How many image pixels one logical pixel of this box needs: the screen's
  /// pixel ratio times how much the box is scaled on the way to the screen.
  double _neededPixelRatio() {
    var scale = 1.0;
    if (attached) {
      final transform = getTransformTo(null);
      final scaleX = math.sqrt(
        transform.entry(0, 0) * transform.entry(0, 0) +
            transform.entry(1, 0) * transform.entry(1, 0),
      );
      final scaleY = math.sqrt(
        transform.entry(0, 1) * transform.entry(0, 1) +
            transform.entry(1, 1) * transform.entry(1, 1),
      );
      final axisScale = math.max(scaleX, scaleY);
      if (axisScale.isFinite && axisScale > 0) scale = axisScale;
    }
    final ratio = _devicePixelRatio * scale;
    final longest = size.longestSide;
    if (longest <= 0) return ratio;
    return math.min(ratio, maxImageSide / longest);
  }

  ui.Image _maskImage(LayerMask mask) {
    final needed = _neededPixelRatio();
    final image = _image;
    // Reused while it is large enough, and while it is not wastefully large
    // for a box that has since been scaled down a lot.
    if (image != null &&
        _imageSize == size &&
        _imagePixelRatio >= needed &&
        _imagePixelRatio <= needed * 2) {
      return image;
    }
    _disposeImage();
    final created = mask.toImageSync(size, pixelRatio: needed);
    _image = created;
    _imageSize = size;
    _imagePixelRatio = needed;
    return created;
  }

  void _disposeImage() {
    _image?.dispose();
    _image = null;
    _imageSize = Size.zero;
    _imagePixelRatio = 0;
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    final mask = _mask;
    if (child == null || mask == null || size.isEmpty) {
      layer = null;
      super.paint(context, offset);
      return;
    }

    final image = _maskImage(mask);
    final shader = ui.ImageShader(
      image,
      TileMode.clamp,
      TileMode.clamp,
      Matrix4.diagonal3Values(
        size.width / image.width,
        size.height / image.height,
        1,
      ).storage,
      filterQuality: FilterQuality.medium,
    );
    final maskLayer = ((layer as ShaderMaskLayer?) ?? ShaderMaskLayer())
      ..shader = shader
      ..maskRect = offset & size
      ..blendMode = BlendMode.dstIn;
    layer = maskLayer;
    context.pushLayer(maskLayer, super.paint, offset);
  }

  @override
  void dispose() {
    _disposeImage();
    super.dispose();
  }
}
