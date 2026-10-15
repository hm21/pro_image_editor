import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart' show immutable;
import 'package:flutter/painting.dart';
import 'package:flutter/widgets.dart' show Matrix4;

import 'layer.dart';

/// The shape a [LayerMask] lets its layer show through.
enum LayerMaskShape {
  /// An ellipse filling the mask's box; a circle when that box is square.
  ellipse,

  /// A rectangle filling the mask's box, its corners rounded by
  /// [LayerMask.cornerRadius].
  rectangle,

  /// A heart filling the mask's box, its tip at the bottom while unturned.
  heart,

  /// A straight edge through [LayerMask.center], turned by
  /// [LayerMask.rotation].
  ///
  /// The layer shows on one side of it: above the edge while it is unturned.
  /// [LayerMask.size] does not apply; [LayerMask.feather] turns the edge into
  /// a gradient that fades the layer out.
  linear,
}

/// Shows a [Layer] only inside a shape, or fades it out through a soft edge.
///
/// Everything is measured in fractions of the layer's own box — the content
/// before the layer's [Layer.scale], [Layer.rotation] and flips — so the mask
/// moves, grows and turns with the layer, and the same mask fits the layer
/// however large it is drawn.
///
/// The mask decides how much of the layer shows at every point: fully inside
/// the shape, not at all outside, and partly across a [feather]ed edge.
/// [invert] swaps inside and outside. On the canvas it is applied by
/// `LayerWidget`, and [Layer.captureAsPng] bakes it into the captured image.
@immutable
class LayerMask {
  /// Creates a [LayerMask].
  const LayerMask({
    required this.shape,
    this.center = const Offset(0.5, 0.5),
    this.size = const Size(0.5, 0.5),
    this.rotation = 0,
    this.feather = 0,
    this.cornerRadius = 0,
    this.invert = false,
  }) : assert(feather >= 0, '[feather] must not be negative'),
       assert(
         cornerRadius >= 0 && cornerRadius <= 1,
         '[cornerRadius] must be between 0 and 1',
       );

  /// Creates a [LayerMask] from a map written by [toMap].
  ///
  /// A shape this version does not know falls back to
  /// [LayerMaskShape.ellipse], so a layer saved by a newer version still shows
  /// inside a shape rather than failing to load.
  factory LayerMask.fromMap(Map<String, dynamic> map) {
    final shapeName = map['shape'];
    return LayerMask(
      shape: LayerMaskShape.values.firstWhere(
        (shape) => shape.name == shapeName,
        orElse: () => LayerMaskShape.ellipse,
      ),
      center: Offset(
        (map['x'] as num?)?.toDouble() ?? 0.5,
        (map['y'] as num?)?.toDouble() ?? 0.5,
      ),
      size: Size(
        (map['width'] as num?)?.toDouble() ?? 0.5,
        (map['height'] as num?)?.toDouble() ?? 0.5,
      ),
      rotation: (map['rotation'] as num?)?.toDouble() ?? 0,
      feather: math.max(0, (map['feather'] as num?)?.toDouble() ?? 0),
      cornerRadius: ((map['cornerRadius'] as num?)?.toDouble() ?? 0).clamp(
        0.0,
        1.0,
      ),
      invert: map['invert'] == true,
    );
  }

  /// The shape the layer shows through.
  final LayerMaskShape shape;

  /// The centre of the shape, in fractions of the layer's box: `(0, 0)` is its
  /// top-left corner and `(1, 1)` its bottom-right one.
  final Offset center;

  /// The size of the shape's box before it is turned, in fractions of the
  /// layer's box: `Size(1, 1)` is as large as the layer.
  ///
  /// Not used by [LayerMaskShape.linear].
  final Size size;

  /// How far the shape is turned around [center], clockwise, in radians.
  final double rotation;

  /// How soft the edge is, in fractions of the shorter side of the layer's
  /// box.
  ///
  /// The layer fades from fully shown to hidden over about this distance,
  /// across the edge. `0` is a hard edge.
  final double feather;

  /// How round the corners of a [LayerMaskShape.rectangle] are, from `0`
  /// (square) to `1` (a radius of half the shorter side of its box).
  final double cornerRadius;

  /// Whether the layer shows outside the shape instead of inside it.
  final bool invert;

  /// The Material Design heart (24 dp `favorite` icon), fitted to a unit box.
  static Path _unitHeart() => Path()
    ..moveTo(0.5, 1)
    ..lineTo(0.4275, 0.92807)
    ..cubicTo(0.17, 0.67357, 0, 0.50572, 0, 0.29973)
    ..cubicTo(0, 0.13188, 0.121, 0, 0.275, 0)
    ..cubicTo(0.362, 0, 0.4455, 0.04414, 0.5, 0.1139)
    ..cubicTo(0.5545, 0.04414, 0.638, 0, 0.725, 0)
    ..cubicTo(0.879, 0, 1, 0.13188, 1, 0.29973)
    ..cubicTo(1, 0.50572, 0.83, 0.67357, 0.5725, 0.92861)
    ..close();

  /// The box [size] describes on a layer of [layerSize], centred on [center]
  /// and not yet turned.
  Rect shapeRect(Size layerSize) {
    return Rect.fromCenter(
      center: Offset(center.dx * layerSize.width, center.dy * layerSize.height),
      width: size.width * layerSize.width,
      height: size.height * layerSize.height,
    );
  }

  /// The point on a layer of [layerSize] the shape is centred on and turns
  /// around.
  Offset _pivot(Size layerSize) =>
      Offset(center.dx * layerSize.width, center.dy * layerSize.height);

  /// Turns by [rotation] around [pivot].
  Matrix4 _turn(Offset pivot) => Matrix4.identity()
    ..translateByDouble(pivot.dx, pivot.dy, 0, 1)
    ..rotateZ(rotation)
    ..translateByDouble(-pivot.dx, -pivot.dy, 0, 1);

  /// How far a linear edge reaches from [pivot] on either side: to the
  /// farthest corner of a layer of [layerSize], so it crosses the whole layer
  /// even when [center] lies outside it.
  static double _reach(Size layerSize, Offset pivot) {
    final bounds = Offset.zero & layerSize;
    return [
      bounds.topLeft,
      bounds.topRight,
      bounds.bottomLeft,
      bounds.bottomRight,
    ].map((corner) => (corner - pivot).distance).reduce(math.max);
  }

  /// The outline of the shape on a layer of [layerSize], turned by
  /// [rotation], in the layer's own coordinates.
  ///
  /// For [LayerMaskShape.linear] this is the edge itself: a line through
  /// [center] that crosses the whole layer. Useful to draw the mask while it
  /// is edited.
  Path outline(Size layerSize) {
    final pivot = _pivot(layerSize);
    final turn = _turn(pivot);

    if (shape == LayerMaskShape.linear) {
      final reach = _reach(layerSize, pivot);
      return (Path()
            ..moveTo(pivot.dx - reach, pivot.dy)
            ..lineTo(pivot.dx + reach, pivot.dy))
          .transform(turn.storage);
    }
    return _shapePath(shapeRect(layerSize)).transform(turn.storage);
  }

  /// The part of a layer of [layerSize] the mask shows, in the layer's own
  /// coordinates, with its edge taken as hard whatever [feather] is.
  ///
  /// With [feather] `0` this is exactly what [paint] fills. `LayerMaskBox`
  /// clips a hard-edged mask to it, so the edge stays sharp however large
  /// the layer is drawn or captured.
  Path area(Size layerSize) {
    final pivot = _pivot(layerSize);
    final Path shown;
    if (shape == LayerMaskShape.linear) {
      final reach = _reach(layerSize, pivot);
      shown = Path()
        ..addRect(
          Rect.fromLTRB(
            pivot.dx - reach,
            pivot.dy - reach,
            pivot.dx + reach,
            pivot.dy,
          ),
        );
    } else {
      shown = _shapePath(shapeRect(layerSize));
    }
    return Path.combine(
      invert ? PathOperation.difference : PathOperation.intersect,
      Path()..addRect(Offset.zero & layerSize),
      shown.transform(_turn(pivot).storage),
    );
  }

  Path _shapePath(Rect rect) {
    switch (shape) {
      case LayerMaskShape.ellipse:
        return Path()..addOval(rect);
      case LayerMaskShape.rectangle:
        final radius = cornerRadius * rect.shortestSide / 2;
        return Path()
          ..addRRect(RRect.fromRectAndRadius(rect, Radius.circular(radius)));
      case LayerMaskShape.heart:
        final scale = Matrix4.identity()
          ..translateByDouble(rect.left, rect.top, 0, 1)
          ..scaleByDouble(rect.width, rect.height, 1, 1);
        return _unitHeart().transform(scale.storage);
      case LayerMaskShape.linear:
        return Path()..addRect(rect);
    }
  }

  /// Paints the mask over a layer of [layerSize] into [canvas], from its
  /// origin.
  ///
  /// Draws opaque white where the layer shows and leaves the rest
  /// transparent, with partly transparent white across a [feather]ed edge.
  /// Composite it over the layer's content with [BlendMode.dstIn] to apply
  /// it; only its alpha matters.
  void paint(Canvas canvas, Size layerSize) {
    if (layerSize.isEmpty) return;
    final featherPx = feather * layerSize.shortestSide;
    if (featherPx <= 0) {
      canvas.drawPath(
        area(layerSize),
        Paint()..color = const Color(0xFFFFFFFF),
      );
      return;
    }

    final bounds = Offset.zero & layerSize;
    final pivot = _pivot(layerSize);
    canvas
      ..save()
      ..clipRect(bounds);

    if (shape == LayerMaskShape.linear) {
      const shown = Color(0xFFFFFFFF);
      const hidden = Color(0x00FFFFFF);
      final reach = _reach(layerSize, pivot);
      canvas
        ..translate(pivot.dx, pivot.dy)
        ..rotate(rotation)
        ..drawRect(
          Rect.fromLTRB(-reach, -reach, reach, reach),
          Paint()
            ..shader = ui.Gradient.linear(
              Offset(0, -featherPx / 2),
              Offset(0, featherPx / 2),
              invert ? const [hidden, shown] : const [shown, hidden],
            ),
        )
        ..restore();
      return;
    }

    // A Gaussian edge goes from about 10 % to 90 % over 2.56 sigma, which is
    // the distance [feather] promises.
    final shapePaint = Paint()
      ..color = const Color(0xFFFFFFFF)
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, featherPx / 2.56);

    if (invert) {
      canvas
        ..saveLayer(bounds, Paint())
        ..drawRect(bounds, Paint()..color = const Color(0xFFFFFFFF));
      shapePaint.blendMode = BlendMode.dstOut;
    }
    canvas
      ..translate(pivot.dx, pivot.dy)
      ..rotate(rotation)
      ..translate(-pivot.dx, -pivot.dy)
      ..drawPath(_shapePath(shapeRect(layerSize)), shapePaint);
    if (invert) canvas.restore();
    canvas.restore();
  }

  /// The whole pixels an image of a layer of [layerSize] at [pixelRatio]
  /// takes.
  static Size _pixelSize(Size layerSize, double pixelRatio) => Size(
    math.max(1, (layerSize.width * pixelRatio).ceil()).toDouble(),
    math.max(1, (layerSize.height * pixelRatio).ceil()).toDouble(),
  );

  /// Records the mask over an image of [pixels].
  ///
  /// Painted at the image's own size rather than scaled by the pixel ratio:
  /// the size is rounded up to whole pixels, and a mask scaled into it would
  /// leave the last row and column half covered. Over a layer that shows as
  /// a thin line of the layer along the edge of an inverted mask, and as a
  /// faint line of video under a timeline clip's cover. Every measure of the
  /// mask is a fraction of the layer, so painting at the image's size draws
  /// the same shape.
  ui.Picture _record(Size pixels) {
    final recorder = ui.PictureRecorder();
    paint(Canvas(recorder), pixels);
    return recorder.endRecording();
  }

  /// Renders the mask over a layer of [layerSize] into an image of
  /// `layerSize * pixelRatio` pixels, rounded up; see [paint] for what it
  /// holds. The mask fills the image exactly, edge pixels included.
  ///
  /// A video renderer can stretch the image over the layer as an alpha
  /// matte.
  Future<ui.Image> toImage(Size layerSize, {double pixelRatio = 1}) async {
    final pixels = _pixelSize(layerSize, pixelRatio);
    final picture = _record(pixels);
    try {
      return await picture.toImage(pixels.width.toInt(), pixels.height.toInt());
    } finally {
      picture.dispose();
    }
  }

  /// Renders the mask like [toImage], synchronously.
  ui.Image toImageSync(Size layerSize, {double pixelRatio = 1}) {
    final pixels = _pixelSize(layerSize, pixelRatio);
    final picture = _record(pixels);
    try {
      return picture.toImageSync(pixels.width.toInt(), pixels.height.toInt());
    } finally {
      picture.dispose();
    }
  }

  /// [image] with this mask applied, as a new image of the same size.
  ///
  /// [image] is taken to show the whole layer, so the mask is stretched over
  /// it.
  Future<ui.Image> applyTo(ui.Image image) async {
    final size = Size(image.width.toDouble(), image.height.toDouble());
    final bounds = Offset.zero & size;
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder, bounds)
      ..saveLayer(bounds, Paint())
      ..drawImage(image, Offset.zero, Paint())
      ..saveLayer(bounds, Paint()..blendMode = BlendMode.dstIn);
    paint(canvas, size);
    canvas
      ..restore()
      ..restore();
    final picture = recorder.endRecording();
    try {
      return await picture.toImage(image.width, image.height);
    } finally {
      picture.dispose();
    }
  }

  /// Converts the mask to a map, readable by [LayerMask.fromMap].
  Map<String, dynamic> toMap() => <String, dynamic>{
    'shape': shape.name,
    'x': center.dx,
    'y': center.dy,
    'width': size.width,
    'height': size.height,
    'rotation': rotation,
    'feather': feather,
    'cornerRadius': cornerRadius,
    'invert': invert,
  };

  /// Creates a copy with the given fields replaced.
  LayerMask copyWith({
    LayerMaskShape? shape,
    Offset? center,
    Size? size,
    double? rotation,
    double? feather,
    double? cornerRadius,
    bool? invert,
  }) {
    return LayerMask(
      shape: shape ?? this.shape,
      center: center ?? this.center,
      size: size ?? this.size,
      rotation: rotation ?? this.rotation,
      feather: feather ?? this.feather,
      cornerRadius: cornerRadius ?? this.cornerRadius,
      invert: invert ?? this.invert,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is LayerMask &&
        other.shape == shape &&
        other.center == center &&
        other.size == size &&
        other.rotation == rotation &&
        other.feather == feather &&
        other.cornerRadius == cornerRadius &&
        other.invert == invert;
  }

  @override
  int get hashCode =>
      Object.hash(shape, center, size, rotation, feather, cornerRadius, invert);

  @override
  String toString() =>
      'LayerMask(shape: ${shape.name}, center: $center, size: $size, '
      'rotation: $rotation, feather: $feather, cornerRadius: $cornerRadius, '
      'invert: $invert)';
}
