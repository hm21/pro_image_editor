// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'theme_shared_values.dart';

/// The `TextEditorTheme` class defines the theme for the text editor in the
/// image editor.
/// It includes properties such as colors for the app bar, background, text
/// input, and more.
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
/// - `appBarBackgroundColor`: Background color of the app bar in the text
///   editor.
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
  /// Creates an instance of the `TextEditorTheme` class with the specified
  /// theme properties.
  const TextEditorTheme({
    this.fontSizeBottomSheetTitle,
    this.textFieldMargin =
        const EdgeInsets.only(bottom: kBottomNavigationBarHeight),
    this.appBarBackgroundColor = imageEditorAppBarColor,
    this.appBarForegroundColor = const Color(0xFFE1E1E1),
    this.background = const Color(0x9B000000),
    this.bottomBarBackgroundColor = const Color(0xFF000000),
    this.bottomBarMainAxisAlignment = MainAxisAlignment.spaceEvenly,
    this.inputHintColor = const Color(0xFFBDBDBD),
    this.inputCursorColor = imageEditorPrimaryColor,
  });

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

  /// How the children should be placed along the main axis.
  final MainAxisAlignment bottomBarMainAxisAlignment;

  /// Margin value around the textField.
  final EdgeInsets textFieldMargin;

  /// Title of the bottom sheet used to select the font-size.
  final TextStyle? fontSizeBottomSheetTitle;

  /// Creates a copy of this `TextEditorTheme` object with the given fields
  /// replaced with new values.
  ///
  /// The [copyWith] method allows you to create a new instance of
  /// [TextEditorTheme] with some properties updated while keeping the
  /// others unchanged.
  TextEditorTheme copyWith({
    Color? appBarBackgroundColor,
    Color? bottomBarBackgroundColor,
    Color? appBarForegroundColor,
    Color? background,
    Color? inputHintColor,
    Color? inputCursorColor,
    MainAxisAlignment? bottomBarMainAxisAlignment,
    EdgeInsets? textFieldMargin,
    TextStyle? fontSizeBottomSheetTitle,
  }) {
    return TextEditorTheme(
      appBarBackgroundColor:
          appBarBackgroundColor ?? this.appBarBackgroundColor,
      bottomBarBackgroundColor:
          bottomBarBackgroundColor ?? this.bottomBarBackgroundColor,
      appBarForegroundColor:
          appBarForegroundColor ?? this.appBarForegroundColor,
      background: background ?? this.background,
      inputHintColor: inputHintColor ?? this.inputHintColor,
      inputCursorColor: inputCursorColor ?? this.inputCursorColor,
      bottomBarMainAxisAlignment:
          bottomBarMainAxisAlignment ?? this.bottomBarMainAxisAlignment,
      textFieldMargin: textFieldMargin ?? this.textFieldMargin,
      fontSizeBottomSheetTitle:
          fontSizeBottomSheetTitle ?? this.fontSizeBottomSheetTitle,
    );
  }
}
