import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pro_image_editor/widgets/transformed_content_generator.dart';
import 'package:screenshot/screenshot.dart';

import '../models/crop_rotate_editor/transform_factors.dart';
import '../models/editor_image.dart';
import '../models/init_configs/blur_editor_init_configs.dart';
import '../models/transform_helper.dart';
import '../mixins/converted_configs.dart';
import '../mixins/standalone_editor.dart';
import '../widgets/layer_stack.dart';
import '../widgets/loading_dialog.dart';
import 'filter_editor/widgets/image_with_multiple_filters.dart';

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
        StandaloneEditorState<BlurEditor, BlurEditorInitConfigs> {
  /// Manages the capturing a screenshot of the image.
  ScreenshotController screenshotController = ScreenshotController();

  /// Represents the selected blur state.
  late double selectedBlur;

  /// Represents the dimensions of the body.
  Size _bodySize = Size.zero;

  /// Indicates it create a screenshot or not.
  bool _createScreenshot = false;

  @override
  void initState() {
    selectedBlur = appliedBlurFactor;
    super.initState();
  }

  /// Closes the editor without applying changes.
  void close() {
    Navigator.pop(context);
  }

  /// Handles the "Done" action, either by applying changes or closing the editor.
  void done() async {
    if (_createScreenshot) return;

    if (initConfigs.convertToUint8List) {
      _createScreenshot = true;
      LoadingDialog loading = LoadingDialog()
        ..show(
          context,
          i18n: i18n,
          theme: theme,
          designMode: designMode,
          message: i18n.blurEditor.applyBlurDialogMsg,
          imageEditorTheme: imageEditorTheme,
        );
      var data = await screenshotController.capture();
      _createScreenshot = false;
      if (mounted) {
        loading.hide(context);
        Navigator.pop(context, data);
      }
    } else {
      Navigator.pop(context, selectedBlur);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: theme.copyWith(
          tooltipTheme: theme.tooltipTheme.copyWith(preferBelow: true)),
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: imageEditorTheme.uiOverlayStyle,
        child: Scaffold(
          backgroundColor: imageEditorTheme.blurEditor.background,
          appBar: _buildAppBar(),
          body: _buildBody(),
          bottomNavigationBar: _buildBottomNavBar(),
        ),
      ),
    );
  }

  /// Builds the app bar for the blur editor.
  PreferredSizeWidget _buildAppBar() {
    return customWidgets.appBarBlurEditor ??
        AppBar(
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
      _bodySize = constraints.biggest;
      return Center(
        child: Screenshot(
          controller: screenshotController,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Hero(
                tag: heroTag,
                createRectTween: (begin, end) =>
                    RectTween(begin: begin, end: end),
                child: TransformedContentGenerator(
                  configs: transformConfigs ?? TransformConfigs.empty(),
                  child: ImageWithMultipleFilters(
                    width: initConfigs.imageSize.width,
                    height: initConfigs.imageSize.height,
                    designMode: designMode,
                    image: editorImage,
                    filters: appliedFilters,
                    blurFactor: selectedBlur,
                  ),
                ),
              ),
              if (blurEditorConfigs.showLayers && layers != null)
                LayerStack(
                  transformHelper: TransformHelper(
                    mainBodySize: bodySizeWithLayers,
                    mainImageSize: imageSizeWithLayers,
                    editorBodySize: _bodySize,
                  ),
                  configs: configs,
                  layers: layers!,
                  clipBehavior: Clip.none,
                ),
            ],
          ),
        ),
      );
    });
  }

  /// Builds the bottom navigation bar with blur slider.
  Widget _buildBottomNavBar() {
    return SafeArea(
      child: SizedBox(
        height: 100,
        child: Slider(
          min: 0,
          max: blurEditorConfigs.maxBlur,
          divisions: 100,
          value: selectedBlur,
          onChanged: (value) {
            selectedBlur = value;
            setState(() {});
            onUpdateUI?.call();
          },
        ),
      ),
    );
  }
}
