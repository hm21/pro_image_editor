// Dart imports:
import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'dart:ui' as ui;

// Flutter imports:
import 'package:example/pages/pick_image_example.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

// Package imports:
import 'package:pro_image_editor/pro_image_editor.dart';

// Project imports:
import '../utils/example_helper.dart';
import '../utils/pixel_transparent_painter.dart';
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
  late final ScrollController _bottomBarScrollCtrl;
  late Uint8List _transparentBytes;
  double _transparentAspectRatio = -1;

  /// Better sense of scale when we start with a large number
  final double _initScale = 20;

  final _bottomTextStyle = const TextStyle(fontSize: 10.0, color: Colors.white);

  @override
  void initState() {
    _bottomBarScrollCtrl = ScrollController();
    super.initState();
  }

  @override
  void dispose() {
    _bottomBarScrollCtrl.dispose();
    super.dispose();
  }

  void _openPicker(ImageSource source) async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: source);

    if (image == null) return;

    Uint8List? bytes;

    bytes = await image.readAsBytes();

    if (!mounted) return;
    await precacheImage(MemoryImage(bytes), context);
    var decodedImage = await decodeImageFromList(bytes);

    if (!mounted) return;
    if (kIsWeb ||
        (!Platform.isWindows && !Platform.isLinux && !Platform.isMacOS)) {
      Navigator.pop(context);
    }

    editorKey.currentState!.addLayer(
      StickerLayerData(
        offset: Offset.zero,
        scale: _initScale * 0.5,
        sticker: Image.memory(
          bytes,
          width: decodedImage.width.toDouble(),
          height: decodedImage.height.toDouble(),
          fit: BoxFit.cover,
        ),
      ),
    );
    setState(() {});
  }

  void _chooseCameraOrGallery() async {
    /// Open directly the gallery if the camera is not supported
    if (!kIsWeb &&
        (Platform.isWindows || Platform.isLinux || Platform.isMacOS)) {
      _openPicker(ImageSource.gallery);
      return;
    }

    if (!kIsWeb && Platform.isIOS) {
      showCupertinoModalPopup(
        context: context,
        builder: (BuildContext context) => CupertinoTheme(
          data: const CupertinoThemeData(),
          child: CupertinoActionSheet(
            actions: <CupertinoActionSheetAction>[
              CupertinoActionSheetAction(
                onPressed: () => _openPicker(ImageSource.camera),
                child: const Wrap(
                  spacing: 7,
                  runAlignment: WrapAlignment.center,
                  children: [
                    Icon(CupertinoIcons.photo_camera),
                    Text('Camera'),
                  ],
                ),
              ),
              CupertinoActionSheetAction(
                onPressed: () => _openPicker(ImageSource.gallery),
                child: const Wrap(
                  spacing: 7,
                  runAlignment: WrapAlignment.center,
                  children: [
                    Icon(CupertinoIcons.photo),
                    Text('Gallery'),
                  ],
                ),
              ),
            ],
            cancelButton: CupertinoActionSheetAction(
              isDefaultAction: true,
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
          ),
        ),
      );
    } else {
      showModalBottomSheet(
        context: context,
        showDragHandle: true,
        constraints: BoxConstraints(
          minWidth: min(MediaQuery.of(context).size.width, 360),
        ),
        builder: (context) {
          return Material(
            color: Colors.transparent,
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 24, left: 16, right: 16),
                child: Wrap(
                  spacing: 45,
                  runSpacing: 30,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  runAlignment: WrapAlignment.center,
                  alignment: WrapAlignment.spaceAround,
                  children: [
                    MaterialIconActionButton(
                      primaryColor: const Color(0xFFEC407A),
                      secondaryColor: const Color(0xFFD3396D),
                      icon: Icons.photo_camera,
                      text: 'Camera',
                      onTap: () => _openPicker(ImageSource.camera),
                    ),
                    MaterialIconActionButton(
                      primaryColor: const Color(0xFFBF59CF),
                      secondaryColor: const Color(0xFFAC44CF),
                      icon: Icons.image,
                      text: 'Gallery',
                      onTap: () => _openPicker(ImageSource.gallery),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      );
    }
  }

  Future<void> _createTransparentImage(double aspectRatio) async {
    if (_transparentAspectRatio == aspectRatio) return;

    double minSize = 1;

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

  Size get _editorSize => Size(
        MediaQuery.of(context).size.width -
            MediaQuery.of(context).padding.horizontal,
        MediaQuery.of(context).size.height -
            kToolbarHeight -
            kBottomNavigationBarHeight -
            MediaQuery.of(context).padding.vertical,
      );
  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () async {
        LoadingDialog.instance.show(
          context,
          configs: const ProImageEditorConfigs(),
          theme: ThemeData.dark(),
        );
        double imgRatio = 1; // set the aspect ratio from your image.

        await _createTransparentImage(_editorSize.aspectRatio);

        if (!context.mounted) return;

        String imageUrl =
            'https://picsum.photos/id/${Random().nextInt(200)}/2000';
        await precacheImage(NetworkImage(imageUrl), context);

        LoadingDialog.instance.hide();

        if (!context.mounted) return;
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                LayoutBuilder(builder: (context, constraints) {
              return CustomPaint(
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
                    mainEditorCallbacks: MainEditorCallbacks(
                      onAfterViewInit: () {
                        editorKey.currentState!.addLayer(
                          StickerLayerData(
                            offset: Offset.zero,
                            scale: _initScale,
                            sticker: Image.network(
                              imageUrl,
                              width: _editorSize.width,
                              height: _editorSize.height,
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
                      },
                    ),
                  ),
                  configs: ProImageEditorConfigs(
                      designMode: platformDesignMode,
                      imageGenerationConfigs: ImageGenerationConfigs(
                        captureOnlyDrawingBounds: true,
                        captureOnlyBackgroundImageArea: false,
                        outputFormat: OutputFormat.png,

                        /// Set the pixel ratio manually. You can also set this value higher than the device pixel ratio for higher quality.
                        customPixelRatio: max(
                            2000 / MediaQuery.of(context).size.width,
                            MediaQuery.of(context).devicePixelRatio),
                      ),

                      /// Crop-Rotate, Filter and Blur editors are not supported
                      cropRotateEditorConfigs:
                          const CropRotateEditorConfigs(enabled: false),
                      filterEditorConfigs:
                          const FilterEditorConfigs(enabled: false),
                      blurEditorConfigs:
                          const BlurEditorConfigs(enabled: false),
                      customWidgets: ImageEditorCustomWidgets(
                          mainEditor: CustomWidgetsMainEditor(
                        bodyItems: (editor, rebuildStream) {
                          return [
                            ReactiveCustomWidget(
                              stream: rebuildStream,
                              builder: (_) => editor.selectedLayerIndex >= 0 ||
                                      editor.isSubEditorOpen
                                  ? const SizedBox.shrink()
                                  : Positioned(
                                      bottom: 20,
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
                                                  layers: editor.activeLayers,
                                                  onReorder:
                                                      (oldIndex, newIndex) {
                                                    editor
                                                        .moveLayerListPosition(
                                                      oldIndex: oldIndex,
                                                      newIndex: newIndex,
                                                    );
                                                    Navigator.pop(context);
                                                  },
                                                );
                                              },
                                            );
                                          },
                                          icon: const Icon(
                                            Icons.reorder,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ),
                            ),
                          ];
                        },
                        bottomBar: (editor, rebuildStream, key) =>
                            editor.selectedLayerIndex < 0
                                ? ReactiveCustomWidget(
                                    stream: rebuildStream,
                                    key: key,
                                    builder: (_) => _bottomNavigationBar(
                                      editor,
                                      constraints,
                                    ),
                                  )
                                : null,
                      )),
                      imageEditorTheme: const ImageEditorTheme(
                        uiOverlayStyle: SystemUiOverlayStyle(
                          statusBarColor: Colors.black,
                        ),
                        background: Colors.transparent,
                        paintingEditor:
                            PaintingEditorTheme(background: Colors.transparent),

                        /// Optionally remove background
                        /// cropRotateEditor: CropRotateEditorTheme(background: Colors.transparent),
                        /// filterEditor: FilterEditorTheme(background: Colors.transparent),
                        /// blurEditor: BlurEditorTheme(background: Colors.transparent),
                      ),
                      stickerEditorConfigs: StickerEditorConfigs(
                        enabled: false,
                        initWidth: (_editorSize.aspectRatio > imgRatio
                                ? _editorSize.height
                                : _editorSize.width) /
                            _initScale,
                        buildStickers: (setLayer, scrollController) {
                          // Optionally your code to pick layers
                          return const SizedBox();
                        },
                      )),
                ),
              );
            }),
          ),
        );
      },
      leading: const Icon(Icons.pan_tool_alt_outlined),
      title: const Text('Movable background image'),
      subtitle: const Text('Includes how to add multiple images.'),
      trailing: const Icon(Icons.chevron_right),
    );
  }

  Widget _bottomNavigationBar(
    ProImageEditorState editor,
    BoxConstraints constraints,
  ) {
    return Scrollbar(
      controller: _bottomBarScrollCtrl,
      scrollbarOrientation: ScrollbarOrientation.top,
      thickness: isDesktop ? null : 0,
      child: BottomAppBar(
        /// kBottomNavigationBarHeight is important that helper-lines will work
        height: kBottomNavigationBarHeight,
        color: Colors.black,
        padding: EdgeInsets.zero,
        child: Center(
          child: SingleChildScrollView(
            controller: _bottomBarScrollCtrl,
            scrollDirection: Axis.horizontal,
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minWidth: min(constraints.maxWidth, 500),
                maxWidth: 500,
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    FlatIconTextButton(
                      label: Text('Add Image', style: _bottomTextStyle),
                      icon: const Icon(
                        Icons.image_outlined,
                        size: 22.0,
                        color: Colors.white,
                      ),
                      onPressed: _chooseCameraOrGallery,
                    ),
                    FlatIconTextButton(
                      label: Text('Paint', style: _bottomTextStyle),
                      icon: const Icon(
                        Icons.edit_rounded,
                        size: 22.0,
                        color: Colors.white,
                      ),
                      onPressed: editor.openPaintingEditor,
                    ),
                    FlatIconTextButton(
                      label: Text('Text', style: _bottomTextStyle),
                      icon: const Icon(
                        Icons.text_fields,
                        size: 22.0,
                        color: Colors.white,
                      ),
                      onPressed: editor.openTextEditor,
                    ),
                    FlatIconTextButton(
                      label: Text('Emoji', style: _bottomTextStyle),
                      icon: const Icon(
                        Icons.sentiment_satisfied_alt_rounded,
                        size: 22.0,
                        color: Colors.white,
                      ),
                      onPressed: editor.openEmojiEditor,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
