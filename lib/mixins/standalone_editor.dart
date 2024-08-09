// Dart imports:
import 'dart:async';
import 'dart:typed_data';

// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:pro_image_editor/mixins/converted_callbacks.dart';
import 'package:pro_image_editor/pro_image_editor.dart';
import '../models/crop_rotate_editor/transform_factors.dart';
import '../models/init_configs/editor_init_configs.dart';
import '../models/multi_threading/thread_capture_model.dart';
import '../modules/filter_editor/types/filter_matrix.dart';
import '../utils/content_recorder.dart/content_recorder_controller.dart';
import 'converted_configs.dart';

/// A mixin providing access to standalone editor configurations and image.
mixin StandaloneEditor<T extends EditorInitConfigs> {
  /// Returns the initialization configurations for the editor.
  T get initConfigs;

  /// Returns the editor image
  EditorImage get editorImage;
}

/// A mixin providing access to standalone editor configurations and image
/// within a state.
mixin StandaloneEditorState<T extends StatefulWidget,
        I extends EditorInitConfigs>
    on State<T>, ImageEditorConvertedConfigs, ImageEditorConvertedCallbacks {
  /// Returns the initialization configurations for the editor.
  I get initConfigs => (widget as StandaloneEditor<I>).initConfigs;

  /// Returns the image being edited.
  EditorImage get editorImage => (widget as StandaloneEditor<I>).editorImage;

  @override
  ProImageEditorConfigs get configs => initConfigs.configs;

  @override
  ProImageEditorCallbacks get callbacks => initConfigs.callbacks;

  /// Helper stream to rebuild widgets.
  @protected
  late final StreamController<void> rebuildController;

  /// Returns the theme data for the editor.
  ThemeData get theme => initConfigs.theme;

  /// Returns the initial transformation configurations for the editor.
  TransformConfigs? get initialTransformConfigs => initConfigs.transformConfigs;

  /// Returns the layers in the editor.
  List<Layer>? get layers => initConfigs.layers;

  /// Returns the applied blur factor.
  double get appliedBlurFactor => initConfigs.appliedBlurFactor;

  /// Returns the applied filters.
  FilterMatrix get appliedFilters => initConfigs.appliedFilters;

  /// Returns the body size with layers.
  Size? get mainBodySize => initConfigs.mainBodySize;

  /// Returns the image size with layers.
  Size? get mainImageSize => initConfigs.mainImageSize;

  /// The information data from the image.
  ImageInfos? imageInfos;

  /// Represents the dimensions of the body.
  Size editorBodySize = Size.infinite;

  /// Manages the capturing a screenshot of the image.
  late ContentRecorderController screenshotCtrl;

  /// Indicates it create a screenshot or not.
  bool createScreenshot = false;

  /// The position in the history of screenshots. This is used to track the
  /// current position in the list of screenshots.
  int screenshotHistoryPosition = 0;

  /// A list of captured screenshots. Each element in the list represents the
  /// state of a screenshot captured by the isolate.
  final List<ThreadCaptureState> screenshotHistory = [];

  /// Sets the image information data.
  ///
  /// This method decodes image information based on the current editor state
  /// and configuration, ensuring accurate metadata extraction.
  Future<void> setImageInfos({
    TransformConfigs? activeHistory,
    bool? forceUpdate,
  }) async {
    if (imageInfos == null || forceUpdate == true) {
      imageInfos = (await decodeImageInfos(
        bytes: await editorImage.safeByteArray(context),
        screenSize: editorBodySize,
        configs: activeHistory,
      ));
    }
  }

  /// This function is for internal use only and is marked as protected.
  /// Please use the `done()` method instead.
  @protected
  void doneEditing({
    dynamic returnValue,
    required EditorImage editorImage,
    Function? onCloseWithValue,
    Function(Uint8List?)? onSetFakeHero,
  }) async {
    if (createScreenshot) return;
    initConfigs.onImageEditingStarted?.call();

    if (initConfigs.convertToUint8List) {
      createScreenshot = true;
      LoadingDialog.instance.show(
        context,
        configs: configs,
        theme: theme,
        message: i18n.doneLoadingMsg,
      );

      /// Ensure the image infos are read
      if (imageInfos == null) await setImageInfos();
      if (!mounted) {
        LoadingDialog.instance.hide();
        return;
      }

      /// Capture the final screenshot
      bool screenshotIsCaptured = screenshotHistoryPosition > 0 &&
          screenshotHistoryPosition <= screenshotHistory.length;
      Uint8List? bytes = await screenshotCtrl.captureFinalScreenshot(
        imageInfos: imageInfos!,
        backgroundScreenshot: screenshotIsCaptured
            ? screenshotHistory[screenshotHistoryPosition - 1]
            : null,
        originalImageBytes: screenshotHistoryPosition > 0
            ? null
            : await editorImage.safeByteArray(context),
      );

      createScreenshot = false;

      /// Return final image that the user can handle it but still with the
      /// active loading dialog
      await initConfigs.onImageEditingComplete
          ?.call(bytes ?? Uint8List.fromList([]));

      /// Precache the image for the case the user require the hero animation
      if (onSetFakeHero != null) {
        if (bytes != null && mounted) {
          await precacheImage(MemoryImage(bytes), context);
        }
        onSetFakeHero.call(bytes);
      }

      /// Hide the loading dialog
      LoadingDialog.instance.hide();

      initConfigs.onCloseEditor?.call();
    } else {
      if (onCloseWithValue == null) {
        Navigator.pop(context, returnValue);
      } else {
        onCloseWithValue.call();
      }
    }
  }

  /// Closes the editor without applying changes.
  void close() {
    if (initConfigs.onCloseEditor == null) {
      Navigator.pop(context);
    } else {
      initConfigs.onCloseEditor!.call();
    }
    if (I is PaintEditorInitConfigs) {
      paintEditorCallbacks?.handleCloseEditor();
    } else if (I is CropRotateEditorInitConfigs) {
      cropRotateEditorCallbacks?.handleCloseEditor();
    } else if (I is FilterEditorInitConfigs) {
      filterEditorCallbacks?.handleCloseEditor();
    } else if (I is BlurEditorInitConfigs) {
      blurEditorCallbacks?.handleCloseEditor();
    }
  }

  /// Takes a screenshot of the current editor state.
  ///
  /// This method captures a screenshot of the current editor state, storing
  /// it in the screenshot history for potential future use.
  @protected
  void takeScreenshot() async {
    if (!initConfigs.convertToUint8List) return;

    await setImageInfos();
    screenshotHistoryPosition++;
    screenshotCtrl.captureImage(
      imageInfos: imageInfos!,
      screenshots: screenshotHistory,
    );
  }

  @override
  @mustCallSuper
  void initState() {
    screenshotCtrl = ContentRecorderController(
        configs: configs, ignoreGeneration: !initConfigs.convertToUint8List);
    rebuildController = StreamController.broadcast();
    super.initState();
  }

  @override
  @mustCallSuper
  void dispose() {
    screenshotCtrl.destroy();
    rebuildController.close();
    super.dispose();
  }

  /// Gets the minimum size between two sizes.
  ///
  /// This method returns the smaller of two sizes, ensuring that the resulting
  /// size is neither null nor empty.
  @protected
  Size getMinimumSize(Size? a, Size b) {
    return a == null || a.isEmpty
        ? b.isEmpty
            ? const Size(1, 1)
            : b
        : a;
  }
}
