import 'package:material_ui/material_ui.dart';
import '/core/models/video/trim_duration_span_model.dart';
import '/shared/controllers/video_controller.dart';
import '/shared/extensions/duration_extension.dart';
import '/shared/extensions/int_extension.dart';
import '/shared/widgets/video/video_editor_configurable.dart';

/// Displays an informational banner in the video editor.
///
/// This widget shows the selected trim duration and the estimated
/// file size based on the trimmed portion.
class VideoEditorInfoBanner extends StatelessWidget {
  /// Creates a [VideoEditorInfoBanner] widget.
  const VideoEditorInfoBanner({super.key});

  /// Calculate estimated file size based on trimmed duration and bitrate.
  int _estimatedFileSize(
    ProVideoController controller,
    TrimDurationSpan durationSpan,
  ) {
    final bitrate = controller.bitrate;
    int durationSec = durationSpan.duration.inSeconds;
    return (bitrate! * durationSec / 8.0).toInt();
  }

  @override
  Widget build(BuildContext context) {
    var player = VideoEditorConfigurable.of(context);
    ProVideoController controller = player.controller;

    return ValueListenableBuilder(
      valueListenable: controller.trimDurationSpanNotifier,
      builder: (_, durationSpan, _) {
        // If a custom info banner widget is provided, use it
        if (player.configs.widgets.infoBanner != null) {
          return player.configs.widgets.infoBanner!(durationSpan);
        }

        return IgnorePointer(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: player.style.infoBannerBackground,
              borderRadius: BorderRadius.circular(20),
            ),
            child: RichText(
              text: TextSpan(
                style:
                    player.style.infoBannerTextStyle ??
                    TextStyle(
                      fontSize: 14,
                      height: 1.2,
                      color: player.style.infoBannerTextColor,
                    ),
                children: [
                  TextSpan(text: durationSpan.duration.toTimeString()),
                  if (player.configs.enableEstimatedFileSize &&
                      controller.bitrate != null) ...[
                    WidgetSpan(
                      alignment: PlaceholderAlignment.middle,
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 7),
                        width: 3,
                        height: 3,
                        decoration: BoxDecoration(
                          color: player.style.infoBannerTextColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                    TextSpan(
                      text: _estimatedFileSize(
                        controller,
                        durationSpan,
                      ).toBytesString(1),
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
