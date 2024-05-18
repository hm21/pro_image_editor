// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:pro_image_editor/pro_image_editor.dart';

/// A mixin providing access to simple editor callbacks.
mixin SimpleCallbacksAccess on StatefulWidget {
  /// Returns the callbacks for the editor.
  ProImageEditorCallbacks get callbacks;
}

/// A mixin providing access to simple editor configurations within a state.
mixin SimpleCallbacksAccessState<T extends StatefulWidget> on State<T> {
  SimpleCallbacksAccess get _widget => (widget as SimpleCallbacksAccess);

  ProImageEditorCallbacks get callbacks => _widget.callbacks;

  /// A callback function that will be called when the editing is done,
  /// and it returns the edited image as a Uint8List.
  ///
  /// The edited image is provided as a Uint8List to the [onImageEditingComplete] function
  /// when the editing is completed.
  ///
  /// <img src="https://github.com/hm21/pro_image_editor/blob/stable/assets/schema_callbacks.jpeg?raw=true" alt="Schema" height="500px" />
  ImageEditingCompleteCallback get onImageEditingComplete =>
      callbacks.onImageEditingComplete;

  /// A callback function that will be called before the image editor will close.
  ///
  /// <img src="https://github.com/hm21/pro_image_editor/blob/stable/assets/schema_callbacks.jpeg?raw=true" alt="Schema" height="500px" />
  ImageEditingEmptyCallback? get onCloseEditor => callbacks.onCloseEditor;

  /// A callback function that can be used to update the UI from custom widgets.
  UpdateUiCallback? get onUpdateUI => callbacks.onUpdateUI;
}
