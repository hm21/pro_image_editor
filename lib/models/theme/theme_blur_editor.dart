// Flutter imports:
import 'package:flutter/widgets.dart';

// Project imports:
import 'theme_shared_values.dart';

/// The `BlurEditorTheme` class defines the theme for the blur editor in the
/// image editor.
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
/// - `appBarBackgroundColor`: Background color of the app bar in the blur
/// editor.
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
  /// Creates an instance of the `BlurEditorTheme` class with the specified
  /// theme properties.
  const BlurEditorTheme({
    this.appBarBackgroundColor = imageEditorAppBarColor,
    this.appBarForegroundColor = const Color(0xFFE1E1E1),
    this.background = imageEditorBackgroundColor,
  });

  /// Background color of the app bar in the blur editor.
  final Color appBarBackgroundColor;

  /// Foreground color (text and icons) of the app bar.
  final Color appBarForegroundColor;

  /// Background color of the blur editor.
  final Color background;

  /// Creates a copy of this `BlurEditorTheme` object with the given fields
  /// replaced with new values.
  ///
  /// The [copyWith] method allows you to create a new instance of
  /// [BlurEditorTheme] with some properties updated while keeping the
  /// others unchanged.
  BlurEditorTheme copyWith({
    Color? appBarBackgroundColor,
    Color? appBarForegroundColor,
    Color? background,
  }) {
    return BlurEditorTheme(
      appBarBackgroundColor:
          appBarBackgroundColor ?? this.appBarBackgroundColor,
      appBarForegroundColor:
          appBarForegroundColor ?? this.appBarForegroundColor,
      background: background ?? this.background,
    );
  }
}
