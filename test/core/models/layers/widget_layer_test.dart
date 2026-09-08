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
