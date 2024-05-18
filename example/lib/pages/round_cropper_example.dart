// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:pro_image_editor/models/init_configs/crop_rotate_editor_init_configs.dart';
import 'package:pro_image_editor/modules/crop_rotate_editor/crop_rotate_editor.dart';
import 'package:pro_image_editor/pro_image_editor.dart';

// Project imports:
import '../utils/example_constants.dart';
import 'preview_img.dart';

class RoundCropperExample extends StatefulWidget {
  const RoundCropperExample({super.key});

  @override
  State<RoundCropperExample> createState() => _RoundCropperExampleState();
}

class _RoundCropperExampleState extends State<RoundCropperExample> {
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
            builder: (context) =>
                LayoutBuilder(builder: (context, constraints) {
              return _buildEditor();
            }),
          ),
        ).then((bytes) {
          if (bytes != null) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) {
                  return PreviewImgPage(imgBytes: bytes);
                },
              ),
            );
          }
        });
      },
      leading: const Icon(Icons.supervised_user_circle_outlined),
      title: const Text('Round Cropper'),
      trailing: const Icon(Icons.chevron_right),
    );
  }

  Widget _buildEditor() {
    return CropRotateEditor.asset(
      ExampleConstants.of(context)!.demoAssetPath,
      initConfigs: CropRotateEditorInitConfigs(
        theme: ThemeData.dark(),
        convertToUint8List: true,
        configs: const ProImageEditorConfigs(
          cropRotateEditorConfigs: CropRotateEditorConfigs(
            roundCropper: true,
            canChangeAspectRatio: false,
            initAspectRatio: 1,
          ),
        ),
      ),
    );
  }
}
