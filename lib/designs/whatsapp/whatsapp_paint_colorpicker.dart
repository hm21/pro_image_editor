// Dart imports:
import 'dart:math';

// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:pro_image_editor/pro_image_editor.dart';

/// A stateless widget that provides a color picker for painting in the
/// WhatsApp theme.
///
/// This widget allows users to select colors for painting operations within
/// a painting editor, using a design inspired by WhatsApp.
class WhatsappPaintColorpicker extends StatelessWidget {
  /// Creates a [WhatsappPaintColorpicker] widget.
  ///
  /// This color picker lets users select colors for painting within a painting
  /// editor, integrating seamlessly with the WhatsApp theme.
  ///
  /// Example:
  /// ```
  /// WhatsappPaintColorpicker(
  ///   paintEditor: myPaintEditorState,
  /// )
  /// ```
  const WhatsappPaintColorpicker({
    super.key,
    required this.paintEditor,
  });

  /// The state of the painting editor associated with this color picker.
  ///
  /// This state allows the color picker to interact with the painting editor,
  /// providing necessary controls to manage painting color selections.
  final PaintingEditorState paintEditor;

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
