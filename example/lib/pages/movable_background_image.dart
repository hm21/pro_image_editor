import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pro_image_editor/models/layer.dart';
import 'package:pro_image_editor/modules/paint_editor/utils/draw/draw_canvas.dart';
import 'package:pro_image_editor/pro_image_editor.dart';
import 'dart:ui' as ui;

import '../utils/example_helper.dart';

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
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                LayoutBuilder(builder: (context, constraints) {
              return Stack(
                children: [
                  CustomPaint(
                    size: Size(constraints.maxWidth, constraints.maxHeight),
                    painter: PixelTransparentPainter(),
                    child: ProImageEditor.memory(
                      _transparentBytes,
                      key: editorKey,
                      onImageEditingComplete: onImageEditingComplete,
                      onCloseEditor: onCloseEditor,
                      onUpdateUI: () {
                        if (!inited) {
                          inited = true;

                          editorKey.currentState?.addLayer(
                            StickerLayerData(
                              offset: Offset(
                                editorSize.width / 2,
                                editorSize.height / 2,
                              ),
                              scale: _initScale,
                              sticker: Image.network(
                                'https://picsum.photos/id/${Random().nextInt(200)}/2000',
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
                                    duration: const Duration(milliseconds: 200),
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
  @override
  void paint(Canvas canvas, Size size) {
    const cellSize = 22.0; // Size of each square
    final numCellsX = size.width / cellSize;
    final numCellsY = size.height / cellSize;
    const grayColor = Color(0xFFE2E2E2); // Gray color
    const whiteColor = Colors.white; // White color

    for (int row = 0; row < numCellsY; row++) {
      for (int col = 0; col < numCellsX; col++) {
        final color = (row + col) % 2 == 0 ? whiteColor : grayColor;
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

class ReorderLayerSheet extends StatefulWidget {
  final List<Layer> layers;
  final ReorderCallback onReorder;

  const ReorderLayerSheet({
    super.key,
    required this.layers,
    required this.onReorder,
  });

  @override
  State<ReorderLayerSheet> createState() => _ReorderLayerSheetState();
}

class _ReorderLayerSheetState extends State<ReorderLayerSheet> {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            'Reorder',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.w500),
          ),
        ),
        Expanded(
          child: ReorderableListView.builder(
            itemBuilder: (context, index) {
              Layer layer = widget.layers[index];
              return ListTile(
                key: ValueKey(layer),
                title: layer.runtimeType == TextLayerData
                    ? Text(
                        (layer as TextLayerData).text,
                        style: const TextStyle(fontSize: 20),
                      )
                    : layer.runtimeType == EmojiLayerData
                        ? Text(
                            (layer as EmojiLayerData).emoji,
                            style: const TextStyle(fontSize: 24),
                          )
                        : layer.runtimeType == PaintingLayerData
                            ? SizedBox(
                                height: 40,
                                child: FittedBox(
                                  alignment: Alignment.centerLeft,
                                  child: CustomPaint(
                                    size: (layer as PaintingLayerData).size,
                                    willChange: true,
                                    isComplex:
                                        layer.item.mode == PaintModeE.freeStyle,
                                    painter: DrawCanvas(
                                      item: layer.item,
                                      scale: layer.scale,
                                      enabledHitDetection: false,
                                      freeStyleHighPerformanceScaling: false,
                                      freeStyleHighPerformanceMoving: false,
                                    ),
                                  ),
                                ),
                              )
                            : layer.runtimeType == StickerLayerData
                                ? SizedBox(
                                    height: 40,
                                    child: FittedBox(
                                      alignment: Alignment.centerLeft,
                                      child:
                                          (layer as StickerLayerData).sticker,
                                    ),
                                  )
                                : Text(layer.id.toString()),
              );
            },
            itemCount: widget.layers.length,
            onReorder: widget.onReorder,
          ),
        ),
      ],
    );
  }
}
