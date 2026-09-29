import 'dart:math';

import 'package:material_ui/material_ui.dart';

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
  /// Returns null for a tilted transform, whose perspective is not linear.
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

    return ImageLayerFrame._(
      box: box,
      scale:
          _containScale(box, bodySize) *
          TransformedContentGenerator.fitFactor(transform, bodySize) *
          transform.scaleUser,
      pan: transform.offset,
      angle: transform.angle,
      flipX: transform.flipX,
      flipY: transform.flipY,
    );
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
