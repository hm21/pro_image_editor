// ignore_for_file: public_member_api_docs, avoid_print

import 'dart:math';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mime/mime.dart';

import 'package:pro_image_editor/pro_image_editor.dart';

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
      home: const ImagePickerScreen(),
    );
  }
}

class ImagePickerScreen extends StatefulWidget {
  const ImagePickerScreen({super.key});

  @override
  State<ImagePickerScreen> createState() => _ImagePickerScreenState();
}

class _ImagePickerScreenState extends State<ImagePickerScreen> {
  bool _showOriginal = false;
  Uint8List? _imageBytes;
  Uint8List? _originalBytes;
  int _testCount = 0;

  @override
  void initState() {
    super.initState();
    _loadImg();
  }

  Future<void> _loadImg() async {
    _originalBytes =
        await fetchImageAsUint8List('https://picsum.photos/id/230/500');
    _imageBytes = _originalBytes;

    setState(() {});
  }

  void _openEditor() async {
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
                    captureOnlyDrawingBounds: true, */
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
              if (bytes.isNotEmpty) {
                _testCount++;
                var decodedImage = await decodeImageFromList(bytes);
                print(
                  Size(
                    decodedImage.width.toDouble(),
                    decodedImage.height.toDouble(),
                  ),
                );
                setState(() => _imageBytes = bytes);
              }

              if (context.mounted) Navigator.pop(context);
            },
          ),
        ),
      ),
    ).whenComplete(() async {
      if (_testCount % 10 != 0) {
        _openEditor();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Image Picker Example'),
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
              _showOriginal = true;
            }),
            tooltip: 'Reset',
            icon: const Icon(Icons.restore),
          ),
        ],
      ),
      body: Container(
        color: Colors.lightBlue,
        child: Stack(
          children: [
            Center(
              child: _imageBytes != null
                  ? Image.memory(_imageBytes!)
                  : const Text('No image selected.'),
            ),
            if (_showOriginal && _originalBytes != null)
              Center(
                child: Image.memory(
                  _originalBytes!,
                ),
              )
          ],
        ),
      ),
      floatingActionButton: _imageBytes == null
          ? null
          : FloatingActionButton.extended(
              onPressed: _openEditor,
              label: const Text('+ 10 Edits'),
            ),
    );
  }
}
