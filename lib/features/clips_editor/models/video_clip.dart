import 'package:flutter/widgets.dart';

import '/core/models/editor_image.dart';
import '/core/models/editor_video_clip.dart';
import '/core/models/video/trim_duration_span_model.dart';

/// Model representing an video-clip with metadata.
class VideoClip {
  /// Creates an instance of [VideoClip].
  VideoClip({
    required this.id,
    required this.title,
    this.subtitle,
    this.image,
    required this.clip,
    required this.duration,
    this.trimSpan,
    this.thumbnails,
  });

  /// Unique identifier for the clip.
  final String id;

  /// Name/title of the clip.
  final String title;

  /// Subtitle of the clip.
  final String? subtitle;

  /// Optional thumbnail from the video-clip.
  final EditorImage? image;

  /// Video-Clip source that should be played for this track.
  final EditorVideoClip clip;

  /// The total duration of the video clip.
  final Duration duration;

  /// The selected trim range within the video clip.
  TrimDurationSpan? trimSpan;

  /// Cached thumbnail images representing the video clip.
  List<ImageProvider<Object>>? thumbnails;

  /// Creates a copy of this [VideoClip] with the given fields replaced.
  VideoClip copyWith({
    String? id,
    String? title,
    String? subtitle,
    EditorImage? image,
    EditorVideoClip? clip,
    Duration? duration,
    TrimDurationSpan? trimSpan,
    List<ImageProvider<Object>>? thumbnails,
  }) {
    return VideoClip(
      id: id ?? this.id,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      image: image ?? this.image,
      clip: clip ?? this.clip,
      duration: duration ?? this.duration,
      trimSpan: trimSpan ?? this.trimSpan,
      thumbnails: thumbnails ?? this.thumbnails,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is VideoClip &&
        other.id == id &&
        other.title == title &&
        other.subtitle == subtitle &&
        other.image == image &&
        other.clip == clip &&
        other.duration == duration &&
        other.trimSpan == trimSpan;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        title.hashCode ^
        subtitle.hashCode ^
        image.hashCode ^
        clip.hashCode ^
        duration.hashCode ^
        trimSpan.hashCode;
  }
}
