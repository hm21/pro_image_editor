import 'package:flutter/material.dart';

/// Defines icon configurations for the audio editor.
class AudioEditorIcons {
  /// Creates an instance of [AudioEditorIcons].
  const AudioEditorIcons({
    this.bottomNavBar = Icons.audiotrack_outlined,
    this.audioTrackDefaultIcon = Icons.music_note,
    this.applyChanges = Icons.done,
    this.backButton = Icons.arrow_back,
  });

  /// The icon to be displayed in the bottom navigation bar.
  final IconData bottomNavBar;

  /// Default icon for an audio track item when no image is available.
  final IconData audioTrackDefaultIcon;

  /// The icon for the back button.
  final IconData backButton;

  /// The icon for applying changes in the editor.
  final IconData applyChanges;

  /// Creates a copy of this instance with the given parameters overridden.
  AudioEditorIcons copyWith({
    IconData? bottomNavBar,
    IconData? audioTrackDefaultIcon,
    IconData? backButton,
    IconData? applyChanges,
  }) {
    return AudioEditorIcons(
      bottomNavBar: bottomNavBar ?? this.bottomNavBar,
      audioTrackDefaultIcon:
          audioTrackDefaultIcon ?? this.audioTrackDefaultIcon,
      backButton: backButton ?? this.backButton,
      applyChanges: applyChanges ?? this.applyChanges,
    );
  }
}
