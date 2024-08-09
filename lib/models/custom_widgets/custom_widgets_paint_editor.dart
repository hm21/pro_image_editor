// Flutter imports:
import 'package:flutter/widgets.dart';

// Project imports:
import 'package:pro_image_editor/pro_image_editor.dart';
import 'utils/custom_widgets_standalone_editor.dart';
import 'utils/custom_widgets_typedef.dart';

/// A custom widget for editing paint effects in an image editor.
///
/// This widget extends the standalone editor for the painting editor state,
/// providing a customizable interface for applying and adjusting painting
/// effects, such as line width, opacity, and color selection.
class CustomWidgetsPaintEditor
    extends CustomWidgetsStandaloneEditor<PaintingEditorState> {
  /// Creates a [CustomWidgetsPaintEditor] widget.
  ///
  /// This widget allows customization of the app bar, bottom bar, body items,
  /// and additional components specific to painting functionality, enabling a
  /// flexible design tailored to specific needs.
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

  /// Custom close button in the paint-editor to close the line-width bottom
  /// sheet.
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

  /// Custom close button in the paint-editor to close the change-opacity
  /// bottom sheet.
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
  /// ```dart
  /// sliderLineWidth:
  /// (editorState, rebuildStream, value, onChanged, onChangeEnd) {
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
  /// ```dart
  /// sliderChangeOpacity:
  /// (editorState, rebuildStream, value, onChanged, onChangeEnd) {
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
  final CustomSlider<PaintingEditorState>? sliderChangeOpacity;

  /// A custom color picker widget for the paint editor.
  ///
  /// - [editorState] - The current state of the editor.
  /// - [rebuildStream] - A [Stream] that triggers the widget to rebuild.
  /// - [currentColor] - The currently selected color.
  /// - [setColor] - A function to update the selected color.
  ///
  /// Returns an optional [ReactiveCustomWidget] that provides a custom color
  /// picker.
  ///
  /// **Example:**
  /// ``` dart
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
  /// ```
  final CustomColorPicker<PaintingEditorState>? colorPicker;
}
