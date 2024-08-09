// Flutter imports:
import 'package:flutter/widgets.dart';

// Project imports:
import '../../pro_image_editor.dart';
import 'utils/custom_widgets_standalone_editor.dart';
import 'utils/custom_widgets_typedef.dart';

/// A custom widget for editing filter effects in an image editor.
///
/// This widget extends the standalone editor for the filter editor state,
/// providing a customizable interface for applying and adjusting image filters.

class CustomWidgetsFilterEditor
    extends CustomWidgetsStandaloneEditor<FilterEditorState> {
  /// Creates a [CustomWidgetsFilterEditor] widget.
  ///
  /// This widget allows customization of the app bar, bottom bar, body items,
  /// and additional widgets specific to filter functionality, enabling a
  /// flexible design tailored to specific needs.
  const CustomWidgetsFilterEditor({
    super.appBar,
    super.bottomBar,
    super.bodyItems,
    this.slider,
    this.filterButton,
  });

  /// A custom slider widget for the filter editor.
  ///
  /// This widget allows users to adjust values using a slider in the filter
  /// editor.
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
  final CustomSlider<FilterEditorState>? slider;

  /// Creating a widget that represents a filter button in an editor.
  ///
  /// [filter] - The [FilterModel] representing the filter applied by the
  /// button.
  /// [isSelected] - A boolean indicating whether the filter is currently
  /// selected.
  /// [scaleFactor] - An optional double representing the scale factor for the
  /// button.
  /// [onSelectFilter] - A callback function to handle the filter selection.
  /// [editorImage] - A widget representing the image being edited.
  /// [filterKey] - A [Key] to uniquely identify the filter button.
  ///
  /// Returns a [Widget] representing the filter button in the editor.
  final Widget Function(
    FilterModel filter,
    bool isSelected,
    double? scaleFactor,
    Function() onSelectFilter,
    Widget editorImage,
    Key filterKey,
  )? filterButton;
}
