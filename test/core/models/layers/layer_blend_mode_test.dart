import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:pro_image_editor/core/models/layers/layer.dart';

void main() {
  group('Layer.blendMode', () {
    test('draws the layer over what is beneath it by default', () {
      final layer = TextLayer(text: 'plain');

      expect(layer.blendMode, BlendMode.srcOver);
      expect(layer.toMap().containsKey('blendMode'), isFalse);
    });

    test('round-trips through toMap and fromMap on every layer type', () {
      final layers = <Layer>[
        Layer(blendMode: BlendMode.multiply),
        TextLayer(text: 'text', blendMode: BlendMode.screen),
        EmojiLayer(emoji: '🔥', blendMode: BlendMode.plus),
        WidgetLayer(widget: const SizedBox(), blendMode: BlendMode.difference),
      ];

      for (final layer in layers) {
        final map = layer.toMap();
        expect(map['blendMode'], layer.blendMode.name);
        expect(Layer.fromMap(map).blendMode, layer.blendMode);
      }
    });

    test('reads a map without or with an unknown mode as srcOver', () {
      final map = TextLayer(text: 'old').toMap();

      expect(Layer.fromMap(map).blendMode, BlendMode.srcOver);
      expect(
        Layer.fromMap({...map, 'blendMode': 'sparkle'}).blendMode,
        BlendMode.srcOver,
      );
    });

    test('a history diff writes a changed mode, srcOver included', () {
      final before = TextLayer(text: 'a', blendMode: BlendMode.multiply);
      final after = before.copyWith(blendMode: BlendMode.srcOver);

      expect(
        after.toMapFromReference(before)['blendMode'],
        BlendMode.srcOver.name,
      );
      expect(
        before.copyWith().toMapFromReference(before).containsKey('blendMode'),
        isFalse,
      );
    });

    test('is kept by copyWith and tells layers apart', () {
      final layer = TextLayer(text: 'a', blendMode: BlendMode.lighten);

      expect(layer.copyWith(opacity: 0.5).blendMode, BlendMode.lighten);
      expect(
        layer.copyWith(blendMode: BlendMode.darken) == layer.copyWith(),
        isFalse,
      );
    });
  });
}
