// Flutter imports:
import 'package:flutter/services.dart';

import '../../constants/editor_style_constants.dart';

/// The `BlurEditorStyle` class defines the style for the blur editor in the
/// image editor.
/// It includes properties such as colors for the app bar and background.
///
/// Usage:
///
/// ```dart
/// BlurEditorStyle BlurEditorStyle = BlurEditorStyle(
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
/// BlurEditorStyle BlurEditorStyle = BlurEditorStyle(
///   appBarBackgroundColor: Colors.black,
///   appBarForegroundColor: Colors.white,
///   background: Colors.grey,
/// );
///
/// Color appBarBackgroundColor = BlurEditorStyle.appBarBackgroundColor;
/// Color background = BlurEditorStyle.background;
/// ```
class BlurEditorStyle {
  /// Creates an instance of the `BlurEditorStyle` class with the specified
  /// style properties.
  const BlurEditorStyle({
    this.appBarBackgroundColor = kImageEditorAppBarBackground,
    this.appBarForegroundColor = const Color(0xFFE1E1E1),
    this.background = kImageEditorBackground,
    this.uiOverlayStyle = kImageEditorUiOverlayStyle,
  });

  /// Background color of the app bar in the blur editor.
  final Color appBarBackgroundColor;

  /// Foreground color (text and icons) of the app bar.
  final Color appBarForegroundColor;

  /// Background color of the blur editor.
  final Color background;

  /// UI overlay style, defining the appearance of system status bars.
  final SystemUiOverlayStyle uiOverlayStyle;

  /// Creates a copy of this `BlurEditorStyle` object with the given fields
  /// replaced with new values.
  ///
  /// The [copyWith] method allows you to create a new instance of
  /// [BlurEditorStyle] with some properties updated while keeping the
  /// others unchanged.
  BlurEditorStyle copyWith({
    Color? appBarBackgroundColor,
    Color? appBarForegroundColor,
    Color? background,
    SystemUiOverlayStyle? uiOverlayStyle,
  }) {
    return BlurEditorStyle(
      appBarBackgroundColor:
          appBarBackgroundColor ?? this.appBarBackgroundColor,
      appBarForegroundColor:
          appBarForegroundColor ?? this.appBarForegroundColor,
      background: background ?? this.background,
      uiOverlayStyle: uiOverlayStyle ?? this.uiOverlayStyle,
    );
  }
}
