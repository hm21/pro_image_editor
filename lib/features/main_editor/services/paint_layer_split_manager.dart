import 'dart:math';

import 'package:flutter/widgets.dart';

import '/core/models/layers/layer.dart';
import '/features/paint_editor/models/eraser_model.dart';
import '/features/paint_editor/models/painted_model.dart';
import 'paint_layer_merge_manager.dart';

/// Pure geometry helpers for splitting a multi-stroke [PaintLayer] into one
/// layer per stroke, the inverse of [PaintLayerMergeManager.merge].
///
/// Every part keeps the source's scale, rotation and flip. Its points are
/// re-normalized to the stroke's own bounds and its offset moves to where that
/// box's center sits on the canvas, so each stroke renders exactly where and
/// how it rendered inside the source.
class PaintLayerSplitManager {
  const PaintLayerSplitManager._();

  /// Whether [layer] can be split into one layer per stroke.
  ///
  /// It must be a [PaintLayer] holding more than one stroke that
  /// [PaintLayerMergeManager.isMergeable] accepts, so splitting and merging
  /// apply to the same layers. A layer with a timeline window, animations,
  /// keyframes, a mask or a blend mode applies them to the whole drawing at
  /// once: a scale or a draw-on animation, a keyframe path or a mask measured
  /// in the source's box cannot be handed to each part on its own without
  /// changing how the drawing looks.
  static bool canSplit(Layer layer) {
    return layer is PaintLayer &&
        layer.items.length > 1 &&
        PaintLayerMergeManager.isMergeable(layer);
  }

  /// Splits [layer] into one [PaintLayer] per stroke, in stroke order (the
  /// first stroke, drawn bottom-most, comes first).
  ///
  /// Each part's [PaintLayer.rawSize] is the bounding box of its stroke,
  /// padded by half the stroke width for stroked shapes the way a freshly
  /// drawn layer is, and never smaller than the stroke width. The part takes
  /// the source's `groupId`, `interaction` and `meta`.
  ///
  /// A merged layer stacks its strokes beneath the layer opacity, each with
  /// its own opacity, while a single-stroke layer draws with the layer opacity
  /// alone. A part therefore carries the product of both, in the layer and in
  /// its stroke, as a freshly drawn stroke does.
  ///
  /// The geometry assumes the default center layer alignment
  /// (`paintEditor.layerFractionalOffset == Offset(-0.5, -0.5)`), i.e. that a
  /// layer's `offset` marks its visual center, as
  /// [PaintLayerMergeManager.merge] does.
  static List<PaintLayer> split(PaintLayer layer) {
    return [for (final item in layer.items) _partOf(layer, item)];
  }

  static PaintLayer _partOf(PaintLayer layer, PaintedModel item) {
    final Offset center = Offset(
      layer.rawSize.width / 2,
      layer.rawSize.height / 2,
    );
    final double halfStroke = item.shouldFill ? 0 : item.strokeWidth / 2;

    double minX = double.infinity;
    double minY = double.infinity;
    double maxX = double.negativeInfinity;
    double maxY = double.negativeInfinity;
    for (final o in item.offsets) {
      if (o == null) continue;
      minX = min(minX, o.dx - halfStroke);
      minY = min(minY, o.dy - halfStroke);
      maxX = max(maxX, o.dx + halfStroke);
      maxY = max(maxY, o.dy + halfStroke);
    }
    // A stroke without points keeps a box at the source's center.
    if (minX > maxX || minY > maxY) {
      minX = maxX = center.dx;
      minY = maxY = center.dy;
    }

    final Rect bounds = Rect.fromLTRB(minX, minY, maxX, maxY);
    final Rect box = Rect.fromCenter(
      center: bounds.center,
      width: max(bounds.width, item.strokeWidth),
      height: max(bounds.height, item.strokeWidth),
    );
    final Offset topLeft = box.topLeft;
    final double opacity =
        layer.opacity * (layer.items.length > 1 ? item.opacity : 1.0);

    // The box center, mapped from layer-local space onto the canvas (relative
    // to the editor body center) through the transform
    // [PaintLayerMergeManager.merge] applies. The part keeps that transform, so
    // every point of the stroke lands where it did inside the source.
    final Offset c = (box.center - center) * layer.scale;
    final double cosR = cos(layer.rotation);
    final double sinR = sin(layer.rotation);
    final double fx = layer.flipX ? -1.0 : 1.0;
    final double fy = layer.flipY ? -1.0 : 1.0;
    final Offset offset =
        layer.offset +
        Offset(
          fx * (c.dx * cosR - c.dy * sinR),
          fy * (c.dx * sinR + c.dy * cosR),
        );

    return PaintLayer(
      item: item.copyWith(
        offsets: [for (final o in item.offsets) o == null ? null : o - topLeft],
        erasedOffsets: [
          for (final e in item.erasedOffsets)
            ErasedOffset(offset: e.offset - topLeft, radius: e.radius),
        ],
        opacity: opacity,
        hit: false,
      ),
      rawSize: box.size,
      opacity: opacity,
      offset: offset,
      rotation: layer.rotation,
      scale: layer.scale,
      flipX: layer.flipX,
      flipY: layer.flipY,
      groupId: layer.groupId,
      interaction: layer.interaction.copyWith(),
      meta: layer.meta == null ? null : Map<String, dynamic>.of(layer.meta!),
    );
  }
}
