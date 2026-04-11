// Dart imports:
import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';

import '/core/mixins/converted_callbacks.dart';
import '/core/models/complete_parameters.dart';
import '/features/filter_editor/types/filter_matrix.dart';
import '/features/tune_editor/models/tune_adjustment_matrix.dart';
import '/shared/controllers/video_controller.dart';
import '/shared/factories/editor_factory.dart';
import '/shared/factories/editor_mapper.dart';
import '/shared/services/content_recorder/controllers/content_recorder_controller.dart';
import '/shared/utils/decode_image.dart';
import '/shared/utils/transparent_image_generator_utils.dart';
import '/shared/widgets/overlays/loading_dialog/loading_dialog.dart';
import '../models/editor_callbacks/pro_image_editor_callbacks.dart';
import '../models/editor_configs/pro_image_editor_configs.dart';
import '../models/editor_image.dart';
import '../models/init_configs/editor_init_configs.dart';
import '../models/layers/layer.dart';
import '../models/multi_threading/thread_capture_model.dart';
import 'converted_configs.dart';

/// A mixin providing access to standalone editor configurations and image.
mixin StandaloneEditor<T extends EditorInitConfigs> {
  /// Returns the initialization configurations for the editor.
  T get initConfigs;

  /// Returns the editor image
  EditorImage? get editorImage;

  /// Returns the video controller
  ProVideoController? get videoController;
}

/// A mixin providing access to standalone editor configurations and image
/// within a state.
mixin StandaloneEditorState<
  T extends StatefulWidget,
  I extends EditorInitConfigs
>
    on State<T>, ImageEditorConvertedConfigs, ImageEditorConvertedCallbacks {
  /// Returns the initialization configurations for the editor.
  I get initConfigs => (widget as StandaloneEditor<I>).initConfigs;

  /// The background image which is used in the video editor.
  EditorImage? videoBackgroundImage;

  /// Returns the image being edited.
  EditorImage? get editorImage =>
      videoBackgroundImage ?? (widget as StandaloneEditor<I>).editorImage;

  /// Returns the controller to edit the video.
  ProVideoController? get videoController =>
      (widget as StandaloneEditor<I>).videoController;

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

  /// Returns the applied tune adjustments.
  List<TuneAdjustmentMatrix> get appliedTuneAdjustments =>
      initConfigs.appliedTuneAdjustments;

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
  bool isGenerationActive = false;

  /// Indicates if the video editor is used
  bool get isVideoEditor => videoController != null;

  /// The position in the history of screenshots. This is used to track the
  /// current position in the list of screenshots.
  int screenshotHistoryPosition = 0;

  /// A list of captured screenshots. Each element in the list represents the
  /// state of a screenshot captured by the isolate.
  final List<ThreadCaptureState> screenshotHistory = [];

  Uint8List? _transparentImageBytes;

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
        bytes:
            await (editorImage?.safeByteArray(context) ??
                _createTransparentImage()),
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
    EditorImage? editorImage,
    Function? onCloseWithValue,
    Function(Uint8List?)? onSetFakeHero,
    required double blur,
    required List<List<double>> matrixFilterList,
    required List<List<double>> matrixTuneAdjustmentsList,
    required TransformConfigs? transform,
  }) async {
    if (isGenerationActive) return;

    if (initConfigs.convertToUint8List) {
      initConfigs.callbacks.onImageEditingStarted?.call();

      isGenerationActive = true;
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
      bool screenshotIsCaptured =
          screenshotHistoryPosition > 0 &&
          screenshotHistoryPosition <= screenshotHistory.length;
      Uint8List? bytes = await screenshotCtrl.captureFinalScreenshot(
        imageInfos: imageInfos!,
        backgroundScreenshot: screenshotIsCaptured
            ? screenshotHistory[screenshotHistoryPosition - 1]
            : null,
        originalImageBytes: screenshotHistoryPosition > 0
            ? null
            : await editorImage!.safeByteArray(context),
      );

      isGenerationActive = false;

      var imageBytes = bytes ?? Uint8List.fromList([]);

      /// Return final image that the user can handle it but still with the
      /// active loading dialog
      await initConfigs.callbacks.onImageEditingComplete?.call(imageBytes);

      /// Return complete parameters if requested
      if (initConfigs.callbacks.onCompleteWithParameters != null) {
        final isTransformed = transform?.isNotEmpty ?? false;

        var decodedImage = await decodeImageFromList(imageBytes);
        Size originalImageSize = Size(
          decodedImage.width.toDouble(),
          decodedImage.height.toDouble(),
        );
        Size? outputSize = transform?.getCropSize(originalImageSize);
        Offset? outputOffset = transform?.getCropStartOffset(originalImageSize);

        await initConfigs.callbacks.onCompleteWithParameters?.call(
          CompleteParameters(
            blur: blur,
            matrixFilterList: matrixFilterList,
            matrixTuneAdjustmentsList: matrixTuneAdjustmentsList,
            cropWidth: isTransformed ? outputSize!.width.round() : null,
            cropHeight: isTransformed ? outputSize!.height.round() : null,
            cropX: isTransformed ? outputOffset!.dx.round() : null,
            cropY: isTransformed ? outputOffset!.dy.round() : null,
            flipX: transform?.flipX ?? false,
            flipY: transform?.flipY ?? false,
            rotateTurns: transform?.angleToTurns() ?? 0,
            startTime: null,
            endTime: null,
            image: imageBytes,
            isTransformed: isTransformed,
            layers: layers ?? [],
            originalImageSize: null,
            temporaryDecodedImageSize: null,
            bodySize: null,
            editorSize: null,
          ),
        );
      }

      /// Precache the image for the case the user require the hero animation
      if (onSetFakeHero != null) {
        if (bytes != null && mounted) {
          await precacheImage(MemoryImage(bytes), context);
        }
        onSetFakeHero.call(bytes);
      }

      /// Hide the loading dialog
      LoadingDialog.instance.hide();

      initConfigs.callbacks.onCloseEditor?.call(editorMode);
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
    if (initConfigs.callbacks.onCloseEditor == null) {
      Navigator.pop(context);
    } else {
      initConfigs.callbacks.onCloseEditor?.call(editorMode);
    }

    EditorFactory.getEditor(editorMode).handleCloseEditor();
  }

  /// Returns the editor mode based on the init config type.
  EditorMode get editorMode {
    return EditorMapper.getEditorModeFromConfigs(initConfigs);
  }

  /// Takes a screenshot of the current editor state.
  ///
  /// This method captures a screenshot of the current editor state, storing
  /// it in the screenshot history for potential future use.
  @protected
  void takeScreenshot() async {
    if (!initConfigs.convertToUint8List) return;

    await setImageInfos();

    screenshotHistory.removeRange(
      screenshotHistoryPosition,
      screenshotHistory.length,
    );

    screenshotHistoryPosition++;

    await screenshotCtrl.capture(
      imageInfos: imageInfos!,
      screenshots: screenshotHistory,
    );
  }

  @override
  @mustCallSuper
  void initState() {
    super.initState();
    screenshotCtrl = ContentRecorderController(
      configs: configs.imageGeneration,
      isVideoEditor: isVideoEditor,
      ignoreGeneration: !initConfigs.convertToUint8List,
    );
    rebuildController = StreamController.broadcast();
  }

  @override
  @mustCallSuper
  void dispose() {
    screenshotCtrl.destroy();
    rebuildController.close();
    super.dispose();
  }

  Future<Uint8List> _createTransparentImage() async {
    if (_transparentImageBytes != null) return _transparentImageBytes!;

    _transparentImageBytes = await createTransparentImage(
      videoController!.initialResolution,
    );
    return _transparentImageBytes!;
  }
}
