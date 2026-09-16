import 'package:flutter_test/flutter_test.dart';
import 'package:pro_image_editor/features/filter_editor/utils/filter_generator/filter_addons.dart';
import 'package:pro_image_editor/features/tune_editor/models/tune_adjustment_matrix.dart';
import 'package:pro_image_editor/features/tune_editor/utils/merge_tune_adjustments.dart';

TuneAdjustmentMatrix _brightness(
  double value, {
  Duration? startTime,
  Duration? endTime,
  Duration? enterDuration,
}) {
  return TuneAdjustmentMatrix(
    id: 'brightness',
    value: value,
    matrix: ColorFilterAddons.brightness(value),
    startTime: startTime,
    endTime: endTime,
    enterDuration: enterDuration,
  );
}

TuneAdjustmentMatrix _custom(String id, double value) {
  return TuneAdjustmentMatrix(
    id: id,
    value: value,
    matrix: ColorFilterAddons.brightness(value),
  );
}

void main() {
  group('mergeTuneAdjustments', () {
    test('returns the sliders when nothing was applied yet', () {
      final sliders = [_brightness(-0.2), _custom('contrast', 0.1)];

      final merged = mergeTuneAdjustments(applied: [], sliders: sliders);

      expect(merged, sliders);
    });

    test('collapses stacked global ids into the slider value', () {
      final merged = mergeTuneAdjustments(
        applied: [_brightness(-0.1), _brightness(-0.4)],
        sliders: [_brightness(-0.2), _custom('contrast', 0.1)],
      );

      expect(merged, [_brightness(-0.2), _custom('contrast', 0.1)]);
    });

    test('keeps timed entries and custom ids in place', () {
      final timed = _brightness(
        -0.9,
        startTime: const Duration(seconds: 1),
        endTime: const Duration(seconds: 4),
      );
      final custom = _custom('custom-vignette', 0.5);

      final merged = mergeTuneAdjustments(
        applied: [timed, custom, _brightness(-0.4)],
        sliders: [_brightness(0.1)],
      );

      expect(merged, [timed, custom, _brightness(0.1)]);
    });

    test('keeps repeated timed entries of the same id', () {
      final firstRange = _brightness(
        -0.2,
        startTime: Duration.zero,
        endTime: const Duration(seconds: 2),
      );
      final secondRange = _brightness(
        0.3,
        startTime: const Duration(seconds: 3),
        endTime: const Duration(seconds: 5),
      );

      final merged = mergeTuneAdjustments(
        applied: [firstRange, secondRange, _brightness(-0.1)],
        sliders: [_brightness(0)],
      );

      expect(merged, [firstRange, secondRange, _brightness(0)]);
    });

    test('treats enterDuration alone as a timeline', () {
      final fading = _brightness(
        -0.5,
        enterDuration: const Duration(milliseconds: 250),
      );

      final merged = mergeTuneAdjustments(
        applied: [fading, _brightness(-0.1)],
        sliders: [_brightness(0.2)],
      );

      expect(merged, [fading, _brightness(0.2)]);
    });

    test('keeps duplicate custom ids and their order', () {
      final first = _custom('custom-vignette', 0.2);
      final second = _custom('custom-vignette', 0.5);

      final merged = mergeTuneAdjustments(
        applied: [first, second],
        sliders: [_brightness(0)],
      );

      expect(merged, [first, second, _brightness(0)]);
    });

    test('returns copies instead of the passed instances', () {
      final applied = _custom('custom-vignette', 0.2);
      final slider = _brightness(0.3);

      final merged = mergeTuneAdjustments(
        applied: [applied],
        sliders: [slider],
      );

      expect(merged, [applied, slider]);
      expect(identical(merged[0], applied), isFalse);
      expect(identical(merged[1], slider), isFalse);
    });
  });
}
