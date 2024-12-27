// Flutter imports:
import 'package:flutter/material.dart';

/// Customizable icons for the Blur Editor component.
class BlurEditorIcons {
  /// Creates an instance of [BlurEditorIcons] with customizable icon settings.
  ///
  /// You can provide a custom icon for the bottom navigation bar in the Blur
  /// Editor component.
  ///
  /// If no custom icon is provided, a default blur icon is used.
  ///
  /// Example:
  ///
  /// ```dart
  /// BlurEditorIcons(
  ///   bottomNavBar: Icons.blur_on,
  /// )
  /// ```
  const BlurEditorIcons({
    this.bottomNavBar = Icons.blur_on,
    this.applyChanges = Icons.done,
    this.backButton = Icons.arrow_back,
  });

  /// The icon to be displayed in the bottom navigation bar.
  final IconData bottomNavBar;

  /// The icon for the back button.
  final IconData backButton;

  /// The icon for applying changes in the editor.
  final IconData applyChanges;

  /// Creates a copy of this `BlurEditorIcons` object with the given fields
  /// replaced with new values.
  ///
  /// The [copyWith] method allows you to create a new instance of
  /// [BlurEditorIcons] with some properties updated while keeping the
  /// others unchanged.
  BlurEditorIcons copyWith({
    IconData? bottomNavBar,
    IconData? backButton,
    IconData? applyChanges,
  }) {
    return BlurEditorIcons(
      bottomNavBar: bottomNavBar ?? this.bottomNavBar,
      backButton: backButton ?? this.backButton,
      applyChanges: applyChanges ?? this.applyChanges,
    );
  }
}
