import 'package:flutter_test/flutter_test.dart';
import 'package:pro_image_editor/core/models/layers/layer.dart';

void main() {
  group('TextHighlight', () {
    const highlight = TextHighlight(
      start: 6,
      end: 11,
      startTime: Duration(milliseconds: 400),
      endTime: Duration(milliseconds: 900),
    );

    group('isActiveAt', () {
      test('is active from startTime up to, not including, endTime', () {
        expect(highlight.isActiveAt(const Duration(milliseconds: 399)), false);
        expect(highlight.isActiveAt(const Duration(milliseconds: 400)), true);
        expect(highlight.isActiveAt(const Duration(milliseconds: 899)), true);
        expect(highlight.isActiveAt(const Duration(milliseconds: 900)), false);
      });

      test('is never active when it covers no text', () {
        final empty = TextHighlight.fromMap(const {
          'start': 3,
          'end': 3,
          'startTime': 0,
          'endTime': 500,
        });

        expect(empty.isValid, false);
        expect(empty.isActiveAt(const Duration(milliseconds: 100)), false);
      });
    });

    group('fromMap', () {
      test('round-trips through toMap', () {
        expect(TextHighlight.fromMap(highlight.toMap()), highlight);
      });

      test('stores times in milliseconds', () {
        expect(highlight.toMap(), {
          'start': 6,
          'end': 11,
          'startTime': 400,
          'endTime': 900,
        });
      });

      test('degrades missing values to an invalid highlight', () {
        final parsed = TextHighlight.fromMap(const {});

        expect(parsed.start, 0);
        expect(parsed.end, 0);
        expect(parsed.startTime, Duration.zero);
        expect(parsed.endTime, Duration.zero);
        expect(parsed.isValid, false);
      });

      test('accepts numbers that are not ints', () {
        final parsed = TextHighlight.fromMap(const {
          'start': 1.0,
          'end': 4.0,
          'startTime': 100.0,
          'endTime': 200.0,
        });

        expect(
          parsed,
          const TextHighlight(
            start: 1,
            end: 4,
            startTime: Duration(milliseconds: 100),
            endTime: Duration(milliseconds: 200),
          ),
        );
      });
    });

    group('copyWith', () {
      test('replaces only the given fields', () {
        final moved = highlight.copyWith(
          startTime: const Duration(milliseconds: 500),
        );

        expect(moved.start, 6);
        expect(moved.end, 11);
        expect(moved.startTime, const Duration(milliseconds: 500));
        expect(moved.endTime, const Duration(milliseconds: 900));
      });
    });

    group('equality', () {
      test('compares by value', () {
        final same = TextHighlight.fromMap(highlight.toMap());

        expect(same, highlight);
        expect(same.hashCode, highlight.hashCode);
        expect(highlight.copyWith(end: 12), isNot(highlight));
      });
    });
  });
}
