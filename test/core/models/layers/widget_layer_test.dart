import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:pro_image_editor/core/models/layers/widget_layer.dart';

void main() {
  group('WidgetLayer', () {
    test('should create a WidgetLayer with default values', () {
      const widget = Text('Test Widget');
      final layer = WidgetLayer(widget: widget);

      expect(layer.widget, widget);
      expect(layer.offset, Offset.zero);
      expect(layer.rotation, 0);
      expect(layer.scale, 1);
      expect(layer.flipX, isFalse);
      expect(layer.flipY, isFalse);
    });

    test('should convert WidgetLayer to a map', () {
      const widget = Text('Test Widget');
      final layer = WidgetLayer(
        widget: widget,
        scale: 0.7,
        rotation: 0.5,
        flipX: true,
        flipY: false,
        offset: const Offset(10, 20),
      );

      final map = layer.toMap(recordPosition: 1);

      expect(map['type'], 'widget');
      expect(map['recordPosition'], 1);
      expect(map['exportConfigs'], isNull);
      expect(map['scale'], 0.7);
      expect(map['rotation'], 0.5);
      expect(map['flipX'], isTrue);
      expect(map['flipY'], isFalse);
      expect(map['x'], 10);
      expect(map['y'], 20);
    });

    group('toMapFromReference', () {
      test('writes export configs that changed since the reference', () {
        final reference = WidgetLayer(
          widget: const SizedBox(),
          id: 'layer_id',
          exportConfigs: const WidgetLayerExportConfigs(
            id: 'clip',
            meta: {'file': 'a.mp4'},
          ),
        );
        final layer = reference.copyWith(
          exportConfigs: const WidgetLayerExportConfigs(
            id: 'clip',
            meta: {
              'file': 'a.mp4',
              'chromaKey': {'color': 0xFF00FF00},
            },
          ),
        );

        final map = layer.toMapFromReference(reference);

        expect(map['exportConfigs'], {
          'id': 'clip',
          'meta': {
            'file': 'a.mp4',
            'chromaKey': {'color': 0xFF00FF00},
          },
        });
      });

      test('writes emptied export configs so the import clears them', () {
        final reference = WidgetLayer(
          widget: const SizedBox(),
          id: 'layer_id',
          exportConfigs: const WidgetLayerExportConfigs(id: 'clip'),
        );
        final layer = reference.copyWith(
          exportConfigs: const WidgetLayerExportConfigs(),
        );

        final map = layer.toMapFromReference(reference);

        expect(map['exportConfigs'], isEmpty);
        expect(map.containsKey('exportConfigs'), isTrue);
      });

      test('omits export configs equal to the reference', () {
        // Separate map instances, as an import produces: const literals would
        // be canonicalized into one identical map.
        Map<String, dynamic> meta() => {
          'nested': {'value': 1},
        };
        final reference = WidgetLayer(
          widget: const SizedBox(),
          id: 'layer_id',
          exportConfigs: WidgetLayerExportConfigs(id: 'clip', meta: meta()),
        );
        final layer = reference.copyWith(
          offset: const Offset(10, 20),
          exportConfigs: WidgetLayerExportConfigs(id: 'clip', meta: meta()),
        );

        final map = layer.toMapFromReference(reference);

        expect(map.containsKey('exportConfigs'), isFalse);
        expect(map['x'], 10);
      });
    });

    test('should copy WidgetLayer with modified properties', () {
      const widget = Text('Test Widget');
      final layer = WidgetLayer(widget: widget, id: 'layer_id');

      final copiedLayer = layer.copyWith(
        widget: const Text('New Widget'),
        id: 'new_layer_id',
      );

      expect(copiedLayer.widget, isA<Text>());
      expect((copiedLayer.widget as Text).data, 'New Widget');
      expect(copiedLayer.id, 'new_layer_id');
      expect(copiedLayer.offset, layer.offset);
    });
  });
}
