import 'package:flutter/widgets.dart';

import 'theme_shared_values.dart';

/// The `BlurEditorTheme` class defines the theme for the blur editor in the image editor.
/// It includes properties such as colors for the app bar and background.
///
/// Usage:
///
/// ```dart
/// BlurEditorTheme BlurEditorTheme = BlurEditorTheme(
///   appBarBackgroundColor: Colors.black,
///   appBarForegroundColor: Colors.white,
///   background: Colors.grey,
/// );
/// ```
///
/// Properties:
///
/// - `appBarBackgroundColor`: Background color of the app bar in the blur editor.
///
/// - `appBarForegroundColor`: Foreground color (text and icons) of the app bar.
///
/// - `background`: Background color of the blur editor.
///
/// Example Usage:
///
/// ```dart
/// BlurEditorTheme BlurEditorTheme = BlurEditorTheme(
///   appBarBackgroundColor: Colors.black,
///   appBarForegroundColor: Colors.white,
///   background: Colors.grey,
/// );
///
/// Color appBarBackgroundColor = BlurEditorTheme.appBarBackgroundColor;
/// Color background = BlurEditorTheme.background;
/// // Access other theme properties...
/// ```
class BlurEditorTheme {
  /// Background color of the app bar in the blur editor.
  final Color appBarBackgroundColor;

  /// Foreground color (text and icons) of the app bar.
  final Color appBarForegroundColor;

  /// Background color of the blur editor.
  final Color background;

  /// Creates an instance of the `BlurEditorTheme` class with the specified theme properties.
  const BlurEditorTheme({
    this.appBarBackgroundColor = imageEditorAppBarColor,
    this.appBarForegroundColor = const Color(0xFFE1E1E1),
    this.background = imageEditorBackgroundColor,
  });
}
