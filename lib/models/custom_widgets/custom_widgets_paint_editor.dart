// Flutter imports:
import 'package:flutter/widgets.dart';

// Project imports:
import 'package:pro_image_editor/pro_image_editor.dart';
import 'utils/custom_widgets_standalone_editor.dart';
import 'utils/custom_widgets_typedef.dart';

class CustomWidgetsPaintEditor
    extends CustomWidgetsStandaloneEditor<PaintingEditorState> {
  /// Custom close button in the paint-editor to close the line-width bottom sheet.
  ///
  /// **Example:**
  /// ```dart
  /// lineWidthCloseButton: (editor, tap) {
  ///   return IconButton(
  ///     onPressed: tap,
  ///     icon: const Icon(Icons.close),
  ///   );
  /// },
  /// ```
  final Widget Function(
    PaintingEditorState editorState,
    Function() tap,
  )? lineWidthCloseButton;

  /// Custom close button in the paint-editor to close the change-opacity bottom sheet.
  ///
  /// **Example:**
  /// ```dart
  /// changeOpacityCloseButton: (editor, tap) {
  ///   return IconButton(
  ///     onPressed: tap,
  ///     icon: const Icon(Icons.close),
  ///   );
  /// },
  /// ```
  final Widget Function(
    PaintingEditorState editorState,
    Function() tap,
  )? changeOpacityCloseButton;

  /// A custom slider widget for the line width in the paint editor.
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
  /// sliderLineWidth: (editorState, rebuildStream, value, onChanged, onChangeEnd) {
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
  final CustomSlider<PaintingEditorState>? sliderLineWidth;

  /// A custom slider widget to change the line width in the paint editor.
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
  /// sliderChangeOpacity: (editorState, rebuildStream, value, onChanged, onChangeEnd) {
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
  final CustomSlider<PaintingEditorState>? sliderChangeOpacity;

  /// A custom color picker widget for the paint editor.
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
  final CustomColorPicker<PaintingEditorState>? colorPicker;

  const CustomWidgetsPaintEditor({
    super.appBar,
    super.bottomBar,
    super.bodyItems,
    this.lineWidthCloseButton,
    this.changeOpacityCloseButton,
    this.sliderLineWidth,
    this.sliderChangeOpacity,
    this.colorPicker,
  });
}
