// Dart imports:
import 'dart:typed_data';
import 'dart:ui' as ui;

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:pro_image_editor/pro_image_editor.dart';

// Project imports:
import '../common/example_constants.dart';
import '../pages/preview_img.dart';

export '../widgets/prepare_image_widget.dart';

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

  /// Indicates whether image-resources are pre-cached.
  bool isPreCached = true;

  /// Determines if the current layout should use desktop mode based on the
  /// screen width.
  ///
  /// Returns `true` if the screen width is greater than or equal to
  /// [kImageEditorExampleIsDesktopBreakPoint], otherwise `false`.
  bool isDesktopMode(BuildContext context) =>
      MediaQuery.of(context).size.width >=
      kImageEditorExampleIsDesktopBreakPoint;

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
    bool enablePop = true,
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

    if (mounted && enablePop) {
      Navigator.pop(context);
    }
  }

  /// Preloads an image into memory to improve performance.
  ///
  /// Supports both asset and network images. Once the image is cached, it
  /// updates the
  /// [isPreCached] flag, triggers a widget rebuild, and optionally executes a
  /// callback.
  ///
  /// Parameters:
  /// - [assetPath]: The file path of the asset image to be cached.
  /// - [networkUrl]: The URL of the network image to be cached.
  /// - [onDone]: An optional callback executed after caching is complete.
  ///
  /// Ensures the widget is still mounted before performing operations.
  void preCacheImage({
    String? assetPath,
    String? networkUrl,
    Function()? onDone,
  }) {
    isPreCached = false;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      precacheImage(
              assetPath != null
                  ? AssetImage(assetPath)
                  : NetworkImage(networkUrl!),
              context)
          .whenComplete(() {
        if (!mounted) return;
        isPreCached = true;
        setState(() {});
        onDone?.call();
      });
    });
  }
}
