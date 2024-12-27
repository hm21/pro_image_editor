/// Safely parses a [dynamic] value to an [int].
///
/// This function attempts to convert the provided [value] to an [int].
/// If the [value] is `null`, an invalid number, or cannot be parsed,
/// the [fallback] value is returned instead.
///
/// - Parameters:
///   - [value]: A [dynamic] value that is expected to be convertible to an
///              [int].
///   - [fallback]: An [int] value to return if parsing fails or if [value] is
///                 `null`.
///                 Defaults to 0 if not provided.
///
/// - Returns:
///   An [int] representation of the [value] if parsing succeeds, or the
///   [fallback] value if it fails.
///
/// - Example:
/// ```dart
/// safeParseInt('123');       // returns 123
/// safeParseInt(null);        // returns 0 (fallback)
/// safeParseInt('abc', fallback: 10);  // returns 10 (fallback)
/// safeParseInt(15);          // returns 15 (automatic conversion from int)
/// ```
int safeParseInt(dynamic value, {int fallback = 0}) {
  return int.tryParse((value ?? fallback).toString()) ?? fallback;
}

/// Attempts to parse a [dynamic] value to an [int].
///
/// This function tries to convert the provided [value] to an [int].
/// If the [value] cannot be parsed, it returns `null`.
///
/// - Parameters:
///   - [value]: A [dynamic] value that is expected to be convertible to an
///              [int].
///
/// - Returns:
///   An [int] if the parsing is successful, or `null` if parsing fails.
///
/// - Example:
/// ```dart
/// tryParseInt('123');       // returns 123
/// tryParseInt('abc');       // returns null
/// tryParseInt(42);          // returns 42 (automatic conversion from int)
/// tryParseInt(null);        // returns null
/// ```
int? tryParseInt(dynamic value) {
  return int.tryParse(value.toString());
}
