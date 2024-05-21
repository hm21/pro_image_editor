// Dart imports:
import 'dart:math';
import 'dart:typed_data';
import 'dart:ui';

// Flutter imports:
import 'package:flutter/material.dart';
import 'package:pro_image_editor/utils/decode_image.dart';

// Project imports:
import 'movable_background_image.dart';

class PreviewImgPage extends StatefulWidget {
  final Uint8List imgBytes;
  final double? generationTime;
  final String? contentType;

  const PreviewImgPage({
    super.key,
    required this.imgBytes,
    this.generationTime,
    this.contentType,
  });

  @override
  State<PreviewImgPage> createState() => _PreviewImgPageState();
}

class _PreviewImgPageState extends State<PreviewImgPage> {
  final _valueStyle = const TextStyle(
    fontStyle: FontStyle.italic,
  );

  Future<DecodedImageInfos>? decodedImageInfos;

  @override
  void initState() {
    super.initState();
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
    TableRow tableSpace =
        const TableRow(children: [SizedBox(height: 3), SizedBox()]);

    return LayoutBuilder(builder: (context, constraints) {
      decodedImageInfos ??= decodeImageInfos(
          bytes: widget.imgBytes, screenSize: constraints.biggest);

      return Theme(
        data: ThemeData.dark(),
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
                Hero(
                  tag: 'Pro-Image-Editor-Hero',
                  child: InteractiveViewer(
                    maxScale: 7,
                    minScale: 1,
                    child: Image.memory(
                      widget.imgBytes,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                if (widget.generationTime != null)
                  Positioned(
                    top: 10,
                    child: ClipRect(
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(7),
                          ),
                          padding: const EdgeInsets.symmetric(
                              vertical: 8, horizontal: 12),
                          child: FutureBuilder<DecodedImageInfos>(
                              future: decodedImageInfos,
                              builder: (context, snapshot) {
                                return Table(
                                  defaultColumnWidth:
                                      const IntrinsicColumnWidth(),
                                  children: [
                                    TableRow(children: [
                                      const Text('Generation-Time'),
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(left: 8.0),
                                        child: Text(
                                          '${widget.generationTime} ms',
                                          style: _valueStyle,
                                          textAlign: TextAlign.right,
                                        ),
                                      ),
                                    ]),
                                    tableSpace,
                                    TableRow(children: [
                                      const Text('Image-Size'),
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(left: 8.0),
                                        child: Text(
                                          formatBytes(widget.imgBytes.length),
                                          style: _valueStyle,
                                          textAlign: TextAlign.right,
                                        ),
                                      ),
                                    ]),
                                    tableSpace,
                                    TableRow(children: [
                                      const Text('Content-Type'),
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(left: 8.0),
                                        child: Text(
                                          widget.contentType ?? 'image/png',
                                          style: _valueStyle,
                                          textAlign: TextAlign.right,
                                        ),
                                      ),
                                    ]),
                                    tableSpace,
                                    TableRow(children: [
                                      const Text('Dimension'),
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(left: 8.0),
                                        child: Text(
                                          snapshot.connectionState ==
                                                  ConnectionState.done
                                              ? '${snapshot.data!.rawImageSize.width.round()} x ${snapshot.data!.rawImageSize.height.round()}'
                                              : 'Loading...',
                                          style: _valueStyle,
                                          textAlign: TextAlign.right,
                                        ),
                                      ),
                                    ]),
                                    tableSpace,
                                    TableRow(children: [
                                      const Text('Pixel-Ratio'),
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(left: 8.0),
                                        child: Text(
                                          snapshot.connectionState ==
                                                  ConnectionState.done
                                              ? snapshot.data!.pixelRatio
                                                  .toStringAsFixed(3)
                                              : 'Loading...',
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
                  ),
              ],
            ),
          ),
        ),
      );
    });
  }
}
