import 'audio_track.dart';

/// Represents the result returned from the audio editor.
///
/// Contains the selected [AudioTrack] and its start time within the video.
class AudioEditorResponse {
  /// Creates a new [AudioEditorResponse].
  const AudioEditorResponse({
    required this.startTime,
    required this.track,
  });

  /// The start time of the selected audio track in the video.
  final Duration? startTime;

  /// The selected audio track.
  final AudioTrack? track;
}
