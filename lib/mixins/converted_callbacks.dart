// Project imports:
import 'package:pro_image_editor/models/editor_callbacks/pro_image_editor_callbacks.dart';

mixin ImageEditorConvertedCallbacks {
  /// Returns the main configuration options for the editor.
  ProImageEditorCallbacks get callbacks;

  PaintEditorCallbacks? get paintEditorCallbacks =>
      callbacks.paintEditorCallbacks;
  TextEditorCallbacks? get textEditorCallbacks => callbacks.textEditorCallbacks;
  CropRotateEditorCallbacks? get cropRotateEditorCallbacks =>
      callbacks.cropRotateEditorCallbacks;
  FilterEditorCallbacks? get filterEditorCallbacks =>
      callbacks.filterEditorCallbacks;
  BlurEditorCallbacks? get blurEditorCallbacks => callbacks.blurEditorCallbacks;
}
