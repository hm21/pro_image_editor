import 'package:pro_image_editor/modules/text_editor/text_editor.dart';

import 'utils/custom_widgets_standalone_editor.dart';
import 'utils/custom_widgets_typedef.dart';

class CustomWidgetsTextEditor
    extends CustomWidgetsStandaloneEditor<TextEditorState> {
  /// A custom color picker widget for the text editor.
  ///
  /// - [editorState] - The current state of the editor.
  /// - [rebuildStream] - A [Stream] that triggers the widget to rebuild.
  /// - [currentColor] - The currently selected color.
  /// - [setColor] - A function to update the selected color.
  ///
  /// Returns an optional [ReactiveCustomWidget] that provides a custom color picker.
  ///
  /// **Example:**
  /// colorPicker: (editor, rebuildStream, currentColor, setColor) =>
  ///    ReactiveCustomWidget(
  ///      stream: rebuildStream,
  ///      builder: (_) => BarColorPicker(
  ///        configs: editor.configs,
  ///        length: 200,
  ///        horizontal: false,
  ///        initialColor: currentColor,
  ///        colorListener: (int value) {
  ///          setColor(Color(value));
  ///        },
  ///      ),
  /// ),
  final CustomColorPicker<TextEditorState>? colorPicker;

  const CustomWidgetsTextEditor({
    super.appBar,
    super.bottomBar,
    super.bodyItems,
    this.colorPicker,
  });
}
