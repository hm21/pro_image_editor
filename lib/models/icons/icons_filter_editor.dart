import 'package:flutter/material.dart';

/// Customizable icons for the Filter Editor component.
class IconsFilterEditor {
  /// The icon to be displayed in the bottom navigation bar.
  final IconData bottomNavBar;

  /// Creates an instance of [IconsFilterEditor] with customizable icon settings.
  ///
  /// You can provide a custom icon for the bottom navigation bar in the Filter Editor component.
  ///
  /// If no custom icon is provided, a default filter icon is used.
  ///
  /// Example:
  ///
  /// ```dart
  /// IconsFilterEditor(
  ///   bottomNavBar: Icons.filter,
  /// )
  /// ```
  const IconsFilterEditor({
    this.bottomNavBar = Icons.filter,
  });
}
