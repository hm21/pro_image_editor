import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pro_image_editor/features/main_editor/services/paint_layer_merge_manager.dart';
import 'package:pro_image_editor/features/paint_editor/models/eraser_model.dart';
import 'package:pro_image_editor/pro_image_editor.dart';

/// Independent re-implementation of the render transform used to validate the
/// merge geometry. Maps a layer-local point (top-left based, unscaled) into the
/// shared world frame relative to the editor body center.
Offset _sourceWorld(PaintLayer layer, Offset point) {
  final center = Offset(layer.rawSize.width / 2, layer.rawSize.height / 2);
  final v = (point - center) * layer.scale;
  final cosR = cos(layer.rotation);
  final sinR = sin(layer.rotation);
  var rx = v.dx * cosR - v.dy * sinR;
  var ry = v.dx * sinR + v.dy * cosR;
  if (layer.flipX) rx = -rx;
  if (layer.flipY) ry = -ry;
  return layer.offset + Offset(rx, ry);
}

/// World position (relative to body center) of a point on the merged layer,
/// which always has an identity transform (scale 1, rotation 0, no flip).
Offset _mergedWorld(PaintLayer merged, Offset point) {
  final center = Offset(merged.rawSize.width / 2, merged.rawSize.height / 2);
  return merged.offset + (point - center);
}

void _expectOffsetClose(Offset a, Offset b, {double eps = 1e-6}) {
  expect(a.dx, closeTo(b.dx, eps), reason: 'dx of $a vs $b');
  expect(a.dy, closeTo(b.dy, eps), reason: 'dy of $a vs $b');
}

PaintLayer _paintLayer({
  required PaintMode mode,
  required List<Offset?> offsets,
  Offset offset = Offset.zero,
  double scale = 1,
  double rotation = 0,
  bool flipX = false,
  bool flipY = false,
  double opacity = 1,
  double strokeWidth = 4,
  List<ErasedOffset> erasedOffsets = const [],
  bool fill = false,
  required Size rawSize,
}) {
  return PaintLayer(
    item: PaintedModel(
      mode: mode,
      offsets: offsets,
      erasedOffsets: erasedOffsets,
      color: Colors.red,
      strokeWidth: strokeWidth,
      opacity: opacity,
      fill: fill,
    ),
    rawSize: rawSize,
    opacity: opacity,
    offset: offset,
    scale: scale,
    rotation: rotation,
    flipX: flipX,
    flipY: flipY,
  );
}

void main() {
  group('PaintLayerMergeManager.merge geometry', () {
    test('bakes each source transform so world positions are preserved', () {
      // A: identity.
      final layerA = _paintLayer(
        mode: PaintMode.freeStyle,
        offsets: const [Offset(0, 0), Offset(100, 100), null, Offset(100, 0)],
        rawSize: const Size(100, 100),
      );
      // B: horizontally flipped, shifted right.
      final layerB = _paintLayer(
        mode: PaintMode.freeStyle,
        offsets: const [Offset(0, 0), Offset(100, 100)],
        offset: const Offset(200, 0),
        flipX: true,
        rawSize: const Size(100, 100),
      );
      // C: rotated 90° and scaled 2x, shifted down.
      final layerC = _paintLayer(
        mode: PaintMode.freeStyle,
        offsets: const [Offset(100, 50), Offset(50, 50)],
        offset: const Offset(0, 300),
        scale: 2,
        rotation: pi / 2,
        rawSize: const Size(100, 100),
      );

      final sources = [layerA, layerB, layerC];
      final merged = PaintLayerMergeManager.merge(sources);

      // Sanity: a couple of hand-computed world positions validate the formula
      // itself (guards against a self-consistent but wrong transform).
      _expectOffsetClose(
        _sourceWorld(layerA, const Offset(0, 0)),
        const Offset(-50, -50),
      );
      _expectOffsetClose(
        _sourceWorld(layerB, const Offset(0, 0)),
        const Offset(250, -50),
      );
      _expectOffsetClose(
        _sourceWorld(layerC, const Offset(100, 50)),
        const Offset(0, 400),
      );

      // Every merged point must map to the same world position as its origin.
      var idx = 0;
      for (final src in sources) {
        for (final item in src.items) {
          final mergedItem = merged.items[idx++];
          expect(mergedItem.offsets.length, item.offsets.length);
          for (var i = 0; i < item.offsets.length; i++) {
            final p = item.offsets[i];
            final q = mergedItem.offsets[i];
            if (p == null) {
              expect(q, isNull);
              continue;
            }
            _expectOffsetClose(_mergedWorld(merged, q!), _sourceWorld(src, p));
          }
        }
      }
    });

    test('produces an identity-transform layer with all strokes', () {
      final merged = PaintLayerMergeManager.merge([
        _paintLayer(
          mode: PaintMode.freeStyle,
          offsets: const [Offset(0, 0), Offset(10, 10)],
          rawSize: const Size(10, 10),
        ),
        _paintLayer(
          mode: PaintMode.line,
          offsets: const [Offset(0, 0), Offset(10, 10)],
          offset: const Offset(50, 0),
          rawSize: const Size(10, 10),
        ),
      ]);

      expect(merged.items.length, 2);
      expect(merged.scale, 1.0);
      expect(merged.rotation, 0.0);
      expect(merged.flipX, isFalse);
      expect(merged.flipY, isFalse);
      expect(merged.opacity, 1.0);
    });

    test('bakes scale into stroke width and erased radius', () {
      final merged = PaintLayerMergeManager.merge([
        _paintLayer(
          mode: PaintMode.freeStyle,
          offsets: const [Offset(0, 0), Offset(10, 10)],
          strokeWidth: 4,
          scale: 3,
          erasedOffsets: const [ErasedOffset(offset: Offset(5, 5), radius: 8)],
          rawSize: const Size(10, 10),
        ),
        _paintLayer(
          mode: PaintMode.freeStyle,
          offsets: const [Offset(0, 0), Offset(10, 10)],
          offset: const Offset(80, 0),
          rawSize: const Size(10, 10),
        ),
      ]);

      // First stroke had scale 3 → width and radius are multiplied by 3.
      expect(merged.items.first.strokeWidth, closeTo(12, 1e-6));
      expect(merged.items.first.erasedOffsets.first.radius, closeTo(24, 1e-6));
    });

    test('preserves per-layer opacity on the merged strokes', () {
      final merged = PaintLayerMergeManager.merge([
        _paintLayer(
          mode: PaintMode.freeStyle,
          offsets: const [Offset(0, 0), Offset(10, 10)],
          opacity: 0.25,
          rawSize: const Size(10, 10),
        ),
        _paintLayer(
          mode: PaintMode.freeStyle,
          offsets: const [Offset(0, 0), Offset(10, 10)],
          offset: const Offset(80, 0),
          opacity: 0.75,
          rawSize: const Size(10, 10),
        ),
      ]);

      expect(merged.items[0].opacity, closeTo(0.25, 1e-6));
      expect(merged.items[1].opacity, closeTo(0.75, 1e-6));
    });

    test('flattens already-merged (multi-item) sources', () {
      final multi = PaintLayerMergeManager.merge([
        _paintLayer(
          mode: PaintMode.freeStyle,
          offsets: const [Offset(0, 0), Offset(10, 10)],
          rawSize: const Size(10, 10),
        ),
        _paintLayer(
          mode: PaintMode.freeStyle,
          offsets: const [Offset(0, 0), Offset(10, 10)],
          offset: const Offset(80, 0),
          rawSize: const Size(10, 10),
        ),
      ]);
      expect(multi.items.length, 2);

      final single = _paintLayer(
        mode: PaintMode.freeStyle,
        offsets: const [Offset(0, 0), Offset(10, 10)],
        offset: const Offset(0, 120),
        rawSize: const Size(10, 10),
      );

      final merged = PaintLayerMergeManager.merge([multi, single]);
      expect(merged.items.length, 3);
    });

    test('preserves per-stroke opacity when re-merging merged sources', () {
      // First merge: two strokes with distinct opacities become one layer that
      // renders each stroke with its own opacity (layer opacity 1).
      final multi = PaintLayerMergeManager.merge([
        _paintLayer(
          mode: PaintMode.freeStyle,
          offsets: const [Offset(0, 0), Offset(10, 10)],
          opacity: 0.25,
          rawSize: const Size(10, 10),
        ),
        _paintLayer(
          mode: PaintMode.freeStyle,
          offsets: const [Offset(0, 0), Offset(10, 10)],
          offset: const Offset(80, 0),
          opacity: 0.75,
          rawSize: const Size(10, 10),
        ),
      ]);
      expect(multi.opacity, 1.0);

      final single = _paintLayer(
        mode: PaintMode.freeStyle,
        offsets: const [Offset(0, 0), Offset(10, 10)],
        offset: const Offset(0, 120),
        opacity: 0.5,
        rawSize: const Size(10, 10),
      );

      // Re-merging must keep each stroke's baked opacity, not overwrite it with
      // the merged layer's opacity of 1.
      final merged = PaintLayerMergeManager.merge([multi, single]);
      expect(merged.items[0].opacity, closeTo(0.25, 1e-6));
      expect(merged.items[1].opacity, closeTo(0.75, 1e-6));
      expect(merged.items[2].opacity, closeTo(0.5, 1e-6));
    });

    test('inherits groupId and meta from the top-most source', () {
      final bottom = PaintLayer(
        item: PaintedModel(
          mode: PaintMode.freeStyle,
          offsets: const [Offset(0, 0), Offset(10, 10)],
          erasedOffsets: const [],
          color: Colors.red,
          strokeWidth: 4,
          opacity: 1,
        ),
        rawSize: const Size(10, 10),
        opacity: 1,
        groupId: 'group-bottom',
        meta: const {'source': 'bottom'},
      );
      final top = PaintLayer(
        item: PaintedModel(
          mode: PaintMode.freeStyle,
          offsets: const [Offset(0, 0), Offset(10, 10)],
          erasedOffsets: const [],
          color: Colors.blue,
          strokeWidth: 4,
          opacity: 1,
        ),
        rawSize: const Size(10, 10),
        opacity: 1,
        offset: const Offset(80, 0),
        groupId: 'group-top',
        meta: const {'source': 'top'},
      );

      final merged = PaintLayerMergeManager.merge([bottom, top]);

      expect(merged.groupId, 'group-top');
      expect(merged.meta, {'source': 'top'});
    });
  });

  group('PaintLayerMergeManager.canMerge gating', () {
    PaintLayer paint({PaintMode mode = PaintMode.freeStyle}) => _paintLayer(
      mode: mode,
      offsets: const [Offset(0, 0), Offset(10, 10)],
      rawSize: const Size(10, 10),
    );

    test('true for two non-censor paint layers', () {
      expect(PaintLayerMergeManager.canMerge([paint(), paint()]), isTrue);
    });

    test('false for fewer than two paint layers', () {
      expect(PaintLayerMergeManager.canMerge([paint()]), isFalse);
      expect(PaintLayerMergeManager.canMerge([]), isFalse);
    });

    test('false for censor layers', () {
      expect(
        PaintLayerMergeManager.canMerge([
          paint(mode: PaintMode.blur),
          paint(mode: PaintMode.pixelate),
        ]),
        isFalse,
      );
    });

    test('false for mixed selections without two paint layers', () {
      expect(
        PaintLayerMergeManager.canMerge([paint(), Layer(id: 'non-paint')]),
        isFalse,
      );
    });

    test('excludes layers carrying video-timeline scheduling', () {
      final scheduled = _paintLayer(
        mode: PaintMode.freeStyle,
        offsets: const [Offset(0, 0), Offset(10, 10)],
        rawSize: const Size(10, 10),
      )..startTime = const Duration(seconds: 1);

      expect(PaintLayerMergeManager.canMerge([paint(), scheduled]), isFalse);
      expect(PaintLayerMergeManager.isMergeable(scheduled), isFalse);
    });

    test('excludes layers carrying animations', () {
      final animated =
          _paintLayer(
              mode: PaintMode.freeStyle,
              offsets: const [Offset(0, 0), Offset(10, 10)],
              rawSize: const Size(10, 10),
            )
            ..animations.add(
              const LayerAnimation(
                type: LayerAnimationType.fade,
                phase: AnimationPhase.animateIn,
                duration: Duration(milliseconds: 300),
              ),
            );

      expect(PaintLayerMergeManager.canMerge([paint(), animated]), isFalse);
      expect(PaintLayerMergeManager.isMergeable(animated), isFalse);
    });
  });
}
