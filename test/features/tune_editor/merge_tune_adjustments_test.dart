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
  group('latestGlobalTuneAdjustment', () {
    test('returns the last untimed entry for an id', () {
      final latest = latestGlobalTuneAdjustment([
        _brightness(-0.1),
        _brightness(-0.4),
      ], 'brightness');

      expect(latest?.value, -0.4);
    });

    test('ignores timed entries with the same id', () {
      final latest = latestGlobalTuneAdjustment([
        _brightness(
          -0.9,
          startTime: const Duration(seconds: 1),
          endTime: const Duration(seconds: 3),
        ),
        _brightness(-0.2),
      ], 'brightness');

      expect(latest?.value, -0.2);
      expect(latest?.hasTimeline, isFalse);
    });

    test('returns null when only timed entries exist', () {
      expect(
        latestGlobalTuneAdjustment([
          _brightness(
            -0.9,
            startTime: const Duration(seconds: 1),
            endTime: const Duration(seconds: 3),
          ),
        ], 'brightness'),
        isNull,
      );
    });
  });

  group('mergeTuneEditorResult', () {
    test('replaces stacked global ids with the session values', () {
      final merged = mergeTuneEditorResult(
        existing: [_brightness(-0.1), _brightness(-0.4)],
        session: [_brightness(-0.2), _custom('contrast', 0.1)],
      );

      expect(merged.where((item) => item.id == 'brightness').length, 1);
      expect(merged.firstWhere((item) => item.id == 'brightness').value, -0.2);
      expect(merged.firstWhere((item) => item.id == 'contrast').value, 0.1);
    });

    test('keeps timed entries and unknown custom ids', () {
      final timed = _brightness(
        -0.9,
        startTime: const Duration(seconds: 1),
        endTime: const Duration(seconds: 4),
      );
      final custom = _custom('custom-vignette', 0.5);

      final merged = mergeTuneEditorResult(
        existing: [timed, custom, _brightness(-0.4)],
        session: [_brightness(0.1)],
      );

      expect(merged, [timed, custom, _brightness(0.1)]);
    });

    test('keeps repeated timed entries of the same id', () {
      final firstRange = _brightness(
        -0.2,
        startTime: const Duration(seconds: 0),
        endTime: const Duration(seconds: 2),
      );
      final secondRange = _brightness(
        0.3,
        startTime: const Duration(seconds: 3),
        endTime: const Duration(seconds: 5),
      );

      final merged = mergeTuneEditorResult(
        existing: [firstRange, secondRange, _brightness(-0.1)],
        session: [_brightness(0)],
      );

      expect(merged.where((item) => item.id == 'brightness').length, 3);
      expect(merged.where((item) => item.hasTimeline).toList(), [
        firstRange,
        secondRange,
      ]);
    });

    test('treats enterDuration as timeline and preserves it', () {
      final fading = _brightness(
        -0.5,
        enterDuration: const Duration(milliseconds: 250),
      );

      final merged = mergeTuneEditorResult(
        existing: [fading, _brightness(-0.1)],
        session: [_brightness(0.2)],
      );

      expect(merged.where((item) => item.hasTimeline).single, fading);
      expect(merged.firstWhere((item) => !item.hasTimeline).value, 0.2);
    });

    test('preserves unknown ids including order and duplicates', () {
      final first = _custom('custom-vignette', 0.2);
      final second = _custom('custom-vignette', 0.5);

      final merged = mergeTuneEditorResult(
        existing: [first, second],
        session: [_brightness(0)],
      );

      expect(merged.where((item) => item.id == 'custom-vignette').toList(), [
        first,
        second,
      ]);
    });
  });
}
