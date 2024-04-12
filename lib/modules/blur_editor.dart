import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pro_image_editor/models/editor_configs/pro_image_editor_configs.dart';
import 'package:pro_image_editor/models/filter_state_history.dart';
import 'package:pro_image_editor/models/blur_state_history.dart';
import 'package:pro_image_editor/widgets/transformed_content_generator.dart';
import 'package:screenshot/screenshot.dart';

import '../models/crop_rotate_editor/transform_factors.dart';
import '../models/editor_image.dart';
import '../models/layer.dart';
import '../models/transform_helper.dart';
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
class BlurEditor extends StatefulWidget {
  /// A byte array representing the image data.
  final Uint8List? byteArray;

  /// The file representing the image.
  final File? file;

  /// The asset path of the image.
  final String? assetPath;

  /// The network URL of the image.
  final String? networkUrl;

  /// The theme configuration for the editor.
  final ThemeData theme;

  /// The size of the image to be edited.
  final Size imageSize;

  /// The image editor configs.
  final ProImageEditorConfigs configs;

  /// The transform configurations how the image should be initialized.
  final TransformConfigs? transformConfigs;

  /// A callback function that can be used to update the UI from custom widgets.
  final Function? onUpdateUI;

  /// Determines whether to return the image as a Uint8List when closing the editor.
  ///
  /// If set to `true`, when closing the editor, the editor will return the final image
  /// as a Uint8List, including all applied blur states. If set to `false`, only
  /// the blur states will be returned.
  final bool convertToUint8List;

  /// A list of Layer objects representing image layers.
  final List<Layer>? layers;

  /// The rendered image size with layers.
  /// Required to calculate the correct layer position.
  final Size? imageSizeWithLayers;

  /// The rendered body size with layers.
  /// Required to calculate the correct layer position.
  final Size? bodySizeWithLayers;

  final List<FilterStateHistory> filters;

  final BlurStateHistory currentBlur;

  /// Private constructor for creating a `BlurEditor` widget.
  const BlurEditor._({
    super.key,
    this.byteArray,
    this.file,
    this.assetPath,
    this.networkUrl,
    this.onUpdateUI,
    this.convertToUint8List = false,
    this.transformConfigs,
    this.layers,
    this.imageSizeWithLayers,
    this.bodySizeWithLayers,
    required this.filters,
    required this.currentBlur,
    required this.theme,
    required this.imageSize,
    required this.configs,
  }) : assert(
          byteArray != null ||
              file != null ||
              networkUrl != null ||
              assetPath != null,
          'At least one of bytes, file, networkUrl, or assetPath must not be null.',
        );

  /// Create a BlurEditor widget with an in-memory image represented as a Uint8List.
  ///
  /// This factory method allows you to create a BlurEditor widget that can be used to apply blur and edit an image represented as a Uint8List in memory. The provided parameters allow you to customize the appearance and behavior of the BlurEditor widget.
  ///
  /// Parameters:
  /// - `byteArray`: A Uint8List representing the image data in memory.
  /// - `key`: An optional Key to uniquely identify this widget in the widget tree.
  /// - `theme`: An optional ThemeData object that defines the visual styling of the BlurEditor widget.
  /// - `configs`: The image editor configs.
  /// - `transformConfigs` The transform configurations how the image should be initialized.
  /// - `convertToUint8List`: Determines whether to return the image as a Uint8List when closing the editor.
  ///
  /// Returns:
  /// A BlurEditor widget configured with the provided parameters and the in-memory image data.
  ///
  /// Example Usage:
  /// ```dart
  /// final Uint8List imageBytes = ... // Load your image data here.
  /// final blurEditor = BlurEditor.memory(
  ///   imageBytes,
  ///   theme: ThemeData.light(),
  /// );
  /// ```
  factory BlurEditor.memory(
    Uint8List byteArray, {
    Key? key,
    required ThemeData theme,
    required Size imageSize,
    TransformConfigs? transformConfigs,
    List<Layer>? layers,
    ProImageEditorConfigs configs = const ProImageEditorConfigs(),
    Function? onUpdateUI,
    bool convertToUint8List = false,
    Size? imageSizeWithLayers,
    Size? bodySizeWithLayers,
    List<FilterStateHistory>? filters,
    BlurStateHistory? currentBlur,
  }) {
    return BlurEditor._(
      key: key,
      byteArray: byteArray,
      theme: theme,
      imageSize: imageSize,
      transformConfigs: transformConfigs,
      configs: configs,
      onUpdateUI: onUpdateUI,
      imageSizeWithLayers: imageSizeWithLayers,
      bodySizeWithLayers: bodySizeWithLayers,
      layers: layers,
      filters: filters ?? [],
      convertToUint8List: convertToUint8List,
      currentBlur: currentBlur ?? BlurStateHistory(),
    );
  }

  /// Create a BlurEditor widget with an image loaded from a File.
  ///
  /// This factory method allows you to create a BlurEditor widget that can be used to apply blur and edit an image loaded from a File. The provided parameters allow you to customize the appearance and behavior of the BlurEditor widget.
  ///
  /// Parameters:
  /// - `file`: A File object representing the image file to be loaded.
  /// - `key`: An optional Key to uniquely identify this widget in the widget tree.
  /// - `theme`: An optional ThemeData object that defines the visual styling of the BlurEditor widget.
  /// - `configs`: The image editor configs.
  /// - `transformConfigs` The transform configurations how the image should be initialized.
  /// - `convertToUint8List`: Determines whether to return the image as a Uint8List when closing the editor.
  ///
  /// Returns:
  /// A BlurEditor widget configured with the provided parameters and the image loaded from the File.
  ///
  /// Example Usage:
  /// ```dart
  /// final File imageFile = ... // Provide the image file.
  /// final blurEditor = BlurEditor.file(
  ///   imageFile,
  ///   theme: ThemeData.light(),
  /// );
  /// ```
  factory BlurEditor.file(
    File file, {
    Key? key,
    required ThemeData theme,
    required Size imageSize,
    TransformConfigs? transformConfigs,
    List<Layer>? layers,
    ProImageEditorConfigs configs = const ProImageEditorConfigs(),
    Function? onUpdateUI,
    bool convertToUint8List = false,
    Size? imageSizeWithLayers,
    Size? bodySizeWithLayers,
    List<FilterStateHistory>? filters,
    BlurStateHistory? currentBlur,
  }) {
    return BlurEditor._(
      key: key,
      file: file,
      theme: theme,
      imageSize: imageSize,
      transformConfigs: transformConfigs,
      configs: configs,
      onUpdateUI: onUpdateUI,
      imageSizeWithLayers: imageSizeWithLayers,
      bodySizeWithLayers: bodySizeWithLayers,
      layers: layers,
      filters: filters ?? [],
      convertToUint8List: convertToUint8List,
      currentBlur: currentBlur ?? BlurStateHistory(),
    );
  }

  /// Create a BlurEditor widget with an image loaded from an asset.
  ///
  /// This factory method allows you to create a BlurEditor widget that can be used to apply blur and edit an image loaded from an asset. The provided parameters allow you to customize the appearance and behavior of the BlurEditor widget.
  ///
  /// Parameters:
  /// - `assetPath`: A String representing the asset path of the image to be loaded.
  /// - `key`: An optional Key to uniquely identify this widget in the widget tree.
  /// - `theme`: An optional ThemeData object that defines the visual styling of the BlurEditor widget.
  /// - `configs`: The image editor configs.
  /// - `transformConfigs` The transform configurations how the image should be initialized.
  /// - `convertToUint8List`: Determines whether to return the image as a Uint8List when closing the editor.
  ///
  /// Returns:
  /// A BlurEditor widget configured with the provided parameters and the image loaded from the asset.
  ///
  /// Example Usage:
  /// ```dart
  /// final String assetPath = 'assets/image.png'; // Provide the asset path.
  /// final blurEditor = BlurEditor.asset(
  ///   assetPath,
  ///   theme: ThemeData.light(),
  /// );
  /// ```
  factory BlurEditor.asset(
    String assetPath, {
    Key? key,
    required ThemeData theme,
    required Size imageSize,
    TransformConfigs? transformConfigs,
    List<Layer>? layers,
    ProImageEditorConfigs configs = const ProImageEditorConfigs(),
    Function? onUpdateUI,
    bool convertToUint8List = false,
    Size? imageSizeWithLayers,
    Size? bodySizeWithLayers,
    List<FilterStateHistory>? filters,
    BlurStateHistory? currentBlur,
  }) {
    return BlurEditor._(
      key: key,
      assetPath: assetPath,
      theme: theme,
      imageSize: imageSize,
      transformConfigs: transformConfigs,
      configs: configs,
      onUpdateUI: onUpdateUI,
      imageSizeWithLayers: imageSizeWithLayers,
      bodySizeWithLayers: bodySizeWithLayers,
      layers: layers,
      filters: filters ?? [],
      convertToUint8List: convertToUint8List,
      currentBlur: currentBlur ?? BlurStateHistory(),
    );
  }

  /// Create a BlurEditor widget with an image loaded from a network URL.
  ///
  /// This factory method allows you to create a BlurEditor widget that can be used to apply blur and edit an image loaded from a network URL. The provided parameters allow you to customize the appearance and behavior of the BlurEditor widget.
  ///
  /// Parameters:
  /// - `networkUrl`: A String representing the network URL of the image to be loaded.
  /// - `key`: An optional Key to uniquely identify this widget in the widget tree.
  /// - `theme`: An optional ThemeData object that defines the visual styling of the BlurEditor widget.
  /// - `configs`: The image editor configs.
  /// - `transformConfigs` The transform configurations how the image should be initialized.
  /// - `convertToUint8List`: Determines whether to return the image as a Uint8List when closing the editor.
  ///
  /// Returns:
  /// A BlurEditor widget configured with the provided parameters and the image loaded from the network URL.
  ///
  /// Example Usage:
  /// ```dart
  /// final String imageUrl = 'https://example.com/image.jpg'; // Provide the network URL.
  /// final blurEditor = BlurEditor.network(
  ///   imageUrl,
  ///   theme: ThemeData.light(),
  /// );
  /// ```
  factory BlurEditor.network(
    String networkUrl, {
    Key? key,
    required ThemeData theme,
    required Size imageSize,
    TransformConfigs? transformConfigs,
    List<Layer>? layers,
    ProImageEditorConfigs configs = const ProImageEditorConfigs(),
    Function? onUpdateUI,
    bool convertToUint8List = false,
    Size? imageSizeWithLayers,
    Size? bodySizeWithLayers,
    List<FilterStateHistory>? filters,
    BlurStateHistory? currentBlur,
  }) {
    return BlurEditor._(
      key: key,
      networkUrl: networkUrl,
      theme: theme,
      imageSize: imageSize,
      transformConfigs: transformConfigs,
      configs: configs,
      onUpdateUI: onUpdateUI,
      imageSizeWithLayers: imageSizeWithLayers,
      bodySizeWithLayers: bodySizeWithLayers,
      layers: layers,
      filters: filters ?? [],
      convertToUint8List: convertToUint8List,
      currentBlur: currentBlur ?? BlurStateHistory(),
    );
  }

  /// Create a BlurEditor widget with automatic image source detection.
  ///
  /// This factory method allows you to create a BlurEditor widget with automatic detection of the image source type (Uint8List, File, asset, or network URL). Based on the provided parameters, it selects the appropriate source type and creates the BlurEditor widget accordingly.
  ///
  /// Parameters:
  /// - `key`: An optional Key to uniquely identify this widget in the widget tree.
  /// - `theme`: An optional ThemeData object that defines the visual styling of the BlurEditor widget.
  /// - `byteArray`: An optional Uint8List representing the image data in memory.
  /// - `file`: An optional File object representing the image file to be loaded.
  /// - `assetPath`: An optional String representing the asset path of the image to be loaded.
  /// - `networkUrl`: An optional String representing the network URL of the image to be loaded.
  /// - `convertToUint8List`: Determines whether to return the image as a Uint8List when closing the editor.
  ///
  /// Returns:
  /// A BlurEditor widget configured with the provided parameters and the detected image source.
  ///
  /// Example Usage:
  /// ```dart
  /// // Provide one of the image sources: byteArray, file, assetPath, or networkUrl.
  /// final blurEditor = BlurEditor.autoSource(
  ///   byteArray: imageBytes,
  ///   theme: ThemeData.light(),
  /// );
  /// ```
  factory BlurEditor.autoSource({
    Key? key,
    required ThemeData theme,
    TransformConfigs? transformConfigs,
    List<Layer>? layers,
    ProImageEditorConfigs configs = const ProImageEditorConfigs(),
    required Size imageSize,
    Function? onUpdateUI,
    bool convertToUint8List = false,
    Size? imageSizeWithLayers,
    Size? bodySizeWithLayers,
    required List<FilterStateHistory> filters,
    Uint8List? byteArray,
    File? file,
    String? assetPath,
    String? networkUrl,
    required BlurStateHistory currentBlur,
  }) {
    if (byteArray != null) {
      return BlurEditor.memory(
        byteArray,
        key: key,
        theme: theme,
        imageSize: imageSize,
        transformConfigs: transformConfigs,
        configs: configs,
        onUpdateUI: onUpdateUI,
        imageSizeWithLayers: imageSizeWithLayers,
        bodySizeWithLayers: bodySizeWithLayers,
        layers: layers,
        filters: filters,
        convertToUint8List: convertToUint8List,
        currentBlur: currentBlur,
      );
    } else if (file != null) {
      return BlurEditor.file(
        file,
        key: key,
        theme: theme,
        imageSize: imageSize,
        transformConfigs: transformConfigs,
        configs: configs,
        onUpdateUI: onUpdateUI,
        imageSizeWithLayers: imageSizeWithLayers,
        bodySizeWithLayers: bodySizeWithLayers,
        layers: layers,
        filters: filters,
        convertToUint8List: convertToUint8List,
        currentBlur: currentBlur,
      );
    } else if (networkUrl != null) {
      return BlurEditor.network(
        networkUrl,
        key: key,
        theme: theme,
        imageSize: imageSize,
        transformConfigs: transformConfigs,
        configs: configs,
        onUpdateUI: onUpdateUI,
        imageSizeWithLayers: imageSizeWithLayers,
        bodySizeWithLayers: bodySizeWithLayers,
        layers: layers,
        filters: filters,
        convertToUint8List: convertToUint8List,
        currentBlur: currentBlur,
      );
    } else if (assetPath != null) {
      return BlurEditor.asset(
        assetPath,
        key: key,
        theme: theme,
        imageSize: imageSize,
        transformConfigs: transformConfigs,
        configs: configs,
        onUpdateUI: onUpdateUI,
        imageSizeWithLayers: imageSizeWithLayers,
        bodySizeWithLayers: bodySizeWithLayers,
        layers: layers,
        filters: filters,
        convertToUint8List: convertToUint8List,
        currentBlur: currentBlur,
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
class BlurEditorState extends State<BlurEditor> {
  /// Manages the capturing a screenshot of the image.
  ScreenshotController screenshotController = ScreenshotController();

  /// Represents the selected blur state.
  late BlurStateHistory selectedBlur;

  /// Represents the dimensions of the body.
  Size _bodySize = Size.zero;

  /// Indicates it create a screenshot or not.
  bool _createScreenshot = false;

  @override
  void initState() {
    selectedBlur = widget.currentBlur;
    super.initState();
  }

  /// Closes the editor without applying changes.
  void close() {
    Navigator.pop(context);
  }

  /// Handles the "Done" action, either by applying changes or closing the editor.
  void done() async {
    if (_createScreenshot) return;

    if (widget.convertToUint8List) {
      _createScreenshot = true;
      LoadingDialog loading = LoadingDialog()
        ..show(
          context,
          i18n: widget.configs.i18n,
          theme: widget.theme,
          designMode: widget.configs.designMode,
          message: widget.configs.i18n.blurEditor.applyBlurDialogMsg,
          imageEditorTheme: widget.configs.imageEditorTheme,
        );
      var data = await screenshotController.capture();
      _createScreenshot = false;
      if (mounted) {
        loading.hide(context);
        Navigator.pop(context, data);
      }
    } else {
      BlurStateHistory blur = selectedBlur;
      Navigator.pop(context, blur);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: widget.theme.copyWith(
          tooltipTheme: widget.theme.tooltipTheme.copyWith(preferBelow: true)),
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: widget.configs.imageEditorTheme.uiOverlayStyle,
        child: Scaffold(
          backgroundColor:
              widget.configs.imageEditorTheme.blurEditor.background,
          appBar: _buildAppBar(),
          body: _buildBody(),
          bottomNavigationBar: _buildBottomNavBar(),
        ),
      ),
    );
  }

  /// Builds the app bar for the blur editor.
  PreferredSizeWidget _buildAppBar() {
    return widget.configs.customWidgets.appBarBlurEditor ??
        AppBar(
          automaticallyImplyLeading: false,
          backgroundColor:
              widget.configs.imageEditorTheme.blurEditor.appBarBackgroundColor,
          foregroundColor:
              widget.configs.imageEditorTheme.blurEditor.appBarForegroundColor,
          actions: [
            IconButton(
              tooltip: widget.configs.i18n.blurEditor.back,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              icon: Icon(widget.configs.icons.backButton),
              onPressed: close,
            ),
            const Spacer(),
            IconButton(
              tooltip: widget.configs.i18n.blurEditor.done,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              icon: Icon(widget.configs.icons.applyChanges),
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
                tag: widget.configs.heroTag,
                createRectTween: (begin, end) =>
                    RectTween(begin: begin, end: end),
                child: TransformedContentGenerator(
                  configs: widget.transformConfigs ?? TransformConfigs.empty(),
                  child: ImageWithMultipleFilters(
                    width: widget.imageSize.width,
                    height: widget.imageSize.height,
                    designMode: widget.configs.designMode,
                    image: EditorImage(
                      assetPath: widget.assetPath,
                      byteArray: widget.byteArray,
                      file: widget.file,
                      networkUrl: widget.networkUrl,
                    ),
                    filters: widget.filters,
                    blur: selectedBlur,
                  ),
                ),
              ),
              if (widget.configs.blurEditorConfigs.showLayers &&
                  widget.layers != null)
                LayerStack(
                  transformHelper: TransformHelper(
                    mainBodySize: widget.bodySizeWithLayers ?? Size.zero,
                    mainImageSize: widget.imageSizeWithLayers ?? Size.zero,
                    editorBodySize: _bodySize,
                  ),
                  configs: widget.configs,
                  layers: widget.layers!,
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
          max: widget.configs.blurEditorConfigs.maxBlur,
          divisions: 100,
          value: selectedBlur.blur,
          onChanged: (value) {
            selectedBlur = BlurStateHistory(blur: value);
            setState(() {});
            widget.onUpdateUI?.call();
          },
        ),
      ),
    );
  }
}
