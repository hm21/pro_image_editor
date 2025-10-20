import 'dart:typed_data';
import 'package:flutter/widgets.dart';
import '/features/clips_editor/models/video_clip.dart';

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

  /// Called to build a custom video player widget for previewing clips.
  final Widget Function()? onBuildPlayer;
}
