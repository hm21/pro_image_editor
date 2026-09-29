import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:pro_image_editor/core/models/layers/enums/layer_background_mode.dart';
import 'package:pro_image_editor/core/models/layers/layer.dart';
import 'package:pro_image_editor/shared/extensions/color_extension.dart';
import 'package:pro_image_editor/shared/services/import_export/utils/key_minifier.dart';

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

    group('outline', () {
      test('has no outline by default', () {
        final textLayer = TextLayer(text: 'Sample Text');

        expect(textLayer.outlineWidth, 0);
        expect(textLayer.hasOutline, isFalse);
        expect(textLayer.toMap(), isNot(contains('outlineWidth')));
        expect(textLayer.toMap(), isNot(contains('outlineColor')));
      });

      test('has no outline when its color is fully transparent', () {
        final textLayer = TextLayer(
          text: 'Sample Text',
          outlineWidth: 2,
          outlineColor: const Color(0x00FF0000),
        );

        expect(textLayer.hasOutline, isFalse);
      });

      test('survives a map round trip', () {
        const outlineColor = Color(0xFFFF0000);
        final textLayer = TextLayer(
          text: 'Sample Text',
          outlineWidth: 2.5,
          outlineColor: outlineColor,
        );

        final restored = TextLayer.fromMap(
          TextLayer(text: 'Base Layer'),
          textLayer.toMap(),
        );

        expect(restored.outlineWidth, 2.5);
        expect(restored.outlineColor, outlineColor);
        expect(restored.hasOutline, isTrue);
      });

      test('is kept by copyWith unless replaced', () {
        final textLayer = TextLayer(
          text: 'Sample Text',
          outlineWidth: 2,
          outlineColor: const Color(0xFFFF0000),
        );

        expect(textLayer.copyWith(text: 'Other').outlineWidth, 2);
        expect(textLayer.copyWith(outlineWidth: 0).hasOutline, isFalse);
      });
    });

    group('toMapFromReference', () {
      const shadow = Shadow(
        color: Color(0x80000000),
        blurRadius: 4,
        offset: Offset(1, 2),
      );

      test('omits shadows and outline that did not change', () {
        final reference = TextLayer(
          text: 'Sample Text',
          textStyle: const TextStyle(shadows: [shadow]),
          outlineWidth: 2,
        );

        final map = reference
            .copyWith(text: 'Other')
            .toMapFromReference(reference);

        expect(map, isNot(contains('shadows')));
        expect(map, isNot(contains('outlineWidth')));
        expect(map, isNot(contains('outlineColor')));
      });

      test('writes an empty list when the shadows were removed', () {
        final reference = TextLayer(
          text: 'Sample Text',
          textStyle: const TextStyle(shadows: [shadow]),
        );
        final updated = reference.copyWith(textStyle: const TextStyle());

        final map = updated.toMapFromReference(reference);

        expect(map['shadows'], isEmpty);
      });

      test('writes the outline when it changed', () {
        final reference = TextLayer(text: 'Sample Text', outlineWidth: 2);
        final updated = reference.copyWith(
          outlineWidth: 0,
          outlineColor: const Color(0xFFFFFFFF),
        );

        final map = updated.toMapFromReference(reference);

        expect(map['outlineWidth'], 0);
        expect(map['outlineColor'], const Color(0xFFFFFFFF).toHex());
      });

      test('keeps a color set before the width in a later step', () {
        final reference = TextLayer(
          text: 'Sample Text',
          outlineColor: const Color(0xFFFF0000),
        );
        final updated = reference.copyWith(outlineWidth: 2);

        // The import merges each history entry over the previous state.
        final restored = TextLayer.fromMap(reference, {
          ...reference.toMap(),
          ...updated.toMapFromReference(reference),
        });

        expect(restored.outlineWidth, 2);
        expect(restored.outlineColor, const Color(0xFFFF0000));
      });
    });

    group('highlights', () {
      const hello = TextHighlight(
        start: 0,
        end: 5,
        startTime: Duration.zero,
        endTime: Duration(milliseconds: 400),
      );
      const world = TextHighlight(
        start: 6,
        end: 11,
        startTime: Duration(milliseconds: 400),
        endTime: Duration(milliseconds: 900),
      );

      TextLayer highlightedLayer({Duration? startTime}) => TextLayer(
        text: 'Hello world',
        startTime: startTime,
        highlights: [hello, world],
        highlightColor: const Color(0xFF00FF00),
      );

      test('defaults to none, in the default highlight color', () {
        final layer = TextLayer(text: 'Plain');

        expect(layer.highlights, isEmpty);
        expect(layer.highlightColor, kDefaultTextHighlightColor);
        expect(layer.highlightIndexAt(Duration.zero), isNull);
      });

      test('highlightIndexAt measures from the layer start', () {
        final layer = highlightedLayer(startTime: const Duration(seconds: 2));

        expect(layer.highlightIndexAt(const Duration(seconds: 1)), isNull);
        expect(layer.highlightIndexAt(const Duration(seconds: 2)), 0);
        expect(layer.highlightIndexAt(const Duration(milliseconds: 2500)), 1);
        expect(
          layer.highlightIndexAt(const Duration(milliseconds: 2900)),
          isNull,
        );
      });

      test('highlightIndexAt measures from zero without a layer start', () {
        final layer = highlightedLayer();

        expect(layer.highlightIndexAt(const Duration(milliseconds: 500)), 1);
      });

      test('the later of two overlapping highlights wins', () {
        final layer = TextLayer(
          text: 'Hello world',
          highlights: [
            hello.copyWith(endTime: const Duration(seconds: 1)),
            world.copyWith(startTime: const Duration(milliseconds: 200)),
          ],
        );

        expect(layer.highlightIndexAt(const Duration(milliseconds: 100)), 0);
        expect(layer.highlightIndexAt(const Duration(milliseconds: 300)), 1);
      });

      test('toMap writes the highlights and their color', () {
        final map = highlightedLayer().toMap();

        expect(map['highlights'], [hello.toMap(), world.toMap()]);
        expect(map['highlightColor'], const Color(0xFF00FF00).toHex());
      });

      test('toMap leaves both out without highlights', () {
        final map = TextLayer(text: 'Plain').toMap();

        expect(map.containsKey('highlights'), false);
        expect(map.containsKey('highlightColor'), false);
      });

      test('keeps a custom color when a later step adds highlights', () {
        // The import merges each history step's diff over the first map of
        // the layer, so that map has to carry the color on its own.
        final before = TextLayer(
          text: 'Hello world',
          highlightColor: const Color(0xFF00FF00),
        );
        final after = before.copyWith(highlights: [hello, world]);

        final restored =
            Layer.fromMap({
                  ...before.toMap(),
                  ...after.toMapFromReference(before),
                })
                as TextLayer;

        expect(restored.highlights, [hello, world]);
        expect(restored.highlightColor, const Color(0xFF00FF00));
      });

      test('round-trips through Layer.fromMap', () {
        final restored = Layer.fromMap(highlightedLayer().toMap()) as TextLayer;

        expect(restored.highlights, [hello, world]);
        expect(restored.highlightColor, const Color(0xFF00FF00));
      });

      test('round-trips through minified keys', () {
        final minifier = EditorKeyMinifier(enableMinify: true);
        final minified = {
          for (final entry in highlightedLayer().toMap().entries)
            minifier.convertLayerKey(entry.key): entry.value,
        };

        final restored =
            Layer.fromMap(minified, minifier: minifier) as TextLayer;

        expect(restored.highlights, [hello, world]);
        expect(restored.highlightColor, const Color(0xFF00FF00));
      });

      test('fromMap drops highlights that can never show', () {
        final map = highlightedLayer().toMap()
          ..['highlights'] = [
            hello.toMap(),
            {'start': 4, 'end': 2, 'startTime': 0, 'endTime': 100},
          ];

        final restored = Layer.fromMap(map) as TextLayer;

        expect(restored.highlights, [hello]);
      });

      test('toMapFromReference writes only changed highlight fields', () {
        final reference = highlightedLayer();

        expect(
          reference.copyWith().toMapFromReference(reference),
          isNot(contains('highlights')),
        );

        final retimed = reference.copyWith(
          highlights: [
            hello,
            world.copyWith(endTime: const Duration(seconds: 1)),
          ],
        );
        final diff = retimed.toMapFromReference(reference);
        expect(diff['highlights'], [
          hello.toMap(),
          world.copyWith(endTime: const Duration(seconds: 1)).toMap(),
        ]);
        expect(diff.containsKey('highlightColor'), false);

        final recolored = reference.copyWith(
          highlightColor: const Color(0xFFFF0000),
        );
        expect(
          recolored.toMapFromReference(reference)['highlightColor'],
          const Color(0xFFFF0000).toHex(),
        );
      });

      test('copyWith keeps the highlights unless replaced', () {
        final layer = highlightedLayer();

        expect(layer.copyWith(text: 'Hello world!').highlights, [hello, world]);
        expect(layer.copyWith(highlights: const []).highlights, isEmpty);
      });
    });
  });
}
