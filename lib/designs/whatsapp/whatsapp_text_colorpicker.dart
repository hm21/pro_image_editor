// Dart imports:
import 'dart:math';

// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:pro_image_editor/pro_image_editor.dart';

class WhatsappTextColorpicker extends StatelessWidget {
  final TextEditorState textEditor;

  const WhatsappTextColorpicker({super.key, required this.textEditor});

  @override
  Widget build(BuildContext context) {
    const double barPickerPadding = 60;

    return Align(
      alignment: Alignment.topRight,
      child: Container(
        margin: const EdgeInsets.only(
          right: 16,
          top: 0,
        ),
        padding: const EdgeInsets.only(
          top: barPickerPadding,
        ),
        child: BarColorPicker(
          configs: textEditor.configs,
          borderWidth:
              textEditor.configs.designMode == ImageEditorDesignModeE.material
                  ? 0
                  : 2,
          showThumb:
              textEditor.configs.designMode == ImageEditorDesignModeE.material,
          length: min(
            200,
            MediaQuery.of(context).size.height -
                MediaQuery.of(context).viewInsets.bottom -
                kToolbarHeight -
                20 -
                barPickerPadding -
                MediaQuery.of(context).padding.top,
          ),
          onPositionChange: (value) {
            textEditor.colorPosition = value;
          },
          initPosition: textEditor.colorPosition,
          initialColor: textEditor.primaryColor,
          horizontal: false,
          thumbColor: Colors.white,
          cornerRadius: 10,
          pickMode: PickMode.color,
          colorListener: (int value) {
            textEditor.primaryColor = Color(value);
          },
        ),
      ),
    );
  }
}
