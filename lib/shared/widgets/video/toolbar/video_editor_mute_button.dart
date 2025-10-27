import 'package:flutter/material.dart';

import '/shared/widgets/video/video_editor_configurable.dart';
import '../../gesture/gesture_interceptor_widget.dart';

/// A mute button for the video editor.
///
/// This widget allows toggling the mute state of the video player.
class VideoEditorMuteButton extends StatelessWidget {
  /// Creates a [VideoEditorMuteButton] widget.
  const VideoEditorMuteButton({super.key});

  @override
  Widget build(BuildContext context) {
    var player = VideoEditorConfigurable.of(context);

    return GestureInterceptor(
      child: ValueListenableBuilder(
        valueListenable: player.isMutedNotifier,
        builder: (_, isMuted, __) {
          // Use custom mute button if provided
          return player.widgets.muteButton?.call != null
              ? player.widgets.muteButton!(player.controller.setMuteState)
              : IconButtonTheme(
                  data: IconButtonThemeData(
                    style: IconButton.styleFrom(
                      backgroundColor: player.style.muteButtonBackground,
                    ),
                  ),
                  child: IconButton.filled(
                    onPressed: () {
                      player.controller.setMuteState(!isMuted);
                    },
                    color: player.style.muteButtonColor,
                    icon: Icon(
                      isMuted
                          ? player.icons.muteActive
                          : player.icons.muteInactive,
                    ),
                  ),
                );
        },
      ),
    );
  }
}
