// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:pro_image_editor/pro_image_editor.dart';

// Project imports:
import '../utils/example_constants.dart';
import '../utils/example_helper.dart';

class RoundCropperExample extends StatefulWidget {
  const RoundCropperExample({super.key});

  @override
  State<RoundCropperExample> createState() => _RoundCropperExampleState();
}

class _RoundCropperExampleState extends State<RoundCropperExample>
    with ExampleHelperState<RoundCropperExample> {
  final _cropRotateEditorKey = GlobalKey<CropRotateEditorState>();

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () async {
        await precacheImage(
            AssetImage(ExampleConstants.of(context)!.demoAssetPath), context);
        if (!context.mounted) return;

        bool initialized = false;

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                LayoutBuilder(builder: (context, constraints) {
              if (!initialized) {
                initialized = true;
                Future.delayed(const Duration(milliseconds: 1), () {
                  _cropRotateEditorKey.currentState!.enableFakeHero = true;
                  setState(() {});
                });
              }
              return _buildEditor();
            }),
          ),
        );
      },
      leading: const Icon(Icons.supervised_user_circle_outlined),
      title: const Text('Round Cropper'),
      trailing: const Icon(Icons.chevron_right),
    );
  }

  Widget _buildEditor() {
    return CropRotateEditor.asset(
      ExampleConstants.of(context)!.demoAssetPath,
      key: _cropRotateEditorKey,
      initConfigs: CropRotateEditorInitConfigs(
        theme: ThemeData.dark(),
        convertToUint8List: true,
        onImageEditingStarted: onImageEditingStarted,
        onImageEditingComplete: onImageEditingComplete,
        onCloseEditor: onCloseEditor,
        configs: ProImageEditorConfigs(
          designMode: platformDesignMode,
          imageGenerationConfigs: const ImageGenerationConfigs(
            outputFormat: OutputFormat.png,
            pngFilter: PngFilter.average,
          ),
          cropRotateEditorConfigs: const CropRotateEditorConfigs(
            roundCropper: true,
            canChangeAspectRatio: false,
            initAspectRatio: 1,
          ),
        ),
      ),
    );
  }
}
