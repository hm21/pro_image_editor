import 'package:flutter/material.dart';

/// Customizable icons for the Blur Editor component.
class IconsBlurEditor {
  /// The icon to be displayed in the bottom navigation bar.
  final IconData bottomNavBar;

  /// Creates an instance of [IconsBlurEditor] with customizable icon settings.
  ///
  /// You can provide a custom icon for the bottom navigation bar in the Blur Editor component.
  ///
  /// If no custom icon is provided, a default blur icon is used.
  ///
  /// Example:
  ///
  /// ```dart
  /// IconsBlurEditor(
  ///   bottomNavBar: Icons.blur_on,
  /// )
  /// ```
  const IconsBlurEditor({
    this.bottomNavBar = Icons.blur_on,
  });
}
