import 'package:example/core/constants/example_constants.dart';
import 'package:example/features/preview/preview_video.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pro_image_editor/core/platform/io/io_helper.dart';
import 'package:pro_image_editor/pro_image_editor.dart';
import 'package:pro_video_editor/pro_video_editor.dart';

/// A mixin for handling video editing states.
mixin VideoEditorMixin<T extends StatefulWidget> on State<T> {
  /// The target format for the exported video.
  final outputFormat = VideoOutputFormat.mp4;

  /// Video editor configuration settings.
  late final VideoEditorConfigs videoConfigs = const VideoEditorConfigs(
    initialMuted: true,
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

  @override
  void dispose() {
    proVideoController?.dispose();

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
