import 'package:flutter/animation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pro_image_editor/shared/utils/timeline_progress.dart';

void main() {
  group('computeTimelineProgress', () {
    double progressAt(Duration currentTime, {Duration? exitDuration}) =>
        computeTimelineProgress(
          currentTime: currentTime,
          startTime: const Duration(seconds: 1),
          endTime: const Duration(seconds: 2),
          enterDuration: null,
          exitDuration: exitDuration,
          defaultEnterCurve: Curves.linear,
          defaultExitCurve: Curves.linear,
        );

    test('is fully visible from the start up to just before the end', () {
      expect(progressAt(const Duration(milliseconds: 999)), 0.0);
      expect(progressAt(const Duration(seconds: 1)), 1.0);
      expect(
        progressAt(
          const Duration(seconds: 2) - const Duration(microseconds: 1),
        ),
        1.0,
      );
    });

    test('is hidden at the end time', () {
      expect(progressAt(const Duration(seconds: 2)), 0.0);
    });

    test('fades out towards the end and is hidden at it', () {
      const exit = Duration(milliseconds: 500);

      expect(
        progressAt(const Duration(milliseconds: 1750), exitDuration: exit),
        closeTo(0.5, 1e-9),
      );
      expect(progressAt(const Duration(seconds: 2), exitDuration: exit), 0.0);
    });
  });
}
