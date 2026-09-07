import 'dart:math';
import 'dart:ui' as ui;

import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:pro_image_editor/pro_image_editor.dart';
import 'package:pro_video_editor/pro_video_editor.dart';

import '/shared/widgets/pixel_transparent_painter.dart';

/// A widget that previews a video from raw bytes.
///
/// Displays the video and optionally shows when it was generated.
class PreviewVideo extends StatefulWidget {
  /// Creates a [PreviewVideo] widget.
  const PreviewVideo({
    super.key,
    required this.filePath,
    required this.generationTime,
  });

  /// The file path of the video to be previewed.
  ///
  /// This property holds the location of the video file as a string.
  /// It is used to load and display the video in the preview feature.
  final String filePath;

  /// The time it took to generate the video preview.
  final Duration generationTime;

  @override
  State<PreviewVideo> createState() => _PreviewVideoState();
}

class _PreviewVideoState extends State<PreviewVideo> {
  final _valueStyle = const TextStyle(fontStyle: FontStyle.italic);

  late Future<VideoMetadata> _videoMetadata;
  late final int _generationTime = widget.generationTime.inMilliseconds;
  final _player = Player();
  late final _controller = VideoController(_player);

  final _numberFormatter = NumberFormat();

  @override
  void initState() {
    super.initState();

    _videoMetadata = ProVideoEditor.instance.getMetadata(
      EditorVideo.file(widget.filePath),
    );
    _initializePlayer();
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  void _initializePlayer() async {
    var media = Media('file://${widget.filePath}');
    await _player.open(media, play: true);
  }

  String formatBytes(int bytes, [int decimals = 2]) {
    if (bytes <= 0) return '0 B';
    const suffixes = ['B', 'KB', 'MB', 'GB', 'TB'];
    var i = (log(bytes) / log(1024)).floor();
    var size = bytes / pow(1024, i);
    return '${size.toStringAsFixed(decimals)} ${suffixes[i]}';
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      return Theme(
        data: Theme.of(context),
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Result'),
          ),
          body: CustomPaint(
            painter: const PixelTransparentPainter(
              primary: Color.fromARGB(255, 17, 17, 17),
              secondary: Color.fromARGB(255, 36, 36, 37),
            ),
            child: Stack(
              fit: StackFit.expand,
              alignment: Alignment.center,
              children: [
                _buildVideoPlayer(constraints),
                _buildGenerationInfos(),
              ],
            ),
          ),
        ),
      );
    });
  }

  Widget _buildVideoPlayer(BoxConstraints constraints) {
    return FutureBuilder<VideoMetadata>(
        future: _videoMetadata,
        builder: (context, snapshot) {
          final aspectRatio = snapshot.data?.resolution.aspectRatio ?? 1;
          final rotation = snapshot.data?.rotation ?? 0;

          int convertedRotation = rotation % 360;

          final is90DegRotated =
              convertedRotation == 90 || convertedRotation == 270;

          final maxWidth = constraints.maxWidth;
          final maxHeight = constraints.maxHeight;

          double width = maxWidth;
          double height =
              is90DegRotated ? width * aspectRatio : width / aspectRatio;

          if (height > maxHeight) {
            height = maxHeight;
            width = height * aspectRatio;
          }
          return Center(
            child: SizedBox(
              width: width,
              height: height,
              child: Hero(
                tag: const ProImageEditorConfigs().heroTag,
                child: Video(
                  key: const ValueKey('Preview-Video-Player'),
                  controller: _controller,
                ),
              ),
            ),
          );
        });
  }

  Widget _buildGenerationInfos() {
    TableRow tableSpace = const TableRow(
      children: [SizedBox(height: 3), SizedBox()],
    );
    return Positioned(
      top: 10,
      child: ClipRect(
        child: BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: 6, sigmaY: 6),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(7),
            ),
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            child: FutureBuilder<VideoMetadata>(
                future: _videoMetadata,
                builder: (context, snapshot) {
                  var data = snapshot.data;

                  if (data == null ||
                      snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator.adaptive();
                  }

                  return Table(
                    defaultColumnWidth: const IntrinsicColumnWidth(),
                    children: [
                      TableRow(children: [
                        const Text('Generation-Time'),
                        Padding(
                          padding: const EdgeInsets.only(left: 8.0),
                          child: Text(
                            '${_numberFormatter.format(_generationTime)} ms',
                            style: _valueStyle,
                            textAlign: TextAlign.right,
                          ),
                        ),
                      ]),
                      tableSpace,
                      TableRow(children: [
                        const Text('Video-Size'),
                        Padding(
                          padding: const EdgeInsets.only(left: 8.0),
                          child: Text(
                            formatBytes(data.fileSize),
                            style: _valueStyle,
                            textAlign: TextAlign.right,
                          ),
                        ),
                      ]),
                      tableSpace,
                      TableRow(children: [
                        const Text('Content-Type'),
                        Padding(
                          padding: const EdgeInsets.only(left: 8.0),
                          child: Text(
                            'video/${data.extension}',
                            style: _valueStyle,
                            textAlign: TextAlign.right,
                          ),
                        ),
                      ]),
                      tableSpace,
                      TableRow(children: [
                        const Text('Dimension'),
                        Padding(
                          padding: const EdgeInsets.only(left: 8.0),
                          child: Text(
                            '${_numberFormatter.format(
                              data.resolution.width.round(),
                            )} x ${_numberFormatter.format(
                              data.resolution.height.round(),
                            )}',
                            style: _valueStyle,
                            textAlign: TextAlign.right,
                          ),
                        ),
                      ]),
                      tableSpace,
                      TableRow(children: [
                        const Text('Video-Duration'),
                        Padding(
                          padding: const EdgeInsets.only(left: 8.0),
                          child: Text(
                            '${data.duration.inSeconds} s',
                            style: _valueStyle,
                            textAlign: TextAlign.right,
                          ),
                        ),
                      ]),
                    ],
                  );
                }),
          ),
        ),
      ),
    );
  }
}
