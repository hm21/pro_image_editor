import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:pro_image_editor/core/models/layers/layer.dart';

void main() {
  group(TextGradient, () {
    group('isValid', () {
      test('needs at least two colors', () {
        expect(
          const TextGradient(colors: [Color(0xFFFF0000)]).isValid,
          isFalse,
        );
        expect(
          const TextGradient(
            colors: [Color(0xFFFF0000), Color(0xFF0000FF)],
          ).isValid,
          isTrue,
        );
      });

      test('needs a stop for each color when it has stops', () {
        expect(
          const TextGradient(
            colors: [Color(0xFFFF0000), Color(0xFF0000FF)],
            stops: [0],
          ).isValid,
          isFalse,
        );
      });
    });

    group('toMap', () {
      test('rounds the stops and the angle', () {
        const gradient = TextGradient(
          colors: [Color(0xFFFF0000), Color(0xFF0000FF)],
          stops: [0.123456, 1],
          angle: 0.987654,
        );

        final map = gradient.toMap(maxDecimalPlaces: 2);

        expect(map['stops'], [0.12, 1]);
        expect(map['angle'], 0.99);
      });

      test('leaves out stops it does not have', () {
        const gradient = TextGradient(
          colors: [Color(0xFFFF0000), Color(0xFF0000FF)],
        );

        expect(gradient.toMap(), isNot(contains('stops')));
        expect(TextGradient.fromMap(gradient.toMap()), gradient);
      });
    });

    group('fromMap', () {
      test('reads a map with missing or broken values without throwing', () {
        final gradient = TextGradient.fromMap(const {
          'colors': 'red',
          'angle': 'up',
        });

        expect(gradient.colors, isEmpty);
        expect(gradient.angle, 0);
        expect(gradient.isValid, isFalse);
      });
    });
  });
}
