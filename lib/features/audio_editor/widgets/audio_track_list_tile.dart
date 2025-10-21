import 'package:flutter/material.dart';

import '/core/models/editor_configs/pro_image_editor_configs.dart';
import '/shared/widgets/auto_image.dart';

/// Tile widget that renders an [AudioTrack] inside a list.
class AudioTrackListTile extends StatelessWidget {
  /// Creates an instance of [AudioTrackListTile].
  const AudioTrackListTile({
    super.key,
    required this.configs,
    required this.audioTrack,
    required this.videoDuration,
    required this.isSelected,
    this.onTap,
    this.onChangeStartTime,
  });

  /// Configuration options for the Image Editor.
  final ProImageEditorConfigs configs;

  /// The audio track to display.
  final AudioTrack audioTrack;

  /// The duration from the video.
  final Duration videoDuration;

  /// Whether the current tile is selected.
  final bool isSelected;

  /// Callback when the tile is tapped.
  final Function(Duration startTime)? onTap;

  /// Callback when the startTime changed.
  final Function(Duration startTime)? onChangeStartTime;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildAudioTile(context),
        if (isSelected) _buildAudioTimeSpanSelector(),
      ],
    );
  }

  Widget _buildAudioTimeSpanSelector() {
    // TODO: Implement span selector with waveform.
    // onChangeStartTime
    return configs.audioEditor.widgets.audioWave
            ?.call(audioTrack, onChangeStartTime) ??
        const SizedBox.shrink();
  }

  Widget _buildAudioTile(BuildContext context) {
    final style = configs.audioEditor.style;
    return configs.audioEditor.widgets.audioTrackItem
            ?.call(audioTrack, onTap) ??
        ListTile(
          selected: isSelected,
          selectedColor: style.selectedTrackColor,
          selectedTileColor: style.selectedTrackBackground,
          leading: _buildLeading(),
          title: Text(
            audioTrack.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: Text(
            audioTrack.subtitle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          trailing: _buildTrailing(context),
          onTap: onTap == null ? null : () => onTap!(Duration.zero),
        );
  }

  Widget _buildLeading() {
    if (audioTrack.image == null) {
      return _buildDefaultIcon();
    }
    return ClipRRect(
      borderRadius: BorderRadius.circular(4),
      child: Container(
        // Important that progress-spinner will not overflow.
        color: configs.audioEditor.style.audioTrackImageBackground,
        width: 50,
        height: 50,
        child: AutoImage(
          audioTrack.image!,
          width: 50,
          height: 50,
          fit: BoxFit.cover,
          configs: configs,
        ),
      ),
    );
  }

  Widget _buildDefaultIcon() {
    final color = configs.audioEditor.style.audioTrackImageBackground;
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        color: color.withAlpha(80),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Icon(
        configs.audioEditor.icons.audioTrackDefaultIcon,
        color: color,
        size: 24,
      ),
    );
  }

  Widget _buildTrailing(BuildContext context) {
    String text = audioTrack.formattedDuration;

    return Text(text);
  }
}
