import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:pro_image_editor/pro_image_editor.dart';

import '../pages/preview_img.dart';

mixin ExampleHelperState<T extends StatefulWidget> on State<T> {
  final editorKey = GlobalKey<ProImageEditorState>();
  Uint8List? editedBytes;

  Future<void> onImageEditingComplete(bytes) async {
    editedBytes = bytes;
    Navigator.pop(context);
  }

  void onCloseEditor() {
    if (editedBytes != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) {
            return PreviewImgPage(imgBytes: editedBytes!);
          },
        ),
      ).whenComplete(() {
        editedBytes = null;
      });
    } else {
      Navigator.pop(context);
    }
  }
}
