import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pro_image_editor/core/models/editor_configs/pro_image_editor_configs.dart';
import 'package:pro_image_editor/core/models/layers/layer.dart';
import 'package:pro_image_editor/core/models/layers/layer_interaction.dart';
import 'package:pro_image_editor/features/paint_editor/paint_editor.dart';

void main() {
  group('Layer', () {
    test('Default constructor initializes properties correctly', () {
      final layer = Layer();

      expect(layer.offset, Offset.zero);
      expect(layer.rotation, 0);
      expect(layer.scale, 1);
      expect(layer.flipX, false);
      expect(layer.flipY, false);
      expect(layer.meta, isNull);
      expect(layer.boxConstraints, isNull);
      expect(layer.interaction, isA<LayerInteraction>());
      expect(layer.key, isA<GlobalKey>());
      expect(layer.keyInternalSize, isA<GlobalKey>());
    });

    test('Factory constructor fromMap initializes properties correctly', () {
      final map = {
        'x': 10.0,
        'y': 20.0,
        'rotation': 45.0,
        'scale': 2.0,
        'flipX': true,
        'flipY': false,
        'meta': {'key': 'value'},
        'interaction': {'movable': true},
        'boxConstraints': {
          'minWidth': 50.0,
          'minHeight': 50.0,
          'maxWidth': 100.0,
          'maxHeight': 100.0,
        },
        'type': 'default',
      };

      final layer = Layer.fromMap(map);

      expect(layer.offset, const Offset(10.0, 20.0));
      expect(layer.rotation, 45.0);
      expect(layer.scale, 2.0);
      expect(layer.flipX, true);
      expect(layer.flipY, false);
      expect(layer.meta, {'key': 'value'});
      expect(layer.boxConstraints, isNotNull);
      expect(layer.boxConstraints!.minWidth, 50.0);
      expect(layer.boxConstraints!.minHeight, 50.0);
      expect(layer.boxConstraints!.maxWidth, 100.0);
      expect(layer.boxConstraints!.maxHeight, 100.0);
    });

    test('toMap converts Layer properties to a map', () {
      final layer = Layer(
        offset: const Offset(10.0, 20.0),
        rotation: 45.0,
        scale: 2.0,
        flipX: true,
        flipY: false,
        meta: {'key': 'value'},
        boxConstraints: const BoxConstraints(
          minWidth: 50.0,
          minHeight: 50.0,
          maxWidth: 100.0,
          maxHeight: 100.0,
        ),
      );

      final map = layer.toMap();

      expect(map['x'], 10.0);
      expect(map['y'], 20.0);
      expect(map['rotation'], 45.0);
      expect(map['scale'], 2.0);
      expect(map['flipX'], true);
      expect(map['flipY'], false);
      expect(map['meta'], {'key': 'value'});
      expect(map['boxConstraints'], isNotNull);
      expect(map['boxConstraints']['minWidth'], 50.0);
      expect(map['boxConstraints']['minHeight'], 50.0);
      expect(map['boxConstraints']['maxWidth'], 100.0);
      expect(map['boxConstraints']['maxHeight'], 100.0);
    });
  });

  group('Layer toMap/fromMap tests', () {
    test('Base Layer', () {
      final original = Layer(
        id: 'base-id',
        offset: const Offset(20, 30),
        rotation: 15.5,
        scale: 2.0,
        flipX: true,
        flipY: false,
        meta: {'custom': 'value'},
        interaction: LayerInteraction(
          enableEdit: true,
          enableMove: false,
          enableRotate: true,
          enableScale: false,
          enableSelection: true,
        ),
        boxConstraints: const BoxConstraints(
          minWidth: 10,
          minHeight: 20,
          maxWidth: 100,
          maxHeight: 200,
        ),
      );

      final map = original.toMap();
      final recreated = Layer.fromMap(map, id: original.id);

      expect(recreated, equals(original));
    });

    test('EmojiLayer', () {
      final original = EmojiLayer(
        id: 'emoji-id',
        emoji: '😎',
        offset: const Offset(50, 100),
        rotation: 90,
        scale: 0.5,
        flipX: false,
        flipY: true,
        meta: {'emojiMeta': 'value'},
        boxConstraints: const BoxConstraints(minWidth: 1, maxWidth: 500),
        interaction: LayerInteraction(
          enableEdit: true,
          enableMove: false,
          enableRotate: true,
          enableScale: false,
          enableSelection: true,
        ),
      );

      final map = original.toMap();
      final recreated = Layer.fromMap(map, id: original.id);

      expect(recreated, equals(original));
    });

    test('TextLayer', () {
      final original = TextLayer(
        id: 'text-id',
        text: 'Hello, Flutter!',
        textStyle: const TextStyle(fontSize: 20, color: Colors.blue),
        offset: const Offset(0, 0),
        rotation: 0,
        scale: 1,
        interaction: LayerInteraction(
          enableEdit: true,
          enableMove: false,
          enableRotate: true,
          enableScale: false,
          enableSelection: true,
        ),
        align: TextAlign.left,
        background: Colors.red,
        boxConstraints: const BoxConstraints(minWidth: 1, maxWidth: 500),
        color: Colors.blue,
        colorMode: LayerBackgroundMode.backgroundAndColor,
        customSecondaryColor: true,
        flipX: true,
        flipY: false,
        fontScale: 12,
        maxTextWidth: 20,
        meta: {'lang': 'en'},
      );

      final map = original.toMap();
      final recreated = Layer.fromMap(map, id: original.id);

      expect(recreated, equals(original));
    });

    test('PaintLayer', () {
      final original = PaintLayer(
        id: 'paint-id',
        item: PaintedModel(
          mode: PaintMode.arrow,
          offsets: [Offset.zero, const Offset(50, 50)],
          erasedOffsets: [],
          color: Colors.amber,
          strokeWidth: 10,
          opacity: 0.8,
          fill: false,
        ),
        offset: const Offset(10, 20),
        scale: 1.2,
        opacity: 0.5,
        rawSize: const Size(50, 50),
        rotation: 10,
        flipX: true,
        flipY: false,
        boxConstraints: const BoxConstraints(minWidth: 1, maxWidth: 500),
        interaction: LayerInteraction(
          enableEdit: true,
          enableMove: false,
          enableRotate: true,
          enableScale: false,
          enableSelection: true,
        ),
        meta: {'meta': 'test'},
      );

      final map = original.toMap();
      final recreated = Layer.fromMap(map, id: original.id);

      expect(recreated, equals(original));
    });

    test('WidgetLayer', () {
      final original = WidgetLayer(
        id: 'widget-id',
        offset: const Offset(10, 20),
        rotation: 180,
        scale: 0.9,
        flipX: true,
        flipY: false,
        boxConstraints: const BoxConstraints(minWidth: 1, maxWidth: 500),
        interaction: LayerInteraction(
          enableEdit: true,
          enableMove: false,
          enableRotate: true,
          enableScale: false,
          enableSelection: true,
        ),
        meta: {'meta': 'test'},
        exportConfigs: const WidgetLayerExportConfigs(networkUrl: 'Test-Url'),
        widget: Container(),
      );

      final map = original.toMap();
      final recreated = Layer.fromMap(map, id: original.id);

      expect(recreated, equals(original));
    });
  });
}
