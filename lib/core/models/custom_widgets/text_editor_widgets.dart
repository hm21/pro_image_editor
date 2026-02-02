// Flutter imports:
import 'package:flutter/widgets.dart';

// Project imports:
import '/features/text_editor/text_editor.dart';
import '/shared/widgets/reactive_widgets/reactive_custom_appbar.dart';
import '/shared/widgets/reactive_widgets/reactive_custom_widget.dart';
import 'utils/custom_widgets_standalone_editor.dart';
import 'utils/custom_widgets_typedef.dart';

/// A custom widget for editing text in an image editor.
///
/// This widget extends the standalone editor for the text editor state,
/// providing a customizable interface for applying and adjusting text
/// properties such as color and font size.
class TextEditorWidgets extends CustomWidgetsStandaloneEditor<TextEditorState> {
  /// Creates a [TextEditorWidgets] widget.
  ///
  /// This widget allows customization of the app bar, bottom bar, body items,
  /// and additional components specific to text editing functionality,
  /// enabling a flexible design tailored to specific needs.
  ///
  /// Example:
  /// ```
  /// TextEditorWidgets(
  ///   appBar: myAppBar,
  ///   bottomBar: myBottomBar,
  ///   bodyItems: myBodyItems,
  ///   colorPicker: myColorPicker,
  ///   sliderFontSize: mySliderFontSize,
  ///   fontSizeCloseButton: myFontSizeCloseButton,
  /// )
  /// ```
  const TextEditorWidgets({
    super.appBar,
    super.bottomBar,
    super.bodyItems,
    this.bodyItemsOverlay,
    this.colorPicker,
    this.sliderFontSize,
    this.fontSizeCloseButton,
  });

  /// Custom body items that are positioned above all other content.
  ///
  /// These widgets are rendered on top of the text field, color picker,
  /// and bottom bar, making them ideal for overlays, tooltips, or custom
  /// controls that need to be always visible.
  ///
  /// **Example:**
  /// ```dart
  /// bodyItemsOverlay: (editor, rebuildStream) => [
  ///   ReactiveWidget(
  ///     stream: rebuildStream,
  ///     builder: (_) => Positioned(
  ///       top: 100,
  ///       right: 16,
  ///       child: MyCustomOverlayWidget(),
  ///     ),
  ///   ),
  /// ],
  /// ```
  final CustomBodyItems<TextEditorState>? bodyItemsOverlay;

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
  TextEditorWidgets copyWith({
    ReactiveAppbar? Function(
            TextEditorState editorState, Stream<void> rebuildStream)?
        appBar,
    ReactiveWidget? Function(
            TextEditorState editorState, Stream<void> rebuildStream)?
        bottomBar,
    CustomBodyItems<TextEditorState>? bodyItems,
    CustomBodyItems<TextEditorState>? bodyItemsOverlay,
    CustomColorPicker<TextEditorState>? colorPicker,
    CustomSlider<TextEditorState>? sliderFontSize,
    Widget Function(TextEditorState editorState, Function() tap)?
        fontSizeCloseButton,
  }) {
    return TextEditorWidgets(
      appBar: appBar ?? this.appBar,
      bottomBar: bottomBar ?? this.bottomBar,
      bodyItems: bodyItems ?? this.bodyItems,
      bodyItemsOverlay: bodyItemsOverlay ?? this.bodyItemsOverlay,
      colorPicker: colorPicker ?? this.colorPicker,
      sliderFontSize: sliderFontSize ?? this.sliderFontSize,
      fontSizeCloseButton: fontSizeCloseButton ?? this.fontSizeCloseButton,
    );
  }
}
