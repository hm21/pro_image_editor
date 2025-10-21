import '/features/audio_editor/models/audio_track.dart';

/// Callbacks triggered by the audio editor when interacting with tracks.
class AudioEditorCallbacks {
  /// Creates a set of callbacks for the audio editor.
  const AudioEditorCallbacks({
    this.onPlay,
    this.onStop,
    this.onDone,
    this.onCloseEditor,
    this.onMuteToggle,
    this.onStartTimeChange,
  });

  /// Invoked when the editor requests to play the given [AudioTrack].
  final Future<void> Function(AudioTrack audio)? onPlay;

  /// Invoked when the editor requests to stop playback.
  final Future<void> Function(AudioTrack? audio)? onStop;

  /// Invoked when the user completes the editor workflow.
  final Function()? onDone;

  /// Invoked when the editor closes without completing the workflow.
  final Function()? onCloseEditor;

  /// Called when the mute state is toggled.
  final Future<void> Function(bool isMuted)? onMuteToggle;

  /// Called when the audio track’s start time changes.
  ///
  /// Provides the updated [startTime] of the track within the video.
  final Future<void> Function(Duration startTime)? onStartTimeChange;

  /// Creates a copy with modified editor callbacks.
  AudioEditorCallbacks copyWith({
    Future<void> Function(AudioTrack audio)? onPlay,
    Future<void> Function(AudioTrack? audio)? onStop,
    Function()? onDone,
    Function()? onCloseEditor,
    Future<void> Function(bool isMuted)? onMuteToggle,
    Future<void> Function(Duration startTime)? onStartTimeChange,
  }) {
    return AudioEditorCallbacks(
      onPlay: onPlay ?? this.onPlay,
      onStop: onStop ?? this.onStop,
      onDone: onDone ?? this.onDone,
      onCloseEditor: onCloseEditor ?? this.onCloseEditor,
      onMuteToggle: onMuteToggle ?? this.onMuteToggle,
      onStartTimeChange: onStartTimeChange ?? this.onStartTimeChange,
    );
  }
}
