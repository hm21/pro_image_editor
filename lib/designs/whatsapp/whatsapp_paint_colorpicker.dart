// Dart imports:
import 'dart:math';

// Flutter imports:
import 'package:material_ui/material_ui.dart';

import '/core/enums/design_mode.dart';
import '/features/paint_editor/paint_editor.dart';
import '/shared/widgets/color_picker/bar_color_picker.dart';

/// A stateless widget that provides a color picker for paint in the
/// WhatsApp theme.
///
/// This widget allows users to select colors for paint operations within
/// a paint editor, using a design inspired by WhatsApp.
class WhatsappPaintColorpicker extends StatelessWidget {
  /// Creates a [WhatsappPaintColorpicker] widget.
  ///
  /// This color picker lets users select colors for paint within a paint
  /// editor, integrating seamlessly with the WhatsApp theme.
  ///
  /// Example:
  /// ```
  /// WhatsappPaintColorpicker(
  ///   paintEditor: myPaintEditorState,
  /// )
  /// ```
  const WhatsappPaintColorpicker({super.key, required this.paintEditor});

  /// The state of the paint editor associated with this color picker.
  ///
  /// This state allows the color picker to interact with the paint editor,
  /// providing necessary controls to manage paint color selections.
  final PaintEditorState paintEditor;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 60,
      right: 16,
      child: BarColorPicker(
        configs: paintEditor.configs,
        borderWidth:
            paintEditor.configs.designMode == ImageEditorDesignMode.material
            ? 0
            : 2,
        showThumb:
            paintEditor.configs.designMode == ImageEditorDesignMode.material,
        length: min(
          200,
          MediaQuery.sizeOf(context).height -
              MediaQuery.viewInsetsOf(context).bottom -
              kToolbarHeight -
              kBottomNavigationBarHeight -
              MediaQuery.paddingOf(context).top -
              30,
        ),
        horizontal: false,
        thumbColor: Colors.white,
        cornerRadius: 10,
        pickMode: PickMode.color,
        color: paintEditor.configs.paintEditor.style.initialColor,
        colorListener: (int value) {
          paintEditor.setColor(Color(value));
        },
      ),
    );
  }
}
