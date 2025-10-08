// Flutter imports:
import 'package:flutter/widgets.dart';

import '/features/paint_editor/paint_editor.dart';
import '/shared/widgets/reactive_widgets/reactive_custom_appbar.dart';
import '/shared/widgets/reactive_widgets/reactive_custom_widget.dart';
import '../layers/paint_layer.dart';
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
    this.editPreview,
    this.editColorSlider,
    this.editOpacitySlider,
    this.editStrokeWidthSlider,
    this.editFillSwitch,
    this.editActionButtons,
    this.editBottomSheet,
    this.editLayer,
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

  /// Builds a preview widget for the [PaintLayer] during editing.
  final Widget Function(PaintLayer layer)? editPreview;

  /// Builds a custom color slider widget for the [PaintLayer].
  /// The [setValue] callback should update the layer's color.
  final Widget Function(PaintLayer layer, Function(Color value) setValue)?
      editColorSlider;

  /// Builds a custom opacity slider widget for the [PaintLayer].
  /// The [setValue] callback should update the layer's opacity.
  final Widget Function(PaintLayer layer, Function(double value) setValue)?
      editOpacitySlider;

  /// Builds a custom stroke width slider widget for the [PaintLayer].
  /// The [setValue] callback should update the layer's stroke width.
  final Widget Function(PaintLayer layer, Function(double value) setValue)?
      editStrokeWidthSlider;

  /// Builds a custom switch widget to toggle the fill mode of the [PaintLayer].
  /// The [setValue] callback should update the fill state.
  final Widget Function(PaintLayer layer, Function(bool value) setValue)?
      editFillSwitch;

  /// Builds custom action buttons (e.g., apply/cancel) for editing the
  /// [PaintLayer].
  final Widget Function(PaintLayer layer)? editActionButtons;

  /// A callback function that returns a widget for editing a [PaintLayer].
  final Widget Function(PaintLayer layer)? editBottomSheet;

  /// A callback function that allows the user to edit a [PaintLayer].
  final Future<PaintLayer> Function(PaintLayer layer)? editLayer;

  @override
  PaintEditorWidgets copyWith({
    ReactiveAppbar? Function(
            PaintEditorState editorState, Stream<void> rebuildStream)?
        appBar,
    ReactiveWidget? Function(
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
    Widget Function(PaintLayer layer)? editPreview,
    Widget Function(PaintLayer layer, Function(Color value) setValue)?
        editColorSlider,
    Widget Function(PaintLayer layer, Function(double value) setValue)?
        editOpacitySlider,
    Widget Function(PaintLayer layer, Function(double value) setValue)?
        editStrokeWidthSlider,
    Widget Function(PaintLayer layer, Function(bool value) setValue)?
        editFillSwitch,
    Widget Function(PaintLayer layer)? editActionButtons,
    Widget Function(PaintLayer layer)? editBottomSheet,
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
      editPreview: editPreview ?? this.editPreview,
      editColorSlider: editColorSlider ?? this.editColorSlider,
      editOpacitySlider: editOpacitySlider ?? this.editOpacitySlider,
      editStrokeWidthSlider:
          editStrokeWidthSlider ?? this.editStrokeWidthSlider,
      editFillSwitch: editFillSwitch ?? this.editFillSwitch,
      editActionButtons: editActionButtons ?? this.editActionButtons,
      editBottomSheet: editBottomSheet ?? this.editBottomSheet,
    );
  }
}
