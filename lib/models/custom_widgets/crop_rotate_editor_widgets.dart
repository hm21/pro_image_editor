// Project imports:
import 'package:pro_image_editor/pro_image_editor.dart';
import 'utils/custom_widgets_standalone_editor.dart';
import 'utils/custom_widgets_typedef.dart';

/// A custom widget for editing crop and rotate effects in an image editor.
///
/// This widget extends the standalone editor for the crop and rotate editor
/// state, providing a customizable interface for applying and adjusting crop
/// and rotate transformations.
class CropRotateEditorWidgets
    extends CustomWidgetsStandaloneEditor<CropRotateEditorState> {
  /// Creates a [CropRotateEditorWidgets] widget.
  ///
  /// This widget allows customization of the app bar, bottom bar, body items,
  /// and additional widgets specific to crop and rotate functionality,
  /// enabling a flexible design tailored to specific needs.
  ///
  /// Example:
  /// ```
  /// CropRotateEditorWidgets(
  ///   appBar: myAppBar,
  ///   bottomBar: myBottomBar,
  ///   bodyItems: myBodyItems,
  /// )
  /// ```
  const CropRotateEditorWidgets({
    super.appBar,
    super.bottomBar,
    super.bodyItems,
    this.aspectRatioOptions,
  });

  /// A widget for selecting aspect ratio options in the crop editor.
  ///
  /// This widget allows users to select different aspect ratio options for the
  /// crop editor.
  ///
  /// - [editorState] - The current state of the editor.
  /// - [rebuildStream] - A [Stream] that triggers the widget to rebuild.
  /// - [aspectRatio] - The aspect ratio to be set.
  /// - [originalAspectRatio] - The original aspect ratio.
  ///
  /// Returns a [ReactiveCustomWidget] that provides options for crop editor
  /// aspect ratios.
  final CropEditorAspectRatioOptions<CropRotateEditorState>? aspectRatioOptions;

  @override
  CropRotateEditorWidgets copyWith({
    ReactiveCustomAppbar? Function(
            CropRotateEditorState editorState, Stream<void> rebuildStream)?
        appBar,
    ReactiveCustomWidget? Function(
            CropRotateEditorState editorState, Stream<void> rebuildStream)?
        bottomBar,
    CustomBodyItems<CropRotateEditorState>? bodyItems,
    CropEditorAspectRatioOptions<CropRotateEditorState>? aspectRatioOptions,
  }) {
    return CropRotateEditorWidgets(
      appBar: appBar ?? this.appBar,
      bottomBar: bottomBar ?? this.bottomBar,
      bodyItems: bodyItems ?? this.bodyItems,
      aspectRatioOptions: aspectRatioOptions ?? this.aspectRatioOptions,
    );
  }
}
