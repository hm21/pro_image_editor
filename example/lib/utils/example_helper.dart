// Dart imports:
import 'dart:typed_data';

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:pro_image_editor/pro_image_editor.dart';

// Project imports:
import '../pages/preview_img.dart';

mixin ExampleHelperState<T extends StatefulWidget> on State<T> {
  final editorKey = GlobalKey<ProImageEditorState>();
  Uint8List? editedBytes;

  Future<void> onImageEditingComplete(bytes) async {
    editedBytes = bytes;
    Navigator.pop(context);
  }

  void onCloseEditor() async {
    if (editedBytes != null) {
      await precacheImage(MemoryImage(editedBytes!), context);
      if (!mounted) return;
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
