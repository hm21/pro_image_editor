// Flutter imports:
import 'package:flutter/widgets.dart';

// Project imports:
import 'package:pro_image_editor/pro_image_editor.dart';
import 'utils/custom_widgets_standalone_editor.dart';
import 'utils/custom_widgets_typedef.dart';

/// A list of custom widgets for the paint editor.
///
/// This widget extends the standalone editor for the paint editor state,
/// providing a customizable interface for applying and adjusting paint
/// effects, such as line width, opacity, and color selection.
class PaintEditorWidgets
    extends CustomWidgetsStandaloneEditor<PaintEditorState> {
  /// Creates a [PaintEditorWidgets] widget.
  ///
  /// This widget allows customization of the app bar, bottom bar, body items,
  /// and additional components specific to paint functionality, enabling a
  /// flexible design tailored to specific needs.
  const PaintEditorWidgets({
    super.appBar,
    super.bottomBar,
    super.bodyItems,
    super.bodyItemsRecorded,
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
    PaintEditorState editorState,
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
    PaintEditorState editorState,
    Function() tap,
  )? changeOpacityCloseButton;

  /// A custom slider widget for the line width in the paint editor.
  ///
  /// {@macro customSliderWidget}
  final CustomSlider<PaintEditorState>? sliderLineWidth;

  /// A custom slider widget to change the line width in the paint editor.
  ///
  /// {@macro customSliderWidget}
  final CustomSlider<PaintEditorState>? sliderChangeOpacity;

  /// A custom color picker widget for the paint editor.
  ///
  /// {@macro colorPickerWidget}
  final CustomColorPicker<PaintEditorState>? colorPicker;

  @override
  PaintEditorWidgets copyWith({
    ReactiveCustomAppbar? Function(
            PaintEditorState editorState, Stream<void> rebuildStream)?
        appBar,
    ReactiveCustomWidget? Function(
            PaintEditorState editorState, Stream<void> rebuildStream)?
        bottomBar,
    CustomBodyItems<PaintEditorState>? bodyItems,
    CustomBodyItems<PaintEditorState>? bodyItemsRecorded,
    Widget Function(PaintEditorState editorState, Function() tap)?
        lineWidthCloseButton,
    Widget Function(PaintEditorState editorState, Function() tap)?
        changeOpacityCloseButton,
    CustomSlider<PaintEditorState>? sliderLineWidth,
    CustomSlider<PaintEditorState>? sliderChangeOpacity,
    CustomColorPicker<PaintEditorState>? colorPicker,
  }) {
    return PaintEditorWidgets(
      appBar: appBar ?? this.appBar,
      bottomBar: bottomBar ?? this.bottomBar,
      bodyItems: bodyItems ?? this.bodyItems,
      bodyItemsRecorded: bodyItemsRecorded ?? this.bodyItemsRecorded,
      lineWidthCloseButton: lineWidthCloseButton ?? this.lineWidthCloseButton,
      changeOpacityCloseButton:
          changeOpacityCloseButton ?? this.changeOpacityCloseButton,
      sliderLineWidth: sliderLineWidth ?? this.sliderLineWidth,
      sliderChangeOpacity: sliderChangeOpacity ?? this.sliderChangeOpacity,
      colorPicker: colorPicker ?? this.colorPicker,
    );
  }
}
