import 'audio_track.dart';

/// Represents the result returned from the audio editor.
class AudioEditorResponse {
  /// Creates a new [AudioEditorResponse].
  const AudioEditorResponse({
    required this.track,
  });

  /// The selected audio track.
  final AudioTrack? track;
}
