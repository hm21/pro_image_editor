import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pro_image_editor/pro_image_editor.dart';

void main() {
  group('PaintLayer', () {
    final mockPaintModel = PaintedModel(
      color: Colors.red,
      mode: PaintMode.arrow,
      offsets: [
        Offset.zero,
        const Offset(50, 50),
      ],
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
          'enableSelection': true
        },
        'type': 'paint',
        'item': {
          'mode': 'arrow',
          'offsets': [
            {'x': 5.0, 'y': 68},
            {'x': 70, 'y': 5.0}
          ],
          'erasedOffsets': [],
          'color': 4294901760,
          'strokeWidth': 10.0,
          'opacity': 1.0,
          'fill': false
        },
        'rawSize': {'w': 100, 'h': 50},
        'opacity': 0.8
      };

      final paintLayer = PaintLayer.fromMap(layer, map);

      expect(paintLayer.rawSize, const Size(100, 50));
      expect(paintLayer.opacity, 0.8);
      expect(paintLayer.item, isA<PaintedModel>());
    });
  });
}
