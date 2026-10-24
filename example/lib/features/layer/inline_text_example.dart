// Flutter imports:
import 'package:material_ui/material_ui.dart';

// Package imports:
import 'package:pro_image_editor/pro_image_editor.dart';

// Project imports:
import '/core/constants/example_constants.dart';
import '/core/mixin/example_helper.dart';

/// A widget that demonstrates typing into text layers on the canvas.
///
/// The editor opens with a text layer already on the image. Editing it, or
/// adding a new text from the bottom bar, turns the layer into a text field
/// where it sits instead of opening the full-screen text editor. A format
/// bar above the image changes the alignment, the background, the box, the
/// text size and the color while typing. Clicking outside the layer or
/// Ctrl/Cmd+Enter saves the text, and Escape drops the edit.
///
/// Example usage:
/// ```dart
/// InlineTextExample();
/// ```
class InlineTextExample extends StatefulWidget {
  /// Creates a new [InlineTextExample] widget.
  const InlineTextExample({super.key});

  @override
  State<InlineTextExample> createState() => _InlineTextExampleState();
}

/// The state for the [InlineTextExample] widget.
class _InlineTextExampleState extends State<InlineTextExample>
    with ExampleHelperState<InlineTextExample> {
  static const _colors = [
    Color(0xFFFFFFFF),
    Color(0xFF000000),
    Color(0xFFF44336),
    Color(0xFFFFC107),
    Color(0xFF2196F3),
  ];

  @override
  void initState() {
    super.initState();
    preCacheImage(assetPath: kImageEditorExampleAssetPath);
  }

  void _onAfterViewInit() {
    editorKey.currentState!.addLayer(
      TextLayer(text: 'Edit this text where it is'),
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
                builder: (_) => _buildFormatBar(editor),
              ),
            ],
          ),
        ),
        layerInteraction: const LayerInteractionConfigs(
          /// Shows the selection, and with it the edit button, on mobile too.
          selectable: LayerInteractionSelectable.enabled,

          /// Shows handles on the edges of a text layer with a box.
          enableTextBoxResize: true,
        ),
        textEditor: const TextEditorConfigs(
          /// Types into the layer instead of opening the text editor.
          enableInlineEditing: true,

          /// A box made with the box button keeps the text size and shows
          /// lines that do not fit below it.
          boxOverflow: TextLayerBoxOverflow.visible,

          /// Ctrl/Cmd+Enter saves the text.
          enableSubmitShortcut: true,
        ),
      ),
    );
  }

  /// The controls for the text being typed, shown while a text layer is
  /// edited on the canvas.
  ///
  /// [InlineTextEditChrome] keeps a click on the bar from saving and closing
  /// the edit, and keeps the keyboard focus in the text.
  Widget _buildFormatBar(ProImageEditorState editor) {
    final session = editor.inlineTextEdit;
    if (session == null) return const SizedBox.shrink();

    return Positioned(
      top: 12,
      left: 0,
      right: 0,
      child: Center(
        child: InlineTextEditChrome(
          session: session,
          child: GestureInterceptor(
            child: Material(
              color: Colors.black87,
              borderRadius: BorderRadius.circular(28),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    IconButton(
                      tooltip: 'Alignment',
                      color: Colors.white,
                      onPressed: session.toggleTextAlign,
                      icon: Icon(switch (session.align) {
                        TextAlign.center => Icons.format_align_center,
                        TextAlign.right => Icons.format_align_right,
                        _ => Icons.format_align_left,
                      }),
                    ),
                    IconButton(
                      tooltip: 'Background',
                      color: Colors.white,
                      onPressed: session.toggleBackgroundMode,
                      icon: const Icon(Icons.format_color_fill),
                    ),
                    IconButton(
                      tooltip: 'Text box',
                      color: session.boxEnabled ? Colors.amber : Colors.white,
                      onPressed: () =>
                          session.setBoxEnabled(!session.boxEnabled),
                      icon: const Icon(Icons.crop_free),
                    ),
                    IconButton(
                      tooltip: 'Smaller text',
                      color: Colors.white,
                      onPressed: () =>
                          session.setFontScale(session.fontScale - 0.1),
                      icon: const Icon(Icons.text_decrease),
                    ),
                    IconButton(
                      tooltip: 'Larger text',
                      color: Colors.white,
                      onPressed: () =>
                          session.setFontScale(session.fontScale + 0.1),
                      icon: const Icon(Icons.text_increase),
                    ),
                    for (final color in _colors)
                      _buildColorButton(session, color),
                    IconButton(
                      tooltip: 'Cancel',
                      color: Colors.white,
                      onPressed: session.cancel,
                      icon: const Icon(Icons.close),
                    ),
                    IconButton(
                      tooltip: 'Done',
                      color: Colors.white,
                      onPressed: session.done,
                      icon: const Icon(Icons.check),
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

  Widget _buildColorButton(InlineTextEditSession session, Color color) {
    final selected = session.primaryColor == color;
    return InkResponse(
      onTap: () => session.setPrimaryColor(color),
      radius: 18,
      child: Padding(
        padding: const EdgeInsets.all(6),
        child: Container(
          width: 22,
          height: 22,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: Border.all(
              color: selected ? Colors.amber : Colors.white54,
              width: selected ? 3 : 1.5,
            ),
          ),
        ),
      ),
    );
  }
}
