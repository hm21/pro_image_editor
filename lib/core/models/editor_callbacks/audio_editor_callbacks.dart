import 'package:flutter/widgets.dart';

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
    this.onBalanceChange,
    this.onBuildWaveformSelector,
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
  final Future<void> Function(Duration startTime)? onStartTimeChange;

  /// Callback triggered when [volumeBalance] is updated.
  final Future<void> Function(double volumeBalance)? onBalanceChange;

  /// Called to build a custom waveform selector widget.
  ///
  /// Use this to integrate pro_video_editor's AudioWaveform widget directly:
  /// ```dart
  /// onBuildWaveformSelector: (audio, videoDuration, onStartTimeChanged) {
  ///   return AudioWaveform.interactive(
  ///     config: WaveformConfigs(
  ///       video: EditorVideo.asset(audio.audio.assetPath!),
  ///       resolution: WaveformResolution.medium,
  ///     ),
  ///     currentPosition: audio.startTime ?? Duration.zero,
  ///     onSeek: onStartTimeChanged,
  ///     style: WaveformStyle(height: 60),
  ///   );
  /// },
  /// ```
  final Widget Function(
    AudioTrack audio,
    Duration videoDuration,
    ValueChanged<Duration> onStartTimeChanged,
  )? onBuildWaveformSelector;

  /// Creates a copy with modified editor callbacks.
  AudioEditorCallbacks copyWith({
    Future<void> Function(AudioTrack audio)? onPlay,
    Future<void> Function(AudioTrack? audio)? onStop,
    Function()? onDone,
    Function()? onCloseEditor,
    Future<void> Function(bool isMuted)? onMuteToggle,
    Future<void> Function(Duration startTime)? onStartTimeChange,
    Future<void> Function(double volumeBalance)? onBalanceChange,
    Widget Function(
      AudioTrack audio,
      Duration videoDuration,
      ValueChanged<Duration> onStartTimeChanged,
    )? onBuildWaveformSelector,
  }) {
    return AudioEditorCallbacks(
      onPlay: onPlay ?? this.onPlay,
      onStop: onStop ?? this.onStop,
      onDone: onDone ?? this.onDone,
      onCloseEditor: onCloseEditor ?? this.onCloseEditor,
      onMuteToggle: onMuteToggle ?? this.onMuteToggle,
      onStartTimeChange: onStartTimeChange ?? this.onStartTimeChange,
      onBalanceChange: onBalanceChange ?? this.onBalanceChange,
      onBuildWaveformSelector:
          onBuildWaveformSelector ?? this.onBuildWaveformSelector,
    );
  }
}
