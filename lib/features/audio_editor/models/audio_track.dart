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
    this.startTime,
  });

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

  /// The start time of the selected audio track in the video.
  Duration? startTime;

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
    Duration? startTime,
  }) {
    return AudioTrack(
      id: id ?? this.id,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      duration: duration ?? this.duration,
      image: image ?? this.image,
      audio: audio ?? this.audio,
      startTime: startTime ?? this.startTime,
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
        other.startTime == startTime;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        title.hashCode ^
        subtitle.hashCode ^
        duration.hashCode ^
        image.hashCode ^
        audio.hashCode ^
        startTime.hashCode;
  }
}
