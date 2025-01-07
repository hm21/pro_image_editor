// Project imports:
import '/features/blur_editor/blur_editor.dart';
import '/shared/widgets/custom_widgets/reactive_custom_appbar.dart';
import '/shared/widgets/custom_widgets/reactive_custom_widget.dart';
import 'utils/custom_widgets_standalone_editor.dart';
import 'utils/custom_widgets_typedef.dart';

/// A custom widget for editing blur effects in an image editor.
///
/// This widget extends the standalone editor for the blur editor state,
/// providing a customizable interface for applying and adjusting blur effects.
class BlurEditorWidgets extends CustomWidgetsStandaloneEditor<BlurEditorState> {
  /// Creates a [BlurEditorWidgets] widget.
  ///
  /// This widget allows customization of the app bar, bottom bar, body items,
  /// and slider for the blur editor, enabling a flexible design tailored to
  /// specific needs.
  ///
  /// Example:
  /// ```
  /// BlurEditorWidgets(
  ///   appBar: myAppBar,
  ///   bottomBar: myBottomBar,
  ///   bodyItems: myBodyItems,
  ///   slider: mySlider,
  /// )
  /// ```
  const BlurEditorWidgets({
    super.appBar,
    super.bottomBar,
    super.bodyItems,
    super.bodyItemsRecorded,
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
  BlurEditorWidgets copyWith({
    ReactiveAppbar? Function(
            BlurEditorState editorState, Stream<void> rebuildStream)?
        appBar,
    ReactiveWidget? Function(
            BlurEditorState editorState, Stream<void> rebuildStream)?
        bottomBar,
    CustomBodyItems<BlurEditorState>? bodyItems,
    CustomBodyItems<BlurEditorState>? bodyItemsRecorded,
    CustomSlider<BlurEditorState>? slider,
  }) {
    return BlurEditorWidgets(
      appBar: appBar ?? this.appBar,
      bottomBar: bottomBar ?? this.bottomBar,
      bodyItems: bodyItems ?? this.bodyItems,
      bodyItemsRecorded: bodyItemsRecorded ?? this.bodyItemsRecorded,
      slider: slider ?? this.slider,
    );
  }
}
