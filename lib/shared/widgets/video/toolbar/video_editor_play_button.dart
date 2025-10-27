import 'package:flutter/material.dart';

import '/shared/widgets/video/video_editor_configurable.dart';
import '../../gesture/gesture_interceptor_widget.dart';

/// A customizable play/pause button widget for the video editor.
///
/// This widget listens to the current playback state and displays either
/// a play or pause icon accordingly. If a custom [playButton] builder is
/// provided via [VideoEditorConfigurable], it will be used instead of the
/// default button.
///
/// The button uses values from [VideoEditorConfigurable] such as:
/// - [VideoEditorConfigurable.isPlayingNotifier] to reactively update its state
/// - [VideoEditorConfigurable.controller] to control playback
/// - [VideoEditorConfigurable.style] for button appearance
/// - [VideoEditorConfigurable.icons] for play/pause icons
///
/// Example:
/// ```dart
/// VideoEditorPlayButton()
/// ```
class VideoEditorPlayButton extends StatelessWidget {
  /// Creates a [VideoEditorPlayButton].
  ///
  /// Use this widget to display a play/pause toggle in your video editor UI.
  const VideoEditorPlayButton({super.key});

  @override
  Widget build(BuildContext context) {
    var player = VideoEditorConfigurable.of(context);
    var controller = player.controller;

    return GestureInterceptor(
      child: ValueListenableBuilder(
        valueListenable: player.isPlayingNotifier,
        builder: (_, isPlaying, __) {
          return player.widgets.playButton?.call != null
              ? player.widgets.playButton!(controller.setMuteState)
              : IconButtonTheme(
                  data: IconButtonThemeData(
                    style: IconButton.styleFrom(
                      backgroundColor: player.style.muteButtonBackground,
                    ),
                  ),
                  child: IconButton.filled(
                    onPressed: () {
                      if (isPlaying) {
                        controller.pause();
                      } else {
                        controller.play();
                      }
                    },
                    color: player.style.muteButtonColor,
                    icon: Icon(
                      isPlaying
                          ? player.icons.pauseIndicator
                          : player.icons.playIndicator,
                    ),
                  ),
                );
        },
      ),
    );
  }
}
