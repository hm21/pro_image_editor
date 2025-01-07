// Flutter imports:
import 'package:flutter/material.dart';

/// Customizable icons for the Emoji Editor component.
class EmojiEditorIcons {
  /// Creates an instance of [EmojiEditorIcons] with customizable icon settings.
  ///
  /// You can provide a custom [bottomNavBar] icon to be displayed in the
  /// bottom navigation bar of the Emoji Editor component. If no custom icon
  /// is provided, the default icon is used.
  ///
  /// Example:
  ///
  /// ```dart
  /// EmojiEditorIcons(
  ///   bottomNavBar: Icons.sentiment_satisfied_alt_rounded,
  /// )
  /// ```
  const EmojiEditorIcons({
    this.bottomNavBar = Icons.sentiment_satisfied_alt_rounded,
  });

  /// The icon to be displayed in the bottom navigation bar.
  final IconData bottomNavBar;

  /// Creates a copy of this `IconsEmojiEditor` object with the given fields
  /// replaced with new values.
  ///
  /// The [copyWith] method allows you to create a new instance of
  /// [EmojiEditorIcons] with some properties updated while keeping the
  /// others unchanged.
  EmojiEditorIcons copyWith({
    IconData? bottomNavBar,
  }) {
    return EmojiEditorIcons(
      bottomNavBar: bottomNavBar ?? this.bottomNavBar,
    );
  }
}
