// Dart imports:
import 'dart:math';

// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:pro_image_editor/pro_image_editor.dart';

class WhatsappPaintColorpicker extends StatelessWidget {
  final PaintingEditorState paintEditor;

  const WhatsappPaintColorpicker({
    super.key,
    required this.paintEditor,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 60,
      right: 16,
      child: BarColorPicker(
        configs: paintEditor.configs,
        borderWidth:
            paintEditor.configs.designMode == ImageEditorDesignModeE.material
                ? 0
                : 2,
        showThumb:
            paintEditor.configs.designMode == ImageEditorDesignModeE.material,
        length: min(
          200,
          MediaQuery.of(context).size.height -
              MediaQuery.of(context).viewInsets.bottom -
              kToolbarHeight -
              kBottomNavigationBarHeight -
              MediaQuery.of(context).padding.top -
              30,
        ),
        horizontal: false,
        thumbColor: Colors.white,
        cornerRadius: 10,
        pickMode: PickMode.color,
        initialColor:
            paintEditor.configs.imageEditorTheme.paintingEditor.initialColor,
        colorListener: (int value) {
          paintEditor.colorChanged(Color(value));
        },
      ),
    );
  }
}
