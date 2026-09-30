import 'dart:math';

import 'package:material_ui/material_ui.dart';

import '/core/models/layers/layer.dart';
import '/features/crop_rotate_editor/models/transform_configs.dart';
import '/shared/widgets/transform/transformed_content_generator.dart';

/// Where the image sits under the layers of the main editor.
///
/// Layer offsets are distances from the center of the editor body. This maps
/// them to a point on the image, given as a fraction of the image size from
/// its center, and back. It follows the transforms that
/// [TransformedContentGenerator] paints the background with, so a layer that
/// is mapped to the image under one crop or body size and back under another
/// stays on the same pixel.
class ImageLayerFrame {
  const ImageLayerFrame._({
    required this.box,
    required this.scale,
    required this.pan,
    required this.angle,
    required this.flipX,
    required this.flipY,
  });

  /// Frame of the image painted with [transform] in [bodySize].
  ///
  /// [renderedImageSize] is the uncropped image fitted to [bodySize]. It is
  /// the painted size when [transform] is empty.
  ///
  /// Returns null for a tilted transform, whose perspective is not linear,
  /// and for sizes that paint no image.
  static ImageLayerFrame? of({
    required TransformConfigs transform,
    required Size bodySize,
    required Size renderedImageSize,
  }) {
    if (bodySize.isEmpty) return null;
    if (transform.isEmpty) {
      if (renderedImageSize.isEmpty) return null;
      return ImageLayerFrame._(
        box: renderedImageSize,
        scale: _containScale(renderedImageSize, bodySize),
        pan: Offset.zero,
        angle: 0,
        flipX: false,
        flipY: false,
      );
    }
    if (transform.isTilted) return null;
    final box = transform.originalSize;
    if (!box.isFinite || box.isEmpty) return null;
    final scale =
        _containScale(box, bodySize) *
        TransformedContentGenerator.fitFactor(transform, bodySize) *
        transform.scaleUser;
    if (!scale.isFinite || scale <= 0) return null;

    return ImageLayerFrame._(
      box: box,
      scale: scale,
      pan: transform.offset,
      angle: transform.angle,
      flipX: transform.flipX,
      flipY: transform.flipY,
    );
  }

  /// Places each of [targets] on the image point the matching [sources]
  /// layer covers in [bodySize] under [from], now that the image is painted
  /// with [to].
  ///
  /// [renderedImageSize] is the uncropped image fitted to [bodySize]. Leaves
  /// [targets] as they are when either transform is tilted.
  static void keepLayersOnImagePoint({
    required List<Layer> sources,
    required List<Layer> targets,
    required TransformConfigs from,
    required TransformConfigs to,
    required Size bodySize,
    required Size renderedImageSize,
  }) {
    final fromFrame = of(
      transform: from,
      bodySize: bodySize,
      renderedImageSize: renderedImageSize,
    );
    final toFrame = of(
      transform: to,
      bodySize: bodySize,
      renderedImageSize: renderedImageSize,
    );
    if (fromFrame == null || toFrame == null) return;

    for (var i = 0; i < targets.length && i < sources.length; i++) {
      fromFrame.moveLayer(sources[i], toFrame, target: targets[i]);
    }
  }

  /// Size of the uncropped image box before scaling.
  final Size box;

  /// Combined fit, crop fit and user zoom applied to [box].
  final double scale;

  /// Crop pan, in [box] units.
  final Offset pan;

  /// Rotation of the image.
  final double angle;

  /// Horizontal flip of the image.
  final bool flipX;

  /// Vertical flip of the image.
  final bool flipY;

  /// Layer pixels per image width. Layers scale by the ratio of this value
  /// between two frames.
  double get pixelsPerImageWidth => scale * box.width;

  /// Point on the image, as a fraction of its size from its center, under
  /// [layerOffset].
  Offset toImage(Offset layerOffset) {
    var v = _rotate(layerOffset / scale, -angle);
    v = _flip(v);
    v -= pan;
    return Offset(v.dx / box.width, v.dy / box.height);
  }

  /// Layer offset over [imagePoint], a fraction of the image size from its
  /// center.
  Offset toLayer(Offset imagePoint) {
    var v = Offset(imagePoint.dx * box.width, imagePoint.dy * box.height);
    v += pan;
    v = _flip(v);
    return _rotate(v, angle) * scale;
  }

  /// Places [target], or [source] itself, on the image point [source] covers
  /// in this frame, painted as [to].
  ///
  /// Only the offset, the scale and the slide distance of its animations
  /// change. Rotation and flips are left to the caller.
  void moveLayer(Layer source, ImageLayerFrame to, {Layer? target}) {
    final ratio = to.pixelsPerImageWidth / pixelsPerImageWidth;
    (target ?? source)
      ..offset = to.toLayer(toImage(source.offset))
      ..scale = source.scale * ratio
      ..scaleSlideFrom(ratio, ratio);
  }

  Offset _flip(Offset v) => Offset(flipX ? -v.dx : v.dx, flipY ? -v.dy : v.dy);

  static Offset _rotate(Offset v, double radians) {
    if (radians == 0) return v;
    final c = cos(radians);
    final s = sin(radians);
    return Offset(v.dx * c - v.dy * s, v.dx * s + v.dy * c);
  }

  static double _containScale(Size child, Size parent) =>
      min(parent.width / child.width, parent.height / child.height);
}
