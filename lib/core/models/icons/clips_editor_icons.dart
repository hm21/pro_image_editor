import 'package:flutter/material.dart';

/// Defines icon configurations for the Video Clips editor.
class ClipsEditorIcons {
  /// Creates an instance of [ClipsEditorIcons].
  const ClipsEditorIcons({
    this.bottomNavBar = Icons.content_cut,
    this.applyChanges = Icons.done,
    this.backButton = Icons.arrow_back,
    this.clipThumbnail = Icons.image,
    this.editPageBackButton = Icons.arrow_back,
    this.editPageApplyChanges = Icons.done,
    this.editPageRemoveClip = Icons.delete_outline,
  });

  /// The icon to be displayed in the bottom navigation bar.
  final IconData bottomNavBar;

  /// The icon for the back button.
  final IconData backButton;

  /// The icon for applying changes in the editor.
  final IconData applyChanges;

  /// Default icon for an clip-thumbnail item when no image is available.
  final IconData clipThumbnail;

  /// The icon for the back button in the edit page.
  final IconData editPageBackButton;

  /// The icon for applying changes in the edit page.
  final IconData editPageApplyChanges;

  /// The icon for removing a video clip in the edit page.
  final IconData editPageRemoveClip;
}
