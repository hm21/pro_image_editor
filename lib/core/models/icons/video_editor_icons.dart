import 'package:material_ui/material_ui.dart';

/// Defines icon configurations for the video editor.
class VideoEditorIcons {
  /// Creates an instance of [VideoEditorIcons].
  ///
  /// Provides customizable icons for play, mute, and trim controls.
  const VideoEditorIcons({
    this.playIndicator = Icons.play_arrow_rounded,
    this.pauseIndicator = Icons.pause_rounded,
    this.muteActive = Icons.volume_off_rounded,
    this.muteInactive = Icons.volume_up_rounded,
  });

  /// Icon displayed when the video is playing.
  final IconData playIndicator;

  /// Icon displayed when the video is paused .
  final IconData pauseIndicator;

  /// Icon displayed when the video is muted.
  final IconData muteActive;

  /// Icon displayed when the video is not muted.
  final IconData muteInactive;

  /// Creates a copy of this instance with the given parameters overridden.
  VideoEditorIcons copyWith({
    IconData? playIndicator,
    IconData? pauseIndicator,
    IconData? muteActive,
    IconData? muteInactive,
  }) {
    return VideoEditorIcons(
      playIndicator: playIndicator ?? this.playIndicator,
      muteActive: muteActive ?? this.muteActive,
      muteInactive: muteInactive ?? this.muteInactive,
      pauseIndicator: pauseIndicator ?? this.pauseIndicator,
    );
  }
}
