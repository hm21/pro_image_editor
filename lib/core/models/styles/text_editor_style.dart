// Flutter imports:
import 'package:flutter/material.dart';

import '../../constants/editor_style_constants.dart';

/// The `TextEditorStyle` class defines the style for the text editor in the
/// image editor.
/// It includes properties such as colors for the app bar, background, text
/// input, and more.
///
/// Usage:
///
/// ```dart
/// TextEditorStyle TextEditorStyle = TextEditorStyle(
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
/// TextEditorStyle TextEditorStyle = TextEditorStyle(
///   appBarBackgroundColor: Colors.black,
///   appBarForegroundColor: Colors.white,
///   background: Colors.grey.withOpacity(0.6),
///   inputHintColor: Colors.grey,
///   inputCursorColor: Colors.blue,
/// );
///
/// Color appBarBackgroundColor = TextEditorStyle.appBarBackgroundColor;
/// Color background = TextEditorStyle.background;
/// // Access other style properties...
/// ```
class TextEditorStyle {
  /// Creates an instance of the `TextEditorStyle` class with the specified
  /// style properties.
  const TextEditorStyle({
    this.fontSizeBottomSheetTitle,
    this.textFieldMargin =
        const EdgeInsets.only(bottom: kBottomNavigationBarHeight),
    this.appBarBackground = kImageEditorAppBarBackground,
    this.appBarColor = kImageEditorAppBarColor,
    this.bottomBarBackground = kImageEditorBottomBarBackground,
    this.background = const Color(0x9B000000),
    this.bottomBarMainAxisAlignment = MainAxisAlignment.spaceEvenly,
    this.inputHintColor = const Color(0xFFBDBDBD),
    this.inputCursorColor = kImageEditorPrimaryColor,
    this.fontScaleBottomSheetBackground = const Color(0xFF252728),
  });

  /// Background color of the app bar in the text editor.
  final Color appBarBackground;

  /// Background color of the bottom bar in the text editor.
  final Color bottomBarBackground;

  /// Foreground color (text and icons) of the app bar.
  final Color appBarColor;

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

  /// Background color for the font scale bottom sheet.
  final Color fontScaleBottomSheetBackground;

  /// Creates a copy of this `TextEditorStyle` object with the given fields
  /// replaced with new values.
  ///
  /// The [copyWith] method allows you to create a new instance of
  /// [TextEditorStyle] with some properties updated while keeping the
  /// others unchanged.
  TextEditorStyle copyWith({
    Color? appBarBackground,
    Color? appBarColor,
    Color? bottomBarBackground,
    Color? background,
    Color? inputHintColor,
    Color? inputCursorColor,
    Color? fontScaleBottomSheetBackground,
    MainAxisAlignment? bottomBarMainAxisAlignment,
    EdgeInsets? textFieldMargin,
    TextStyle? fontSizeBottomSheetTitle,
  }) {
    return TextEditorStyle(
      fontScaleBottomSheetBackground:
          fontScaleBottomSheetBackground ?? this.fontScaleBottomSheetBackground,
      appBarBackground: appBarBackground ?? this.appBarBackground,
      appBarColor: appBarColor ?? this.appBarColor,
      bottomBarBackground: bottomBarBackground ?? this.bottomBarBackground,
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
