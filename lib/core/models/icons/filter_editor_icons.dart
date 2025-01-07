// Flutter imports:
import 'package:flutter/material.dart';

/// Customizable icons for the Filter Editor component.
class FilterEditorIcons {
  /// Creates an instance of [FilterEditorIcons] with customizable icon
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
  /// FilterEditorIcons(
  ///   bottomNavBar: Icons.filter,
  /// )
  /// ```
  const FilterEditorIcons({
    this.bottomNavBar = Icons.filter,
    this.applyChanges = Icons.done,
    this.backButton = Icons.arrow_back,
  });

  /// The icon to be displayed in the bottom navigation bar.
  final IconData bottomNavBar;

  /// The icon for the back button.
  final IconData backButton;

  /// The icon for applying changes in the editor.
  final IconData applyChanges;

  /// Creates a copy of this `FilterEditorIcons` object with the given fields
  /// replaced with new values.
  ///
  /// The [copyWith] method allows you to create a new instance of
  /// [FilterEditorIcons] with some properties updated while keeping the
  /// others unchanged.
  FilterEditorIcons copyWith({
    IconData? bottomNavBar,
    IconData? backButton,
    IconData? applyChanges,
  }) {
    return FilterEditorIcons(
      bottomNavBar: bottomNavBar ?? this.bottomNavBar,
      backButton: backButton ?? this.backButton,
      applyChanges: applyChanges ?? this.applyChanges,
    );
  }
}
