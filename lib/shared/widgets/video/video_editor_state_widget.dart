import 'package:material_ui/material_ui.dart';
import 'video_editor_configurable.dart';

/// Displays the current play state in the video editor.
///
/// This widget shows a play or pause indicator based on the video state.
class VideoEditorStateWidget extends StatelessWidget {
  /// Creates a [VideoEditorStateWidget] widget.
  const VideoEditorStateWidget({super.key});

  @override
  Widget build(BuildContext context) {
    var player = VideoEditorConfigurable.of(context);

    return Center(
      child: ValueListenableBuilder(
        valueListenable: player.isPlayingNotifier,
        builder: (_, isPlaying, _) {
          return AnimatedSwitcher(
            duration: player.configs.animatedIndicatorDuration,
            switchInCurve: player.configs.animatedIndicatorSwitchInCurve,
            switchOutCurve: player.configs.animatedIndicatorSwitchOutCurve,
            child: isPlaying
                ? player.widgets.pauseIndicator ?? const SizedBox.shrink()
                : player.widgets.playIndicator ??
                      IgnorePointer(
                        child: Container(
                          width: 64,
                          height: 64,
                          decoration: ShapeDecoration(
                            shape: const CircleBorder(),
                            color: player.style.playIndicatorBackground,
                          ),
                          child: Icon(
                            player.icons.playIndicator,
                            color: player.style.playIndicatorColor,
                            size: 44,
                          ),
                        ),
                      ),
          );
        },
      ),
    );
  }
}
