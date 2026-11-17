import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:pro_image_editor/features/paint_editor/models/eraser_model.dart';
import 'package:pro_image_editor/pro_image_editor.dart';

/// Independent re-implementation of the render transform: maps a layer-local
/// point (top-left based, unscaled) onto the canvas, relative to the editor
/// body center.
Offset _canvas(PaintLayer layer, Offset point) {
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

void _expectOffsetClose(Offset a, Offset b, {double eps = 1e-6}) {
  expect(a.dx, closeTo(b.dx, eps), reason: 'dx of $a vs $b');
  expect(a.dy, closeTo(b.dy, eps), reason: 'dy of $a vs $b');
}

PaintedModel _stroke(
  List<Offset?> offsets, {
  PaintMode mode = PaintMode.freeStyle,
  double strokeWidth = 4,
  double opacity = 1,
  bool fill = false,
  List<ErasedOffset> erasedOffsets = const [],
}) {
  return PaintedModel(
    mode: mode,
    offsets: offsets,
    erasedOffsets: erasedOffsets,
    color: Colors.red,
    strokeWidth: strokeWidth,
    opacity: opacity,
    fill: fill,
  );
}

PaintLayer _drawing({
  List<PaintedModel>? items,
  Offset offset = const Offset(30, -20),
  double scale = 1.5,
  double rotation = pi / 6,
  bool flipX = true,
  bool flipY = false,
  double opacity = 0.8,
}) {
  return PaintLayer(
    items:
        items ??
        [
          _stroke(
            const [Offset(10, 10), Offset(40, 30), null, Offset(20, 60)],
            erasedOffsets: const [
              ErasedOffset(offset: Offset(25, 20), radius: 3),
            ],
          ),
          _stroke(
            const [Offset(70, 20), Offset(90, 80)],
            mode: PaintMode.rect,
            fill: true,
            opacity: 0.5,
          ),
        ],
    rawSize: const Size(100, 100),
    opacity: opacity,
    offset: offset,
    scale: scale,
    rotation: rotation,
    flipX: flipX,
    flipY: flipY,
    groupId: 'group',
    meta: const {'kind': 'drawing'},
  );
}

void main() {
  group('PaintLayerSplitManager.split', () {
    test('puts every point of every stroke where it was on the canvas', () {
      final source = _drawing();

      final parts = PaintLayerSplitManager.split(source);

      expect(parts, hasLength(2));
      for (final (index, part) in parts.indexed) {
        final original = source.items[index];
        final item = part.item;
        expect(item.offsets, hasLength(original.offsets.length));
        for (var i = 0; i < original.offsets.length; i++) {
          final before = original.offsets[i];
          final after = item.offsets[i];
          if (before == null) {
            expect(after, isNull);
            continue;
          }
          _expectOffsetClose(_canvas(part, after!), _canvas(source, before));
        }
        for (var i = 0; i < original.erasedOffsets.length; i++) {
          _expectOffsetClose(
            _canvas(part, item.erasedOffsets[i].offset),
            _canvas(source, original.erasedOffsets[i].offset),
          );
          expect(
            item.erasedOffsets[i].radius,
            original.erasedOffsets[i].radius,
          );
        }
      }
    });

    test('keeps the transform, grouping and metadata of the source', () {
      final source = _drawing();

      final parts = PaintLayerSplitManager.split(source);

      for (final part in parts) {
        expect(part.id, isNot(source.id));
        expect(part.scale, source.scale);
        expect(part.rotation, source.rotation);
        expect(part.flipX, source.flipX);
        expect(part.flipY, source.flipY);
        expect(part.groupId, 'group');
        expect(part.meta, {'kind': 'drawing'});
        expect(part.items, hasLength(1));
        expect(part.item.hit, isFalse);
      }
      expect(parts.map((p) => p.id).toSet(), hasLength(2));
    });

    test('fades each part by the layer and the stroke opacity together', () {
      final parts = PaintLayerSplitManager.split(_drawing(opacity: 0.8));

      expect(parts[0].opacity, closeTo(0.8, 1e-9));
      expect(parts[0].item.opacity, closeTo(0.8, 1e-9));
      expect(parts[1].opacity, closeTo(0.4, 1e-9));
      expect(parts[1].item.opacity, closeTo(0.4, 1e-9));
    });

    test('pads a stroked part by half its width but not a filled one', () {
      final parts = PaintLayerSplitManager.split(_drawing());

      // Freestyle points span 30 x 50, plus 2 on every side for width 4.
      expect(parts[0].rawSize, const Size(34, 54));
      // The filled rect spans 20 x 60 and draws no stroke past its points.
      expect(parts[1].rawSize, const Size(20, 60));
    });

    test('gives a single dot a box as large as its stroke', () {
      final source = _drawing(
        items: [
          _stroke(const [Offset(50, 50)], mode: PaintMode.rect, fill: true),
          _stroke(const [Offset(10, 10), Offset(20, 20)]),
        ],
      );

      final dot = PaintLayerSplitManager.split(source).first;

      expect(dot.rawSize, const Size(4, 4));
      _expectOffsetClose(
        _canvas(dot, dot.item.offsets.single!),
        _canvas(source, const Offset(50, 50)),
      );
    });

    test('undoes a merge, stroke for stroke', () {
      final a = PaintLayer(
        item: _stroke(const [Offset(0, 0), Offset(20, 10)]),
        rawSize: const Size(24, 14),
        opacity: 0.6,
        offset: const Offset(-40, 10),
        rotation: pi / 4,
      );
      final b = PaintLayer(
        item: _stroke(const [Offset(5, 5), Offset(5, 30)], strokeWidth: 8),
        rawSize: const Size(18, 33),
        opacity: 1,
        offset: const Offset(60, -20),
        scale: 2,
        flipY: true,
      );

      final parts = PaintLayerSplitManager.split(
        PaintLayerMergeManager.merge([a, b]),
      );

      expect(parts, hasLength(2));
      for (final (source, part) in [(a, parts[0]), (b, parts[1])]) {
        for (var i = 0; i < source.item.offsets.length; i++) {
          _expectOffsetClose(
            _canvas(part, part.item.offsets[i]!),
            _canvas(source, source.item.offsets[i]!),
          );
        }
        expect(part.opacity, closeTo(source.opacity, 1e-9));
        expect(
          part.item.strokeWidth * part.scale,
          closeTo(source.item.strokeWidth * source.scale, 1e-9),
        );
      }
    });
  });

  group('PaintLayerSplitManager.canSplit', () {
    test('accepts a static drawing with several strokes', () {
      expect(PaintLayerSplitManager.canSplit(_drawing()), isTrue);
    });

    test('rejects a drawing with a single stroke', () {
      expect(
        PaintLayerSplitManager.canSplit(
          _drawing(
            items: [
              _stroke(const [Offset(0, 0), Offset(9, 9)]),
            ],
          ),
        ),
        isFalse,
      );
    });

    test('rejects a drawing merging would reject', () {
      expect(
        PaintLayerSplitManager.canSplit(
          _drawing()..startTime = const Duration(seconds: 1),
        ),
        isFalse,
      );
      expect(
        PaintLayerSplitManager.canSplit(
          _drawing()..blendMode = BlendMode.multiply,
        ),
        isFalse,
      );
    });

    test('rejects a layer that is not a drawing', () {
      expect(PaintLayerSplitManager.canSplit(TextLayer(text: 'Hi')), isFalse);
    });
  });

  group('PaintLayerMergeManager.mergeRuns', () {
    PaintLayer single(Offset offset, {PaintMode mode = PaintMode.freeStyle}) {
      return PaintLayer(
        item: _stroke(const [Offset(0, 0), Offset(10, 10)], mode: mode),
        rawSize: const Size(14, 14),
        opacity: 1,
        offset: offset,
      );
    }

    test('merges consecutive drawings into one', () {
      final layers = [
        single(const Offset(0, 0)),
        single(const Offset(20, 0)),
        single(const Offset(40, 0)),
      ];

      final result = PaintLayerMergeManager.mergeRuns(layers);

      expect(result, hasLength(1));
      expect(result.single.items, hasLength(3));
    });

    test('keeps a censor area between the strokes around it', () {
      final censor = single(const Offset(10, 0), mode: PaintMode.blur);
      final layers = [
        single(const Offset(0, 0)),
        single(const Offset(20, 0)),
        censor,
        single(const Offset(40, 0)),
      ];

      final result = PaintLayerMergeManager.mergeRuns(layers);

      expect(result, hasLength(3));
      expect(result[0].items, hasLength(2));
      expect(result[1], same(censor));
      expect(result[2], same(layers[3]));
    });

    test('leaves the layers the test rejects as they are', () {
      final kept = single(const Offset(0, 0));
      final layers = [kept, single(const Offset(20, 0))];

      final result = PaintLayerMergeManager.mergeRuns(
        layers,
        test: (layer) => layer.id != kept.id,
      );

      expect(result, [same(kept), same(layers[1])]);
    });
  });
}
