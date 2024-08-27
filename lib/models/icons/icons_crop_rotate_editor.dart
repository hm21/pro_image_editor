// Flutter imports:
import 'package:flutter/material.dart';

/// Customizable icons for the Crop/Rotate Editor component.
class IconsCropRotateEditor {
  /// Creates an instance of [IconsCropRotateEditor] with customizable icon
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
  /// IconsCropRotateEditor(
  ///   bottomNavBar: Icons.crop_rotate_rounded,
  ///   rotate: Icons.rotate_90_degrees_ccw_outlined,
  ///   aspectRatio: Icons.crop,
  /// )
  /// ```
  const IconsCropRotateEditor({
    this.bottomNavBar = Icons.crop_rotate_rounded,
    this.rotate = Icons.rotate_90_degrees_ccw_outlined,
    this.aspectRatio = Icons.crop,
    this.flip = Icons.flip,
    this.reset = Icons.restore,
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

  /// Creates a copy of this `IconsCropRotateEditor` object with the given
  /// fields replaced with new values.
  ///
  /// The [copyWith] method allows you to create a new instance of
  /// [IconsCropRotateEditor] with some properties updated while keeping the
  /// others unchanged.
  IconsCropRotateEditor copyWith({
    IconData? bottomNavBar,
    IconData? rotate,
    IconData? aspectRatio,
    IconData? flip,
    IconData? reset,
  }) {
    return IconsCropRotateEditor(
      bottomNavBar: bottomNavBar ?? this.bottomNavBar,
      rotate: rotate ?? this.rotate,
      aspectRatio: aspectRatio ?? this.aspectRatio,
      flip: flip ?? this.flip,
      reset: reset ?? this.reset,
    );
  }
}
