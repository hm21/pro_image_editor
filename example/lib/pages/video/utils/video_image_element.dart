import 'package:flutter/widgets.dart';
import 'package:pro_image_editor/pro_image_editor.dart';

class ContentElement {
  final bool isVideo;
  final EditorImage editorImage;
  final GlobalKey<ProImageEditorState> imageEditorKey;

  ContentElement({
    required this.isVideo,
    required this.editorImage,
    required this.imageEditorKey,
  });

  ProImageEditorState? get imageEditor => imageEditorKey.currentState;
}
