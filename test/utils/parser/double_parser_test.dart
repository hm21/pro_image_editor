import 'package:flutter_test/flutter_test.dart';
import 'package:pro_image_editor/utils/parser/double_parser.dart';

void main() {
  group('safeParseDouble', () {
    test('returns double when given a valid string number', () {
      expect(safeParseDouble('3.14'), equals(3.14));
    });

    test('returns fallback when given a non-numeric string', () {
      expect(safeParseDouble('abc', fallback: 1.5), equals(1.5));
    });

    test('returns 0 when given a non-numeric string without a fallback', () {
      expect(safeParseDouble('abc'), equals(0.0));
    });

    test('returns 0 when given null', () {
      expect(safeParseDouble(null), equals(0.0));
    });

    test('returns fallback when given null and a fallback value', () {
      expect(safeParseDouble(null, fallback: 2.5), equals(2.5));
    });

    test('returns double when given an integer', () {
      expect(safeParseDouble(10), equals(10.0));
    });

    test('returns double when given a valid double', () {
      expect(safeParseDouble(5.67), equals(5.67));
    });
  });

  group('tryParseDouble', () {
    test('returns double when given a valid string number', () {
      expect(tryParseDouble('3.14'), equals(3.14));
    });

    test('returns null when given a non-numeric string', () {
      expect(tryParseDouble('abc'), isNull);
    });

    test('returns double when given an integer', () {
      expect(tryParseDouble(10), equals(10.0));
    });

    test('returns double when given a valid double', () {
      expect(tryParseDouble(7.89), equals(7.89));
    });

    test('returns null when given null', () {
      expect(tryParseDouble(null), isNull);
    });
  });
}
