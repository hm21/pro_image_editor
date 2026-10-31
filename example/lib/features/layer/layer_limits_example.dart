// Flutter imports:
import 'package:material_ui/material_ui.dart';

// Package imports:
import 'package:pro_image_editor/core/models/layers/layer_interaction.dart';
import 'package:pro_image_editor/pro_image_editor.dart';

// Project imports:
import '/core/constants/example_constants.dart';
import '/core/mixin/example_helper.dart';

/// A widget that demonstrates layers that stay inside an area and within a
/// range of sizes.
///
/// The editor opens with an emoji and a card inside a framed area. Drag,
/// pinch or turn them: they stop at the edges of the frame instead of
/// leaving it. The card does not turn and only scales between half and
/// twice its size.
///
/// Example usage:
/// ```dart
/// LayerLimitsExample();
/// ```
class LayerLimitsExample extends StatefulWidget {
  /// Creates a new [LayerLimitsExample] widget.
  const LayerLimitsExample({super.key});

  @override
  State<LayerLimitsExample> createState() => _LayerLimitsExampleState();
}

/// The state for the [LayerLimitsExample] widget.
class _LayerLimitsExampleState extends State<LayerLimitsExample>
    with ExampleHelperState<LayerLimitsExample> {
  @override
  void initState() {
    super.initState();
    preCacheImage(assetPath: kImageEditorExampleAssetPath);
  }

  /// The area the layers stay inside, in the logical pixels of the editor's
  /// body. It is derived from the size of the body, so it follows it when
  /// the device turns or the window is resized.
  static Rect _safeArea(Size editorBodySize) => Rect.fromLTRB(
        editorBodySize.width * 0.1,
        editorBodySize.height * 0.15,
        editorBodySize.width * 0.9,
        editorBodySize.height * 0.75,
      );

  void _onAfterViewInit() {
    editorKey.currentState!
      ..addLayer(
        EmojiLayer(
          emoji: '🎯',
          offset: const Offset(0, -60),
          interaction: LayerInteraction(bounds: _safeArea),
        ),
      )
      ..addLayer(
        WidgetLayer(
          offset: const Offset(0, 60),
          widget: _buildCard(),
          interaction: LayerInteraction(
            enableRotate: false,
            minScale: 0.5,
            maxScale: 2,
            bounds: _safeArea,
          ),
        ),
      );
  }

  Widget _buildCard() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Text(
        'Stays inside',
        style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!isPreCached) return const PrepareImageWidget();

    return ProImageEditor.asset(
      kImageEditorExampleAssetPath,
      key: editorKey,
      callbacks: ProImageEditorCallbacks(
        onImageEditingStarted: onImageEditingStarted,
        onImageEditingComplete: onImageEditingComplete,
        onCloseEditor: (editorMode) => onCloseEditor(
          editorMode: editorMode,
          enablePop: !isDesktopMode(context),
        ),
        mainEditorCallbacks: MainEditorCallbacks(
          onAfterViewInit: _onAfterViewInit,
          helperLines: HelperLinesCallbacks(onLineHit: vibrateLineHit),
        ),
      ),
      configs: ProImageEditorConfigs(
        designMode: platformDesignMode,
        mainEditor: MainEditorConfigs(
          enableCloseButton: !isDesktopMode(context),
          widgets: MainEditorWidgets(
            bodyItems: (editor, rebuildStream) => [
              ReactiveWidget(
                stream: rebuildStream,
                builder: (_) => editor.isSubEditorOpen
                    ? const SizedBox.shrink()
                    : _buildSafeAreaFrame(editor.sizesManager.bodySize),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Outlines [_safeArea], so it shows where the layers stop.
  Widget _buildSafeAreaFrame(Size editorBodySize) {
    if (editorBodySize.isEmpty || !editorBodySize.isFinite) {
      return const SizedBox.shrink();
    }
    return Positioned.fromRect(
      rect: _safeArea(editorBodySize),
      child: IgnorePointer(
        child: DecoratedBox(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.white54, width: 2),
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }
}
