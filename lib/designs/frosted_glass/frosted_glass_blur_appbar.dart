import 'package:flutter/material.dart';
import 'package:pro_image_editor/pro_image_editor.dart';

import 'frosted_glass_effect.dart';

class FrostedGlassBlurAppbar extends StatelessWidget {
  final BlurEditorState blurEditor;

  const FrostedGlassBlurAppbar({
    super.key,
    required this.blurEditor,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              FrostedGlassEffect(
                child: IconButton(
                  tooltip: blurEditor.configs.i18n.cancel,
                  onPressed: blurEditor.close,
                  icon: Icon(blurEditor.configs.icons.closeEditor),
                ),
              ),
              FrostedGlassEffect(
                child: IconButton(
                  tooltip: blurEditor.configs.i18n.done,
                  onPressed: blurEditor.done,
                  icon: Icon(
                    blurEditor.configs.icons.doneIcon,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
