// Dart imports:
import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:material_ui/material_ui.dart';
import 'package:pro_image_editor/pro_image_editor.dart';
import 'package:pro_image_editor/shared/utils/transparent_image_generator_utils.dart';

import '/core/mixin/example_helper.dart';
import '/shared/widgets/material_icon_button.dart';
import '/shared/widgets/pixel_transparent_painter.dart';

/// The example for a frame around the images
class FrameExample extends StatefulWidget {
  /// Creates a new [FrameExample] widget.
  const FrameExample({super.key});

  @override
  State<FrameExample> createState() => _FrameExampleState();
}

class _FrameExampleState extends State<FrameExample>
    with ExampleHelperState<FrameExample> {
  late final ScrollController _bottomBarScrollCtrl;

  String _frameUrl = 'assets/frame.png';

  /// Better scale experience
  final double _initScale = 10;
  final double _layerInitWidth = 200;

  final _bottomTextStyle = const TextStyle(fontSize: 10.0, color: Colors.white);

  Uint8List? _transparentBytes;

  @override
  void initState() {
    super.initState();
    _bottomBarScrollCtrl = ScrollController();
    preCacheImage(assetPath: _frameUrl);
    _createTransparentBackgroundImage();
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
      WidgetLayer(
        /// Adjust the offset position to place the image at any desired
        /// location. Note that a zero offset places the image at the center
        /// of the editor.
        offset: Offset.zero,
        scale: _initScale,
        widget: Image.memory(
          bytes,
          width: 100,
          height: 100 /
              Size(
                decodedImage.width.toDouble(),
                decodedImage.height.toDouble(),
              ).aspectRatio,
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
      await showCupertinoModalPopup(
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
      await showModalBottomSheet(
        context: context,
        showDragHandle: true,
        constraints: BoxConstraints(
          minWidth: min(MediaQuery.sizeOf(context).width, 360),
        ),
        builder: (context) => SafeArea(
          child: Material(
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
          ),
        ),
      );
    }
  }

  void _toggleFrame() async {
    String newFrameUrl = _frameUrl == 'assets/frame.png'
        ? 'assets/frame1.png'
        : 'assets/frame.png';

    /// Important to precache the frame before we add it to the editor
    await precacheImage(AssetImage(newFrameUrl), context);

    _frameUrl = newFrameUrl;

    /// Mark all background-generated screenshots as broken, as the user has
    /// selected a different frame. This will trigger the screenshot to
    /// regenerate when the user selects 'Done.'
    for (var el in editorKey.currentState!.stateManager.screenshots) {
      el.broken = true;
    }

    /// To allow users to switch between multiple frames efficiently,
    /// consider caching the image bytes.
    await _createTransparentBackgroundImage();

    /// Set the background bounds
    await editorKey.currentState!.updateBackgroundImage(
      EditorImage(byteArray: _transparentBytes),
      updateHistory: false,
    );

    await editorKey.currentState!.decodeImage();
  }

  Future<void> _createTransparentBackgroundImage() async {
    var frameBytes = await _frameImage.safeByteArray(context);

    var decodedImage = await decodeImageFromList(frameBytes);

    final bytes = await createTransparentImage(Size(
      decodedImage.width.toDouble(),
      decodedImage.height.toDouble(),
    ));
    // ignore: use_build_context_synchronously
    await precacheImage(MemoryImage(bytes), context);

    _transparentBytes = bytes;
    if (mounted) setState(() {});
  }

  EditorImage get _frameImage => EditorImage(
        assetPath: _frameUrl,

        /// Optional use another option below
        ///
        /// networkUrl: ,
        /// byteArray: ,
        /// file: ,
      );

  @override
  Widget build(BuildContext context) {
    if (!isPreCached || _transparentBytes == null) {
      return const PrepareImageWidget();
    }

    return LayoutBuilder(builder: (context, constraints) {
      return CustomPaint(
        size: Size(constraints.maxWidth, constraints.maxHeight),
        painter: const PixelTransparentPainter(
          primary: Colors.white,
          secondary: Color(0xFFE2E2E2),
        ),
        child: _buildEditor(constraints),
      );
    });
  }

  Widget _buildEditor(BoxConstraints constraints) {
    return ProImageEditor.memory(
      _transparentBytes!,
      key: editorKey,
      callbacks: ProImageEditorCallbacks(
        onImageEditingStarted: onImageEditingStarted,
        onImageEditingComplete: onImageEditingComplete,
        onCloseEditor: (editorMode) => onCloseEditor(
          editorMode: editorMode,
          enablePop: !isDesktopMode(context),
        ),
        mainEditorCallbacks: MainEditorCallbacks(
          helperLines: HelperLinesCallbacks(onLineHit: vibrateLineHit),
        ),
      ),
      configs: ProImageEditorConfigs(
          designMode: platformDesignMode,
          imageGeneration: const ImageGenerationConfigs(
            enableUseOriginalBytes: false,

            /// Optional set the output format to png. Default format is jpeg
            /// outputFormat: OutputFormat.png,
          ),
          layerInteraction: const LayerInteractionConfigs(
            selectable: LayerInteractionSelectable.disabled,
          ),
          mainEditor: MainEditorConfigs(
            /// Crop-Rotate, Filter, Tune and Blur editors are not supported
            tools: [
              SubEditorMode.paint,
              SubEditorMode.text,
              // SubEditorMode.cropRotate,
              // SubEditorMode.tune,
              // SubEditorMode.filter,
              // SubEditorMode.blur,
              SubEditorMode.emoji,
              // SubEditorMode.sticker,
            ],
            enableCloseButton: !isDesktopMode(context),
            widgets: MainEditorWidgets(
              bodyItemsRecorded: (editor, rebuildStream) => [
                _buildFrame(editor.sizesManager.bodySize, rebuildStream),
              ],
              bottomBar: (editor, rebuildStream, key) => ReactiveWidget(
                stream: rebuildStream,
                key: key,
                builder: (_) => _buildBottomBar(
                  editor,
                  constraints,
                ),
              ),
            ),
            style: const MainEditorStyle(
              background: Colors.transparent,
              uiOverlayStyle:
                  SystemUiOverlayStyle(statusBarColor: Colors.black),
            ),
          ),
          paintEditor: PaintEditorConfigs(
            widgets: PaintEditorWidgets(
              bodyItemsRecorded: (editor, rebuildStream) => [
                _buildFrame(editor.editorBodySize, rebuildStream),
              ],
            ),
            style: const PaintEditorStyle(
              background: Colors.transparent,
              uiOverlayStyle:
                  SystemUiOverlayStyle(statusBarColor: Colors.black),
            ),
          ),
          cropRotateEditor: const CropRotateEditorConfigs(

              /// widgets: CropRotateEditorWidgets(
              ///   bodyItems: (editor, rebuildStream) => [
              ///     _buildFrame(editor.editorBodySize, rebuildStream),
              ///   ],
              /// ),
              ),
          filterEditor: const FilterEditorConfigs(
              // widgets: FilterEditorWidgets(
              //   bodyItemsRecorded: (editor, rebuildStream) => [
              //     _buildFrame(editor.editorBodySize, rebuildStream),
              //   ],
              // ),
              ),
          blurEditor: const BlurEditorConfigs(
              // widgets: BlurEditorWidgets(
              //   bodyItemsRecorded: (editor, rebuildStream) => [
              //     _buildFrame(editor.editorBodySize, rebuildStream),
              //   ],
              // ),
              ),
          tuneEditor: const TuneEditorConfigs(
              // widgets: TuneEditorWidgets(
              //   bodyItemsRecorded: (editor, rebuildStream) => [
              //     _buildFrame(editor.editorBodySize, rebuildStream),
              //   ],
              // ),
              ),
          stickerEditor: StickerEditorConfigs(
            initWidth: _layerInitWidth / _initScale,
            builder: (setLayer, scrollController) {
              // Optionally your code to pick layers
              return const SizedBox();
            },
          )),
    );
  }

  ReactiveWidget _buildFrame(Size bodySize, Stream<void> rebuildStream) {
    return ReactiveWidget(
      builder: (_) => IgnorePointer(
        child: Image.asset(
          _frameUrl,
          width: bodySize.width,
          height: bodySize.height,
          fit: BoxFit.contain,
        ),
      ),
      stream: rebuildStream,
    );
  }

  Widget _buildBottomBar(
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
                      label: Text('Toggle Frame', style: _bottomTextStyle),
                      icon: const Icon(
                        Icons.filter_frames_outlined,
                        size: 22.0,
                        color: Colors.white,
                      ),
                      onPressed: _toggleFrame,
                    ),
                    const VerticalDivider(width: 3),
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
                      onPressed: editor.openPaintEditor,
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
