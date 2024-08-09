// Dart imports:
import 'dart:math';

// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:pro_image_editor/pro_image_editor.dart';

/// A stateless widget that provides a color picker for text in the WhatsApp
/// theme.
///
/// This widget allows users to select colors for text within a text editor,
/// using a design inspired by WhatsApp.
class WhatsappTextColorpicker extends StatelessWidget {
  /// Creates a [WhatsappTextColorpicker] widget.
  ///
  /// This color picker lets users select colors for text, integrating
  /// seamlessly with the WhatsApp-themed text editor.
  ///
  /// Example:
  /// ```
  /// WhatsappTextColorpicker(
  ///   textEditor: myTextEditorState,
  /// )
  /// ```
  const WhatsappTextColorpicker({super.key, required this.textEditor});

  /// The state of the text editor associated with this color picker.
  ///
  /// This state allows the color picker to interact with the text editor,
  /// providing necessary controls to manage text color selections.
  final TextEditorState textEditor;

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
