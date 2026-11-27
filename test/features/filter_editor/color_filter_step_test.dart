import 'package:flutter_test/flutter_test.dart';
import 'package:pro_image_editor/features/filter_editor/filter_editor.dart';

void main() {
  group(ColorFilterStep, () {
    group('matrix', () {
      test('calls the addon of its type with its values', () {
        expect(
          ColorFilterStep.colorOverlay(228, 130, 225, 0.13).matrix,
          ColorFilterAddons.colorOverlay(228, 130, 225, 0.13),
        );
        expect(
          ColorFilterStep.rgbScale(1.35, 1, 0.55).matrix,
          ColorFilterAddons.rgbScale(1.35, 1, 0.55),
        );
        expect(
          ColorFilterStep.addictiveColor(50, 0, 25).matrix,
          ColorFilterAddons.addictiveColor(50, 0, 25),
        );
        expect(
          ColorFilterStep.temperature(-0.2).matrix,
          ColorFilterAddons.temperature(-0.2),
        );
        expect(
          ColorFilterStep.grayscale().matrix,
          ColorFilterAddons.grayscale(),
        );
        expect(ColorFilterStep.sepia(0.3).matrix, ColorFilterAddons.sepia(0.3));
        expect(ColorFilterStep.invert().matrix, ColorFilterAddons.invert());
        expect(
          ColorFilterStep.brightness(-0.1).matrix,
          ColorFilterAddons.brightness(-0.1),
        );
        expect(
          ColorFilterStep.contrast(0.15).matrix,
          ColorFilterAddons.contrast(0.15),
        );
        expect(ColorFilterStep.hue(0.4).matrix, ColorFilterAddons.hue(0.4));
        expect(
          ColorFilterStep.saturation(-0.5).matrix,
          ColorFilterAddons.saturation(-0.5),
        );
        expect(
          ColorFilterStep.exposure(0.15).matrix,
          ColorFilterAddons.exposure(0.15),
        );
        expect(ColorFilterStep.fade(0.6).matrix, ColorFilterAddons.fade(0.6));
        expect(ColorFilterStep.tint(0.04).matrix, ColorFilterAddons.tint(0.04));
      });
    });

    group('map', () {
      test('round-trips every type', () {
        final steps = [
          ColorFilterStep.colorOverlay(0, 140, 140, 0.08),
          ColorFilterStep.rgbScale(1.04, 1, 1.02),
          ColorFilterStep.grayscale(),
          ColorFilterStep.contrast(0.1),
        ];

        expect(
          steps.map((step) => ColorFilterStep.fromMap(step.toMap())).toList(),
          steps,
        );
      });

      test('reads integers as doubles', () {
        final step = ColorFilterStep.fromMap(const {
          'type': 'addictiveColor',
          'values': [50, 0, 0],
        });

        expect(step, ColorFilterStep.addictiveColor(50, 0, 0));
      });

      test('throws a FormatException for an unknown type', () {
        expect(
          () => ColorFilterStep.fromMap(const {
            'type': 'glow',
            'values': <num>[],
          }),
          throwsFormatException,
        );
      });

      test('throws a FormatException for the wrong number of values', () {
        expect(
          () => ColorFilterStep.fromMap(const {
            'type': 'contrast',
            'values': [0.1, 0.2],
          }),
          throwsFormatException,
        );
        expect(
          () => ColorFilterStep.fromMap(const {
            'type': 'contrast',
            'values': ['0.1'],
          }),
          throwsFormatException,
        );
      });
    });

    group('copyWith', () {
      test('keeps the type and replaces the values', () {
        final step = ColorFilterStep.brightness(0.1).copyWith(values: [0.3]);

        expect(step, ColorFilterStep.brightness(0.3));
      });

      test('throws an ArgumentError for the wrong number of values', () {
        expect(
          () => ColorFilterStep.brightness(0.1).copyWith(values: [0.3, 0.4]),
          throwsArgumentError,
        );
        expect(
          () => ColorFilterStep(ColorFilterStepType.rgbScale, const [1, 1]),
          throwsArgumentError,
        );
      });
    });
  });

  group(FilterModel, () {
    group('fromSteps', () {
      test('builds its matrices from its steps, in order', () {
        final filter = FilterModel.fromSteps(
          name: 'Test',
          steps: [ColorFilterStep.grayscale(), ColorFilterStep.contrast(0.3)],
        );

        expect(filter.filters, [
          ColorFilterAddons.grayscale(),
          ColorFilterAddons.contrast(0.3),
        ]);
      });
    });

    group('copyWith', () {
      test('rebuilds the matrices from new steps', () {
        final filter = PresetFilters.clarendon.copyWith(
          steps: [
            ColorFilterStep.brightness(0.2),
            ...PresetFilters.clarendon.steps.skip(1),
          ],
        );

        expect(filter.name, 'Clarendon');
        expect(filter.filters.first, ColorFilterAddons.brightness(0.2));
        expect(filter.filters.skip(1), PresetFilters.clarendon.filters.skip(1));
      });

      test('keeps the steps and matrices when only the name changes', () {
        final filter = PresetFilters.crema.copyWith(name: 'Mine');

        expect(filter.name, 'Mine');
        expect(filter.steps, PresetFilters.crema.steps);
        expect(filter.filters, same(PresetFilters.crema.filters));
      });

      test('keeps a filter built from matrices without steps', () {
        const filter = FilterModel(
          name: 'Matrix',
          filters: [
            [1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 0],
          ],
        );

        final copy = filter.copyWith(name: 'Copy');

        expect(copy.steps, isEmpty);
        expect(copy.filters, same(filter.filters));
      });
    });
  });

  group(PresetFilters, () {
    test('every preset but none keeps the steps it is built from', () {
      for (final filter in presetFiltersList) {
        if (filter == PresetFilters.none) {
          expect(filter.steps, isEmpty);
          continue;
        }
        expect(filter.steps, isNotEmpty, reason: filter.name);
        expect(filter.filters, [
          for (final step in filter.steps) step.matrix,
        ], reason: filter.name);
      }
    });

    test('Clarendon is brightness, contrast and saturation', () {
      expect(PresetFilters.clarendon.steps, [
        ColorFilterStep.brightness(.1),
        ColorFilterStep.contrast(.1),
        ColorFilterStep.saturation(.15),
      ]);
    });
  });
}
