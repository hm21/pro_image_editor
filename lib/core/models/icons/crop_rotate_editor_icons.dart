// Flutter imports:
import 'package:flutter/material.dart';

/// Customizable icons for the Crop/Rotate Editor component.
class CropRotateEditorIcons {
  /// Creates an instance of [CropRotateEditorIcons] with customizable icon
  /// settings.
  ///
  /// You can provide custom icons for various actions in the Crop/Rotate Editor component.
  /// - [bottomNavBar] icon represents the icon in the bottom navigation bar.
  /// - [rotate] icon represents the rotate action.
  /// - [aspectRatio] icon represents the aspect ratio action.
  ///
  /// If no custom icons are provided, default icons are used for each action.
  ///
  /// Example:
  ///
  /// ```dart
  /// CropRotateEditorIcons(
  ///   bottomNavBar: Icons.crop_rotate_rounded,
  ///   rotate: Icons.rotate_90_degrees_ccw_outlined,
  ///   aspectRatio: Icons.crop,
  /// )
  /// ```
  const CropRotateEditorIcons({
    this.bottomNavBar = Icons.crop_rotate_rounded,
    this.rotate = Icons.rotate_90_degrees_ccw_outlined,
    this.aspectRatio = Icons.crop,
    this.flip = Icons.flip,
    this.reset = Icons.restore,
    this.applyChanges = Icons.done,
    this.backButton = Icons.arrow_back,
    this.undoAction = Icons.undo,
    this.redoAction = Icons.redo,
  });

  /// The icon to be displayed in the bottom navigation bar.
  final IconData bottomNavBar;

  /// The icon for the rotate action.
  final IconData rotate;

  /// The icon for the aspect ratio action.
  final IconData aspectRatio;

  /// The icon for the flip action.
  final IconData flip;

  /// The icon for the reset action.
  final IconData reset;

  /// The icon for the back button.
  final IconData backButton;

  /// The icon for applying changes in the editor.
  final IconData applyChanges;

  /// The icon for undoing the last action.
  final IconData undoAction;

  /// The icon for redoing the last undone action.
  final IconData redoAction;

  /// Creates a copy of this `CropRotateEditorIcons` object with the given
  /// fields replaced with new values.
  ///
  /// The [copyWith] method allows you to create a new instance of
  /// [CropRotateEditorIcons] with some properties updated while keeping the
  /// others unchanged.
  CropRotateEditorIcons copyWith({
    IconData? bottomNavBar,
    IconData? rotate,
    IconData? aspectRatio,
    IconData? flip,
    IconData? reset,
    IconData? backButton,
    IconData? applyChanges,
    IconData? undoAction,
    IconData? redoAction,
  }) {
    return CropRotateEditorIcons(
      bottomNavBar: bottomNavBar ?? this.bottomNavBar,
      rotate: rotate ?? this.rotate,
      aspectRatio: aspectRatio ?? this.aspectRatio,
      flip: flip ?? this.flip,
      reset: reset ?? this.reset,
      backButton: backButton ?? this.backButton,
      applyChanges: applyChanges ?? this.applyChanges,
      undoAction: undoAction ?? this.undoAction,
      redoAction: redoAction ?? this.redoAction,
    );
  }
}
