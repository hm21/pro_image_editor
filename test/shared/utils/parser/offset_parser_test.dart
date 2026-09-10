import 'package:flutter_test/flutter_test.dart';
import 'package:pro_image_editor/shared/utils/parser/offset_parser.dart';

void main() {
  group('safeParseOffset', () {
    test('parses valid dx and dy', () {
      final map = {'dx': 200, 'dy': 100};
      final result = safeParseOffset(map);
      expect(result, const Offset(200.0, 100.0));
    });

    test('returns fallback for null map', () {
      const fallback = Offset(10, 20);
      final result = safeParseOffset(null, fallback: fallback);
      expect(result, fallback);
    });

    test('returns Offset.zero for null map if no fallback', () {
      final result = safeParseOffset(null);
      expect(result, Offset.zero);
    });

    test('parses dx and dy as strings', () {
      final map = {'dx': '50.5', 'dy': '-25.2'};
      final result = safeParseOffset(map);
      expect(result, const Offset(50.5, -25.2));
    });

    test('uses fallback if dx is invalid', () {
      const fallback = Offset(1, 2);
      final map = {'dx': 'abc', 'dy': 10};
      final result = safeParseOffset(map, fallback: fallback);
      expect(result.dx, fallback.dx);
      expect(result.dy, 10);
    });

    test('uses fallback if dy is invalid', () {
      const fallback = Offset(3, 4);
      final map = {'dx': 10, 'dy': 'xyz'};
      final result = safeParseOffset(map, fallback: fallback);
      expect(result.dx, 10);
      expect(result.dy, fallback.dy);
    });

    test('uses fallback if both dx and dy are missing', () {
      const fallback = Offset(5, 6);
      Map<String, dynamic>? map = {};
      final result = safeParseOffset(map, fallback: fallback);
      expect(result, fallback);
    });

    test('parses using "x" and "y" keys', () {
      final map = {'x': 12, 'y': 34};
      final result = safeParseOffset(map);
      expect(result, const Offset(12.0, 34.0));
    });

    test('uses fallback dx if dx is missing', () {
      const fallback = Offset(7, 8);
      final map = {'dy': 20};
      final result = safeParseOffset(map, fallback: fallback);
      expect(result.dx, fallback.dx);
      expect(result.dy, 20.0);
    });

    test('uses fallback dy if dy is missing', () {
      const fallback = Offset(9, 10);
      final map = {'dx': 30};
      final result = safeParseOffset(map, fallback: fallback);
      expect(result.dx, 30.0);
      expect(result.dy, fallback.dy);
    });
  });
}
