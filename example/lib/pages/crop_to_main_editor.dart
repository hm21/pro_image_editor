// Flutter imports:
import 'package:example/utils/example_constants.dart';
import 'package:flutter/material.dart';

// Package imports:
import 'package:pro_image_editor/models/crop_rotate_editor/transform_factors.dart';
import 'package:pro_image_editor/models/editor_configs/main_editor_configs.dart';
import 'package:pro_image_editor/pro_image_editor.dart';

// Project imports:
import '../utils/example_helper.dart';

class CropToMainEditorExample extends StatefulWidget {
  const CropToMainEditorExample({super.key});

  @override
  State<CropToMainEditorExample> createState() =>
      _CropToMainEditorExampleState();
}

class _CropToMainEditorExampleState extends State<CropToMainEditorExample>
    with ExampleHelperState<CropToMainEditorExample> {
  final ProImageEditorConfigs _editorConfigs = ProImageEditorConfigs(
    designMode: platformDesignMode,
    cropRotateEditorConfigs: const CropRotateEditorConfigs(
      initAspectRatio: 1,
      provideImageInfos: true,
      canChangeAspectRatio: false,
    ),
  );

  void _openCropEditor() {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (_, animation, secondaryAnimation) =>
            CropRotateEditor.asset(
          ExampleConstants.of(context)!.demoAssetPath,
          initConfigs: CropRotateEditorInitConfigs(
            theme: ThemeData.dark(),
            configs: _editorConfigs,
            onDone: (transformations, fitToScreenFactor, imageInfos) {
              /// Skip one frame before opening the main editor, as the crop
              /// editor will call Navigator.pop(context).
              WidgetsBinding.instance.addPostFrameCallback((_) {
                _openMainEditor(transformations, imageInfos!);
              });
            },
          ),
        ),
      ),
    );
  }

  void _openMainEditor(
    TransformConfigs transformations,
    ImageInfos imageInfos,
  ) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (_, animation, secondaryAnimation) => ProImageEditor.asset(
          ExampleConstants.of(context)!.demoAssetPath,
          key: editorKey,
          callbacks: ProImageEditorCallbacks(
            onImageEditingStarted: onImageEditingStarted,
            onCloseEditor: onCloseEditor,
            onImageEditingComplete: onImageEditingComplete,
          ),
          configs: _editorConfigs.copyWith(
            mainEditorConfigs: MainEditorConfigs(
              transformSetup: MainEditorTransformSetup(
                transformConfigs: transformations,
                imageInfos: imageInfos,
              ),
            ),
            cropRotateEditorConfigs: const CropRotateEditorConfigs(
              enabled: false,
            ),
          ),
        ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          if (animation.status != AnimationStatus.forward) {
            return FadeTransition(
              opacity: animation,
              child: child,
            );
          }

          return child;
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () async {
        await precacheImage(
            AssetImage(ExampleConstants.of(context)!.demoAssetPath), context);
        if (!context.mounted) return;
        _openCropEditor();
      },
      leading: const Icon(Icons.crop),
      title: const Text('Start with Crop-Editor'),
      trailing: const Icon(Icons.chevron_right),
    );
  }
}
