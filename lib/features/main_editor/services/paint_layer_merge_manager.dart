import 'dart:math';

import 'package:flutter/widgets.dart';

import '/core/models/layers/layer.dart';
import '/features/paint_editor/models/eraser_model.dart';
import '/features/paint_editor/models/painted_model.dart';

/// Pure geometry helpers for merging several [PaintLayer]s into one.
///
/// The merge bakes every source layer's transform (offset, scale, rotation,
/// flipX/flipY and layer opacity) into a shared coordinate frame so the result
/// is a single [PaintLayer] with an identity transform (`scale = 1`,
/// `rotation = 0`, no flip, `opacity = 1`) whose strokes render pixel-identical
/// to the originals.
class PaintLayerMergeManager {
  const PaintLayerMergeManager._();

  /// Whether [layer] can take part in a merge.
  ///
  /// A censor layer is excluded because its blur/pixelate effect cannot be
  /// baked into a shared frame. A layer that carries video-timeline scheduling
  /// ([Layer.startTime] / [Layer.endTime]) or [Layer.animations] is excluded
  /// too, because a single static merged layer cannot reproduce a per-source
  /// appearance that changes over the timeline.
  static bool isMergeable(PaintLayer layer) {
    return !layer.isCensor &&
        layer.startTime == null &&
        layer.endTime == null &&
        layer.animations.isEmpty;
  }

  /// Returns the mergeable paint layers contained in [layers], preserving their
  /// original order (bottom-most first). See [isMergeable] for the criteria.
  static List<PaintLayer> mergeableLayers(Iterable<Layer> layers) {
    return layers.whereType<PaintLayer>().where(isMergeable).toList();
  }

  /// Whether [layers] contains at least two mergeable paint layers that can be
  /// merged into one.
  static bool canMerge(Iterable<Layer> layers) {
    return mergeableLayers(layers).length >= 2;
  }

  /// Merges [layers] (given in z-order, bottom-most first) into a single
  /// [PaintLayer].
  ///
  /// Each source stroke is mapped from its layer-local space through the
  /// layer's scale, rotation, flip and world center into a shared world frame
  /// (relative to the editor body center). The union bounding rect of all
  /// transformed strokes becomes the merged [PaintLayer.rawSize]; every point
  /// is re-normalized relative to that rect's top-left and the merged layer is
  /// given an identity transform. Per-stroke color, mode, fill and the baked
  /// stroke width / opacity / erased offsets are preserved so the appearance is
  /// unchanged.
  ///
  /// The merged layer inherits `groupId`, `interaction` and `meta` from the
  /// top-most source (the last entry of [layers]), matching the z-index it is
  /// re-inserted at.
  ///
  /// The geometry assumes every source uses the default center layer alignment
  /// (`paintEditor.layerFractionalOffset == Offset(-0.5, -0.5)`), i.e. that a
  /// layer's `offset` marks its visual center.
  ///
  /// Appearance is preserved for the merged strokes themselves, but stacking
  /// order relative to *other, non-merged* layers is not: because the merged
  /// layer occupies a single z-index (the top-most source's), any unselected
  /// layer that previously sat between two sources ends up entirely below the
  /// merged result.
  static PaintLayer merge(List<PaintLayer> layers) {
    assert(
      layers.length >= 2,
      'merge requires at least two layers, got ${layers.length}.',
    );

    final List<_TransformedStroke> strokes = [];

    double minX = double.infinity;
    double minY = double.infinity;
    double maxX = double.negativeInfinity;
    double maxY = double.negativeInfinity;

    for (final layer in layers) {
      final Offset center = Offset(
        layer.rawSize.width / 2,
        layer.rawSize.height / 2,
      );
      final double cosR = cos(layer.rotation);
      final double sinR = sin(layer.rotation);
      final double fx = layer.flipX ? -1.0 : 1.0;
      final double fy = layer.flipY ? -1.0 : 1.0;

      // Maps a layer-local point (top-left based, unscaled) into the shared
      // world frame relative to the editor body center. Mirrors the render
      // transform `Rx(flipY)·Ry(flipX)·Rz(rotation)` applied around the layer
      // center with the layer scale baked into the CustomPaint.
      Offset transform(Offset point) {
        final Offset c = (point - center) * layer.scale;
        final double rx = c.dx * cosR - c.dy * sinR;
        final double ry = c.dx * sinR + c.dy * cosR;
        return layer.offset + Offset(fx * rx, fy * ry);
      }

      for (final item in layer.items) {
        final List<Offset?> worldOffsets = item.offsets
            .map((o) => o == null ? null : transform(o))
            .toList();

        final List<ErasedOffset> worldErased = item.erasedOffsets
            .map(
              (e) => ErasedOffset(
                offset: transform(e.offset),
                radius: e.radius * layer.scale,
              ),
            )
            .toList();

        // Stroked shapes bleed half their stroke width past their points;
        // filled shapes and censor areas do not. Padding the bounds keeps the
        // stroke from being clipped by the merged raw size.
        final double halfStroke = item.shouldFill
            ? 0
            : item.strokeWidth * layer.scale / 2;

        for (final o in worldOffsets) {
          if (o == null) continue;
          minX = min(minX, o.dx - halfStroke);
          minY = min(minY, o.dy - halfStroke);
          maxX = max(maxX, o.dx + halfStroke);
          maxY = max(maxY, o.dy + halfStroke);
        }

        strokes.add(
          _TransformedStroke(
            source: item,
            offsets: worldOffsets,
            erasedOffsets: worldErased,
            // Bake the source scale into the stroke width so it renders the
            // same on the identity-scaled merged layer.
            strokeWidth: item.strokeWidth * layer.scale,
            // Effective on-screen opacity of this stroke. A single-stroke
            // source renders with the layer opacity only (the per-item opacity
            // is ignored on the single-item render fast path); an already
            // merged multi-stroke source renders each stroke with its own
            // opacity beneath the layer opacity. Bake the product so the merged
            // layer, which renders every stroke with its own opacity, matches.
            opacity:
                layer.opacity * (layer.items.length > 1 ? item.opacity : 1.0),
          ),
        );
      }
    }

    // Guard against degenerate input (e.g. strokes without any offsets).
    if (minX > maxX || minY > maxY) {
      minX = minY = maxX = maxY = 0;
    }

    final Rect rect = Rect.fromLTRB(minX, minY, maxX, maxY);
    final Offset topLeft = rect.topLeft;

    final List<PaintedModel> mergedItems = strokes.map((stroke) {
      return stroke.source.copyWith(
        offsets: stroke.offsets
            .map((o) => o == null ? null : o - topLeft)
            .toList(),
        erasedOffsets: stroke.erasedOffsets
            .map(
              (e) => ErasedOffset(offset: e.offset - topLeft, radius: e.radius),
            )
            .toList(),
        strokeWidth: stroke.strokeWidth,
        opacity: stroke.opacity,
        hit: false,
      );
    }).toList();

    // The merged layer takes the top-most source's z-index, so it inherits
    // that source's grouping, interaction and metadata.
    final PaintLayer topMost = layers.last;

    return PaintLayer(
      items: mergedItems,
      rawSize: rect.size,
      opacity: 1.0,
      offset: rect.center,
      scale: 1.0,
      rotation: 0.0,
      flipX: false,
      flipY: false,
      groupId: topMost.groupId,
      interaction: topMost.interaction.copyWith(),
      meta: topMost.meta == null
          ? null
          : Map<String, dynamic>.of(topMost.meta!),
    );
  }
}

/// A source stroke already mapped into the shared world frame, kept until the
/// merged bounding rect is known so its points can be normalized in one pass.
class _TransformedStroke {
  _TransformedStroke({
    required this.source,
    required this.offsets,
    required this.erasedOffsets,
    required this.strokeWidth,
    required this.opacity,
  });

  final PaintedModel source;
  final List<Offset?> offsets;
  final List<ErasedOffset> erasedOffsets;
  final double strokeWidth;
  final double opacity;
}
