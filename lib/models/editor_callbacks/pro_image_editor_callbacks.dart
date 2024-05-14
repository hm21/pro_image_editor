import 'main_editor_callbacks.dart';

export 'main_editor_callbacks.dart';

/// A class representing configuration options for the Image Editor.
class ProImageEditorCallbacks {
  /// A callback function that will be called when the editing is done,
  /// and it returns the edited image as a Uint8List.
  ///
  /// The edited image is provided as a Uint8List to the [onImageEditingComplete] function
  /// when the editing is completed.
  ///
  /// <img src="https://github.com/hm21/pro_image_editor/blob/stable/assets/schema_callbacks.jpeg?raw=true" alt="Schema" width="400px"/>
  final ImageEditingCompleteCallback onImageEditingComplete;

  /// A callback function that will be called before the image editor will close.
  ///
  /// <img src="https://github.com/hm21/pro_image_editor/blob/stable/assets/schema_callbacks.jpeg?raw=true" alt="Schema" width="400px"/>
  final ImageEditingEmptyCallback? onCloseEditor;

  /// A callback function that can be used to update the UI from custom widgets.
  final UpdateUiCallback? onUpdateUI;

  const ProImageEditorCallbacks({
    required this.onImageEditingComplete,
    this.onCloseEditor,
    this.onUpdateUI,
  });
}
