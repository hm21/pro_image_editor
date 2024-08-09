// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:pro_image_editor/pro_image_editor.dart';

/// A mixin providing access to simple editor callbacks.
mixin SimpleCallbacksAccess on StatefulWidget {
  /// Returns the callbacks for the editor.
  ///
  /// This getter should be implemented by the widget that uses this mixin
  /// to provide the [ProImageEditorCallbacks] instance.
  ProImageEditorCallbacks get callbacks;
}

/// A mixin providing access to simple editor configurations within a state.
mixin SimpleCallbacksAccessState<T extends StatefulWidget> on State<T> {
  /// Casts the widget to [SimpleCallbacksAccess] to access its callbacks.
  SimpleCallbacksAccess get _widget => (widget as SimpleCallbacksAccess);

  /// Returns the callbacks for the editor.
  ///
  /// This getter provides access to the [ProImageEditorCallbacks] instance
  /// from the widget that uses the [SimpleCallbacksAccess] mixin.
  ProImageEditorCallbacks get callbacks => _widget.callbacks;

  /// Returns the main editor callbacks.
  MainEditorCallbacks? get mainEditorCallbacks => callbacks.mainEditorCallbacks;

  /// Returns the paint editor callbacks.
  PaintEditorCallbacks? get paintEditorCallbacks =>
      callbacks.paintEditorCallbacks;

  /// Returns the text editor callbacks.
  TextEditorCallbacks? get textEditorCallbacks => callbacks.textEditorCallbacks;

  /// Returns the crop-rotate editor callbacks.
  CropRotateEditorCallbacks? get cropRotateEditorCallbacks =>
      callbacks.cropRotateEditorCallbacks;

  /// Returns the filter editor callbacks.
  FilterEditorCallbacks? get filterEditorCallbacks =>
      callbacks.filterEditorCallbacks;

  /// Returns the blur editor callbacks.
  BlurEditorCallbacks? get blurEditorCallbacks => callbacks.blurEditorCallbacks;

  /// A callback function that will be called when the editing is done,
  /// and it returns the edited image as a Uint8List.
  ///
  /// The edited image is provided as a Uint8List to the
  /// [onImageEditingComplete] function
  /// when the editing is completed.
  ///
  /// <img src="https://github.com/hm21/pro_image_editor/blob/stable/assets/schema_callbacks.jpeg?raw=true" alt="Schema" height="500px" />
  ImageEditingCompleteCallback? get onImageEditingComplete =>
      callbacks.onImageEditingComplete;

  /// A callback function that will be called before the image editor will
  /// close.
  ///
  /// <img src="https://github.com/hm21/pro_image_editor/blob/stable/assets/schema_callbacks.jpeg?raw=true" alt="Schema" height="500px" />
  ImageEditingEmptyCallback? get onCloseEditor => callbacks.onCloseEditor;
}
