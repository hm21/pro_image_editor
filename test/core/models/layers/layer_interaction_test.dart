import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:pro_image_editor/core/models/layers/layer_interaction.dart';
import 'package:pro_image_editor/pro_image_editor.dart';
import 'package:pro_image_editor/shared/services/import_export/utils/key_minifier.dart';

Rect _bounds(Size editorBodySize) => Offset.zero & editorBodySize;

void main() {
  group('LayerInteraction limits', () {
    test('are not set by default', () {
      final interaction = LayerInteraction();

      expect(interaction.minScale, isNull);
      expect(interaction.maxScale, isNull);
      expect(interaction.bounds, isNull);
      expect(LayerInteraction.fromDefaultValue(false).minScale, isNull);
    });

    test('toMap writes the scale limits only when they are set', () {
      expect(LayerInteraction().toMap().keys, [
        'enableMove',
        'enableScale',
        'enableRotate',
        'enableSelection',
        'enableEdit',
      ]);

      final map = LayerInteraction(
        minScale: 0.5,
        maxScale: 2,
        bounds: _bounds,
      ).toMap();
      expect(map['minScale'], 0.5);
      expect(map['maxScale'], 2);
      expect(map.containsKey('bounds'), isFalse);
    });

    test('scale limits survive a JSON round trip, the bounds do not', () {
      final interaction = LayerInteraction(
        enableRotate: false,
        minScale: 0.75,
        maxScale: 1.5,
        bounds: _bounds,
      );

      final json = jsonDecode(jsonEncode(interaction.toMap()));
      final restored = LayerInteraction.fromMap(
        Map<String, dynamic>.from(json as Map),
      );

      expect(restored.enableRotate, isFalse);
      expect(restored.minScale, 0.75);
      expect(restored.maxScale, 1.5);
      expect(restored.bounds, isNull);
    });

    test('scale limits survive a minified round trip', () {
      final minifier = EditorKeyMinifier(enableMinify: true);
      final interaction = LayerInteraction(minScale: 0.75, maxScale: 1.5);

      final minified = interaction
          .toMap(enableMinify: true)
          .map<String, dynamic>(
            (key, value) =>
                MapEntry(minifier.convertLayerInteractionKey(key), value),
          );
      expect(minified['n'], 0.75);
      expect(minified['x'], 1.5);

      final restored = LayerInteraction.fromMap(
        minified,
        keyConverter: minifier.convertLayerInteractionKey,
      );
      expect(restored.minScale, 0.75);
      expect(restored.maxScale, 1.5);
    });

    test('a map stored without the limits loads without them', () {
      final restored = LayerInteraction.fromMap(const {
        'enableMove': true,
        'enableScale': false,
        'enableRotate': true,
        'enableSelection': true,
        'enableEdit': true,
      });

      expect(restored.enableScale, isFalse);
      expect(restored.minScale, isNull);
      expect(restored.maxScale, isNull);

      final minifier = EditorKeyMinifier(enableMinify: true);
      final minified = LayerInteraction.fromMap(const {
        'm': true,
        's': false,
      }, keyConverter: minifier.convertLayerInteractionKey);
      expect(minified.enableScale, isFalse);
      expect(minified.minScale, isNull);
      expect(minified.maxScale, isNull);
    });

    test('toMapFromReference writes changed and removed scale limits', () {
      final before = LayerInteraction(minScale: 0.5);
      final after = LayerInteraction(maxScale: 2);

      expect(after.toMapFromReference(before), {
        'minScale': null,
        'maxScale': 2,
      });
      expect(after.toMapFromReference(after.copyWith()), isEmpty);
    });

    test('copyWith keeps the limits and replaces given ones', () {
      final interaction = LayerInteraction(
        minScale: 0.5,
        maxScale: 2,
        bounds: _bounds,
      );

      final copy = interaction.copyWith(enableMove: false);
      expect(copy.minScale, 0.5);
      expect(copy.maxScale, 2);
      expect(copy.bounds, same(_bounds));
      expect(copy.enableMove, isFalse);

      Rect other(Size size) => Rect.zero;
      final replaced = interaction.copyWith(maxScale: 3, bounds: other);
      expect(replaced.minScale, 0.5);
      expect(replaced.maxScale, 3);
      expect(replaced.bounds, same(other));
    });

    test('limits take part in equality', () {
      expect(
        LayerInteraction(minScale: 0.5, bounds: _bounds),
        LayerInteraction(minScale: 0.5, bounds: _bounds),
      );
      expect(
        LayerInteraction(minScale: 0.5),
        isNot(LayerInteraction(minScale: 0.6)),
      );
      expect(
        LayerInteraction(maxScale: 2),
        isNot(LayerInteraction(maxScale: 2, bounds: _bounds)),
      );
      expect(
        LayerInteraction(minScale: 0.5, bounds: _bounds).hashCode,
        LayerInteraction(minScale: 0.5, bounds: _bounds).hashCode,
      );
    });

    test('asserts that maxScale is not below minScale', () {
      expect(
        () => LayerInteraction(minScale: 2, maxScale: 1),
        throwsAssertionError,
      );
    });
  });

  group('Layer.toMapFromReference', () {
    test('writes no interaction when only the bounds changed', () {
      final layer = EmojiLayer(
        id: 'a',
        emoji: '🙂',
        interaction: LayerInteraction(minScale: 0.5),
      );
      final next = EmojiLayer(
        id: 'a',
        emoji: '🙂',
        interaction: LayerInteraction(minScale: 0.5, bounds: _bounds),
      );

      expect(next.toMapFromReference(layer).containsKey('interaction'), false);
    });

    test('writes the interaction settings that changed', () {
      final layer = EmojiLayer(
        id: 'a',
        emoji: '🙂',
        interaction: LayerInteraction(minScale: 0.5),
      );
      final next = EmojiLayer(
        id: 'a',
        emoji: '🙂',
        interaction: LayerInteraction(minScale: 0.5, enableMove: false),
      );

      expect(next.toMapFromReference(layer)['interaction'], {
        'enableMove': false,
      });
    });
  });
}
