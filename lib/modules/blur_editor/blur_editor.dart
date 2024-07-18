// Dart imports:
import 'dart:async';
import 'dart:io';

// Flutter imports:
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Project imports:
import 'package:pro_image_editor/mixins/converted_callbacks.dart';
import 'package:pro_image_editor/utils/content_recorder.dart/utils/record_invisible_widget.dart';
import '../../mixins/converted_configs.dart';
import '../../mixins/standalone_editor.dart';
import '../../models/crop_rotate_editor/transform_factors.dart';
import '../../models/editor_image.dart';
import '../../models/init_configs/blur_editor_init_configs.dart';
import '../../models/transform_helper.dart';
import '../../utils/content_recorder.dart/content_recorder.dart';
import '../../widgets/layer_stack.dart';
import '../../widgets/transform/transformed_content_generator.dart';
import '../filter_editor/widgets/filtered_image.dart';

/// The `BlurEditor` widget allows users to apply blur to images.
///
/// You can create a `BlurEditor` using one of the factory methods provided:
/// - `BlurEditor.file`: Loads an image from a file.
/// - `BlurEditor.asset`: Loads an image from an asset.
/// - `BlurEditor.network`: Loads an image from a network URL.
/// - `BlurEditor.memory`: Loads an image from memory as a `Uint8List`.
/// - `BlurEditor.autoSource`: Automatically selects the source based on provided parameters.
class BlurEditor extends StatefulWidget
    with StandaloneEditor<BlurEditorInitConfigs> {
  @override
  final BlurEditorInitConfigs initConfigs;
  @override
  final EditorImage editorImage;

  /// Constructs a `BlurEditor` widget.
  ///
  /// The [key] parameter is used to provide a key for the widget.
  /// The [editorImage] parameter specifies the image to be edited.
  /// The [initConfigs] parameter specifies the initialization configurations for the editor.
  const BlurEditor._({
    super.key,
    required this.editorImage,
    required this.initConfigs,
  });

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
    File file, {
    Key? key,
    required BlurEditorInitConfigs initConfigs,
  }) {
    return BlurEditor._(
      key: key,
      editorImage: EditorImage(file: file),
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

  /// Constructs a `BlurEditor` widget with an image loaded automatically based on the provided source.
  ///
  /// Either [byteArray], [file], [networkUrl], or [assetPath] must be provided.
  factory BlurEditor.autoSource({
    Key? key,
    required BlurEditorInitConfigs initConfigs,
    Uint8List? byteArray,
    File? file,
    String? assetPath,
    String? networkUrl,
  }) {
    if (byteArray != null) {
      return BlurEditor.memory(
        byteArray,
        key: key,
        initConfigs: initConfigs,
      );
    } else if (file != null) {
      return BlurEditor.file(
        file,
        key: key,
        initConfigs: initConfigs,
      );
    } else if (networkUrl != null) {
      return BlurEditor.network(
        networkUrl,
        key: key,
        initConfigs: initConfigs,
      );
    } else if (assetPath != null) {
      return BlurEditor.asset(
        assetPath,
        key: key,
        initConfigs: initConfigs,
      );
    } else {
      throw ArgumentError(
          "Either 'byteArray', 'file', 'networkUrl' or 'assetPath' must be provided.");
    }
  }

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
  late final StreamController _uiBlurStream;

  /// Represents the selected blur state.
  late double blurFactor;

  @override
  void initState() {
    blurFactor = appliedBlurFactor;
    _uiBlurStream = StreamController.broadcast();
    _uiBlurStream.stream.listen((_) => rebuildController.add(null));

    blurEditorCallbacks?.onInit?.call();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      blurEditorCallbacks?.onAfterViewInit?.call();
    });
    super.initState();
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

  /// Handles the "Done" action, either by applying changes or closing the editor.
  void done() async {
    doneEditing(
      returnValue: blurFactor,
      editorImage: widget.editorImage,
    );
    blurEditorCallbacks?.handleDone();
  }

  /// Handles changes in the blur factor value.
  void _onChanged(double value) {
    blurFactor = value;
    _uiBlurStream.add(null);
    blurEditorCallbacks?.handleBlurFactorChange(value);
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
        value: imageEditorTheme.uiOverlayStyle,
        child: RecordInvisibleWidget(
          controller: screenshotCtrl,
          child: Scaffold(
            backgroundColor: imageEditorTheme.blurEditor.background,
            appBar: _buildAppBar(),
            body: _buildBody(),
            bottomNavigationBar: _buildBottomNavBar(),
          ),
        ),
      ),
    );
  }

  /// Builds the app bar for the blur editor.
  PreferredSizeWidget? _buildAppBar() {
    if (customWidgets.blurEditor.appBar != null) {
      return customWidgets.blurEditor.appBar!
          .call(this, rebuildController.stream);
    }

    return AppBar(
      automaticallyImplyLeading: false,
      backgroundColor: imageEditorTheme.blurEditor.appBarBackgroundColor,
      foregroundColor: imageEditorTheme.blurEditor.appBarForegroundColor,
      actions: [
        IconButton(
          tooltip: i18n.blurEditor.back,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          icon: Icon(icons.backButton),
          onPressed: close,
        ),
        const Spacer(),
        IconButton(
          tooltip: i18n.blurEditor.done,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          icon: Icon(icons.applyChanges),
          iconSize: 28,
          onPressed: done,
        ),
      ],
    );
  }

  /// Builds the main content area of the editor.
  Widget _buildBody() {
    return LayoutBuilder(builder: (context, constraints) {
      editorBodySize = constraints.biggest;
      return ContentRecorder(
        controller: screenshotCtrl,
        child: Stack(
          alignment: Alignment.center,
          fit: StackFit.expand,
          children: [
            Hero(
              tag: heroTag,
              createRectTween: (begin, end) =>
                  RectTween(begin: begin, end: end),
              child: TransformedContentGenerator(
                configs: configs,
                transformConfigs: transformConfigs ?? TransformConfigs.empty(),
                child: StreamBuilder(
                    stream: _uiBlurStream.stream,
                    builder: (context, snapshot) {
                      return FilteredImage(
                        width:
                            getMinimumSize(mainImageSize, editorBodySize).width,
                        height: getMinimumSize(mainImageSize, editorBodySize)
                            .height,
                        configs: configs,
                        image: editorImage,
                        filters: appliedFilters,
                        blurFactor: blurFactor,
                      );
                    }),
              ),
            ),
            if (blurEditorConfigs.showLayers && layers != null)
              LayerStack(
                transformHelper: TransformHelper(
                  mainBodySize: getMinimumSize(mainBodySize, editorBodySize),
                  mainImageSize: getMinimumSize(mainImageSize, editorBodySize),
                  transformConfigs: transformConfigs,
                  editorBodySize: editorBodySize,
                ),
                configs: configs,
                layers: layers!,
                clipBehavior: Clip.none,
              ),
            if (customWidgets.blurEditor.bodyItems != null)
              ...customWidgets.blurEditor.bodyItems!(
                  this, rebuildController.stream),
          ],
        ),
      );
    });
  }

  /// Builds the bottom navigation bar with blur slider.
  Widget? _buildBottomNavBar() {
    if (customWidgets.blurEditor.bottomBar != null) {
      return customWidgets.blurEditor.bottomBar!
          .call(this, rebuildController.stream);
    }

    return SafeArea(
      child: Container(
        color: imageEditorTheme.blurEditor.background,
        height: 100,
        child: Align(
          alignment: Alignment.center,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: RepaintBoundary(
              child: StreamBuilder(
                  stream: _uiBlurStream.stream,
                  builder: (context, snapshot) {
                    return customWidgets.blurEditor.slider?.call(
                          this,
                          rebuildController.stream,
                          blurFactor,
                          _onChanged,
                          _onChangedEnd,
                        ) ??
                        Slider(
                          min: 0,
                          max: blurEditorConfigs.maxBlur,
                          divisions: 100,
                          value: blurFactor,
                          onChanged: _onChanged,
                          onChangeEnd: _onChangedEnd,
                        );
                  }),
            ),
          ),
        ),
      ),
    );
  }
}
