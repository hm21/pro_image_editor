// Dart imports:
import 'dart:math' as math;
import 'dart:ui' as ui;

// Flutter imports:
import 'package:flutter/foundation.dart' show ValueListenable;
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

import '/core/models/layers/layer_mask.dart';

/// Shows [child] through a [LayerMask]: only inside its shape, or fading out
/// across its soft edge.
///
/// The mask is stretched over the child's box. It applies to everything the
/// child paints, including a video [Texture] and other composited layers:
/// a hard edge is a path clip, a [LayerMask.feather]ed one a shader mask.
///
/// A mask with [LayerMask.keyframes] changes as [playTime] moves, read
/// [keyframeOrigin] after its start (see [LayerMask.at]). Without [playTime]
/// it shows as it is at its start.
///
/// With [mask] `null` the child paints as it is.
class LayerMaskBox extends SingleChildRenderObjectWidget {
  /// Creates a [LayerMaskBox].
  const LayerMaskBox({
    super.key,
    required this.mask,
    this.playTime,
    this.keyframeOrigin = Duration.zero,
    super.child,
  });

  /// The mask to show [child] through, or `null` to show all of it.
  final LayerMask? mask;

  /// The video position the [LayerMask.keyframes] of [mask] are read at, or
  /// `null` outside a video.
  final ValueListenable<Duration>? playTime;

  /// The video position the [LayerMask.keyframes] of [mask] are measured
  /// from, such as the masked layer's `Layer.keyframeOrigin`.
  final Duration keyframeOrigin;

  @override
  RenderLayerMaskBox createRenderObject(BuildContext context) {
    return RenderLayerMaskBox(
      mask: mask,
      playTime: playTime,
      keyframeOrigin: keyframeOrigin,
    );
  }

  @override
  void updateRenderObject(
    BuildContext context,
    RenderLayerMaskBox renderObject,
  ) {
    renderObject
      ..mask = mask
      ..playTime = playTime
      ..keyframeOrigin = keyframeOrigin;
  }
}

/// The render object of a [LayerMaskBox].
///
/// A hard-edged mask clips the child to [LayerMask.area], which stays sharp
/// at any resolution: when the editor is zoomed in, and when its image is
/// captured at a higher pixel ratio than the screen's.
///
/// A [LayerMask.feather]ed mask is rasterized once into an image as sharp as
/// the child is drawn on screen and reused until the mask, the box size or
/// the needed resolution changes. A soft edge stays smooth when that image
/// is scaled up for a capture.
///
/// A mask with keyframes is drawn as it is at [playTime], and repainted
/// whenever that changes what it shows; it is never rebuilt for it.
class RenderLayerMaskBox extends RenderProxyBox {
  /// Creates a [RenderLayerMaskBox].
  RenderLayerMaskBox({
    LayerMask? mask,
    ValueListenable<Duration>? playTime,
    Duration keyframeOrigin = Duration.zero,
    RenderBox? child,
  }) : // The setters drop the cached mask, so the fields stay private and the
       // parameters cannot initialize them directly.
       // ignore: prefer_initializing_formals
       _mask = mask,
       // ignore: prefer_initializing_formals
       _playTime = playTime,
       // ignore: prefer_initializing_formals
       _keyframeOrigin = keyframeOrigin,
       super(child) {
    _shown = _resolve();
  }

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
    _mask = value;
    _show(_resolve());
  }

  ValueListenable<Duration>? _playTime;

  /// The video position a [mask] with keyframes is drawn at.
  ValueListenable<Duration>? get playTime => _playTime;
  set playTime(ValueListenable<Duration>? value) {
    if (value == _playTime) return;
    if (attached) _playTime?.removeListener(_onPlayTimeChanged);
    _playTime = value;
    if (attached) _playTime?.addListener(_onPlayTimeChanged);
    _show(_resolve());
  }

  Duration _keyframeOrigin;

  /// The video position the keyframes of [mask] are measured from.
  Duration get keyframeOrigin => _keyframeOrigin;
  set keyframeOrigin(Duration value) {
    if (value == _keyframeOrigin) return;
    _keyframeOrigin = value;
    _show(_resolve());
  }

  /// The still mask drawn now: [mask] at [playTime].
  LayerMask? _shown;

  /// The still mask [mask] makes at [playTime].
  LayerMask? _resolve() {
    final mask = _mask;
    if (mask == null || !mask.hasKeyframes) return mask;
    final time = _playTime?.value;
    return mask.at(time == null ? Duration.zero : time - _keyframeOrigin);
  }

  /// Draws [shown] from the next frame on, if it differs from what shows.
  void _show(LayerMask? shown) {
    if (shown == _shown) return;
    final wasSoft = _isSoft;
    _shown = shown;
    _disposeImage();
    _area = null;
    if (wasSoft != _isSoft) markNeedsCompositingBitsUpdate();
    markNeedsPaint();
  }

  void _onPlayTimeChanged() {
    if (_mask?.hasKeyframes ?? false) _show(_resolve());
  }

  @override
  void attach(PipelineOwner owner) {
    super.attach(owner);
    _playTime?.addListener(_onPlayTimeChanged);
    // The position may have moved while the box was detached.
    _show(_resolve());
  }

  @override
  void detach() {
    _playTime?.removeListener(_onPlayTimeChanged);
    super.detach();
  }

  /// Whether the mask has a soft edge and so is applied as a shader mask.
  bool get _isSoft => (_shown?.feather ?? 0) > 0;

  ui.Image? _image;
  Size _imageSize = Size.zero;
  double _imagePixelRatio = 0;

  Path? _area;
  Size _areaSize = Size.zero;

  @override
  bool get alwaysNeedsCompositing => child != null && _isSoft;

  /// The clip of a hard-edged [mask], kept while the box size does not
  /// change: combining paths on every frame of a drag is not free.
  Path _clipPath(LayerMask mask) {
    if (_area case final area? when _areaSize == size) return area;
    _areaSize = size;
    return _area = mask.area(size);
  }

  /// How many image pixels one logical pixel of this box needs: how much the
  /// box is scaled on the way to the screen's physical pixels.
  ///
  /// The transform to the root holds the screen's pixel ratio already, as
  /// the root view scales logical to physical pixels.
  double _neededPixelRatio() {
    var ratio = 1.0;
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
      if (axisScale.isFinite && axisScale > 0) ratio = axisScale;
    }
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
    final mask = _shown;
    if (child == null || mask == null || size.isEmpty) {
      layer = null;
      super.paint(context, offset);
      return;
    }

    if (!_isSoft) {
      final oldLayer = layer;
      layer = context.pushClipPath(
        needsCompositing,
        offset,
        Offset.zero & size,
        _clipPath(mask),
        super.paint,
        clipBehavior: Clip.antiAlias,
        oldLayer: oldLayer is ClipPathLayer ? oldLayer : null,
      );
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
    final oldLayer = layer;
    final maskLayer =
        (oldLayer is ShaderMaskLayer ? oldLayer : ShaderMaskLayer())
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
