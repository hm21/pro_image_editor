// Flutter imports:
import 'package:flutter/material.dart';

/// Customizable icons for the Blur Editor component.
class IconsBlurEditor {
  /// Creates an instance of [IconsBlurEditor] with customizable icon settings.
  ///
  /// You can provide a custom icon for the bottom navigation bar in the Blur
  /// Editor component.
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

  /// The icon to be displayed in the bottom navigation bar.
  final IconData bottomNavBar;

  /// Creates a copy of this `IconsBlurEditor` object with the given fields
  /// replaced with new values.
  ///
  /// The [copyWith] method allows you to create a new instance of
  /// [IconsBlurEditor] with some properties updated while keeping the
  /// others unchanged.
  IconsBlurEditor copyWith({
    IconData? bottomNavBar,
  }) {
    return IconsBlurEditor(
      bottomNavBar: bottomNavBar ?? this.bottomNavBar,
    );
  }
}
