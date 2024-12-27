// Project imports:
import '../../pro_image_editor.dart';
import 'utils/custom_widgets_standalone_editor.dart';
import 'utils/custom_widgets_typedef.dart';

/// A custom widget for the Tune Editor that extends the
/// [CustomWidgetsStandaloneEditor] to manage its state.
///
/// This widget provides an interface to adjust the tune settings
/// of an image editor using various UI components like app bar,
/// bottom bar, and body items.
class TuneEditorWidgets extends CustomWidgetsStandaloneEditor<TuneEditorState> {
  /// Creates a [TuneEditorWidgets] with optional appBar,
  /// bottomBar, bodyItems, and a custom slider widget.
  ///
  /// The [appBar], [bottomBar], and [bodyItems] are reactive widgets
  /// that rebuild based on the [TuneEditorState]. The [slider] allows
  /// the user to adjust tune parameters.
  const TuneEditorWidgets({
    super.appBar,
    super.bottomBar,
    super.bodyItems,
    super.bodyItemsRecorded,
    this.slider,
  });

  /// A custom slider widget for the tune editor.
  ///
  /// This widget allows users to adjust values using a slider in the tune
  /// editor.
  ///
  /// {@macro customSliderWidget}
  final CustomSlider<TuneEditorState>? slider;

  /// Copies the current [TuneEditorWidgets] with new values for
  /// [appBar], [bottomBar], [bodyItems], or [slider].
  ///
  /// If any of these are not provided, the existing value will be used.
  ///
  /// - [appBar] is a function that returns a reactive app bar widget based
  ///   on the editor state and a rebuild stream.
  /// - [bottomBar] is a function that returns a reactive bottom bar widget
  ///   based on the editor state and a rebuild stream.
  /// - [bodyItems] is a function that returns a list of reactive body
  ///   widgets based on the editor state and a rebuild stream.
  /// - [slider] is a custom slider for the tune editor.
  @override
  TuneEditorWidgets copyWith({
    ReactiveCustomAppbar? Function(
            TuneEditorState editorState, Stream<void> rebuildStream)?
        appBar,
    ReactiveCustomWidget? Function(
            TuneEditorState editorState, Stream<void> rebuildStream)?
        bottomBar,
    CustomBodyItems<TuneEditorState>? bodyItems,
    CustomBodyItems<TuneEditorState>? bodyItemsRecorded,
    CustomSlider<TuneEditorState>? slider,
  }) {
    return TuneEditorWidgets(
      appBar: appBar ?? this.appBar,
      bottomBar: bottomBar ?? this.bottomBar,
      bodyItemsRecorded: bodyItemsRecorded ?? this.bodyItemsRecorded,
      slider: slider ?? this.slider,
    );
  }
}
