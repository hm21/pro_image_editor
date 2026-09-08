import 'dart:async';
import 'dart:math';

import 'package:material_ui/material_ui.dart';

import '/core/models/editor_configs/pro_image_editor_configs.dart';
import '/shared/widgets/color_picker/bar_color_picker.dart';
import '../paint_editor.dart';

/// A widget for selecting colors in the paint editor, allowing users to
/// customize their brush or fill colors.
class PaintEditorColorPicker extends StatelessWidget {
  /// Creates a `PaintEditorColorPicker` with the provided state,
  /// configurations, and a controller for triggering UI rebuilds.
  ///
  /// - [state]: Represents the current state of the paint editor.
  /// - [configs]: Configuration settings for the paint editor, including
  ///   available colors and styles.
  /// - [rebuildController]: A stream controller for triggering UI updates
  ///   when the color picker state changes.
  const PaintEditorColorPicker({
    super.key,
    required this.state,
    required this.configs,
    required this.rebuildController,
  });

  /// Represents the current state of the paint editor.
  final PaintEditorState state;

  /// Configuration settings for the paint editor, including available colors.
  final ProImageEditorConfigs configs;

  /// A stream controller for triggering UI updates when the color picker
  /// changes.
  final StreamController<void> rebuildController;

  @override
  Widget build(BuildContext context) {
    if (configs.paintEditor.widgets.colorPicker != null) {
      return configs.paintEditor.widgets.colorPicker!.call(
            state,
            rebuildController.stream,
            state.paintCtrl.color,
            state.setColor,
          ) ??
          const SizedBox.shrink();
    }

    return Positioned(
      top: 10,
      right: 0,
      child: StreamBuilder(
        stream: state.uiPickerStream.stream,
        builder: (context, snapshot) {
          return BarColorPicker(
            configs: configs,
            length: min(
              350,
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
            color: state.activeColor,
            colorListener: (int value) {
              state.setColor(Color(value));
            },
          );
        },
      ),
    );
  }
}
