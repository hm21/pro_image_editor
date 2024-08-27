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
  /// {@macro customSliderWidget}
  final CustomSlider<BlurEditorState>? slider;

  @override
  CustomWidgetsBlurEditor copyWith({
    ReactiveCustomAppbar? Function(
            BlurEditorState editorState, Stream<void> rebuildStream)?
        appBar,
    ReactiveCustomWidget? Function(
            BlurEditorState editorState, Stream<void> rebuildStream)?
        bottomBar,
    List<ReactiveCustomWidget> Function(
            BlurEditorState editorState, Stream<void> rebuildStream)?
        bodyItems,
    CustomSlider<BlurEditorState>? slider,
  }) {
    return CustomWidgetsBlurEditor(
      appBar: appBar ?? this.appBar,
      bottomBar: bottomBar ?? this.bottomBar,
      bodyItems: bodyItems ?? this.bodyItems,
      slider: slider ?? this.slider,
    );
  }
}
