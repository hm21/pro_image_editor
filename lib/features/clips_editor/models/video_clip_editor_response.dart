import 'video_clip.dart';

/// Represents the response returned after editing video clips in the editor.
///
/// Contains the list of updated [VideoClip]s that reflect the user's
/// modifications made during the editing session.
class VideoClipEditorResponse {
  /// Creates a new [VideoClipEditorResponse].
  ///
  /// The [videoClips] parameter contains the list of modified or
  /// newly created video clips from the editor.
  const VideoClipEditorResponse({
    required this.videoClips,
  });

  /// The list of video clips resulting from the editing session.
  ///
  /// Can be `null` if the editor was closed without saving or if
  /// no clips were modified.
  final List<VideoClip>? videoClips;
}
