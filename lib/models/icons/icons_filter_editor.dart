// Flutter imports:
import 'package:flutter/material.dart';

/// Customizable icons for the Filter Editor component.
class IconsFilterEditor {
  /// Creates an instance of [IconsFilterEditor] with customizable icon
  /// settings.
  ///
  /// You can provide a custom icon for the bottom navigation bar in the Filter
  /// Editor component.
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

  /// The icon to be displayed in the bottom navigation bar.
  final IconData bottomNavBar;

  /// Creates a copy of this `IconsFilterEditor` object with the given fields
  /// replaced with new values.
  ///
  /// The [copyWith] method allows you to create a new instance of
  /// [IconsFilterEditor] with some properties updated while keeping the
  /// others unchanged.
  IconsFilterEditor copyWith({
    IconData? bottomNavBar,
  }) {
    return IconsFilterEditor(
      bottomNavBar: bottomNavBar ?? this.bottomNavBar,
    );
  }
}
