import 'package:flutter/widgets.dart';

import 'theme_shared_values.dart';

/// The `EmojiEditorTheme` class defines the theme for the emoji editor in the image editor.
/// It includes properties such as colors for the background, category indicator, category icons, and more.
///
/// Usage:
///
/// ```dart
/// EmojiEditorTheme emojiEditorTheme = EmojiEditorTheme(
///   background: Colors.grey,
///   indicatorColor: Colors.blue,
///   iconColorSelected: Colors.green,
///   iconColor: Colors.black,
///   skinToneDialogBgColor: Colors.brown,
///   skinToneIndicatorColor: Colors.orange,
/// );
/// ```
///
/// Properties:
///
/// - `background`: Background color of the emoji editor widget.
///
/// - `indicatorColor`: Color of the category indicator.
///
/// - `iconColorSelected`: Color of the category icon when selected.
///
/// - `iconColor`: Color of the category icons.
///
/// - `skinToneDialogBgColor`: Background color of the skin tone dialog.
///
/// - `skinToneIndicatorColor`: Color of the small triangle next to multiple skin tone emojis.
///
/// Example Usage:
///
/// ```dart
/// EmojiEditorTheme emojiEditorTheme = EmojiEditorTheme(
///   background: Colors.grey,
///   indicatorColor: Colors.blue,
///   iconColorSelected: Colors.green,
///   iconColor: Colors.black,
///   skinToneDialogBgColor: Colors.brown,
///   skinToneIndicatorColor: Colors.orange,
/// );
///
/// Color background = emojiEditorTheme.background;
/// Color indicatorColor = emojiEditorTheme.indicatorColor;
/// // Access other theme properties...
/// ```
class EmojiEditorTheme {
  /// Background color of the emoji editor widget.
  final Color background;

  /// Color of the category indicator.
  final Color indicatorColor;

  /// Color of the category icon when selected.
  final Color iconColorSelected;

  /// Color of the category icons.
  final Color iconColor;

  /// Background color of the skin tone dialog.
  final Color skinToneDialogBgColor;

  /// Color of the small triangle next to multiple skin tone emojis.
  final Color skinToneIndicatorColor;

  /// Creates an instance of the `EmojiEditorTheme` class with the specified theme properties.
  const EmojiEditorTheme({
    this.background = imageEditorBackgroundColor,
    this.indicatorColor = imageEditorPrimaryColor,
    this.iconColorSelected = imageEditorPrimaryColor,
    this.iconColor = const Color(0xFF9E9E9E),
    this.skinToneDialogBgColor = const Color(0xFF252728),
    this.skinToneIndicatorColor = const Color(0xFF9E9E9E),
  });
}
