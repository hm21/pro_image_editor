// ignore_for_file: public_member_api_docs, avoid_print

import 'dart:math';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import 'package:pro_image_editor/pro_image_editor.dart';
import 'package:pro_image_editor/shared/widgets/extended/repaint/extended_render_repaint_boundary.dart';
import 'package:pro_image_editor/shared/widgets/extended/repaint/extended_repaint_boundary.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Image Picker Example',
      theme: ThemeData(primarySwatch: Colors.blue),
      debugShowCheckedModeBanner: false,
      home: const EditorTest(),
    );
  }
}

class EditorTest extends StatefulWidget {
  const EditorTest({super.key});

  @override
  State<EditorTest> createState() => _EditorTestState();
}

class _EditorTestState extends State<EditorTest> {
  final _testAreaKey = GlobalKey();

  bool _showOriginal = false;
  bool _enableQuickExample = false;

  int _testCount = 0;

  Uint8List? _imageBytes;
  Uint8List? _originalBytes;

  @override
  void initState() {
    super.initState();
    _loadImg();
  }

  Future<void> _loadImg() async {
    _originalBytes =
        await fetchImageAsUint8List('https://picsum.photos/id/230/500');
    _imageBytes = _originalBytes;

    _logSize();

    setState(() {});
  }

  /// Captures the widget wrapped in ExtendedRepaintBoundary and converts it to
  /// PNG bytes
  Future<void> _captureQuick() async {
    try {
      // Find the ExtendedRenderRepaintBoundary from the global key.
      ExtendedRenderRepaintBoundary boundary = _testAreaKey.currentContext!
          .findRenderObject() as ExtendedRenderRepaintBoundary;

      // Capture the image with an appropriate pixel ratio.
      double pixelRatio = 500 / MediaQuery.sizeOf(context).width;
      pixelRatio = (pixelRatio * 1000).round() / 1000;
      ui.Image image = await boundary.toImage();

      // Convert the captured image to PNG bytes.
      ByteData? byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);
      Uint8List pngBytes = byteData!.buffer.asUint8List();

      _setImage(pngBytes);
      await Future.delayed(const Duration(milliseconds: 200));
      _checkRecapture();
    } catch (e) {
      print('Error capturing image: $e');
    }
  }

  void _captureWithEditor() async {
    _showOriginal = false;

    final editor = GlobalKey<ProImageEditorState>();

    double radius = 140;
    double angle = (_testCount * 2 * pi) / 10;
    double x = radius * cos(angle);
    double y = radius * sin(angle);

    await Navigator.push(
      context,
      PageRouteBuilder(
        transitionDuration: Duration.zero,
        reverseTransitionDuration: Duration.zero,
        pageBuilder: (context, animation1, animation2) => ProImageEditor.memory(
          _imageBytes!,
          key: editor,
          configs: const ProImageEditorConfigs(
            layerInteraction: LayerInteractionConfigs(
              selectable: LayerInteractionSelectable.disabled,
              initialSelected: false,
              style: LayerInteractionStyle(
                buttonRadius: 10,
                strokeWidth: 1.2,
                borderElementWidth: 7,
                borderElementSpace: 5,
                borderColor: Colors.blue,
                removeCursor: SystemMouseCursors.click,
                rotateScaleCursor: SystemMouseCursors.click,
                editCursor: SystemMouseCursors.click,
                hoverCursor: SystemMouseCursors.move,
                borderStyle: LayerInteractionBorderStyle.solid,
                showTooltips: false,
              ),
            ),
            paintEditor: PaintEditorConfigs(canToggleFill: false),
            helperLines: HelperLineConfigs(hitVibration: false),
            blurEditor: BlurEditorConfigs(enabled: false),
            emojiEditor: EmojiEditorConfigs(enabled: false),
            imageGeneration: ImageGenerationConfigs(
              generateImageInBackground: false,
              /*  allowEmptyEditCompletion: true,
                  captureOnlyBackgroundImageArea: true,
                  captureOnlyDrawingBounds: true,
               */
            ),
          ),
          callbacks: ProImageEditorCallbacks(
            mainEditorCallbacks: MainEditorCallbacks(
              onAfterViewInit: () async {
                await Future.delayed(const Duration(milliseconds: 500));
                editor.currentState!.addLayer(
                  TextLayer(
                    text: '$_testCount',
                    color: Colors.red,
                    customSecondaryColor: true,
                    background: Colors.white,
                    fontScale: 1.6,
                    offset: Offset(x, y),
                  ),
                );
                await Future.delayed(const Duration(milliseconds: 1));
                editor.currentState!.doneEditing();
              },
            ),
            onImageEditingComplete: (Uint8List bytes) async {
              _setImage(bytes);

              if (context.mounted) Navigator.pop(context);
            },
          ),
        ),
      ),
    ).whenComplete(() async {
      await Future.delayed(const Duration(milliseconds: 200));
      _checkRecapture();
    });
  }

  void _setImage(Uint8List bytes) {
    if (bytes.isNotEmpty) {
      _testCount++;
      _imageBytes = bytes;
      _logSize();

      setState(() {});
    }
  }

  void _logSize() async {
    var decodedImage = await decodeImageFromList(_imageBytes!);
    print(
      'Image-Size: ${Size(
        decodedImage.width.toDouble(),
        decodedImage.height.toDouble(),
      )}',
    );
  }

  void _checkRecapture() {
    if (_testCount % 10 != 0) {
      if (_enableQuickExample) {
        _captureQuick();
      } else {
        _captureWithEditor();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: _buildAppBar(),
        body: _buildBody(),
        floatingActionButton: _buildFloatingAction());
  }

  AppBar _buildAppBar() {
    return AppBar(
      title: const Text('Bugfix'),
      actions: [
        IconButton(
          onPressed: () => setState(() {
            _showOriginal = !_showOriginal;
          }),
          tooltip: _showOriginal ? 'Hide Original' : 'Show Original',
          icon: Icon(_showOriginal ? Icons.visibility : Icons.visibility_off),
        ),
        IconButton(
          onPressed: () => setState(() {
            _imageBytes = _originalBytes;
            _testCount = 0;
            _enableQuickExample = !_enableQuickExample;
            _showOriginal = false;
          }),
          tooltip:
              _enableQuickExample ? 'Use Image-Editor' : 'Use Quick-Example',
          icon: Icon(_enableQuickExample ? Icons.speed : Icons.image),
        ),
        IconButton(
          onPressed: () => setState(() {
            _imageBytes = _originalBytes;
            _testCount = 0;
            _showOriginal = false;
          }),
          tooltip: 'Reset',
          icon: const Icon(Icons.restore),
        ),
      ],
    );
  }

  Widget _buildBody() {
    return Container(
      color: Colors.lightBlue,
      child: Stack(
        children: [
          if (_imageBytes == null)
            const Center(
              child: CircularProgressIndicator(color: Colors.white),
            )
          else
            _buildEditedImage(),
          _buildOriginal()
        ],
      ),
    );
  }

  Widget _buildEditedImage() {
    return Center(
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: SingleChildScrollView(
          child: ExtendedRepaintBoundary(
            key: _testAreaKey,
            child: SizedBox(
              width: 500,
              height: 500,
              child: Image.memory(
                _imageBytes!,
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOriginal() {
    if (_showOriginal && _originalBytes != null) {
      return Center(
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: SizedBox(
            width: 500,
            height: 500,
            child: Image.memory(
              _originalBytes!,
              fit: BoxFit.cover,
            ),
          ),
        ),
      );
    }
    return const SizedBox.shrink();
  }

  Widget? _buildFloatingAction() {
    return _imageBytes == null
        ? null
        : FloatingActionButton.extended(
            onPressed: _enableQuickExample ? _captureQuick : _captureWithEditor,
            label: const Text('+ 10 Edits'),
          );
  }
}
