// Project imports:
import 'package:pro_image_editor/pro_image_editor.dart';
import 'utils/custom_widgets_standalone_editor.dart';
import 'utils/custom_widgets_typedef.dart';

class CustomWidgetsCropRotateEditor
    extends CustomWidgetsStandaloneEditor<CropRotateEditorState> {
  /// A widget for selecting aspect ratio options in the crop editor.
  ///
  /// This widget allows users to select different aspect ratio options for the crop
  /// editor.
  ///
  /// - [editorState] - The current state of the editor.
  /// - [rebuildStream] - A [Stream] that triggers the widget to rebuild.
  /// - [aspectRatio] - The aspect ratio to be set.
  /// - [originalAspectRatio] - The original aspect ratio.
  ///
  /// Returns a [ReactiveCustomWidget] that provides options for crop editor aspect ratios.
  final CropEditorAspectRatioOptions<CropRotateEditorState>? aspectRatioOptions;

  const CustomWidgetsCropRotateEditor({
    super.appBar,
    super.bottomBar,
    super.bodyItems,
    this.aspectRatioOptions,
  });
}
