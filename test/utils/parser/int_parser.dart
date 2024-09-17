import 'package:flutter_test/flutter_test.dart';
import 'package:pro_image_editor/utils/parser/int_parser.dart';

void main() {
  group('safeParseInt', () {
    test('returns int when given a valid string number', () {
      expect(safeParseInt('123'), equals(123));
    });

    test('returns fallback when given a non-numeric string', () {
      expect(safeParseInt('abc', fallback: 10), equals(10));
    });

    test('returns 0 when given a non-numeric string without a fallback', () {
      expect(safeParseInt('abc'), equals(0));
    });

    test('returns 0 when given null', () {
      expect(safeParseInt(null), equals(0));
    });

    test('returns fallback when given null and a fallback value', () {
      expect(safeParseInt(null, fallback: 5), equals(5));
    });

    test('returns int when given an integer', () {
      expect(safeParseInt(15), equals(15));
    });

    test('returns int when given a double that can be converted to int', () {
      expect(safeParseInt(15.0), equals(15));
    });

    test(
        'returns fallback when given a double that cannot be exactly converted',
        () {
      expect(safeParseInt(15.6, fallback: 2), equals(2));
    });
  });

  group('tryParseInt', () {
    test('returns int when given a valid string number', () {
      expect(tryParseInt('123'), equals(123));
    });

    test('returns null when given a non-numeric string', () {
      expect(tryParseInt('abc'), isNull);
    });

    test('returns null when given null', () {
      expect(tryParseInt(null), isNull);
    });

    test('returns int when given an integer', () {
      expect(tryParseInt(42), equals(42));
    });

    test('returns null when given a double', () {
      expect(tryParseInt(42.5), isNull);
    });
  });
}
