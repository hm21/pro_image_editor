import 'dart:async';
import 'dart:math';

import 'package:material_ui/material_ui.dart';

import '/core/models/editor_configs/pro_image_editor_configs.dart';
import '/shared/widgets/color_picker/bar_color_picker.dart';
import '../text_editor.dart';

/// A widget for selecting and customizing text colors in the text editor,
/// allowing updates to primary and background colors.
class TextEditorColorPicker extends StatelessWidget {
  /// Creates a `TextEditorColorPicker` with the necessary configurations,
  /// state, and callbacks for handling color updates and position changes.
  ///
  /// - [state]: Represents the current state of the text editor.
  /// - [configs]: Configuration settings for the editor, including available
  ///   colors.
  /// - [rebuildController]: A stream controller for triggering UI updates.
  /// - [primaryColor]: The current primary color selected for the text.
  /// - [selectedTextStyle]: The text style currently applied to the text.
  /// - [onUpdateColor]: Callback triggered when the color is updated.
  const TextEditorColorPicker({
    super.key,
    required this.state,
    required this.configs,
    required this.rebuildController,
    required this.primaryColor,
    required this.selectedTextStyle,
    required this.onUpdateColor,
  });

  /// Represents the current state of the text editor.
  final TextEditorState state;

  /// Configuration settings for the editor, including available colors.
  final ProImageEditorConfigs configs;

  /// A stream controller for triggering UI updates.
  final StreamController<void> rebuildController;

  /// The current primary color selected for the text.
  final Color primaryColor;

  /// The text style currently applied to the text.
  final TextStyle selectedTextStyle;

  /// Callback triggered when the color is updated.
  final Function(Color color) onUpdateColor;

  @override
  Widget build(BuildContext context) {
    if (configs.textEditor.widgets.colorPicker != null) {
      return configs.textEditor.widgets.colorPicker!.call(
            state,
            rebuildController.stream,
            selectedTextStyle.color ?? primaryColor,
            onUpdateColor,
          ) ??
          const SizedBox.shrink();
    }

    return Align(
      alignment: Alignment.topRight,
      child: Container(
        margin: null,
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: BarColorPicker(
          configs: configs,
          length: min(
            350,
            MediaQuery.sizeOf(context).height -
                MediaQuery.viewInsetsOf(context).bottom -
                kToolbarHeight -
                kBottomNavigationBarHeight -
                10 * 2 -
                MediaQuery.paddingOf(context).top,
          ),
          color: primaryColor,
          horizontal: false,
          thumbColor: Colors.white,
          cornerRadius: 10,
          pickMode: PickMode.color,
          colorListener: (int value) => onUpdateColor(Color(value)),
        ),
      ),
    );
  }
}
