import 'package:flutter/widgets.dart';

import 'theme_shared_values.dart';

/// The `TextEditorTheme` class defines the theme for the text editor in the image editor.
/// It includes properties such as colors for the app bar, background, text input, and more.
///
/// Usage:
///
/// ```dart
/// TextEditorTheme textEditorTheme = TextEditorTheme(
///   appBarBackgroundColor: Colors.black,
///   appBarForegroundColor: Colors.white,
///   background: Colors.grey.withOpacity(0.6),
///   inputHintColor: Colors.grey,
///   inputCursorColor: Colors.blue,
/// );
/// ```
///
/// Properties:
///
/// - `appBarBackgroundColor`: Background color of the app bar in the text editor.
///
/// - `appBarForegroundColor`: Foreground color (text and icons) of the app bar.
///
/// - `background`: Background color of the text editor.
///
/// - `inputHintColor`: Color of input hints in the text editor.
///
/// - `inputCursorColor`: Color of the input cursor in the text editor.
///
/// Example Usage:
///
/// ```dart
/// TextEditorTheme textEditorTheme = TextEditorTheme(
///   appBarBackgroundColor: Colors.black,
///   appBarForegroundColor: Colors.white,
///   background: Colors.grey.withOpacity(0.6),
///   inputHintColor: Colors.grey,
///   inputCursorColor: Colors.blue,
/// );
///
/// Color appBarBackgroundColor = textEditorTheme.appBarBackgroundColor;
/// Color background = textEditorTheme.background;
/// // Access other theme properties...
/// ```
class TextEditorTheme {
  /// Background color of the app bar in the text editor.
  final Color appBarBackgroundColor;

  /// Background color of the bottom bar in the text editor.
  final Color bottomBarBackgroundColor;

  /// Foreground color (text and icons) of the app bar.
  final Color appBarForegroundColor;

  /// Background color of the text editor.
  final Color background;

  /// Color of input hints in the text editor.
  final Color inputHintColor;

  /// Color of the input cursor in the text editor.
  final Color inputCursorColor;

  /// Creates an instance of the `TextEditorTheme` class with the specified theme properties.
  const TextEditorTheme({
    this.appBarBackgroundColor = imageEditorAppBarColor,
    this.appBarForegroundColor = const Color(0xFFE1E1E1),
    this.background = const Color(0x9B000000),
    this.bottomBarBackgroundColor = const Color(0xFF000000),
    this.inputHintColor = const Color(0xFFBDBDBD),
    this.inputCursorColor = imageEditorPrimaryColor,
  });
}
