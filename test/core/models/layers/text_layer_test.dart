import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:pro_image_editor/core/models/layers/enums/layer_background_mode.dart';
import 'package:pro_image_editor/core/models/layers/text_layer.dart';
import 'package:pro_image_editor/shared/extensions/color_extension.dart';

void main() {
  group('TextLayer', () {
    test('should create a TextLayer with default values', () {
      final textLayer = TextLayer(text: 'Sample Text');

      expect(textLayer.text, 'Sample Text');
      expect(textLayer.color, const Color(0xFF000000));
      expect(textLayer.background, const Color(0xFFFFFFFF));
      expect(textLayer.align, TextAlign.left);
      expect(textLayer.fontScale, 1.0);
      expect(textLayer.maxTextWidth, isNull);
      expect(textLayer.textStyle, isNull);
      expect(textLayer.colorMode, LayerBackgroundMode.backgroundAndColor);
      expect(textLayer.customSecondaryColor, false);
      expect(textLayer.align, TextAlign.left);
      expect(textLayer.hit, false);
    });

    test('should create a TextLayer from a map', () {
      final layer = TextLayer(text: 'Base Layer');
      final map = {
        'text': 'Mapped Text',
        'color': 0xFF0000FF,
        'background': 0xFFFF0000,
        'align': 'center',
        'fontScale': 1.5,
        'colorMode': 'background',
        'customSecondaryColor': true,
      };

      final textLayer = TextLayer.fromMap(layer, map);

      expect(textLayer.text, 'Mapped Text');
      expect(textLayer.color, const Color(0xFF0000FF));
      expect(textLayer.background, const Color(0xFFFF0000));
      expect(textLayer.align, TextAlign.center);
      expect(textLayer.fontScale, 1.5);
      expect(textLayer.colorMode, LayerBackgroundMode.background);
      expect(textLayer.customSecondaryColor, true);
    });

    test('should convert TextLayer to map', () {
      const color = Color(0xFF123456);
      const background = Color(0xFF654321);
      final textLayer = TextLayer(
        text: 'Sample Text',
        offset: const Offset(5, 10),
        scale: 0.6,
        rotation: 0.5,
        flipX: true,
        flipY: false,
        color: color,
        background: background,
        align: TextAlign.right,
        fontScale: 2.0,
        customSecondaryColor: true,
        textStyle: const TextStyle(
          fontFamily: 'Roboto',
          fontWeight: FontWeight.bold,
        ),
      );

      final map = textLayer.toMap();

      expect(map['text'], 'Sample Text');
      expect(map['color'], color.toHex());
      expect(map['background'], background.toHex());
      expect(map['align'], 'right');
      expect(map['fontScale'], 2.0);
      expect(map['customSecondaryColor'], true);
      expect(map['fontFamily'], 'Roboto');
      expect(map['fontWeight'], FontWeight.bold.value);
      expect(map['scale'], 0.6);
      expect(map['x'], 5);
      expect(map['y'], 10);
      expect(map['rotation'], 0.5);
      expect(map['flipX'], isTrue);
      expect(map['flipY'], isFalse);
    });
  });
}
