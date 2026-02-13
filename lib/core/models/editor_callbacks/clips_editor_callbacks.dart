import 'dart:typed_data';

import 'package:flutter/widgets.dart';

import '/features/clips_editor/models/video_clip.dart';
import '/shared/controllers/video_controller.dart';

/// Defines callback hooks used by the clips editor.
class ClipsEditorCallbacks {
  /// Creates a new [ClipsEditorCallbacks] instance.
  const ClipsEditorCallbacks({
    this.onDone,
    this.onCloseEditor,
    this.onReadKeyFrame,
    this.onReadKeyFrames,
    this.onAddClip,
    this.onBuildPlayer,
    this.onMergeClips,
  });

  /// Called when the user finishes editing and confirms the result.
  final Function()? onDone;

  /// Called when the editor is closed without saving or confirming.
  final Function()? onCloseEditor;

  /// Called to read a single key frame from the given [VideoClip].
  final Future<Uint8List> Function(VideoClip source)? onReadKeyFrame;

  /// Called to read multiple key frames from the given [VideoClip].
  final Future<List<Uint8List>> Function(VideoClip source)? onReadKeyFrames;

  /// Called when the user adds a new clip to the editor.
  final Future<VideoClip?> Function()? onAddClip;

  /// Callback triggered when multiple [VideoClip]s must be merged.
  ///
  /// The [onProgress] callback reports progress as a value between 0.0 and 1.0.
  final Future<void> Function(
    List<VideoClip> videoClips,
    void Function(double progress) onProgress,
  )? onMergeClips;

  /// Called to build a custom video player widget for previewing clips.
  final Widget Function(ProVideoController controller, VideoClip videoClip)?
      onBuildPlayer;

  /// Creates a copy with modified callbacks.
  ClipsEditorCallbacks copyWith({
    Function()? onDone,
    Function()? onCloseEditor,
    Future<Uint8List> Function(VideoClip source)? onReadKeyFrame,
    Future<List<Uint8List>> Function(VideoClip source)? onReadKeyFrames,
    Future<VideoClip?> Function()? onAddClip,
    Future<void> Function(
      List<VideoClip> videoClips,
      void Function(double progress) onProgress,
    )? onMergeClips,
    Widget Function(ProVideoController controller, VideoClip videoClip)?
        onBuildPlayer,
  }) {
    return ClipsEditorCallbacks(
      onDone: onDone ?? this.onDone,
      onCloseEditor: onCloseEditor ?? this.onCloseEditor,
      onReadKeyFrame: onReadKeyFrame ?? this.onReadKeyFrame,
      onReadKeyFrames: onReadKeyFrames ?? this.onReadKeyFrames,
      onAddClip: onAddClip ?? this.onAddClip,
      onMergeClips: onMergeClips ?? this.onMergeClips,
      onBuildPlayer: onBuildPlayer ?? this.onBuildPlayer,
    );
  }
}
