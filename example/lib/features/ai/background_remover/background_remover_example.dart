// Flutter imports:
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:image_background_remover/image_background_remover.dart';
import 'package:image_picker/image_picker.dart';
import 'package:material_ui/material_ui.dart';
import 'package:pro_image_editor/pro_image_editor.dart';

// Project imports:
import '/core/mixin/example_helper.dart';

/// A widget that demonstrates how to remove the background from a image.
class BackgroundRemoverExample extends StatefulWidget {
  /// Creates a new [BackgroundRemoverExample] widget.
  const BackgroundRemoverExample({super.key});

  @override
  State<BackgroundRemoverExample> createState() =>
      _BackgroundRemoverExampleState();
}

class _BackgroundRemoverExampleState extends State<BackgroundRemoverExample>
    with ExampleHelperState<BackgroundRemoverExample> {
  final _url = 'https://picsum.photos/id/669/1600';

  @override
  void initState() {
    super.initState();
    BackgroundRemover.instance.initializeOrt();
    preCacheImage(networkUrl: _url);
  }

  @override
  void dispose() {
    BackgroundRemover.instance.dispose();
    super.dispose();
  }

  void _removeBackground() async {
    final editor = editorKey.currentState!;

    LoadingDialog dialog = LoadingDialog.instance
      ..show(
        context,
        configs: const ProImageEditorConfigs(),
      );

    await Future(() async {
      final imageBytes = await editor.editorImage!.safeByteArray();
      if (!mounted) return;

      final resultImage = await BackgroundRemover.instance.removeBg(
        imageBytes,
        threshold: 0.5,
        enhanceEdges: true,
        smoothMask: true,
      );
      if (!mounted) return;

      var resultBytes = await ImageConverter.instance.uiImageToImageBytes(
        resultImage,
        context: context,
      );
      if (!mounted) return;

      /// Optional set a background color
      ///
      /// resultBytes = await BackgroundRemover.instance.addBackground(
      ///   image: resultBytes!,
      ///   bgColor: Colors.pink, // Set your desired background color
      /// );

      await editor.updateBackgroundImage(EditorImage(byteArray: resultBytes));
    });
    dialog.hide();
  }

  void _openPicker() async {
    final editor = editorKey.currentState!;

    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image == null) return;

    Uint8List? bytes;

    bytes = await image.readAsBytes();

    if (!mounted) return;
    await precacheImage(MemoryImage(bytes), context);

    await editor.updateBackgroundImage(EditorImage(byteArray: bytes));
  }

  @override
  Widget build(BuildContext context) {
    if (!isPreCached) return const PrepareImageWidget();

    return ProImageEditor.network(
      _url,
      key: editorKey,
      callbacks: ProImageEditorCallbacks(
        onImageEditingStarted: onImageEditingStarted,
        onImageEditingComplete: onImageEditingComplete,
        onCloseEditor: (editorMode) => onCloseEditor(editorMode: editorMode),
        mainEditorCallbacks: MainEditorCallbacks(
          helperLines: HelperLinesCallbacks(onLineHit: vibrateLineHit),
        ),
      ),
      configs: ProImageEditorConfigs(
        designMode: platformDesignMode,
        imageGeneration: const ImageGenerationConfigs(
          outputFormat: OutputFormat.png,
        ),
        mainEditor: MainEditorConfigs(
          enableCloseButton: !isDesktopMode(context),
          widgets: _buildBodyItems(),
        ),
      ),
    );
  }

  MainEditorWidgets _buildBodyItems() {
    return MainEditorWidgets(
      bodyItems: (editor, rebuildStream) {
        return [
          ReactiveWidget(
            stream: rebuildStream,
            builder: (_) =>
                editor.isLayerBeingTransformed || editor.isSubEditorOpen
                    ? const SizedBox.shrink()
                    : Positioned(
                        bottom: 20,
                        left: 0,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.blue.shade700,
                            borderRadius: const BorderRadius.only(
                              topRight: Radius.circular(100),
                              bottomRight: Radius.circular(100),
                            ),
                          ),
                          child: GestureInterceptor(
                            child: IconButton(
                              onPressed: _removeBackground,
                              icon: const Icon(
                                Icons.content_cut,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
          ),
          ReactiveWidget(
            stream: rebuildStream,
            builder: (_) =>
                editor.isLayerBeingTransformed || editor.isSubEditorOpen
                    ? const SizedBox.shrink()
                    : Positioned(
                        bottom: 20,
                        right: 0,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.green.shade700,
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(100),
                              bottomLeft: Radius.circular(100),
                            ),
                          ),
                          child: GestureInterceptor(
                            child: IconButton(
                              onPressed: _openPicker,
                              icon: const Icon(
                                Icons.image,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
          ),
        ];
      },
    );
  }
}
