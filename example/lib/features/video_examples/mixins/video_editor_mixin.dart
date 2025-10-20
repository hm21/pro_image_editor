import 'package:audioplayers/audioplayers.dart';
import 'package:example/core/constants/example_constants.dart';
import 'package:example/features/preview/preview_video.dart';
import 'package:example/shared/widgets/video_progress_alert.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pro_image_editor/core/platform/io/io_helper.dart';
import 'package:pro_image_editor/features/clips_editor/models/video_clip.dart';
import 'package:pro_image_editor/pro_image_editor.dart';
import 'package:pro_video_editor/pro_video_editor.dart';

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

  final _audioPlayer = AudioPlayer();

  final Map<String, Uint8List> _cachedKeyFrames = {};
  final Map<String, List<Uint8List>> _cachedKeyFrameList = {};
  final List<VideoClip> _initialVideoClips = [];

  /// Callback options for the Image Editor.
  @protected
  late final callbacks = ProImageEditorCallbacks(
    onCompleteWithParameters: generateVideo,
    onCloseEditor: onCloseEditor,
    audioEditorCallbacks: AudioEditorCallbacks(
      onPlay: (audio, startTime) async {
        Source source;
        if (audio.hasAssetPath) {
          source = AssetSource(audio.assetPath!);
        } else if (audio.hasFile) {
          source = DeviceFileSource(audio.file!.path);
        } else if (audio.hasNetworkUrl) {
          source = UrlSource(audio.networkUrl!);
        } else {
          source = BytesSource(audio.bytes!);
        }

        await _audioPlayer.setReleaseMode(ReleaseMode.loop);
        await _audioPlayer.play(source, position: startTime);
      },
      onStop: (audio) async {
        return _audioPlayer.pause();
      },
      onMuteToggle: (isMuted) async {
        // You can also pause or play the audio instantly, or set the volume to
        // zero. Some other audio players may support mute directly.
        if (isMuted) {
          await _audioPlayer.setVolume(0);
        } else {
          await _audioPlayer.setVolume(1);
        }
      },
      onStartTimeChange: (startTime) async {
        await _audioPlayer.seek(startTime);
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
        if (result == null || result.files.isEmpty) return null;

        final file = result.files.single;
        final path = file.path;
        if (path == null) return null;

        // Extract file name for display
        final name = file.name;
        final title = name.split('.').first;
        final meta = await ProVideoEditor.instance.getMetadata(
          EditorVideo.file(path),
        );

        // Create and return your video clip
        return VideoClip(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          title: title,
          clip: EditorVideoClip.file(path),
          duration: meta.duration,
        );
      },
      onBuildPlayer: () {
        // TODO: Return video player for only video-clips
        return Container(
          width: 200,
          height: 200,
          color: Colors.red,
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
      tools: [
        SubEditorMode.videoClips,
        SubEditorMode.audio,
        SubEditorMode.paint,
        SubEditorMode.text,
        SubEditorMode.cropRotate,
        SubEditorMode.tune,
        SubEditorMode.filter,
        SubEditorMode.blur,
        SubEditorMode.emoji,
      ],
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
    audioEditor: AudioEditorConfigs(
      audioTracks: [
        AudioTrack(
          id: 'track_1',
          title: 'Summer Vibes',
          subtitle: 'Beach Band',
          duration: const Duration(seconds: 10),
          image: EditorImage.network('https://picsum.photos/200/200?random=1'),
          audio: EditorAudio.asset('audio1.mp3'),
        ),
        AudioTrack(
          id: 'track_2',
          title: 'Night Drive',
          subtitle: 'Synthwave Artist',
          duration: const Duration(seconds: 59),
          image: EditorImage.network('https://picsum.photos/200/200?random=2'),
          audio: EditorAudio.asset('audio2.wav'),
        ),
        AudioTrack(
          id: 'track_4',
          title: 'Electronic Pulse',
          subtitle: 'EDM Producer',
          duration: const Duration(seconds: 34),
          image: EditorImage.network('https://picsum.photos/200/200?random=3'),
          audio: EditorAudio.asset('audio3.wav'),
        ),
      ],
    ),
    clipsEditor: ClipsEditorConfigs(
      clips: _initialVideoClips,
    ),
    videoEditor: videoConfigs,
  );

  @override
  void dispose() {
    proVideoController?.dispose();
    _audioPlayer.dispose();
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

      _initialVideoClips.add(
        VideoClip(
          id: '001',
          title: 'My awesome video',
          // subtitle: 'Optional',
          duration: videoMetadata.duration,
          image: EditorImage.memory(thumbnailList.first),
          thumbnails: temporaryThumbnails,
          clip: EditorVideoClip.autoSource(
            assetPath: video.assetPath,
            bytes: video.byteArray,
            file: video.file,
            networkUrl: video.networkUrl,
          ),
        ),
      );
    });
  }

  /// Generates the final video based on the given [parameters].
  ///
  /// Applies blur, color filters, cropping, rotation, flipping, and trimming
  /// before exporting using FFmpeg. Measures and stores the generation time.
  Future<void> generateVideo(CompleteParameters parameters) async {
    final stopwatch = Stopwatch()..start();

    var exportModel = RenderVideoModel(
      id: taskId,
      video: video,
      imageBytes: parameters.layers.isNotEmpty ? parameters.image : null,
      blur: parameters.blur,
      colorMatrixList: [parameters.colorFiltersCombined],
      startTime: parameters.startTime,
      endTime: parameters.endTime,
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
    );
    final directory = await getTemporaryDirectory();

    final now = DateTime.now().millisecondsSinceEpoch;
    _outputPath = await ProVideoEditor.instance.renderVideoToFile(
      '${directory.path}/my_video_$now.mp4',
      exportModel,
    );
    videoGenerationTime = stopwatch.elapsed;
  }

  /// Closes the video editor and opens a preview screen if a video was
  /// exported.
  ///
  /// If [exportedVideo] is available, it navigates to [PreviewVideo].
  /// Afterwards, it pops the current editor page.
  void onCloseEditor(EditorMode editorMode) async {
    if (editorMode != EditorMode.main) return Navigator.pop(context);
    if (_outputPath != null) {
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
