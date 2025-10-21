import 'dart:async';

import 'package:example/core/constants/example_constants.dart';
import 'package:flutter/material.dart';
import 'package:pro_image_editor/pro_image_editor.dart';
import 'package:video_player/video_player.dart';

import '../mixins/video_editor_mixin.dart';
import '../widgets/video_initializing_widget.dart';

/// A widget that demonstrates video playback functionality.
///
/// This serves as an example implementation of a video player.
class VideoPlayerExample extends StatefulWidget {
  /// Creates a [VideoPlayerExample] widget.
  const VideoPlayerExample({super.key});

  @override
  State<VideoPlayerExample> createState() => _VideoPlayerExampleState();
}

class _VideoPlayerExampleState extends State<VideoPlayerExample>
    with VideoEditorMixin {
  late VideoPlayerController _videoController;

  /// The Clips Editor and Audio Editor are not supported by that video player.
  /// Use video_media_kit_example.dart instead.
  @override
  final List<SubEditorMode> subEditors = [
    SubEditorMode.paint,
    SubEditorMode.text,
    SubEditorMode.cropRotate,
    SubEditorMode.tune,
    SubEditorMode.filter,
    SubEditorMode.blur,
    SubEditorMode.emoji,
  ];

  @override
  void initState() {
    super.initState();
    _initializePlayer();
  }

  @override
  void dispose() {
    _videoController.dispose();
    super.dispose();
  }

  void _initializePlayer() async {
    generateThumbnails();

    _videoController =
        VideoPlayerController.asset(kVideoEditorExampleAssetPath);

    await Future.wait([
      setMetadata(),
      _videoController.initialize(),
      _videoController.setLooping(false),
      _videoController.setVolume(videoConfigs.initialMuted ? 0 : 100),
      videoConfigs.initialPlay
          ? _videoController.play()
          : _videoController.pause(),
    ]);
    if (!mounted) return;

    proVideoController = ProVideoController(
      videoPlayer: _buildVideoPlayer(),
      initialResolution: videoMetadata.resolution,
      videoDuration: videoMetadata.duration,
      fileSize: videoMetadata.fileSize,
      bitrate: videoMetadata.bitrate,
      thumbnails: thumbnails,
    );

    _videoController.addListener(_onDurationChange);

    setState(() {});
  }

  void _onDurationChange() {
    var totalVideoDuration = videoMetadata.duration;
    var duration = _videoController.value.position;
    proVideoController!.setPlayTime(duration);

    if (durationSpan != null && duration >= durationSpan!.end) {
      _seekToPosition(durationSpan!);
    } else if (duration >= totalVideoDuration) {
      _seekToPosition(
        TrimDurationSpan(start: Duration.zero, end: totalVideoDuration),
      );
    }
  }

  Future<void> _seekToPosition(TrimDurationSpan span) async {
    durationSpan = span;

    if (isSeeking) {
      tempDurationSpan = span; // Store the latest seek request
      return;
    }
    isSeeking = true;

    proVideoController!.pause();
    proVideoController!.setPlayTime(durationSpan!.start);

    await _videoController.pause();
    await _videoController.seekTo(span.start);

    isSeeking = false;

    // Check if there's a pending seek request
    if (tempDurationSpan != null) {
      TrimDurationSpan nextSeek = tempDurationSpan!;
      tempDurationSpan = null; // Clear the pending seek
      await _seekToPosition(nextSeek); // Process the latest request
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 220),
      child: proVideoController == null
          ? const VideoInitializingWidget()
          : _buildEditor(),
    );
  }

  Widget _buildEditor() {
    return ProImageEditor.video(
      proVideoController!,
      callbacks: callbacks.copyWith(
        videoEditorCallbacks: callbacks.videoEditorCallbacks!.copyWith(
          onPause: _videoController.pause,
          onPlay: _videoController.play,
          onMuteToggle: (isMuted) {
            _videoController.setVolume(isMuted ? 0 : 100);
          },
          onTrimSpanUpdate: (durationSpan) {
            if (_videoController.value.isPlaying) {
              proVideoController!.pause();
            }
          },
          onTrimSpanEnd: _seekToPosition,
        ),
      ),
      configs: configs.copyWith(
        videoEditor: configs.videoEditor.copyWith(
          playTimeSmoothingDuration: const Duration(milliseconds: 600),
        ),
      ),
    );
  }

  Widget _buildVideoPlayer() {
    return Center(
      child: AspectRatio(
        aspectRatio: _videoController.value.size.aspectRatio,
        child: VideoPlayer(
          _videoController,
        ),
      ),
    );
  }
}
