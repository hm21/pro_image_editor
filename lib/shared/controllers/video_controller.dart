import 'package:flutter/widgets.dart';

import '/core/models/editor_callbacks/audio_editor_callbacks.dart';
import '/core/models/editor_callbacks/video_editor_callbacks.dart';
import '/core/models/editor_configs/video/video_editor_configs.dart';
import '/core/models/video/trim_duration_span_model.dart';
import '/features/audio_editor/models/audio_track.dart';

/// Controls video playback and trimming for the video editor.
class ProVideoController {
  /// Creates a [ProVideoController] instance.
  ///
  /// Requires a [videoPlayer] widget, [videoDuration], [initialResolution],
  /// and the video file size in bytes.
  ProVideoController({
    required this.videoPlayer,
    required this.videoDuration,
    required this.initialResolution,
    required this.fileSize,
    this.bitrate,
    this.audioTrack,
    this.audioTrackStartTime,
    List<ImageProvider>? thumbnails,
  }) {
    this.thumbnails = thumbnails;
  }

  /// The currently selected audio track.
  AudioTrack? audioTrack;

  /// The start time of the audio track within the video.
  Duration? audioTrackStartTime;

  /// The video player widget.
  final Widget videoPlayer;

  /// The total duration of the video.
  final Duration videoDuration;

  /// The initial resolution of the video.
  final Size initialResolution;

  /// The size of the video file in bytes.
  final int fileSize;

  /// The bitrate of the video in bits per second.
  ///
  /// This value represents the amount of data processed per unit of time in
  /// the video stream.
  /// Higher bitrate generally result in better video quality, but also
  /// larger file sizes.
  ///
  /// **WARNING:** Not all devices support CBR (Constant Bitrate) mode.
  /// If unsupported, the encoder may silently fall back to VBR
  /// (Variable Bitrate), and the actual bitrate may be constrained by
  /// device-specific minimum and maximum limits.
  final int? bitrate;

  /// A [ValueNotifier] that holds a list of [ImageProvider] objects
  /// representing video thumbnails.
  ///
  /// The [thumbnailsNotifier] notifies its listeners whenever the list of
  /// thumbnails changes.
  final thumbnailsNotifier = ValueNotifier<List<ImageProvider>?>(null);

  /// The [thumbnails] getter returns the current list of thumbnails, or `null`
  /// if not set.
  List<ImageProvider>? get thumbnails => thumbnailsNotifier.value;

  /// The [thumbnails] setter updates the list of thumbnails and notifies
  /// listeners.
  set thumbnails(List<ImageProvider>? value) =>
      thumbnailsNotifier.value = value;

  late AudioEditorCallbacks Function() _callbacksAudioFunction;
  late VideoEditorCallbacks Function() _callbacksFunction;
  late VideoEditorConfigs Function() _configsFunction;

  /// Returns the configured video editor callbacks.
  VideoEditorCallbacks get callbacks => _callbacksFunction();

  /// Returns the configured audio editor callbacks.
  AudioEditorCallbacks get callbacksAudio => _callbacksAudioFunction();

  /// Returns the video editor configuration settings.
  VideoEditorConfigs get configs => _configsFunction();

  /// Notifies listeners of the current playback position.
  late final playTimeNotifier = ValueNotifier<Duration>(Duration.zero);

  /// Notifies listeners of the current play state.
  late final isPlayingNotifier = ValueNotifier<bool>(configs.initialPlay);

  /// Notifies listeners of the current mute state.
  late final isMutedNotifier = ValueNotifier<bool>(configs.initialMuted);

  /// Notifies listeners of the selected trim duration span.
  late final trimDurationSpanNotifier = ValueNotifier<TrimDurationSpan>(
    TrimDurationSpan(
      start: Duration.zero,
      end: configs.maxTrimDuration == null ||
              configs.maxTrimDuration! > videoDuration
          ? videoDuration
          : configs.maxTrimDuration!,
    ),
  );

  /// Notifier that indicates whether the trim time span UI should be shown.
  final showTrimTimeSpanNotifier = ValueNotifier(false);

  /// Indicates whether audio is currently enabled for the video.
  ///
  /// This returns `true` if the video is not muted, based on the value
  /// of [isMutedNotifier]. It's useful for checking whether audio should
  /// be included during playback or export.
  bool get isAudioEnabled => !isMutedNotifier.value;

  /// The start time of the trimmed video segment.
  ///
  /// Retrieved from the [trimDurationSpanNotifier].
  Duration get startTime => trimDurationSpanNotifier.value.start;

  /// The end time of the trimmed video segment.
  ///
  /// Retrieved from the [trimDurationSpanNotifier].
  Duration get endTime => trimDurationSpanNotifier.value.end;

  /// Initializes the controller with provided callback and config functions.
  void initialize({
    required AudioEditorCallbacks Function() callbacksAudioFunction,
    required VideoEditorCallbacks Function() callbacksFunction,
    required VideoEditorConfigs Function() configsFunction,
  }) {
    _callbacksAudioFunction = callbacksAudioFunction;
    _callbacksFunction = callbacksFunction;
    _configsFunction = configsFunction;
  }

  /// Dispose the video controller.
  void dispose() {
    thumbnailsNotifier.dispose();
    playTimeNotifier.dispose();
    isPlayingNotifier.dispose();
    isMutedNotifier.dispose();
    trimDurationSpanNotifier.dispose();
    showTrimTimeSpanNotifier.dispose();
  }

  /// Toggles the play state of the video.
  void togglePlayState() {
    if (!isPlayingNotifier.value) {
      play();
    } else {
      pause();
    }
  }

  /// Starts video playback and triggers the play callback.
  void play() {
    isPlayingNotifier.value = true;
    callbacks.onPlay?.call();
    if (audioTrack?.audio != null) {
      callbacksAudio.onPlay?.call(
        audioTrack!.audio,
        audioTrackStartTime ?? Duration.zero,
      );
    }
  }

  /// Pauses video playback and triggers the pause callback.
  void pause() {
    isPlayingNotifier.value = false;
    callbacks.onPause?.call();
    callbacksAudio.onStop?.call(audioTrack?.audio);
  }

  /// Sets the mute state and triggers the mute toggle callback.
  void setMuteState(bool isMuted) {
    isMutedNotifier.value = isMuted;
    callbacks.onMuteToggle?.call(isMuted);
    callbacksAudio.onMuteToggle?.call(isMuted);
  }

  /// Updates the trim span and triggers the trim update callback.
  void setTrimSpan(TrimDurationSpan span) {
    trimDurationSpanNotifier.value = TrimDurationSpan(
      start: span.start,
      end: span.end,
    );
    callbacks.onTrimSpanUpdate?.call(trimDurationSpanNotifier.value);
  }

  /// Sets the start time for trimming and triggers the trim update callback.
  void setTrimStart(Duration duration) {
    trimDurationSpanNotifier.value = TrimDurationSpan(
      start: duration,
      end: trimDurationSpanNotifier.value.end,
    );
    callbacks.onTrimSpanUpdate?.call(trimDurationSpanNotifier.value);
  }

  /// Sets the end time for trimming and triggers the trim update callback.
  void setTrimEnd(Duration duration) {
    trimDurationSpanNotifier.value = TrimDurationSpan(
      start: trimDurationSpanNotifier.value.start,
      end: duration,
    );
    callbacks.onTrimSpanUpdate?.call(trimDurationSpanNotifier.value);
  }

  /// Updates the current play position.
  void setPlayTime(Duration duration) {
    playTimeNotifier.value = duration;
  }
}
