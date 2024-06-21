// Flutter imports:
import 'package:flutter/widgets.dart';

// Project imports:
import 'package:pro_image_editor/modules/text_editor/text_editor.dart';
import 'utils/custom_widgets_standalone_editor.dart';
import 'utils/custom_widgets_typedef.dart';

class CustomWidgetsTextEditor
    extends CustomWidgetsStandaloneEditor<TextEditorState> {
  /// A custom color picker widget for the text editor.
  ///
  /// - [editorState] - The current state of the editor.
  /// - [rebuildStream] - A [Stream] that triggers the widget to rebuild.
  /// - [currentColor] - The currently selected color.
  /// - [setColor] - A function to update the selected color.
  ///
  /// Returns an optional [ReactiveCustomWidget] that provides a custom color picker.
  ///
  /// **Example:**
  /// colorPicker: (editor, rebuildStream, currentColor, setColor) =>
  ///    ReactiveCustomWidget(
  ///      stream: rebuildStream,
  ///      builder: (_) => BarColorPicker(
  ///        configs: editor.configs,
  ///        length: 200,
  ///        horizontal: false,
  ///        initialColor: currentColor,
  ///        colorListener: (int value) {
  ///          setColor(Color(value));
  ///        },
  ///      ),
  /// ),
  final CustomColorPicker<TextEditorState>? colorPicker;

  /// Custom close button to close the font-size bottom sheet.
  ///
  /// **Example:**
  /// ```dart
  /// fontSizeCloseButton: (editor, tap) {
  ///   return IconButton(
  ///     onPressed: tap,
  ///     icon: const Icon(Icons.close),
  ///   );
  /// },
  /// ```
  final Widget Function(
    TextEditorState editorState,
    Function() tap,
  )? fontSizeCloseButton;

  /// A custom slider widget for the font-size.
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
  /// sliderFontSize: (editorState, rebuildStream, value, onChanged, onChangeEnd) {
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
  final CustomSlider<TextEditorState>? sliderFontSize;

  const CustomWidgetsTextEditor({
    super.appBar,
    super.bottomBar,
    super.bodyItems,
    this.colorPicker,
    this.sliderFontSize,
    this.fontSizeCloseButton,
  });
}
