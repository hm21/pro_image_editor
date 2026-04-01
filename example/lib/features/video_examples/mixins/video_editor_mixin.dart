import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:example/core/constants/example_constants.dart';
import 'package:example/features/preview/preview_video.dart';
import 'package:example/shared/widgets/video_progress_alert.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pro_image_editor/core/platform/io/io_helper.dart';
import 'package:pro_image_editor/pro_image_editor.dart';
import 'package:pro_video_editor/pro_video_editor.dart';

import '../constants/example_audio_tracks_constant.dart';

/// A mixin for handling video editing states.
mixin VideoEditorMixin<T extends StatefulWidget> on State<T> {
  /// The target format for the exported video.
  final outputFormat = VideoOutputFormat.mp4;

  /// Video editor configuration settings.
  late final VideoEditorConfigs videoConfigs = const VideoEditorConfigs(
    initialMuted: false,
    initialPlay: false,
    isAudioSupported: true,
    minTrimDuration: Duration(seconds: 5),
    // maxTrimDuration: Duration(seconds: 15),
  );

  /// Indicates whether a seek operation is in progress.
  bool isSeeking = false;

  /// Stores the currently selected trim duration span.
  TrimDurationSpan? durationSpan;

  /// Temporarily stores a pending trim duration span.
  TrimDurationSpan? tempDurationSpan;

  /// Controls video playback and trimming functionalities.
  ProVideoController? proVideoController;

  /// Stores generated thumbnails for the trimmer bar and filter background.
  List<ImageProvider>? thumbnails;

  /// Holds information about the selected video.
  ///
  /// This will be populated via [setMetadata].
  late VideoMetadata videoMetadata;

  /// Number of thumbnails to generate across the video timeline.
  final int thumbnailCount = 10;

  /// The video currently loaded in the editor.
  EditorVideo video = EditorVideo.asset(kVideoEditorExampleAssetPath);

  String? _outputPath;

  /// The duration it took to generate the exported video.
  Duration videoGenerationTime = Duration.zero;

  /// The task ID used for rendering the video.
  /// It's optional, but when multiple operations run simultaneously,
  /// it allows tracking each task individually.
  final taskId = DateTime.now().microsecondsSinceEpoch.toString();

  /// The audio player instance.
  final audioPlayer = AudioPlayer();

  final Map<String, Uint8List> _cachedKeyFrames = {};
  final Map<String, List<Uint8List>> _cachedKeyFrameList = {};

  /// The list of available sub-editors in the video editor interface.
  List<SubEditorMode> get subEditors => [
        SubEditorMode.videoClips,
        SubEditorMode.audio,
        SubEditorMode.paint,
        SubEditorMode.text,
        SubEditorMode.cropRotate,
        SubEditorMode.tune,
        SubEditorMode.filter,
        SubEditorMode.blur,
        SubEditorMode.emoji,
      ];

  /// Callback options for the Image Editor.
  @protected
  late final callbacks = ProImageEditorCallbacks(
    onCompleteWithParameters: generateVideo,
    onCloseEditor: onCloseEditor,
    audioEditorCallbacks: AudioEditorCallbacks(
      onPlay: (track) async {
        final audio = track.audio;
        Source source;
        if (audio.hasAssetPath) {
          // audioplayers adds 'assets/' prefix automatically, so strip it
          var assetPath = audio.assetPath!;
          if (assetPath.startsWith('assets/')) {
            assetPath = assetPath.substring(7);
          }
          source = AssetSource(assetPath);
        } else if (audio.hasFile) {
          source = DeviceFileSource(audio.file!.path);
        } else if (audio.hasNetworkUrl) {
          source = UrlSource(audio.networkUrl!);
        } else {
          source = BytesSource(audio.bytes!);
        }

        await audioPlayer.setReleaseMode(ReleaseMode.loop);
        await audioPlayer.play(source, position: track.startTime);
      },
      onStop: (audio) async {
        return audioPlayer.pause();
      },
      onMuteToggle: (isMuted) async {
        // You can also pause or play the audio instantly, or set the volume to
        // zero. Some other audio players may support mute directly.
        if (isMuted) {
          await audioPlayer.setVolume(0);
        } else {
          await audioPlayer.setVolume(1);
        }
      },
      onBuildWaveformSelector: (track, videoDuration, onStartTimeChanged) {
        final audio = track.audio;
        return AudioWaveform.streaming(
          key: ValueKey(audio),
          config: WaveformConfigs(
            video: EditorVideo.autoSource(
              assetPath: audio.assetPath,
              byteArray: audio.bytes,
              file: audio.file,
              networkUrl: audio.networkUrl,
            ),
            resolution: WaveformResolution.medium,
          ),
          showPositionIndicator: true,
          onSeek: onStartTimeChanged,
          currentPosition: track.startTime ?? Duration.zero,
          style: WaveformStyle(
            height: 80,
            waveColor: Colors.cyan.shade400,
            waveColorPlayed: Colors.cyan.shade200,
            backgroundColor: Colors.grey.shade900,
            playedOverlayColor: Colors.black38,
            positionIndicatorColor: Colors.white,
            barWidth: 2.5,
            barSpacing: 1.5,
            minBarHeight: 3.0,
            borderRadius: BorderRadius.circular(8),
          ),
        );
      },
    ),
    clipsEditorCallbacks: ClipsEditorCallbacks(
      onReadKeyFrame: (source) async {
        if (_cachedKeyFrames.containsKey(source.id)) {
          return _cachedKeyFrames[source.id]!;
        }

        final result = await ProVideoEditor.instance.getKeyFrames(
          KeyFramesConfigs(
            video: EditorVideo.autoSource(
              assetPath: source.clip.assetPath,
              byteArray: source.clip.bytes,
              file: source.clip.file,
              networkUrl: source.clip.networkUrl,
            ),
            outputSize: const Size.square(200),
            boxFit: ThumbnailBoxFit.cover,
            maxOutputFrames: 1,
            outputFormat: ThumbnailFormat.jpeg,
          ),
        );
        _cachedKeyFrames[source.id] = result.first;
        return result.first;
      },
      onReadKeyFrames: (source) async {
        if (_cachedKeyFrameList.containsKey(source.id)) {
          return _cachedKeyFrameList[source.id]!;
        }

        final result = await ProVideoEditor.instance.getKeyFrames(
          KeyFramesConfigs(
            video: EditorVideo.autoSource(
              assetPath: source.clip.assetPath,
              byteArray: source.clip.bytes,
              file: source.clip.file,
              networkUrl: source.clip.networkUrl,
            ),
            outputSize: const Size.square(200),
            boxFit: ThumbnailBoxFit.cover,
            maxOutputFrames: thumbnailCount,
            outputFormat: ThumbnailFormat.jpeg,
          ),
        );
        _cachedKeyFrameList[source.id] = result;
        return result;
      },
      onAddClip: () async {
        // Open video picker
        final result = await FilePicker.platform.pickFiles(
          type: FileType.video,
          allowMultiple: false,
        );

        // User cancelled picker
        if (!mounted || result == null || result.files.isEmpty) return null;

        final file = result.files.single;
        final path = file.path;
        if (path == null) return null;

        // Extract file name for display
        final name = file.name;
        final title = name.split('.').first;
        LoadingDialog.instance.show(context, configs: configs);
        final meta = await ProVideoEditor.instance.getMetadata(
          EditorVideo.file(path),
        );
        LoadingDialog.instance.hide();

        // Create and return your video clip
        return VideoClip(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          title: title,
          clip: EditorVideoClip.file(path),
          duration: meta.duration,
        );
      },
    ),
    videoEditorCallbacks: VideoEditorCallbacks(),
  );

  /// Configuration options for the Image Editor.
  late final configs = ProImageEditorConfigs(
    dialogConfigs: DialogConfigs(
      widgets: DialogWidgets(
        loadingDialog: (message, configs) => VideoProgressAlert(taskId: taskId),
      ),
    ),
    mainEditor: MainEditorConfigs(
      tools: subEditors,
      widgets: MainEditorWidgets(
        removeLayerArea: (
          removeAreaKey,
          editor,
          rebuildStream,
          isLayerBeingTransformed,
        ) =>
            VideoEditorRemoveArea(
          removeAreaKey: removeAreaKey,
          editor: editor,
          rebuildStream: rebuildStream,
          isLayerBeingTransformed: isLayerBeingTransformed,
        ),
      ),
    ),
    paintEditor: const PaintEditorConfigs(
      tools: [
        PaintMode.freeStyle,
        PaintMode.arrow,
        PaintMode.line,
        PaintMode.rect,
        PaintMode.circle,
        PaintMode.dashLine,
        PaintMode.polygon,
        // Blur and pixelate are not supported.
        // PaintMode.pixelate,
        // PaintMode.blur,
        PaintMode.eraser,
      ],
    ),
    audioEditor: AudioEditorConfigs(audioTracks: kExampleAudioTracks),
    clipsEditor: ClipsEditorConfigs(
      clips: [
        VideoClip(
          id: '001',
          title: 'My awesome video',
          // subtitle: 'Optional',
          duration: Duration.zero,
          clip: EditorVideoClip.autoSource(
            assetPath: video.assetPath,
            bytes: video.byteArray,
            file: video.file,
            networkUrl: video.networkUrl,
          ),
        ),
      ],
    ),
    videoEditor: videoConfigs,
  );

  @override
  void dispose() {
    proVideoController?.dispose();
    audioPlayer.dispose();
    super.dispose();
  }

  /// Loads and sets [videoMetadata] for the given [video].
  Future<void> setMetadata() async {
    await video.safeFilePath();
    videoMetadata = await ProVideoEditor.instance.getMetadata(video);
  }

  /// Generates thumbnails for the given [video].
  void generateThumbnails() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted || (!kIsWeb && (Platform.isLinux || Platform.isWindows))) {
        thumbnails = [];

        if (proVideoController != null) {
          proVideoController!.thumbnails = thumbnails;
        }
        return;
      }
      var imageWidth = MediaQuery.sizeOf(context).width /
          thumbnailCount *
          MediaQuery.devicePixelRatioOf(context);

      /// `getKeyFrames` is faster than `getThumbnails` but the timestamp is
      /// more "random".
      var thumbnailList = await ProVideoEditor.instance.getKeyFrames(
        KeyFramesConfigs(
          video: video,
          outputSize: Size.square(imageWidth),
          boxFit: ThumbnailBoxFit.cover,
          maxOutputFrames: thumbnailCount,
          outputFormat: ThumbnailFormat.jpeg,
        ),
      );

      List<ImageProvider> temporaryThumbnails =
          thumbnailList.map(MemoryImage.new).toList();

      /// Optional precache every thumbnail
      var cacheList =
          temporaryThumbnails.map((item) => precacheImage(item, context));
      await Future.wait(cacheList);
      thumbnails = temporaryThumbnails;

      if (proVideoController != null) {
        proVideoController!.thumbnails = thumbnails;
      }
      configs.clipsEditor.clips.first =
          configs.clipsEditor.clips.first.copyWith(
        image: EditorImage.memory(thumbnailList.first),
        thumbnails: temporaryThumbnails,
        duration: videoMetadata.duration,
      );
    });
  }

  /// Generates the final video based on the given [parameters].
  ///
  /// Applies blur, color filters, cropping, rotation, flipping, and trimming
  /// before exporting using FFmpeg. Measures and stores the generation time.
  Future<void> generateVideo(CompleteParameters parameters) async {
    final stopwatch = Stopwatch()..start();
    final directory = await getTemporaryDirectory();

    // Convert video clips to video segments
    final videoSegments = parameters.videoClips.map((clip) {
      return VideoSegment(
        video: EditorVideo.autoSource(
          assetPath: clip.clip.assetPath,
          byteArray: clip.clip.bytes,
          file: clip.clip.file,
          networkUrl: clip.clip.networkUrl,
        ),
        startTime: clip.trimSpan?.start,
        endTime: clip.trimSpan?.end,
      );
    }).toList();

    // Extract custom audio path and volume settings
    final customAudioPath =
        await _safeCustomAudioPath(parameters.customAudioTrack, directory.path);
    final audioVolumes = _calculateAudioVolumes(parameters.customAudioTrack);

    // Use videoSegments when multiple clips exist, otherwise use single video
    final useSegments = videoSegments.length > 1;

    var exportModel = VideoRenderData(
      id: taskId,
      videoSegments: useSegments
          ? videoSegments
              .map((video) =>
                  video.copyWith(volume: audioVolumes.originalVolume))
              .toList()
          : [VideoSegment(video: video, volume: audioVolumes.originalVolume)],
      imageLayers: [
        if (parameters.layers.isNotEmpty)
          ImageLayer(image: EditorLayerImage.memory(parameters.image))
      ],
      blur: parameters.blur,
      colorFilters: [ColorFilter(matrix: parameters.colorFiltersCombined)],
      startTime: useSegments ? null : parameters.startTime,
      endTime: useSegments ? null : parameters.endTime,
      transform: parameters.isTransformed
          ? ExportTransform(
              width: parameters.cropWidth,
              height: parameters.cropHeight,
              rotateTurns: 4 - parameters.rotateTurns,
              x: parameters.cropX,
              y: parameters.cropY,
              flipX: parameters.flipX,
              flipY: parameters.flipY,
            )
          : null,
      enableAudio: proVideoController?.isAudioEnabled ?? true,
      outputFormat: outputFormat,
      bitrate: videoMetadata.bitrate,
      audioTracks: [
        if (customAudioPath != null)
          VideoAudioTrack(
            path: customAudioPath,
            volume: audioVolumes.customVolume,
          )
      ],
    );

    final now = DateTime.now().millisecondsSinceEpoch;
    _outputPath = await ProVideoEditor.instance.renderVideoToFile(
      '${directory.path}/my_video_$now.mp4',
      exportModel,
    );
    videoGenerationTime = stopwatch.elapsed;
  }

  /// Returns a local file path for the given [track]'s audio source.
  Future<String?> _safeCustomAudioPath(
    AudioTrack? track,
    String directoryPath,
  ) async {
    final audio = track?.audio;
    if (audio == null) return null;

    if (audio.hasFile) {
      return audio.file!.path;
    } else {
      String filePath = '$directoryPath/temp-audio.mp3';

      if (audio.hasNetworkUrl) {
        return (await fetchVideoToFile(audio.networkUrl!, filePath)).path;
      } else if (audio.hasAssetPath) {
        // writeAssetVideoToFile expects path without 'assets/' prefix
        var assetPath = audio.assetPath!;
        if (!assetPath.startsWith('assets/')) {
          assetPath = 'assets/$assetPath';
        }
        return (await writeAssetVideoToFile(
          assetPath,
          filePath,
        ))
            .path;
      } else {
        return (await writeMemoryVideoToFile(audio.bytes!, filePath)).path;
      }
    }
  }

  /// Calculates the original and custom audio volumes based on volume balance.
  ({double originalVolume, double customVolume}) _calculateAudioVolumes(
    AudioTrack? track,
  ) {
    if (track == null) {
      return (originalVolume: 1.0, customVolume: 1.0);
    }

    final balance = track.volumeBalance;
    // balance: -1.0 = only original, 0.0 = equal mix, 1.0 = only custom
    final originalVolume = (1.0 - balance) / 2.0;
    final customVolume = (1.0 + balance) / 2.0;

    return (originalVolume: originalVolume, customVolume: customVolume);
  }

  /// Closes the video editor and opens a preview screen if a video was
  /// exported.
  ///
  /// If [exportedVideo] is available, it navigates to [PreviewVideo].
  /// Afterwards, it pops the current editor page.
  void onCloseEditor(EditorMode editorMode) async {
    if (editorMode != EditorMode.main) return Navigator.pop(context);
    if (_outputPath != null) {
      // Pause audio and video before opening preview
      unawaited(audioPlayer.pause());
      proVideoController?.pause();

      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => PreviewVideo(
            filePath: _outputPath!,
            generationTime: videoGenerationTime,
          ),
        ),
      );
      _outputPath = null;
    }

    if (mounted) {
      Navigator.pop(context);
    }
  }
}
