import 'package:flutter/widgets.dart';

import 'theme_shared_values.dart';

/// The `FilterEditorTheme` class defines the theme for the filter editor in the image editor.
/// It includes properties such as colors for the app bar, background, and preview text.
///
/// Usage:
///
/// ```dart
/// FilterEditorTheme filterEditorTheme = FilterEditorTheme(
///   appBarBackgroundColor: Colors.black,
///   appBarForegroundColor: Colors.white,
///   background: Colors.grey,
///   previewTextColor: Colors.blue,
/// );
/// ```
///
/// Properties:
///
/// - `appBarBackgroundColor`: Background color of the app bar in the filter editor.
///
/// - `appBarForegroundColor`: Foreground color (text and icons) of the app bar.
///
/// - `background`: Background color of the filter editor.
///
/// - `previewTextColor`: Color of the preview text.
///
/// Example Usage:
///
/// ```dart
/// FilterEditorTheme filterEditorTheme = FilterEditorTheme(
///   appBarBackgroundColor: Colors.black,
///   appBarForegroundColor: Colors.white,
///   background: Colors.grey,
///   previewTextColor: Colors.blue,
/// );
///
/// Color appBarBackgroundColor = filterEditorTheme.appBarBackgroundColor;
/// Color background = filterEditorTheme.background;
/// // Access other theme properties...
/// ```
class FilterEditorTheme {
  /// Background color of the app bar in the filter editor.
  final Color appBarBackgroundColor;

  /// Foreground color (text and icons) of the app bar.
  final Color appBarForegroundColor;

  /// Background color of the filter editor.
  final Color background;

  /// Color of the preview text.
  final Color previewTextColor;

  /// Color from the background from the bottom bar.
  final Color whatsAppBottomBarColor;

  /// Creates an instance of the `FilterEditorTheme` class with the specified theme properties.
  const FilterEditorTheme({
    this.appBarBackgroundColor = imageEditorAppBarColor,
    this.appBarForegroundColor = const Color(0xFFE1E1E1),
    this.previewTextColor = const Color(0xFFE1E1E1),
    this.whatsAppBottomBarColor = const Color(0xFF121B22),
    this.background = imageEditorBackgroundColor,
  });
}
