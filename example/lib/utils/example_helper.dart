// Dart imports:
import 'dart:typed_data';
import 'dart:ui' as ui;

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:pro_image_editor/pro_image_editor.dart';

// Project imports:
import '../pages/preview_img.dart';

/// A mixin that provides helper methods and state management for image editing
/// using the [ProImageEditor]. It is intended to be used in a [StatefulWidget].
mixin ExampleHelperState<T extends StatefulWidget> on State<T> {
  /// The global key used to reference the state of [ProImageEditor].
  final editorKey = GlobalKey<ProImageEditorState>();

  /// Holds the edited image bytes after the editing is complete.
  Uint8List? editedBytes;

  /// The time it took to generate the edited image in milliseconds.
  double? _generationTime;

  /// Records the start time of the editing process.
  DateTime? startEditingTime;

  /// Called when the image editing process starts.
  /// Records the time when editing began.
  Future<void> onImageEditingStarted() async {
    startEditingTime = DateTime.now();
  }

  /// Called when the image editing process is complete.
  /// Saves the edited image bytes and calculates the generation time.
  ///
  /// [bytes] is the edited image in bytes.
  Future<void> onImageEditingComplete(Uint8List bytes) async {
    editedBytes = bytes;
    setGenerationTime();
  }

  /// Calculates the time taken for the image generation in milliseconds
  /// and stores it in [_generationTime].
  void setGenerationTime() {
    if (startEditingTime != null) {
      _generationTime = DateTime.now()
          .difference(startEditingTime!)
          .inMilliseconds
          .toDouble();
    }
  }

  /// Closes the image editor and navigates to a preview page showing the
  /// edited image.
  ///
  /// If [showThumbnail] is true, a thumbnail of the image will be displayed.
  /// The [rawOriginalImage] can be passed if the unedited image needs to be
  /// shown.
  /// The [generationConfigs] can be used to pass additional configurations for
  /// generating the image.
  void onCloseEditor({
    bool showThumbnail = false,
    ui.Image? rawOriginalImage,
    final ImageGenerationConfigs? generationConfigs,
  }) async {
    if (editedBytes != null) {
      // Pre-cache the edited image to improve display performance.
      await precacheImage(MemoryImage(editedBytes!), context);
      if (!mounted) return;

      // Navigate to the preview page to display the edited image.
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
        // Reset the state variables after navigation.
        editedBytes = null;
        _generationTime = null;
        startEditingTime = null;
      });
    }

    // Close the editor if no image editing is done.
    if (mounted) Navigator.pop(context);
  }
}
