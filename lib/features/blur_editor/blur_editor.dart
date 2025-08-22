// Dart imports:
import 'dart:async';

// Flutter imports:
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '/core/mixins/converted_callbacks.dart';
import '/core/mixins/converted_configs.dart';
import '/core/mixins/standalone_editor.dart';
import '/core/models/editor_image.dart';
import '/core/models/init_configs/blur_editor_init_configs.dart';
import '/core/models/transform_helper.dart';
import '/core/utils/size_utils.dart';
import '/features/blur_editor/widgets/blur_editor_bottombar.dart';
import '/shared/controllers/video_controller.dart';
import '/shared/services/content_recorder/widgets/content_recorder.dart';
import '/shared/utils/file_constructor_utils.dart';
import '/shared/widgets/layer/layer_stack.dart';
import '/shared/widgets/transform/transformed_content_generator.dart';
import '../crop_rotate_editor/models/transform_configs.dart';
import '../filter_editor/widgets/filtered_widget.dart';
import '../tune_editor/models/tune_adjustment_matrix.dart';
import 'widgets/blur_editor_appbar.dart';

/// The `BlurEditor` widget allows users to apply blur to images.
///
/// You can create a `BlurEditor` using one of the factory methods provided:
/// - `BlurEditor.file`: Loads an image from a file.
/// - `BlurEditor.asset`: Loads an image from an asset.
/// - `BlurEditor.network`: Loads an image from a network URL.
/// - `BlurEditor.memory`: Loads an image from memory as a `Uint8List`.
/// - `BlurEditor.autoSource`: Automatically selects the source based on
/// provided parameters.
class BlurEditor extends StatefulWidget
    with StandaloneEditor<BlurEditorInitConfigs> {
  /// Constructs a `BlurEditor` widget.
  ///
  /// The [key] parameter is used to provide a key for the widget.
  /// The [editorImage] parameter specifies the image to be edited.
  /// The [initConfigs] parameter specifies the initialization configurations
  /// for the editor.
  const BlurEditor._({
    super.key,
    required this.initConfigs,
    this.editorImage,
    this.videoController,
  }) : assert(editorImage != null || videoController != null,
            'Either editorImage or videoController must be provided.');

  /// Constructs a `BlurEditor` widget with image data loaded from memory.
  factory BlurEditor.memory(
    Uint8List byteArray, {
    Key? key,
    required BlurEditorInitConfigs initConfigs,
  }) {
    return BlurEditor._(
      key: key,
      editorImage: EditorImage(byteArray: byteArray),
      initConfigs: initConfigs,
    );
  }

  /// Constructs a `BlurEditor` widget with an image loaded from a file.
  factory BlurEditor.file(
    dynamic file, {
    Key? key,
    required BlurEditorInitConfigs initConfigs,
  }) {
    return BlurEditor._(
      key: key,
      editorImage: EditorImage(file: ensureFileInstance(file)),
      initConfigs: initConfigs,
    );
  }

  /// Constructs a `BlurEditor` widget with an image loaded from an asset.
  factory BlurEditor.asset(
    String assetPath, {
    Key? key,
    required BlurEditorInitConfigs initConfigs,
  }) {
    return BlurEditor._(
      key: key,
      editorImage: EditorImage(assetPath: assetPath),
      initConfigs: initConfigs,
    );
  }

  /// Constructs a `BlurEditor` widget with an image loaded from a network URL.
  factory BlurEditor.network(
    String networkUrl, {
    Key? key,
    required BlurEditorInitConfigs initConfigs,
  }) {
    return BlurEditor._(
      key: key,
      editorImage: EditorImage(networkUrl: networkUrl),
      initConfigs: initConfigs,
    );
  }

  /// Constructs a `BlurEditor` widget with an image loaded automatically based
  /// on the provided source.
  ///
  /// Either [byteArray], [file], [networkUrl], or [assetPath] must be provided.
  factory BlurEditor.autoSource({
    Key? key,
    Uint8List? byteArray,
    dynamic file,
    String? assetPath,
    String? networkUrl,
    EditorImage? editorImage,
    ProVideoController? videoController,
    required BlurEditorInitConfigs initConfigs,
  }) {
    return BlurEditor._(
      key: key,
      editorImage: videoController != null
          ? null
          : editorImage ??
              EditorImage(
                byteArray: byteArray,
                file: file,
                networkUrl: networkUrl,
                assetPath: assetPath,
              ),
      videoController: videoController,
      initConfigs: initConfigs,
    );
  }

  /// Constructs a `BlurEditor` widget with an video player.
  factory BlurEditor.video(
    ProVideoController videoController, {
    Key? key,
    required BlurEditorInitConfigs initConfigs,
  }) {
    return BlurEditor._(
      key: key,
      videoController: videoController,
      initConfigs: initConfigs,
    );
  }

  @override
  final BlurEditorInitConfigs initConfigs;
  @override
  final EditorImage? editorImage;
  @override
  final ProVideoController? videoController;

  @override
  createState() => BlurEditorState();
}

/// The state class for the `BlurEditor` widget.
class BlurEditorState extends State<BlurEditor>
    with
        ImageEditorConvertedConfigs,
        ImageEditorConvertedCallbacks,
        StandaloneEditorState<BlurEditor, BlurEditorInitConfigs> {
  /// Update the image with the applied blur and the slider value.
  late final StreamController<void> _uiBlurStream;

  late final ValueNotifier<double> _blurFactor =
      ValueNotifier(appliedBlurFactor);

  /// Represents the selected blur state.
  double get blurFactor => _blurFactor.value;

  set blurFactor(double value) {
    _blurFactor.value = value;
  }

  @override
  void initState() {
    super.initState();
    _uiBlurStream = StreamController.broadcast();
    _uiBlurStream.stream.listen((_) => rebuildController.add(null));

    blurEditorCallbacks?.onInit?.call();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      blurEditorCallbacks?.onAfterViewInit?.call();
    });
  }

  @override
  void dispose() {
    _uiBlurStream.close();
    screenshotCtrl.destroy();
    super.dispose();
  }

  @override
  void setState(void Function() fn) {
    rebuildController.add(null);
    super.setState(fn);
  }

  /// Handles the "Done" action, either by applying changes or closing the
  /// editor.
  void done() async {
    doneEditing(
      returnValue: blurFactor,
      editorImage: widget.editorImage,
      blur: blurFactor,
      matrixFilterList: appliedFilters,
      matrixTuneAdjustmentsList:
          appliedTuneAdjustments.map((item) => item.matrix).toList(),
      transform: initialTransformConfigs,
    );
    blurEditorCallbacks?.handleDone();
  }

  /// Set the blur factor and update the UI.
  void setBlurFactor(double value) {
    blurFactor = value;
    _uiBlurStream.add(null);
    blurEditorCallbacks?.handleBlurFactorChange(value);
  }

  /// Handles changes in the blur factor value.
  void _onChanged(double value) {
    setBlurFactor(value);
  }

  /// Handles the end of changes in the blur factor value.
  void _onChangedEnd(double value) {
    blurEditorCallbacks?.handleBlurFactorChangeEnd(value);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      takeScreenshot();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: theme.copyWith(
          tooltipTheme: theme.tooltipTheme.copyWith(preferBelow: true)),
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: blurEditorConfigs.style.uiOverlayStyle,
        child: SafeArea(
          top: blurEditorConfigs.safeArea.top,
          bottom: blurEditorConfigs.safeArea.bottom,
          left: blurEditorConfigs.safeArea.left,
          right: blurEditorConfigs.safeArea.right,
          child: RecordInvisibleWidget(
            controller: screenshotCtrl,
            child: Scaffold(
              backgroundColor: blurEditorConfigs.style.background,
              appBar: _buildAppBar(),
              body: _buildBody(),
              bottomNavigationBar: _buildBottomNavBar(),
            ),
          ),
        ),
      ),
    );
  }

  /// Builds the app bar for the blur editor.
  PreferredSizeWidget? _buildAppBar() {
    if (blurEditorConfigs.widgets.appBar != null) {
      return blurEditorConfigs.widgets.appBar!
          .call(this, rebuildController.stream);
    }

    return BlurEditorAppBar(
      blurEditorConfigs: blurEditorConfigs,
      i18n: i18n.blurEditor,
      close: close,
      done: done,
    );
  }

  /// Builds the main content area of the editor.
  Widget _buildBody() {
    return LayoutBuilder(builder: (context, constraints) {
      editorBodySize = constraints.biggest;
      return Stack(
        alignment: Alignment.center,
        fit: StackFit.expand,
        children: [
          if (initConfigs.convertToUint8List && isVideoEditor)
            _buildBackground(),
          ContentRecorder(
            controller: screenshotCtrl,
            child: Stack(
              alignment: Alignment.center,
              fit: StackFit.expand,
              children: [
                if (!initConfigs.convertToUint8List || !isVideoEditor)
                  _buildBackground(),
                if (blurEditorConfigs.showLayers && layers != null)
                  LayerStack(
                    transformHelper: TransformHelper(
                      mainBodySize:
                          getValidSizeOrDefault(mainBodySize, editorBodySize),
                      mainImageSize:
                          getValidSizeOrDefault(mainImageSize, editorBodySize),
                      transformConfigs: initialTransformConfigs,
                      editorBodySize: editorBodySize,
                    ),
                    overlayColor: blurEditorConfigs.style.background,
                    configs: configs,
                    layers: layers!,
                    clipBehavior: Clip.none,
                  ),
                if (blurEditorConfigs.widgets.bodyItemsRecorded != null)
                  ...blurEditorConfigs.widgets.bodyItemsRecorded!(
                      this, rebuildController.stream),
              ],
            ),
          ),
          if (blurEditorConfigs.widgets.bodyItems != null)
            ...blurEditorConfigs.widgets.bodyItems!(
                this, rebuildController.stream),
        ],
      );
    });
  }

  Widget _buildBackground() {
    return Hero(
      tag: heroTag,
      createRectTween: (begin, end) => RectTween(begin: begin, end: end),
      child: TransformedContentGenerator(
        isVideoPlayer: videoController != null,
        configs: configs,
        transformConfigs: initialTransformConfigs ?? TransformConfigs.empty(),
        child: StreamBuilder(
            stream: _uiBlurStream.stream,
            builder: (context, snapshot) {
              return FilteredWidget(
                width:
                    getValidSizeOrDefault(mainImageSize, editorBodySize).width,
                height:
                    getValidSizeOrDefault(mainImageSize, editorBodySize).height,
                configs: configs,
                image: editorImage,
                videoPlayer: videoController?.videoPlayer,
                filters: appliedFilters,
                tuneAdjustments: appliedTuneAdjustments,
                blurFactor: blurFactor,
              );
            }),
      ),
    );
  }

  /// Builds the bottom navigation bar with blur slider.
  Widget? _buildBottomNavBar() {
    if (blurEditorConfigs.widgets.bottomBar != null) {
      return blurEditorConfigs.widgets.bottomBar!
          .call(this, rebuildController.stream);
    }

    return BlurEditorBottombar(
      blurEditorConfigs: blurEditorConfigs,
      blurFactor: _blurFactor,
      rebuildController: rebuildController,
      blurEditorState: this,
      onChanged: _onChanged,
      onChangedEnd: _onChangedEnd,
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty<BlurEditorInitConfigs>(
        'initConfigs',
        widget.initConfigs,
      ))
      ..add(DiagnosticsProperty<EditorImage?>(
        'editorImage',
        widget.editorImage,
      ))
      ..add(DiagnosticsProperty<ProVideoController?>(
        'videoController',
        widget.videoController,
      ))
      ..add(DoubleProperty(
        'blurFactor',
        blurFactor,
      ))
      ..add(IterableProperty<List<double>>(
        'appliedFilters',
        appliedFilters,
      ))
      ..add(IterableProperty<TuneAdjustmentMatrix>(
        'appliedTuneAdjustments',
        appliedTuneAdjustments,
      ));
  }
}
