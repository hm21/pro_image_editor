// Dart imports:
import 'dart:typed_data';
import 'dart:ui' as ui;

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:pro_image_editor/pro_image_editor.dart';

// Project imports:
import '../pages/preview_img.dart';

mixin ExampleHelperState<T extends StatefulWidget> on State<T> {
  final editorKey = GlobalKey<ProImageEditorState>();
  Uint8List? editedBytes;
  double? _generationTime;
  DateTime? startEditingTime;

  Future<void> onImageEditingStarted() async {
    startEditingTime = DateTime.now();
  }

  Future<void> onImageEditingComplete(bytes) async {
    editedBytes = bytes;
    setGenerationTime();
  }

  void setGenerationTime() {
    if (startEditingTime != null) {
      _generationTime = DateTime.now()
          .difference(startEditingTime!)
          .inMilliseconds
          .toDouble();
    }
  }

  void onCloseEditor({
    bool showThumbnail = false,
    ui.Image? rawOriginalImage,
    final ImageGenerationConfigs? generationConfigs,
  }) async {
    if (editedBytes != null) {
      await precacheImage(MemoryImage(editedBytes!), context);
      if (!mounted) return;
      editorKey.currentState?.disablePopScope = true;
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) {
            return PreviewImgPage(
              imgBytes: editedBytes!,
              generationTime: _generationTime,
              showThumbnail: showThumbnail,
              rawOriginalImage: rawOriginalImage,
              generationConfigs: generationConfigs,
            );
          },
        ),
      ).whenComplete(() {
        editedBytes = null;
        _generationTime = null;
        startEditingTime = null;
      });
    }
    if (mounted) Navigator.pop(context);
  }
}
