import 'package:flick_video_player/flick_video_player.dart';
import 'package:flutter/material.dart';
import 'package:pro_image_editor/pro_image_editor.dart';
import 'package:pro_video_editor/pro_video_editor.dart';
import 'package:video_player/video_player.dart';

import '/core/constants/example_constants.dart';
import '../mixins/video_editor_mixin.dart';
import '../widgets/video_initializing_widget.dart';

/// A widget that demonstrates video playback using the Flick video player.
///
/// This serves as an example implementation of a video player with Flick.
class FlickVideoPlayerExample extends StatefulWidget {
  /// Creates a [FlickVideoPlayerExample] widget.
  const FlickVideoPlayerExample({super.key});

  @override
  State<FlickVideoPlayerExample> createState() =>
      _FlickVideoPlayerExampleState();
}

class _FlickVideoPlayerExampleState extends State<FlickVideoPlayerExample>
    with VideoEditorMixin {
  late FlickManager _flickManager;

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
    _flickManager.dispose();
    super.dispose();
  }

  void _initializePlayer() async {
    generateThumbnails();
    video = EditorVideo.asset(kVideoEditorExampleAssetPath);

    _flickManager = FlickManager(
      videoPlayerController:
          VideoPlayerController.asset(kVideoEditorExampleAssetPath),
      autoPlay: videoConfigs.initialPlay,
      onVideoEnd: () {
        if (!mounted || isSeeking || durationSpan == null) {
          return;
        }
        _seekToPosition(durationSpan!);
      },
    );

    await Future.wait([
      if (_flickManager.flickControlManager != null)
        _flickManager.flickControlManager!.setVolume(
          videoConfigs.initialMuted ? 0.0 : 100.0,
          isMute: videoConfigs.initialMuted,
        ),
      setMetadata(),
    ]);

    proVideoController = ProVideoController(
      videoPlayer: _buildVideoPlayer(),
      initialResolution: videoMetadata.resolution,
      videoDuration: videoMetadata.duration,
      fileSize: videoMetadata.fileSize,
      bitrate: videoMetadata.bitrate,
      thumbnails: thumbnails,
    );
    _flickManager.flickVideoManager!.videoPlayerController!
        .addListener(_onDurationChange);
    setState(() {});
  }

  void _onDurationChange() {
    var totalVideoDuration = videoMetadata.duration;
    var duration = _flickManager.flickVideoManager!.videoPlayerValue!.position;
    proVideoController!.setPlayTime(duration);

    if (durationSpan != null && duration > durationSpan!.end) {
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

    await _flickManager.flickControlManager?.pause();
    await _flickManager.flickControlManager?.seekTo(span.start);

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
          : ProImageEditor.video(
              proVideoController!,
              callbacks: callbacks.copyWith(
                videoEditorCallbacks: callbacks.videoEditorCallbacks!.copyWith(
                  onPause: _flickManager.flickControlManager?.pause,
                  onPlay: _flickManager.flickControlManager?.play,
                  onMuteToggle: (isMuted) {
                    _flickManager.flickControlManager?.setVolume(
                      isMuted ? 0.0 : 100.0,
                      isMute: isMuted,
                    );
                  },
                  onTrimSpanUpdate: (durationSpan) {
                    if (_flickManager.flickVideoManager?.isPlaying == true) {
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
            ),
    );
  }

  Widget _buildVideoPlayer() {
    return FlickVideoPlayer(
      key: const ValueKey('Video-Player'),
      flickManager: _flickManager,
      webKeyDownHandler: (p0, p1) {},
      flickVideoWithControls: const FlickVideoWithControls(
        videoFit: BoxFit.contain,
      ),
    );
  }
}
