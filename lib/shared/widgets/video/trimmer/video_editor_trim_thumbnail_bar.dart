import 'package:flutter/widgets.dart';
import 'package:material_ui/material_ui.dart';

import '/shared/widgets/video/video_editor_configurable.dart';
import 'video_editor_trim_skeleton.dart';

/// Displays a thumbnail preview of the video trim selection.
///
/// This widget shows a series of generated thumbnails representing
/// different frames of the trimmed video section.
class VideoEditorTrimThumbnailBar extends StatelessWidget {
  /// Creates a [VideoEditorTrimThumbnailBar] widget.
  const VideoEditorTrimThumbnailBar({super.key});

  @override
  Widget build(BuildContext context) {
    var player = VideoEditorConfigurable.of(context);

    return Container(
      clipBehavior: Clip.hardEdge,
      height: player.style.trimBarHeight,
      decoration: BoxDecoration(
        gradient: player.style.trimBarGradientBackground,
        borderRadius: BorderRadius.circular(player.style.trimBarHandlerRadius),
      ),
      child: ValueListenableBuilder(
        valueListenable: player.controller.thumbnailsNotifier,
        builder: (_, thumbnails, _) {
          return AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: thumbnails == null
                ? player.widgets.trimBarSkeletonLoader ??
                      const VideoEditorTrimSkeleton()
                : Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: thumbnails.map((item) {
                      return Expanded(
                        child: Image(image: item, fit: BoxFit.cover),
                      );
                    }).toList(),
                  ),
          );
        },
      ),
    );
  }
}
