// Flutter imports:
import 'package:flutter/material.dart';
import 'package:pro_image_editor/models/editor_configs/main_editor_configs.dart';

// Package imports:
import 'package:pro_image_editor/pro_image_editor.dart';

// Project imports:
import '../utils/example_constants.dart';
import '../utils/example_helper.dart';

/// A widget that demonstrates zoom and move functionality within an editor.
///
/// The [ZoomMoveEditorExample] widget is a stateful widget that provides an
/// example of how to implement zooming and moving features, likely within an
/// image editor or a similar application that requires user interaction for
/// manipulating content.
///
/// This widget holds the state, and the state class
/// [_ZoomMoveEditorExampleState]
/// will contain the logic to handle zoom and move gestures.
///
/// Example usage:
/// ```dart
/// ZoomMoveEditorExample();
/// ```
class ZoomMoveEditorExample extends StatefulWidget {
  /// Creates a new [ZoomMoveEditorExample] widget.
  const ZoomMoveEditorExample({super.key});

  @override
  State<ZoomMoveEditorExample> createState() => _ZoomMoveEditorExampleState();
}

class _ZoomMoveEditorExampleState extends State<ZoomMoveEditorExample>
    with ExampleHelperState<ZoomMoveEditorExample> {
  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () async {
        await precacheImage(
            AssetImage(ExampleConstants.of(context)!.demoAssetPath), context);
        if (!context.mounted) return;
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => _buildEditor(),
          ),
        );
      },
      leading: const Icon(Icons.zoom_in),
      title: const Text('Zoom in Paint and Main Editor'),
      trailing: const Icon(Icons.chevron_right),
    );
  }

  Widget _buildEditor() {
    return ProImageEditor.asset(
      ExampleConstants.of(context)!.demoAssetPath,
      key: editorKey,
      callbacks: ProImageEditorCallbacks(
        onImageEditingStarted: onImageEditingStarted,
        onImageEditingComplete: onImageEditingComplete,
        onCloseEditor: onCloseEditor,
      ),
      configs: ProImageEditorConfigs(
        designMode: platformDesignMode,
        mainEditorConfigs: const MainEditorConfigs(
          enableZoom: true,
        ),
        paintEditorConfigs: const PaintEditorConfigs(
          enableZoom: true,
        ),
        icons: const ImageEditorIcons(
          paintingEditor: IconsPaintingEditor(
            moveAndZoom: Icons.pinch_outlined,
          ),
        ),
        i18n: const I18n(
          paintEditor: I18nPaintingEditor(
            moveAndZoom: 'Zoom',
          ),
        ),
      ),
    );
  }
}
