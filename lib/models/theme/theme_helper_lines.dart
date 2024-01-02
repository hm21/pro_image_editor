import 'package:flutter/widgets.dart';

/// The `HelperLineTheme` class defines the theme for helper lines in the image editor.
/// Helper lines are used to assist with alignment and positioning of elements in the editor.
///
/// Usage:
///
/// ```dart
/// HelperLineTheme helperLineTheme = HelperLineTheme(
///   horizontalColor: Colors.blue,
///   verticalColor: Colors.red,
///   rotateColor: Colors.pink,
/// );
/// ```
///
/// Properties:
///
/// - `horizontalColor`: Color of horizontal helper lines.
///
/// - `verticalColor`: Color of vertical helper lines.
///
/// - `rotateColor`: Color of rotation helper lines.
///
/// Example Usage:
///
/// ```dart
/// HelperLineTheme helperLineTheme = HelperLineTheme(
///   horizontalColor: Colors.blue,
///   verticalColor: Colors.red,
///   rotateColor: Colors.pink,
/// );
///
/// Color horizontalColor = helperLineTheme.horizontalColor;
/// Color verticalColor = helperLineTheme.verticalColor;
/// // Access other theme properties...
/// ```
class HelperLineTheme {
  /// Color of horizontal helper lines.
  final Color horizontalColor;

  /// Color of vertical helper lines.
  final Color verticalColor;

  /// Color of rotation helper lines.
  final Color rotateColor;

  /// Creates an instance of the `HelperLineTheme` class with the specified theme properties.
  const HelperLineTheme({
    this.horizontalColor = const Color(0xFF1565C0),
    this.verticalColor = const Color(0xFF1565C0),
    this.rotateColor = const Color(0xFFE91E63),
  });
}
