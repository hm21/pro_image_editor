import 'dart:math' as math;

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:pro_image_editor/core/models/layers/layer.dart';
import 'package:pro_image_editor/features/main_editor/services/layer_copy_manager.dart';
import 'package:pro_image_editor/shared/services/import_export/utils/key_minifier.dart';

void main() {
  const box = TextLayerBox(
    size: Size(200, 80),
    verticalAlign: TextLayerBoxVerticalAlign.center,
    overflow: TextLayerBoxOverflow.shrink,
  );

  TextLayer boxedLayer() => TextLayer(text: 'Name', box: box);

  group(TextLayerBox, () {
    test('defaults to the top, clipping what does not fit', () {
      const plain = TextLayerBox(size: Size(10, 20));

      expect(plain.verticalAlign, TextLayerBoxVerticalAlign.top);
      expect(plain.overflow, TextLayerBoxOverflow.clip);
    });

    test('survives a map round trip', () {
      expect(TextLayerBox.fromMap(box.toMap()), box);
    });

    test('falls back to the defaults for values it does not know', () {
      final restored = TextLayerBox.fromMap(const {
        'width': 10,
        'height': -5,
        'verticalAlign': 'baseline',
        'overflow': 'scroll',
      });

      expect(restored.size, const Size(10, 0));
      expect(restored.verticalAlign, TextLayerBoxVerticalAlign.top);
      expect(restored.overflow, TextLayerBoxOverflow.clip);
    });

    test('reads a size written as text', () {
      final restored = TextLayerBox.fromMap(const {
        'width': '120.5',
        'height': '40',
      });

      expect(restored.size, const Size(120.5, 40));
    });

    test('rounds its size to the decimal places asked for', () {
      const exact = TextLayerBox(size: Size(144.30656934306566, 40.004));

      final map = exact.toMap(maxDecimalPlaces: 2);

      expect(map['width'], 144.31);
      expect(map['height'], 40);
    });
  });

  group('TextLayerBox.resize', () {
    // A 100×40 box drawn at twice its size, placed by its top-left corner.
    ({Size size, Offset offset}) resize(
      TextLayerBoxHandle handle,
      Offset delta, {
      double rotation = 0,
      bool flipX = false,
      Offset fractionalOffset = Offset.zero,
    }) {
      return TextLayerBox.resize(
        size: const Size(100, 40),
        offset: const Offset(10, 20),
        handle: handle,
        delta: delta,
        scale: 2,
        rotation: rotation,
        flipX: flipX,
        fractionalOffset: fractionalOffset,
      );
    }

    void expectOffset(Offset actual, Offset expected) {
      expect(actual.dx, closeTo(expected.dx, 1e-9));
      expect(actual.dy, closeTo(expected.dy, 1e-9));
    }

    test('grows to the right and down, keeping the top-left corner', () {
      final resized = resize(
        TextLayerBoxHandle.bottomRight,
        const Offset(20, 10),
      );

      expect(resized.size, const Size(110, 45));
      expectOffset(resized.offset, const Offset(10, 20));
    });

    test('grows to the left and up, moving the top-left corner', () {
      final resized = resize(
        TextLayerBoxHandle.topLeft,
        const Offset(-20, -10),
      );

      expect(resized.size, const Size(110, 45));
      expectOffset(resized.offset, const Offset(-10, 10));
    });

    test('an edge ignores the drag across it', () {
      final resized = resize(TextLayerBoxHandle.right, const Offset(20, 50));

      expect(resized.size, const Size(110, 40));
      expectOffset(resized.offset, const Offset(10, 20));
    });

    test('keeps the opposite edge of a centered layer in place', () {
      final resized = resize(
        TextLayerBoxHandle.right,
        const Offset(20, 0),
        fractionalOffset: const Offset(-0.5, -0.5),
      );

      // The offset is the center, which moves half the growth.
      expect(resized.size, const Size(110, 40));
      expectOffset(resized.offset, const Offset(20, 20));
    });

    test('measures the drag along a turned layer', () {
      // Turned a quarter, the right edge points down the canvas.
      final resized = resize(
        TextLayerBoxHandle.right,
        const Offset(0, 20),
        rotation: math.pi / 2,
        fractionalOffset: const Offset(-0.5, -0.5),
      );

      expect(resized.size.width, closeTo(110, 1e-9));
      expect(resized.size.height, closeTo(40, 1e-9));
      expectOffset(resized.offset, const Offset(10, 30));
    });

    test('follows a mirrored layer', () {
      // Mirrored, the right edge of the box shows on the left.
      final resized = resize(
        TextLayerBoxHandle.right,
        const Offset(-20, 0),
        flipX: true,
        fractionalOffset: const Offset(-0.5, -0.5),
      );

      expect(resized.size, const Size(110, 40));
      expectOffset(resized.offset, const Offset(0, 20));
    });

    test('stops at the minimum size', () {
      final resized = resize(
        TextLayerBoxHandle.bottomRight,
        const Offset(-1000, -1000),
      );

      expect(resized.size, TextLayerBox.minSize);
      expectOffset(resized.offset, const Offset(10, 20));
    });
  });

  group('TextLayer.box', () {
    test('is null by default and left out of the map', () {
      final layer = TextLayer(text: 'Name');

      expect(layer.box, isNull);
      expect(layer.toMap(), isNot(contains('box')));
    });

    test('round-trips through Layer.fromMap', () {
      final restored = Layer.fromMap(boxedLayer().toMap()) as TextLayer;

      expect(restored.box, box);
    });

    test('round-trips through minified keys', () {
      final minifier = EditorKeyMinifier(enableMinify: true);
      final minified = {
        for (final entry in boxedLayer().toMap().entries)
          minifier.convertLayerKey(entry.key): entry.value,
      };

      final restored = Layer.fromMap(minified, minifier: minifier) as TextLayer;

      expect(restored.box, box);
    });

    test('toMapFromReference writes the box only when it changed', () {
      final reference = boxedLayer();

      expect(
        reference.copyWith(text: 'Other').toMapFromReference(reference),
        isNot(contains('box')),
      );

      final resized = reference.copyWith(
        box: box.copyWith(size: const Size(300, 80)),
      );
      expect(
        resized.toMapFromReference(reference)['box'],
        resized.box!.toMap(),
      );
    });

    test('toMapFromReference rounds the box like the other values', () {
      final reference = boxedLayer();
      final resized = reference.copyWith(
        box: box.copyWith(size: const Size(144.30656934306566, 80)),
      );

      final map = resized.toMapFromReference(reference, maxDecimalPlaces: 2);

      expect(map['box']['width'], 144.31);
      expect(resized.toMap(maxDecimalPlaces: 2)['box']['width'], 144.31);
    });

    test('toMapFromReference writes null when the box was removed', () {
      final reference = boxedLayer();
      final removed = reference.copyWith()..box = null;

      final map = removed.toMapFromReference(reference);

      expect(map, contains('box'));
      expect(map['box'], isNull);
    });

    test('is kept by copyWith and copies', () {
      final layer = boxedLayer();

      expect(layer.copyWith(text: 'Other').box, box);
      expect((LayerCopyManager().copyLayer(layer) as TextLayer).box, box);
    });
  });
}
