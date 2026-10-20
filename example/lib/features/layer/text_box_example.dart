// Flutter imports:
import 'package:material_ui/material_ui.dart';

// Package imports:
import 'package:pro_image_editor/pro_image_editor.dart';

// Project imports:
import '/core/constants/example_constants.dart';
import '/core/mixin/example_helper.dart';

/// A widget that demonstrates text layers in a fixed, resizable box.
///
/// The editor opens with a boxed text layer already on the image. Drag the
/// handles on its edges to resize the box: the text wraps and shrinks to fit,
/// but its size does not change. The text editor gets a "Text box" chip
/// that puts new or edited text into a box, or takes it out of one.
///
/// Example usage:
/// ```dart
/// TextBoxExample();
/// ```
class TextBoxExample extends StatefulWidget {
  /// Creates a new [TextBoxExample] widget.
  const TextBoxExample({super.key});

  @override
  State<TextBoxExample> createState() => _TextBoxExampleState();
}

/// The state for the [TextBoxExample] widget.
class _TextBoxExampleState extends State<TextBoxExample>
    with ExampleHelperState<TextBoxExample> {
  @override
  void initState() {
    super.initState();
    preCacheImage(assetPath: kImageEditorExampleAssetPath);
  }

  void _onAfterViewInit() {
    editorKey.currentState!.addLayer(
      TextLayer(
        text: 'Drag the handles on the edges to resize this box. '
            'The text wraps and shrinks to fit.',
        box: const TextLayerBox(
          size: Size(260, 120),
          verticalAlign: TextLayerBoxVerticalAlign.center,
          overflow: TextLayerBoxOverflow.shrink,
        ),
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
        ),
        layerInteraction: const LayerInteractionConfigs(
          /// Shows the selection, and with it the box handles, on mobile too.
          selectable: LayerInteractionSelectable.enabled,

          /// Shows handles on the edges of a text layer with a box.
          enableTextBoxResize: true,
        ),
        textEditor: TextEditorConfigs(
          widgets: TextEditorWidgets(
            bodyItemsOverlay: (textEditor, rebuildStream) => [
              ReactiveWidget(
                stream: rebuildStream,
                builder: (_) => _buildBoxToggle(textEditor),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// A chip that puts the text into a box, or takes it out of one.
  ///
  /// Turning it on fits the box around the text as it is, so the layer
  /// looks the same until its box is resized.
  Widget _buildBoxToggle(TextEditorState textEditor) {
    return Positioned(
      top: 12,
      left: 12,
      child: FilterChip(
        avatar: const Icon(Icons.crop_free),
        label: const Text('Text box'),
        selected: textEditor.boxEnabled,
        showCheckmark: false,
        onSelected: textEditor.setBoxEnabled,
      ),
    );
  }
}
