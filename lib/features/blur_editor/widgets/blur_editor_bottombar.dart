import 'dart:async';

import 'package:material_ui/material_ui.dart';
import '/core/models/editor_configs/blur_editor_configs.dart';

import '../blur_editor.dart';

/// A widget that represents the bottom bar of the blur editor.
///
/// This widget provides controls for adjusting the blur effect in the editor.
///
/// The [BlurEditorBottombar] requires the following parameters:
///
/// * [blurEditorConfigs]: Configuration settings for the blur editor.
/// * [blurFactor]: The current factor by which the blur effect is applied.
/// * [rebuildController]: A controller to manage rebuilding of the widget.
/// * [blurEditorState]: The current state of the blur editor.
/// * [onChanged]: A callback function that is called when the blur factor
/// changes.
/// * [onChangedEnd]: A callback function that is called when the blur factor
/// change ends.
class BlurEditorBottombar extends StatelessWidget {
  /// Creates an instance of `BlurEditorBottombar`, a custom `BottomBar` for
  /// the Blur-Editor UI.
  const BlurEditorBottombar({
    super.key,
    required this.blurEditorConfigs,
    required this.blurFactor,
    required this.rebuildController,
    required this.blurEditorState,
    required this.onChanged,
    required this.onChangedEnd,
  });

  /// Represents the state of the blur editor.
  final BlurEditorState blurEditorState;

  /// Configuration settings for the blur editor.
  final BlurEditorConfigs blurEditorConfigs;

  /// Stream controller to handle rebuild events.
  final StreamController<void> rebuildController;

  /// The factor by which the blur effect is applied.
  final ValueNotifier<double> blurFactor;

  /// Callback function that is called when the blur value changes.
  ///
  /// [value] The new blur value.
  final Function(double value) onChanged;

  /// Callback function that is called when the blur value change ends.
  ///
  /// [value] The final blur value.
  final Function(double value) onChangedEnd;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        color: blurEditorConfigs.style.background,
        height: 100,
        child: Align(
          alignment: Alignment.center,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: RepaintBoundary(
              child: ValueListenableBuilder(
                valueListenable: blurFactor,
                builder: (_, value, _) {
                  return blurEditorConfigs.widgets.slider?.call(
                        blurEditorState,
                        rebuildController.stream,
                        value,
                        onChanged,
                        onChangedEnd,
                      ) ??
                      Slider(
                        min: 0,
                        max: blurEditorConfigs.maxBlur,
                        divisions: 100,
                        value: value,
                        onChanged: onChanged,
                        onChangeEnd: onChangedEnd,
                      );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
