import 'package:flutter/material.dart';

/// Customizable icons for the Emoji Editor component.
class IconsEmojiEditor {
  /// The icon to be displayed in the bottom navigation bar.
  final IconData bottomNavBar;

  /// Creates an instance of [IconsEmojiEditor] with customizable icon settings.
  ///
  /// You can provide a custom [bottomNavBar] icon to be displayed in the
  /// bottom navigation bar of the Emoji Editor component. If no custom icon
  /// is provided, the default icon is used.
  ///
  /// Example:
  ///
  /// ```dart
  /// IconsEmojiEditor(
  ///   bottomNavBar: Icons.sentiment_satisfied_alt_rounded,
  /// )
  /// ```
  const IconsEmojiEditor({
    this.bottomNavBar = Icons.sentiment_satisfied_alt_rounded,
  });
}
