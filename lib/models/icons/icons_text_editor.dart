// Flutter imports:
import 'package:flutter/material.dart';

/// Customizable icons for the Text Editor component.
class IconsTextEditor {
  /// Creates an instance of [IconsTextEditor] with customizable icon settings.
  ///
  /// You can provide custom icons for various actions in the Text Editor
  /// component.
  ///
  /// - [bottomNavBar]: The icon for the bottom navigation bar.
  /// - [alignLeft]: The icon for aligning text to the left.
  /// - [alignCenter]: The icon for aligning text to the center.
  /// - [alignRight]: The icon for aligning text to the right.
  /// - [backgroundMode]: The icon for toggling background mode.
  ///
  /// If no custom icons are provided, default icons are used for each action.
  ///
  /// Example:
  ///
  /// ```dart
  /// IconsTextEditor(
  ///   bottomNavBar: Icons.text_fields,
  ///   alignLeft: Icons.align_horizontal_left_rounded,
  ///   alignCenter: Icons.align_horizontal_center_rounded,
  ///   alignRight: Icons.align_horizontal_right_rounded,
  ///   backgroundMode: Icons.layers_rounded,
  /// )
  /// ```
  const IconsTextEditor({
    this.bottomNavBar = Icons.title_rounded,
    this.alignLeft = Icons.align_horizontal_left_rounded,
    this.alignCenter = Icons.align_horizontal_center_rounded,
    this.alignRight = Icons.align_horizontal_right_rounded,
    this.fontScale = Icons.format_size_rounded,
    this.resetFontScale = Icons.refresh_rounded,
    this.backgroundMode = Icons.layers_rounded,
  });

  /// The icon to be displayed in the bottom navigation bar.
  final IconData bottomNavBar;

  /// The icon for aligning text to the left.
  final IconData alignLeft;

  /// The icon for aligning text to the center.
  final IconData alignCenter;

  /// The icon for aligning text to the right.
  final IconData alignRight;

  /// The icon for toggling background mode.
  final IconData backgroundMode;

  /// The icon for changing font scale.
  final IconData fontScale;

  /// The icon for resetting font scale to preset value.
  final IconData resetFontScale;

  /// Creates a copy of this `IconsTextEditor` object with the given fields
  /// replaced with new values.
  ///
  /// The [copyWith] method allows you to create a new instance of
  /// [IconsTextEditor] with some properties updated while keeping the
  /// others unchanged.
  IconsTextEditor copyWith({
    IconData? bottomNavBar,
    IconData? alignLeft,
    IconData? alignCenter,
    IconData? alignRight,
    IconData? backgroundMode,
    IconData? fontScale,
    IconData? resetFontScale,
  }) {
    return IconsTextEditor(
      bottomNavBar: bottomNavBar ?? this.bottomNavBar,
      alignLeft: alignLeft ?? this.alignLeft,
      alignCenter: alignCenter ?? this.alignCenter,
      alignRight: alignRight ?? this.alignRight,
      backgroundMode: backgroundMode ?? this.backgroundMode,
      fontScale: fontScale ?? this.fontScale,
      resetFontScale: resetFontScale ?? this.resetFontScale,
    );
  }
}
