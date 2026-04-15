import '/core/models/editor_audio.dart';
import '/core/models/editor_image.dart';

/// Model representing an audio track with metadata.
class AudioTrack {
  /// Creates an instance of [AudioTrack].
  AudioTrack({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.duration,
    required this.audio,
    this.image,
    this.volume = 1.0,
    this.loop = false,
    this.audioStartTime,
    this.audioEndTime,
    this.startTime,
    this.endTime,
    this.volumeBalance = 0.0,
  }) : assert(volume >= 0, '[volume] must be greater than or equal to 0'),
       assert(
         volumeBalance >= -1 && volumeBalance <= 1,
         '[volumeBalance] must be greater than or equal to -1.0 and '
         'less than or equal to 1.0.',
       ),
       assert(
         startTime == null || endTime == null || startTime < endTime,
         'startTime must be before endTime',
       );

  /// Unique identifier for the audio track.
  final String id;

  /// Name/title of the audio track.
  final String title;

  /// Subtitle like the artist or creator of the audio track.
  final String subtitle;

  /// Duration of the audio track.
  final Duration duration;

  /// Optional artwork associated with the track.
  final EditorImage? image;

  /// Audio source that should be played for this track.
  final EditorAudio audio;

  /// Volume multiplier for this audio track.
  ///
  /// - `0.0`: Mute
  /// - `1.0`: Full volume (default)
  /// - `> 1.0`: Amplified
  final double volume;

  /// Whether to loop the audio if it is shorter than the time range.
  ///
  /// **Default**: `false`
  final bool loop;

  /// The start time offset within the audio file.
  ///
  /// When provided, playback begins from this position in the audio file
  /// instead of from the beginning.
  final Duration? audioStartTime;

  /// The end time offset within the audio file.
  ///
  /// When provided, playback stops at this position in the audio file
  /// instead of at the end.
  final Duration? audioEndTime;

  /// The start time of the selected audio track in the video.
  Duration? startTime;

  /// The end time of the selected audio track in the video.
  Duration? endTime;

  /// The balance between the original audio and the overlay track.
  /// A value of `1.0` means only the overlay (this track) is audible.
  /// A value of `-1.0` means only the original audio is audible.
  double volumeBalance;

  /// Returns a formatted duration string (e.g., "3:45").
  String get formattedDuration {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '${minutes.toString()}:${seconds.toString().padLeft(2, '0')}';
  }

  /// Creates a copy of this [AudioTrack] with the given fields replaced.
  AudioTrack copyWith({
    String? id,
    String? title,
    String? subtitle,
    Duration? duration,
    EditorImage? image,
    EditorAudio? audio,
    double? volume,
    @Deprecated('Use loop instead') bool? enableLoop,
    bool? loop,
    Duration? audioStartTime,
    Duration? audioEndTime,
    Duration? startTime,
    Duration? endTime,
    double? volumeBalance,
  }) {
    return AudioTrack(
      id: id ?? this.id,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      duration: duration ?? this.duration,
      image: image ?? this.image,
      audio: audio ?? this.audio,
      volume: volume ?? this.volume,
      loop: loop ?? enableLoop ?? this.loop,
      audioStartTime: audioStartTime ?? this.audioStartTime,
      audioEndTime: audioEndTime ?? this.audioEndTime,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      volumeBalance: volumeBalance ?? this.volumeBalance,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is AudioTrack &&
        other.id == id &&
        other.title == title &&
        other.subtitle == subtitle &&
        other.duration == duration &&
        other.image == image &&
        other.audio == audio &&
        other.volume == volume &&
        other.loop == loop &&
        other.audioStartTime == audioStartTime &&
        other.audioEndTime == audioEndTime &&
        other.startTime == startTime &&
        other.endTime == endTime &&
        other.volumeBalance == volumeBalance;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        title.hashCode ^
        subtitle.hashCode ^
        duration.hashCode ^
        image.hashCode ^
        audio.hashCode ^
        volume.hashCode ^
        loop.hashCode ^
        audioStartTime.hashCode ^
        audioEndTime.hashCode ^
        startTime.hashCode ^
        endTime.hashCode ^
        volumeBalance.hashCode;
  }
}
