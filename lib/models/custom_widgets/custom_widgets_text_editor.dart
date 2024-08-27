// Flutter imports:
import 'package:flutter/widgets.dart';

// Project imports:
import 'package:pro_image_editor/modules/text_editor/text_editor.dart';
import 'package:pro_image_editor/widgets/custom_widgets/reactive_custom_appbar.dart';
import 'package:pro_image_editor/widgets/custom_widgets/reactive_custom_widget.dart';
import 'utils/custom_widgets_standalone_editor.dart';
import 'utils/custom_widgets_typedef.dart';

/// A custom widget for editing text in an image editor.
///
/// This widget extends the standalone editor for the text editor state,
/// providing a customizable interface for applying and adjusting text
/// properties such as color and font size.
class CustomWidgetsTextEditor
    extends CustomWidgetsStandaloneEditor<TextEditorState> {
  /// Creates a [CustomWidgetsTextEditor] widget.
  ///
  /// This widget allows customization of the app bar, bottom bar, body items,
  /// and additional components specific to text editing functionality,
  /// enabling a flexible design tailored to specific needs.
  ///
  /// Example:
  /// ```
  /// CustomWidgetsTextEditor(
  ///   appBar: myAppBar,
  ///   bottomBar: myBottomBar,
  ///   bodyItems: myBodyItems,
  ///   colorPicker: myColorPicker,
  ///   sliderFontSize: mySliderFontSize,
  ///   fontSizeCloseButton: myFontSizeCloseButton,
  /// )
  /// ```
  const CustomWidgetsTextEditor({
    super.appBar,
    super.bottomBar,
    super.bodyItems,
    this.colorPicker,
    this.sliderFontSize,
    this.fontSizeCloseButton,
  });

  /// A custom color picker widget for the text editor.
  ///
  /// {@macro colorPickerWidget}
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
  /// {@macro customSliderWidget}
  final CustomSlider<TextEditorState>? sliderFontSize;

  @override
  CustomWidgetsTextEditor copyWith({
    ReactiveCustomAppbar? Function(
            TextEditorState editorState, Stream<void> rebuildStream)?
        appBar,
    ReactiveCustomWidget? Function(
            TextEditorState editorState, Stream<void> rebuildStream)?
        bottomBar,
    List<ReactiveCustomWidget> Function(
            TextEditorState editorState, Stream<void> rebuildStream)?
        bodyItems,
    CustomColorPicker<TextEditorState>? colorPicker,
    CustomSlider<TextEditorState>? sliderFontSize,
    Widget Function(TextEditorState editorState, Function() tap)?
        fontSizeCloseButton,
  }) {
    return CustomWidgetsTextEditor(
      appBar: appBar ?? this.appBar,
      bottomBar: bottomBar ?? this.bottomBar,
      bodyItems: bodyItems ?? this.bodyItems,
      colorPicker: colorPicker ?? this.colorPicker,
      sliderFontSize: sliderFontSize ?? this.sliderFontSize,
      fontSizeCloseButton: fontSizeCloseButton ?? this.fontSizeCloseButton,
    );
  }
}
