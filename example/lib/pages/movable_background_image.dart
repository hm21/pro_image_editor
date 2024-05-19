// Dart imports:
import 'dart:math';
import 'dart:ui' as ui;

// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Package imports:
import 'package:pro_image_editor/models/layer.dart';
import 'package:pro_image_editor/pro_image_editor.dart';
import 'package:pro_image_editor/widgets/loading_dialog.dart';

// Project imports:
import '../utils/example_helper.dart';
import 'reorder_layer_example.dart';

class MoveableBackgroundImageExample extends StatefulWidget {
  const MoveableBackgroundImageExample({super.key});

  @override
  State<MoveableBackgroundImageExample> createState() =>
      _MoveableBackgroundImageExampleState();
}

class _MoveableBackgroundImageExampleState
    extends State<MoveableBackgroundImageExample>
    with ExampleHelperState<MoveableBackgroundImageExample> {
  late Uint8List _transparentBytes;
  double _transparentAspectRatio = -1;

  /// Better sense of scale when we start with a large number
  final double _initScale = 20;

  Future<void> _createTransparentImage(double aspectRatio) async {
    if (_transparentAspectRatio == aspectRatio) return;

    /// The larger the value, the more precise but also slower.
    double minSize = 500;

    double width = aspectRatio < 1 ? minSize : minSize * aspectRatio;
    double height = aspectRatio < 1 ? minSize / aspectRatio : minSize;

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(
        recorder, Rect.fromLTWH(0, 0, width.toDouble(), height.toDouble()));
    final paint = Paint()..color = Colors.transparent;
    canvas.drawRect(
        Rect.fromLTWH(0.0, 0.0, width.toDouble(), height.toDouble()), paint);

    final picture = recorder.endRecording();
    final img = await picture.toImage(width.toInt(), height.toInt());
    final pngBytes = await img.toByteData(format: ui.ImageByteFormat.png);

    _transparentAspectRatio = aspectRatio;
    _transparentBytes = pngBytes!.buffer.asUint8List();
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () async {
        LoadingDialog loading = LoadingDialog()
          ..show(
            context,
            configs: const ProImageEditorConfigs(),
            theme: ThemeData.dark(),
          );
        var width = MediaQuery.of(context).size.width;
        var height = MediaQuery.of(context).size.height;

        double imgRatio = 1; // set the aspect ratio from your image.
        Size editorSize = Size(
          width - MediaQuery.of(context).padding.horizontal,
          height -
              kToolbarHeight -
              kBottomNavigationBarHeight -
              MediaQuery.of(context).padding.vertical,
        );

        await _createTransparentImage(editorSize.aspectRatio);

        if (!context.mounted) return;
        bool inited = false;

        String imageUrl =
            'https://picsum.photos/id/${Random().nextInt(200)}/2000';
        await precacheImage(NetworkImage(imageUrl), context);

        if (context.mounted) await loading.hide(context);

        if (!context.mounted) return;

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                LayoutBuilder(builder: (context, constraints) {
              return Stack(
                children: [
                  CustomPaint(
                    size: Size(constraints.maxWidth, constraints.maxHeight),
                    painter: const PixelTransparentPainter(
                      primary: Colors.white,
                      secondary: Color(0xFFE2E2E2),
                    ),
                    child: ProImageEditor.memory(
                      _transparentBytes,
                      key: editorKey,
                      callbacks: ProImageEditorCallbacks(
                        onImageEditingStarted: onImageEditingStarted,
                        onImageEditingComplete: onImageEditingComplete,
                        onCloseEditor: onCloseEditor,
                        onUpdateUI: () {
                          if (!inited) {
                            inited = true;

                            editorKey.currentState?.addLayer(
                              StickerLayerData(
                                offset: Offset.zero,
                                scale: _initScale,
                                sticker: Image.network(
                                  imageUrl,
                                  width: editorSize.width,
                                  height: editorSize.height,
                                  fit: BoxFit.cover,
                                  loadingBuilder:
                                      (context, child, loadingProgress) {
                                    return AnimatedSwitcher(
                                      layoutBuilder:
                                          (currentChild, previousChildren) {
                                        return SizedBox(
                                          width: 120,
                                          height: 120,
                                          child: Stack(
                                            fit: StackFit.expand,
                                            alignment: Alignment.center,
                                            children: <Widget>[
                                              ...previousChildren,
                                              if (currentChild != null)
                                                currentChild,
                                            ],
                                          ),
                                        );
                                      },
                                      duration:
                                          const Duration(milliseconds: 200),
                                      child: loadingProgress == null
                                          ? child
                                          : Center(
                                              child: CircularProgressIndicator(
                                                value: loadingProgress
                                                            .expectedTotalBytes !=
                                                        null
                                                    ? loadingProgress
                                                            .cumulativeBytesLoaded /
                                                        loadingProgress
                                                            .expectedTotalBytes!
                                                    : null,
                                              ),
                                            ),
                                    );
                                  },
                                ),
                              ),
                            );
                          }
                        },
                      ),
                      configs: ProImageEditorConfigs(
                          removeTransparentAreas: true,

                          /// Crop-Rotate, Filter and Blur editors are not supported
                          cropRotateEditorConfigs:
                              const CropRotateEditorConfigs(enabled: false),
                          filterEditorConfigs:
                              const FilterEditorConfigs(enabled: false),
                          blurEditorConfigs:
                              const BlurEditorConfigs(enabled: false),
                          imageEditorTheme: const ImageEditorTheme(
                            uiOverlayStyle: SystemUiOverlayStyle(
                              statusBarColor: Colors.black,
                            ),
                            background: Colors.transparent,

                            /// Optionally remove background
                            /// paintingEditor: PaintingEditorTheme(background: Colors.transparent),
                            /// cropRotateEditor: CropRotateEditorTheme(background: Colors.transparent),
                            /// filterEditor: FilterEditorTheme(background: Colors.transparent),
                            /// blurEditor: BlurEditorTheme(background: Colors.transparent),
                          ),
                          stickerEditorConfigs: StickerEditorConfigs(
                            enabled: false,
                            initWidth: (editorSize.aspectRatio > imgRatio
                                    ? editorSize.height
                                    : editorSize.width) /
                                _initScale,
                            buildStickers: (setLayer) {
                              // Optionally your code to pick layers
                              return const SizedBox();
                            },
                          )),
                    ),
                  ),
                  Positioned(
                    bottom: 2 * kBottomNavigationBarHeight,
                    left: 0,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.lightBlue.shade200,
                        borderRadius: const BorderRadius.only(
                          topRight: Radius.circular(100),
                          bottomRight: Radius.circular(100),
                        ),
                      ),
                      child: IconButton(
                        onPressed: () {
                          showModalBottomSheet(
                            context: context,
                            builder: (context) {
                              return ReorderLayerSheet(
                                layers: editorKey.currentState!.activeLayers,
                                onReorder: (oldIndex, newIndex) {
                                  editorKey.currentState!.moveLayerListPosition(
                                    oldIndex: oldIndex,
                                    newIndex: newIndex,
                                  );
                                  Navigator.pop(context);
                                },
                              );
                            },
                          );
                        },
                        icon: const Icon(Icons.reorder),
                      ),
                    ),
                  ),
                ],
              );
            }),
          ),
        );
      },
      leading: const Icon(Icons.pan_tool_alt_outlined),
      title: const Text('Movable background image'),
      trailing: const Icon(Icons.chevron_right),
    );
  }
}

class PixelTransparentPainter extends CustomPainter {
  final Color primary;
  final Color secondary;

  const PixelTransparentPainter({
    required this.primary,
    required this.secondary,
  });

  @override
  void paint(Canvas canvas, Size size) {
    const cellSize = 22.0; // Size of each square
    final numCellsX = size.width / cellSize;
    final numCellsY = size.height / cellSize;

    for (int row = 0; row < numCellsY; row++) {
      for (int col = 0; col < numCellsX; col++) {
        final color = (row + col) % 2 == 0 ? primary : secondary;
        canvas.drawRect(
          Rect.fromLTWH(col * cellSize, row * cellSize, cellSize, cellSize),
          Paint()..color = color,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
