import 'package:flutter/widgets.dart';
import 'package:pro_image_editor/utils/parser/double_parser.dart';

/// Safely parses a [Map] representation of a size to a [Size] object.
///
/// This function attempts to convert the provided [map] to a [Size] object.
/// If the [map] is `null`, missing required keys (`width` and `height`), or
/// contains invalid values, a [fallback] size is returned instead.
///
/// - Parameters:
///   - [map]: A [Map] that is expected to contain `width` and `height` keys,
///            where their values can be converted to [double].
///   - [fallback]: A [Size] value to return if parsing fails or if [map] is
///                  `null`.
///                  Defaults to [Size.zero] if not provided.
///
/// - Returns:
///   A [Size] object constructed from the [map] if parsing succeeds, or the
///   [fallback] size if it fails.
///
/// - Example:
/// ```dart
/// safeParseSize({'width': 200, 'height': 100}); // returns Size(200.0, 100.0)
/// safeParseSize(null);                          // returns Size.zero (fallback)
/// safeParseSize({'width': 'abc', 'height': 50}, fallback: Size(10, 10));
///                                               // returns Size(10.0, 10.0) (fallback)
/// ```
Size safeParseSize(Map<String, dynamic>? map, {Size fallback = Size.zero}) {
  if (map == null) return fallback;

  return Size(
    safeParseDouble(map['width'], fallback: fallback.width),
    safeParseDouble(map['height'], fallback: fallback.height),
  );
}
