// Flutter imports:
import 'dart:ui' as ui;

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
    this.textHeight = 0.0,
    this.leadingDistribution = ui.TextLeadingDistribution.proportional,
    this.fontSizeBottomSheetTitle,
    this.textFieldMargin = const EdgeInsets.only(
      bottom: kBottomNavigationBarHeight,
    ),
    this.textFieldPadding = EdgeInsets.zero,
    this.appBarBackground = kImageEditorAppBarBackground,
    this.appBarColor = kImageEditorAppBarColor,
    this.bottomBarBackground = kImageEditorBottomBarBackground,
    this.background = const Color(0x9B000000),
    this.bottomBarMainAxisAlignment = MainAxisAlignment.spaceEvenly,
    this.inputHintColor = const Color(0xFFBDBDBD),
    this.inputCursorColor = kImageEditorPrimaryColor,
    this.fontScaleBottomSheetBackground = const Color(0xFF252728),
    this.inputTextFieldBackground = Colors.transparent,
    this.inputTextFieldBorderColor = Colors.transparent,
    this.inputTextFieldBorderRadius = const BorderRadius.all(
      Radius.circular(4),
    ),
    this.inputTextFieldPadding = EdgeInsets.zero,
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

  /// Padding value applied outside the scroll area of the text field.
  ///
  /// This padding is always visible at the screen edges, even when the text
  /// field content is wider than the screen and scrollable.
  final EdgeInsets textFieldPadding;

  /// Title of the bottom sheet used to select the font-size.
  final TextStyle? fontSizeBottomSheetTitle;

  /// Background color for the font scale bottom sheet.
  final Color fontScaleBottomSheetBackground;

  /// Background color of the input text field.
  final Color inputTextFieldBackground;

  /// Border color of the input text field.
  final Color inputTextFieldBorderColor;

  /// Border radius of the input text field.
  final BorderRadius inputTextFieldBorderRadius;

  /// Padding of the input text field.
  final EdgeInsets inputTextFieldPadding;

  /// Height value for the text input style. Set to 0.0 for proper centering
  /// on various platforms. Set to null to use the default line height.
  final double? textHeight;

  /// Controls how extra leading from the [TextStyle.height] multiplier is
  /// distributed above and below the text glyph.
  ///
  /// [TextLeadingDistribution.proportional] distributes leading proportional
  /// to the font's ascent / descent ratio (~75% above, ~25% below for most
  /// Latin fonts). This is the default and matches Flutter's standard
  /// rendering.
  ///
  /// [TextLeadingDistribution.even] splits the extra leading 50 / 50, which
  /// visually centres glyphs inside their rounded background rects when
  /// [TextStyle.height] is greater than 1.0.
  final ui.TextLeadingDistribution leadingDistribution;

  /// Creates a copy of this `TextEditorStyle` object with the given fields
  /// replaced with new values.
  ///
  /// The [copyWith] method allows you to create a new instance of
  /// [TextEditorStyle] with some properties updated while keeping the
  /// others unchanged.
  TextEditorStyle copyWith({
    double? textHeight,
    ui.TextLeadingDistribution? leadingDistribution,
    Color? appBarBackground,
    Color? appBarColor,
    Color? bottomBarBackground,
    Color? background,
    Color? inputHintColor,
    Color? inputCursorColor,
    Color? fontScaleBottomSheetBackground,
    Color? inputTextFieldBackground,
    Color? inputTextFieldBorderColor,
    BorderRadius? inputTextFieldBorderRadius,
    EdgeInsets? inputTextFieldPadding,
    MainAxisAlignment? bottomBarMainAxisAlignment,
    EdgeInsets? textFieldMargin,
    EdgeInsets? textFieldPadding,
    TextStyle? fontSizeBottomSheetTitle,
  }) {
    return TextEditorStyle(
      textHeight: textHeight ?? this.textHeight,
      leadingDistribution: leadingDistribution ?? this.leadingDistribution,
      fontScaleBottomSheetBackground:
          fontScaleBottomSheetBackground ?? this.fontScaleBottomSheetBackground,
      appBarBackground: appBarBackground ?? this.appBarBackground,
      appBarColor: appBarColor ?? this.appBarColor,
      bottomBarBackground: bottomBarBackground ?? this.bottomBarBackground,
      background: background ?? this.background,
      inputHintColor: inputHintColor ?? this.inputHintColor,
      inputCursorColor: inputCursorColor ?? this.inputCursorColor,
      inputTextFieldBackground:
          inputTextFieldBackground ?? this.inputTextFieldBackground,
      inputTextFieldBorderColor:
          inputTextFieldBorderColor ?? this.inputTextFieldBorderColor,
      inputTextFieldBorderRadius:
          inputTextFieldBorderRadius ?? this.inputTextFieldBorderRadius,
      inputTextFieldPadding:
          inputTextFieldPadding ?? this.inputTextFieldPadding,
      bottomBarMainAxisAlignment:
          bottomBarMainAxisAlignment ?? this.bottomBarMainAxisAlignment,
      textFieldMargin: textFieldMargin ?? this.textFieldMargin,
      textFieldPadding: textFieldPadding ?? this.textFieldPadding,
      fontSizeBottomSheetTitle:
          fontSizeBottomSheetTitle ?? this.fontSizeBottomSheetTitle,
    );
  }
}
