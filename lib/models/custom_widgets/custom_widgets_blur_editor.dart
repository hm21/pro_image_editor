// Project imports:
import 'package:pro_image_editor/pro_image_editor.dart';
import 'utils/custom_widgets_standalone_editor.dart';
import 'utils/custom_widgets_typedef.dart';

/// A custom widget for editing blur effects in an image editor.
///
/// This widget extends the standalone editor for the blur editor state,
/// providing a customizable interface for applying and adjusting blur effects.
class CustomWidgetsBlurEditor
    extends CustomWidgetsStandaloneEditor<BlurEditorState> {
  /// Creates a [CustomWidgetsBlurEditor] widget.
  ///
  /// This widget allows customization of the app bar, bottom bar, body items,
  /// and slider for the blur editor, enabling a flexible design tailored to
  /// specific needs.
  ///
  /// Example:
  /// ```
  /// CustomWidgetsBlurEditor(
  ///   appBar: myAppBar,
  ///   bottomBar: myBottomBar,
  ///   bodyItems: myBodyItems,
  ///   slider: mySlider,
  /// )
  /// ```
  const CustomWidgetsBlurEditor({
    super.appBar,
    super.bottomBar,
    super.bodyItems,
    this.slider,
  });

  /// A custom slider widget for the blur editor.
  ///
  /// This widget allows users to adjust the blur factor using a slider in the
  /// blur editor.
  ///
  /// - [editorState] - The current state of the editor.
  /// - [rebuildStream] - A [Stream] that triggers the widget to rebuild.
  /// - [value] - The current value of the slider.
  /// - [onChanged] - A function to handle changes to the slider's value.
  /// - [onChangeEnd] - A function to handle the end of slider value changes.
  ///
  /// Returns a [ReactiveCustomWidget] that provides a custom slider.
  ///
  /// **Example:**
  /// ```dart
  /// slider: (editorState, rebuildStream, value, onChanged, onChangeEnd) {
  ///   return ReactiveCustomWidget(
  ///     stream: rebuildStream,
  ///     builder: (_) => Slider(
  ///       onChanged: onChanged,
  ///       onChangeEnd: onChangeEnd,
  ///       value: value,
  ///       activeColor: Colors.blue.shade200,
  ///     ),
  ///   );
  /// },
  /// ```
  final CustomSlider<BlurEditorState>? slider;
}
