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
  /// {@macro customSliderWidget}
  final CustomSlider<PaintingEditorState>? sliderLineWidth;

  /// A custom slider widget to change the line width in the paint editor.
  ///
  /// {@macro customSliderWidget}
  final CustomSlider<PaintingEditorState>? sliderChangeOpacity;

  /// A custom color picker widget for the paint editor.
  ///
  /// {@macro colorPickerWidget}
  final CustomColorPicker<PaintingEditorState>? colorPicker;

  @override
  CustomWidgetsPaintEditor copyWith({
    ReactiveCustomAppbar? Function(
            PaintingEditorState editorState, Stream<void> rebuildStream)?
        appBar,
    ReactiveCustomWidget? Function(
            PaintingEditorState editorState, Stream<void> rebuildStream)?
        bottomBar,
    List<ReactiveCustomWidget> Function(
            PaintingEditorState editorState, Stream<void> rebuildStream)?
        bodyItems,
    Widget Function(PaintingEditorState editorState, Function() tap)?
        lineWidthCloseButton,
    Widget Function(PaintingEditorState editorState, Function() tap)?
        changeOpacityCloseButton,
    CustomSlider<PaintingEditorState>? sliderLineWidth,
    CustomSlider<PaintingEditorState>? sliderChangeOpacity,
    CustomColorPicker<PaintingEditorState>? colorPicker,
  }) {
    return CustomWidgetsPaintEditor(
      appBar: appBar ?? this.appBar,
      bottomBar: bottomBar ?? this.bottomBar,
      bodyItems: bodyItems ?? this.bodyItems,
      lineWidthCloseButton: lineWidthCloseButton ?? this.lineWidthCloseButton,
      changeOpacityCloseButton:
          changeOpacityCloseButton ?? this.changeOpacityCloseButton,
      sliderLineWidth: sliderLineWidth ?? this.sliderLineWidth,
      sliderChangeOpacity: sliderChangeOpacity ?? this.sliderChangeOpacity,
      colorPicker: colorPicker ?? this.colorPicker,
    );
  }
}
