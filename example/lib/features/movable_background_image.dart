import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';
import 'package:pro_image_editor/pro_image_editor.dart';

import '/core/mixin/example_helper.dart';
import '/shared/widgets/pixel_transparent_painter.dart';

/// The example for movableBackground
class MovableBackgroundImageExample extends StatefulWidget {
  /// Creates a new [MovableBackgroundImageExample] widget.
  const MovableBackgroundImageExample({super.key});

  @override
  State<MovableBackgroundImageExample> createState() =>
      _MovableBackgroundImageExampleState();
}

class _MovableBackgroundImageExampleState
    extends State<MovableBackgroundImageExample>
    with ExampleHelperState<MovableBackgroundImageExample> {
  final _outputSize = const Size(1080, 1920);

  /// Better sense of scale when we start with a large number
  final double _initScale = 20;

  late final _imageUrl = 'https://picsum.photos/id/230/'
      '${_outputSize.width.toInt()}/${_outputSize.height.toInt()}';

  final _uiOverlayStyle = const SystemUiOverlayStyle(
    statusBarColor: Colors.black,
  );

  final _isMovableImageReadyNotifier = ValueNotifier(false);

  @override
  void initState() {
    super.initState();
    preCacheImage(networkUrl: _imageUrl);
  }

  @override
  void dispose() {
    _isMovableImageReadyNotifier.dispose();
    super.dispose();
  }

  void _onAfterViewInit() {
    final backgroundImage = WidgetLayer(
      offset: Offset.zero,
      scale: _initScale,
      widget: Image.network(
        _imageUrl,
        width: _outputSize.width,
        height: _outputSize.height,
        fit: BoxFit.cover,
      ),
    );

    editorKey.currentState!.addLayer(backgroundImage);
    _isMovableImageReadyNotifier.value = true;
  }

  late final _callbacks = ProImageEditorCallbacks(
    onImageEditingStarted: onImageEditingStarted,
    onImageEditingComplete: onImageEditingComplete,
    onCloseEditor: (editorMode) => onCloseEditor(
      editorMode: editorMode,
      enablePop: !isDesktopMode(context),
    ),
    mainEditorCallbacks: MainEditorCallbacks(
      onAfterViewInit: _onAfterViewInit,
    ),
  );

  Size get _editorBodySize =>
      editorKey.currentState?.sizesManager.bodySize ??
      MediaQuery.sizeOf(context);

  late final _configs = ProImageEditorConfigs(
    designMode: platformDesignMode,
    imageGeneration: const ImageGenerationConfigs(
      cropToDrawingBounds: true,
      enableUseOriginalBytes: false,
      outputFormat: OutputFormat.png,
    ),
    layerInteraction: const LayerInteractionConfigs(
      initialSelected: false,
    ),
    mainEditor: MainEditorConfigs(
      /// Crop-Rotate, Filter, Tune and Blur editors are not supported
      tools: [
        SubEditorMode.paint,
        SubEditorMode.text,
        SubEditorMode.emoji,
        // SubEditorMode.cropRotate,
        // SubEditorMode.tune,
        // SubEditorMode.filter,
        // SubEditorMode.blur,
        //  SubEditorMode.sticker,
      ],
      enableCloseButton: !isDesktopMode(context),
      style: MainEditorStyle(
        uiOverlayStyle: _uiOverlayStyle,
        background: Colors.transparent,
      ),
    ),
    paintEditor: PaintEditorConfigs(
      style: PaintEditorStyle(
        uiOverlayStyle: _uiOverlayStyle,
        background: Colors.transparent,
      ),
    ),
  );

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: const PixelTransparentPainter(
        primary: Colors.white,
        secondary: Color(0xFFE2E2E2),
      ),
      child: ValueListenableBuilder(
          valueListenable: _isMovableImageReadyNotifier,
          builder: (_, isReady, __) {
            return Stack(
              fit: StackFit.expand,
              children: [
                if (isPreCached)
                  ProImageEditor.blank(
                    _outputSize,
                    key: editorKey,
                    callbacks: _callbacks,
                    configs: _configs.copyWith(
                      // The sticker configurations must be rendered in the
                      // build itself because the editorBodySize is not
                      // available before the editor is rendered.
                      stickerEditor: StickerEditorConfigs(
                        initWidth: (_editorBodySize.aspectRatio >
                                    _outputSize.aspectRatio
                                ? _editorBodySize.height *
                                    _outputSize.aspectRatio
                                : _editorBodySize.width) /
                            _initScale,
                      ),
                    ),
                  ),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 400),
                  switchInCurve: Curves.easeInOut,
                  child: isReady
                      ? const SizedBox.shrink(key: ValueKey('Loader'))
                      : const SizedBox.expand(child: PrepareImageWidget()),
                )
              ],
            );
          }),
    );
  }
}
