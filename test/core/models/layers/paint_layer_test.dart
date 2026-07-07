import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pro_image_editor/pro_image_editor.dart';
import 'package:pro_image_editor/shared/services/import_export/utils/key_minifier.dart';

void main() {
  group('PaintLayer', () {
    final mockPaintModel = PaintedModel(
      color: Colors.red,
      mode: PaintMode.arrow,
      offsets: [Offset.zero, const Offset(50, 50)],
      erasedOffsets: [],
      opacity: 1,
      strokeWidth: 5,
    );

    test('should correctly calculate size with scaling', () {
      final layer = PaintLayer(
        item: mockPaintModel,
        rawSize: const Size(100, 50),
        opacity: 1.0,
        scale: 2.0,
      );

      expect(layer.size, const Size(200, 100));
    });

    test('should correctly convert to map', () {
      final layer = PaintLayer(
        item: mockPaintModel,
        rawSize: const Size(100, 50),
        opacity: 0.5,
      );

      final map = layer.toMap();

      expect(map['item'], isNotNull);
      expect(map['rawSize'], {'w': 100.0, 'h': 50.0});
      expect(map['opacity'], 0.5);
      expect(map['type'], 'paint');
    });

    test('should correctly create from map', () {
      final layer = Layer(id: '123');
      final Map<String, dynamic> map = {
        'x': 0,
        'y': 77,
        'rotation': 0.0,
        'scale': 1.0,
        'flipX': false,
        'flipY': false,
        'interaction': {
          'enableMove': true,
          'enableScale': true,
          'enableRotate': true,
          'enableSelection': true,
        },
        'type': 'paint',
        'item': {
          'mode': 'arrow',
          'offsets': [
            {'x': 5.0, 'y': 68},
            {'x': 70, 'y': 5.0},
          ],
          'erasedOffsets': [],
          'color': 4294901760,
          'strokeWidth': 10.0,
          'opacity': 1.0,
          'fill': false,
        },
        'rawSize': {'w': 100, 'h': 50},
        'opacity': 0.8,
      };

      final paintLayer = PaintLayer.fromMap(layer, map);

      expect(paintLayer.rawSize, const Size(100, 50));
      expect(paintLayer.opacity, 0.8);
      expect(paintLayer.item, isA<PaintedModel>());
    });

    test('legacy single-item map deserializes to a one-item layer', () {
      final layer = Layer(id: '123');
      final Map<String, dynamic> map = {
        'type': 'paint',
        'item': {
          'mode': 'arrow',
          'offsets': [
            {'x': 5.0, 'y': 68},
            {'x': 70, 'y': 5.0},
          ],
          'erasedOffsets': [],
          'color': 4294901760,
          'strokeWidth': 10.0,
          'opacity': 1.0,
          'fill': false,
        },
        'rawSize': {'w': 100, 'h': 50},
        'opacity': 0.8,
      };

      final paintLayer = PaintLayer.fromMap(layer, map);

      expect(paintLayer.items.length, 1);
      expect(paintLayer.item, same(paintLayer.items.first));
      expect(paintLayer.item.mode, PaintMode.arrow);
    });
  });

  group('PaintLayer multi-item (merged)', () {
    PaintedModel model({
      PaintMode mode = PaintMode.freeStyle,
      Color color = Colors.blue,
      double opacity = 1,
    }) {
      return PaintedModel(
        mode: mode,
        offsets: const [Offset(0, 0), Offset(10, 20)],
        erasedOffsets: const [],
        color: color,
        strokeWidth: 3,
        opacity: opacity,
      );
    }

    test('item getter/setter maps to items.first (back-compat)', () {
      final a = model(color: Colors.red);
      final b = model(color: Colors.green);
      final layer = PaintLayer(
        items: [a, b],
        rawSize: const Size(20, 20),
        opacity: 1,
      );

      expect(layer.item, same(a));
      expect(layer.items.length, 2);

      final replacement = model(color: Colors.orange);
      layer.item = replacement;
      expect(layer.items.first, same(replacement));
      expect(layer.items[1], same(b));
    });

    test('single-item toMap stays legacy (no items array)', () {
      final layer = PaintLayer(
        item: model(),
        rawSize: const Size(20, 20),
        opacity: 1,
      );
      final map = layer.toMap();
      expect(map['item'], isNotNull);
      expect(map.containsKey('items'), isFalse);
    });

    test('multi-item toMap serializes items array + legacy first item', () {
      final layer = PaintLayer(
        items: [
          model(color: Colors.red),
          model(color: Colors.green),
          model(color: Colors.blue),
        ],
        rawSize: const Size(20, 20),
        opacity: 1,
      );
      final map = layer.toMap();
      expect(map['item'], isNotNull, reason: 'legacy first item retained');
      expect((map['items'] as List).length, 3);
    });

    test('multi-item round-trip keeps all N items', () {
      final layer = PaintLayer(
        items: [
          model(mode: PaintMode.freeStyle, color: Colors.red),
          model(mode: PaintMode.line, color: Colors.green),
          model(mode: PaintMode.rect, color: Colors.blue),
        ],
        rawSize: const Size(40, 30),
        opacity: 1,
      );

      final restored = Layer.fromMap(layer.toMap()) as PaintLayer;

      expect(restored.items.length, 3);
      expect(restored.items[0].mode, PaintMode.freeStyle);
      expect(restored.items[1].mode, PaintMode.line);
      expect(restored.items[2].mode, PaintMode.rect);
      expect(restored.items[0].color.toARGB32(), Colors.red.toARGB32());
      expect(restored.items[2].color.toARGB32(), Colors.blue.toARGB32());
    });

    test('multi-item round-trip keeps all N items when minified', () {
      final layer = PaintLayer(
        items: [
          model(color: Colors.red),
          model(color: Colors.green),
        ],
        rawSize: const Size(40, 30),
        opacity: 1,
      );

      final minifier = EditorKeyMinifier(enableMinify: true);
      final map = layer.toMap(enableMinify: true);
      final minified = minifier.convertListOfLayerKeys([map]).first;

      // Keys are minified (`items` -> `it`).
      expect(minified.containsKey('it'), isTrue);

      final restored =
          Layer.fromMap(minified, minifier: minifier) as PaintLayer;
      expect(restored.items.length, 2);
    });
  });
}
