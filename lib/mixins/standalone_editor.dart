// Dart imports:
import 'dart:typed_data';

// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../models/crop_rotate_editor/transform_factors.dart';
import '../models/editor_callbacks/editor_callbacks_typedef.dart';
import '../models/editor_configs/pro_image_editor_configs.dart';
import '../models/editor_image.dart';
import '../models/init_configs/editor_init_configs.dart';
import '../models/layer.dart';
import '../models/multi_threading/thread_capture_model.dart';
import '../modules/filter_editor/types/filter_matrix.dart';
import '../utils/content_recorder.dart/content_recorder_controller.dart';
import '../utils/decode_image.dart';
import '../widgets/loading_dialog.dart';
import 'converted_configs.dart';

/// A mixin providing access to standalone editor configurations and image.
mixin StandaloneEditor<T extends EditorInitConfigs> {
  /// Returns the initialization configurations for the editor.
  T get initConfigs;

  /// Returns the editor image
  EditorImage get editorImage;
}

/// A mixin providing access to standalone editor configurations and image within a state.
mixin StandaloneEditorState<T extends StatefulWidget,
    I extends EditorInitConfigs> on State<T>, ImageEditorConvertedConfigs {
  /// Returns the initialization configurations for the editor.
  I get initConfigs => (widget as StandaloneEditor<I>).initConfigs;

  /// Returns the image being edited.
  EditorImage get editorImage => (widget as StandaloneEditor<I>).editorImage;

  @override
  ProImageEditorConfigs get configs => initConfigs.configs;

  /// Returns the theme data for the editor.
  ThemeData get theme => initConfigs.theme;

  /// Returns the transformation configurations for the editor.
  TransformConfigs? get transformConfigs => initConfigs.transformConfigs;

  /// Returns the layers in the editor.
  List<Layer>? get layers => initConfigs.layers;

  /// Returns the callback function to update the UI.
  UpdateUiCallback? get onUpdateUI => initConfigs.onUpdateUI;

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
  int historyPosition = 0;

  /// A list of captured screenshots. Each element in the list represents the
  /// state of a screenshot captured by the isolate.
  final List<ThreadCaptureState> screenshots = [];

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
      LoadingDialog loading = LoadingDialog();
      await loading.show(
        context,
        configs: configs,
        theme: theme,
        message: i18n.doneLoadingMsg,
      );
      if (imageInfos == null) await setImageInfos();
      if (!mounted) return;
      bool screenshotIsCaptured =
          historyPosition > 0 && historyPosition <= screenshots.length;
      Uint8List? bytes = await screenshotCtrl.captureFinalScreenshot(
        imageInfos: imageInfos!,
        backgroundScreenshot:
            screenshotIsCaptured ? screenshots[historyPosition - 1] : null,
        originalImageBytes: historyPosition > 0
            ? null
            : await editorImage.safeByteArray(context),
      );

      createScreenshot = false;
      if (mounted) {
        loading.hide(context);

        await initConfigs.onImageEditingComplete
            ?.call(bytes ?? Uint8List.fromList([]));

        if (onSetFakeHero != null) {
          if (bytes != null && mounted) {
            await precacheImage(MemoryImage(bytes), context);
          }
          onSetFakeHero.call(bytes);
        }

        initConfigs.onCloseEditor?.call();
      }
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
  }

  @protected
  void takeScreenshot() async {
    if (!initConfigs.convertToUint8List) return;

    await setImageInfos();
    historyPosition++;
    screenshotCtrl.captureImage(
      imageInfos: imageInfos!,
      screenshots: screenshots,
    );
  }

  @override
  void initState() {
    screenshotCtrl = ContentRecorderController(
        configs: configs, ignoreGeneration: !initConfigs.convertToUint8List);
    super.initState();
  }

  @override
  void dispose() {
    screenshotCtrl.destroy();
    super.dispose();
  }

  @protected
  Size getMinimumSize(Size? a, Size b) {
    return a == null || a.isEmpty
        ? b.isEmpty
            ? const Size(1, 1)
            : b
        : a;
  }
}
