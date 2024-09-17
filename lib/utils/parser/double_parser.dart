/// Safely parses a [dynamic] value to a [double].
///
/// This function attempts to convert the provided [value] to a [double].
/// If the [value] is `null`, an invalid number, or cannot be parsed,
/// the [fallback] value is returned instead.
///
/// - Parameters:
///   - [value]: A [dynamic] value that is expected to be convertible to a
///              [double].
///   - [fallback]: A [double] value to return if parsing fails or if [value]
///                 is `null`.
///                 Defaults to 0 if not provided.
///
/// - Returns:
///   A [double] representation of the [value] if parsing succeeds, or the
/// [fallback] value if it fails.
///
/// - Example:
/// ```dart
/// safeParseDouble('3.14');     // returns 3.14
/// safeParseDouble(null);       // returns 0 (fallback)
/// safeParseDouble('abc', fallback: 1.5);  // returns 1.5 (fallback)
/// safeParseDouble(10);         // returns 10.0 (automatic conversion from int)
/// ```
double safeParseDouble(dynamic value, {double fallback = 0}) {
  return double.tryParse((value ?? fallback).toString()) ?? fallback;
}

/// Attempts to parse a [dynamic] value to a [double].
///
/// This function tries to convert the provided [value] to a [double].
/// If the [value] cannot be parsed or is invalid, it returns `null`.
///
/// - Parameters:
///   - [value]: A [dynamic] value that is expected to be convertible to a
///              [double].
///
/// - Returns:
///   A [double] if the parsing is successful, or `null` if parsing fails.
///
/// - Example:
/// ```dart
/// tryParseDouble('3.14');    // returns 3.14
/// tryParseDouble('abc');     // returns null
/// tryParseDouble(10);        // returns 10.0 (automatic conversion from int)
/// tryParseDouble(null);      // throws error (null cannot be converted to String)
/// ```
double? tryParseDouble(dynamic value) {
  return double.tryParse(value.toString());
}
