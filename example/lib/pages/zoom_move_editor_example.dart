// Flutter imports:
import 'package:flutter/material.dart';
import 'package:pro_image_editor/models/editor_configs/main_editor_configs.dart';

// Package imports:
import 'package:pro_image_editor/pro_image_editor.dart';

// Project imports:
import '../utils/example_constants.dart';
import '../utils/example_helper.dart';

class ZoomMoveEditorExample extends StatefulWidget {
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
        Navigator.push(
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
