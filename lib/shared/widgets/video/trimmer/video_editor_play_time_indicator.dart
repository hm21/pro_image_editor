import 'package:material_ui/material_ui.dart';

import '../video_editor_configurable.dart';

/// Displays a playtime indicator on the video trim bar.
///
/// This widget visually represents the current playback position
/// within the selected trim duration.
class VideoEditorPlayTimeIndicator extends StatelessWidget {
  /// Creates a [VideoEditorPlayTimeIndicator] widget.
  ///
  /// Requires the [areaWidth] to determine positioning within the trim bar.
  const VideoEditorPlayTimeIndicator({super.key, required this.areaWidth});

  /// The width of the trim bar area.
  final double areaWidth;

  @override
  Widget build(BuildContext context) {
    var player = VideoEditorConfigurable.of(context);

    // double handlerWidth = player.configs.style.trimBarHandlerWidth;
    double barWidth = areaWidth; // - 2 * handlerWidth;

    return ValueListenableBuilder(
      valueListenable: player.controller.trimDurationSpanNotifier,
      builder: (_, durationSpan, _) {
        Duration startDuration = durationSpan.start;
        int areaDuration = durationSpan.duration.inMicroseconds;

        return ValueListenableBuilder(
          valueListenable: player.controller.playTimeNotifier,
          builder: (_, playTime, _) {
            int convertedPlay = (playTime - startDuration).inMicroseconds;

            double startX = barWidth / areaDuration * convertedPlay;

            return AnimatedPositioned(
              duration: player.configs.playTimeSmoothingDuration,
              left: startX, // handlerWidth +
              top: player.style.trimBarBorderWidth,
              bottom: player.style.trimBarBorderWidth,
              width: player.style.trimBarPlayTimeIndicatorWidth,
              child: Container(
                color: player.style.trimBarPlayTimeIndicatorColor,
              ),
            );
          },
        );
      },
    );
  }
}
