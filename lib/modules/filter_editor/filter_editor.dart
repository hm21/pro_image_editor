import 'dart:io';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pro_image_editor/models/filter_state_history.dart';
import 'package:pro_image_editor/models/blur_state_history.dart';
import 'package:pro_image_editor/models/transform_helper.dart';
import 'package:pro_image_editor/pro_image_editor.dart';
import 'package:pro_image_editor/widgets/transformed_content_generator.dart';
import 'package:screenshot/screenshot.dart';

import '../../models/crop_rotate_editor/transform_factors.dart';
import '../../models/editor_image.dart';
import '../../models/layer.dart';
import '../../widgets/layer_stack.dart';
import '../../widgets/loading_dialog.dart';
import 'widgets/filter_editor_item_list.dart';
import 'widgets/image_with_filter.dart';

/// The `FilterEditor` widget allows users to apply filters to images.
///
/// You can create a `FilterEditor` using one of the factory methods provided:
/// - `FilterEditor.file`: Loads an image from a file.
/// - `FilterEditor.asset`: Loads an image from an asset.
/// - `FilterEditor.network`: Loads an image from a network URL.
/// - `FilterEditor.memory`: Loads an image from memory as a `Uint8List`.
/// - `FilterEditor.autoSource`: Automatically selects the source based on provided parameters.
class FilterEditor extends StatefulWidget {
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

  /// The image editor configs.
  final ProImageEditorConfigs configs;

  /// The transform configurations how the image should be initialized.
  final TransformConfigs? transformConfigs;

  /// A callback function that can be used to update the UI from custom widgets.
  final Function? onUpdateUI;

  /// Determines whether to return the image as a Uint8List when closing the editor.
  ///
  /// If set to `true`, when closing the editor, the editor will return the final image
  /// as a Uint8List, including all applied filter states. If set to `false`, only
  /// the filter states will be returned.
  final bool convertToUint8List;

  /// A list of Layer objects representing image layers.
  final List<Layer>? layers;

  /// The rendered image size with layers.
  /// Required to calculate the correct layer position.
  final Size? imageSizeWithLayers;

  /// The rendered body size with layers.
  /// Required to calculate the correct layer position.
  final Size? bodySizeWithLayers;

  final List<FilterStateHistory>? activeFilters;

  final BlurStateHistory? blur;

  /// Private constructor for creating a `FilterEditor` widget.
  const FilterEditor._({
    super.key,
    this.byteArray,
    this.file,
    this.assetPath,
    this.networkUrl,
    this.onUpdateUI,
    this.convertToUint8List = false,
    this.activeFilters,
    this.blur,
    this.transformConfigs,
    this.imageSizeWithLayers,
    this.bodySizeWithLayers,
    this.layers,
    required this.theme,
    required this.configs,
  }) : assert(
          byteArray != null || file != null || networkUrl != null || assetPath != null,
          'At least one of bytes, file, networkUrl, or assetPath must not be null.',
        );

  /// Create a FilterEditor widget with an in-memory image represented as a Uint8List.
  ///
  /// This factory method allows you to create a FilterEditor widget that can be used to apply various image filters and edit an image represented as a Uint8List in memory. The provided parameters allow you to customize the appearance and behavior of the FilterEditor widget.
  ///
  /// Parameters:
  /// - `byteArray`: A Uint8List representing the image data in memory.
  /// - `key`: An optional Key to uniquely identify this widget in the widget tree.
  /// - `theme`: An optional ThemeData object that defines the visual styling of the FilterEditor widget.
  /// - `configs`: The image editor configs.
  /// - `transformConfigs` The transform configurations how the image should be initialized.
  /// - `convertToUint8List`: Determines whether to return the image as a Uint8List when closing the editor.
  ///
  /// Returns:
  /// A FilterEditor widget configured with the provided parameters and the in-memory image data.
  ///
  /// Example Usage:
  /// ```dart
  /// final Uint8List imageBytes = ... // Load your image data here.
  /// final filterEditor = FilterEditor.memory(
  ///   imageBytes,
  ///   theme: ThemeData.light(),
  /// );
  /// ```
  factory FilterEditor.memory(
    Uint8List byteArray, {
    Key? key,
    required ThemeData theme,
    TransformConfigs? transformConfigs,
    ProImageEditorConfigs configs = const ProImageEditorConfigs(),
    Function? onUpdateUI,
    bool convertToUint8List = false,
    Size? imageSizeWithLayers,
    Size? bodySizeWithLayers,
    List<Layer>? layers,
    List<FilterStateHistory>? activeFilters,
    BlurStateHistory? blur,
  }) {
    return FilterEditor._(
      key: key,
      byteArray: byteArray,
      theme: theme,
      transformConfigs: transformConfigs,
      configs: configs,
      onUpdateUI: onUpdateUI,
      imageSizeWithLayers: imageSizeWithLayers,
      bodySizeWithLayers: bodySizeWithLayers,
      layers: layers,
      activeFilters: activeFilters,
      convertToUint8List: convertToUint8List,
      blur: blur,
    );
  }

  /// Create a FilterEditor widget with an image loaded from a File.
  ///
  /// This factory method allows you to create a FilterEditor widget that can be used to apply various image filters and edit an image loaded from a File. The provided parameters allow you to customize the appearance and behavior of the FilterEditor widget.
  ///
  /// Parameters:
  /// - `file`: A File object representing the image file to be loaded.
  /// - `key`: An optional Key to uniquely identify this widget in the widget tree.
  /// - `theme`: An optional ThemeData object that defines the visual styling of the FilterEditor widget.
  /// - `configs`: The image editor configs.
  /// - `transformConfigs` The transform configurations how the image should be initialized.
  /// - `convertToUint8List`: Determines whether to return the image as a Uint8List when closing the editor.
  ///
  /// Returns:
  /// A FilterEditor widget configured with the provided parameters and the image loaded from the File.
  ///
  /// Example Usage:
  /// ```dart
  /// final File imageFile = ... // Provide the image file.
  /// final filterEditor = FilterEditor.file(
  ///   imageFile,
  ///   theme: ThemeData.light(),
  /// );
  /// ```
  factory FilterEditor.file(
    File file, {
    Key? key,
    required ThemeData theme,
    TransformConfigs? transformConfigs,
    ProImageEditorConfigs configs = const ProImageEditorConfigs(),
    Function? onUpdateUI,
    bool convertToUint8List = false,
    Size? imageSizeWithLayers,
    Size? bodySizeWithLayers,
    List<Layer>? layers,
    List<FilterStateHistory>? activeFilters,
    BlurStateHistory? blur,
  }) {
    return FilterEditor._(
      key: key,
      file: file,
      theme: theme,
      transformConfigs: transformConfigs,
      configs: configs,
      onUpdateUI: onUpdateUI,
      imageSizeWithLayers: imageSizeWithLayers,
      bodySizeWithLayers: bodySizeWithLayers,
      layers: layers,
      activeFilters: activeFilters,
      convertToUint8List: convertToUint8List,
      blur: blur,
    );
  }

  /// Create a FilterEditor widget with an image loaded from an asset.
  ///
  /// This factory method allows you to create a FilterEditor widget that can be used to apply various image filters and edit an image loaded from an asset. The provided parameters allow you to customize the appearance and behavior of the FilterEditor widget.
  ///
  /// Parameters:
  /// - `assetPath`: A String representing the asset path of the image to be loaded.
  /// - `key`: An optional Key to uniquely identify this widget in the widget tree.
  /// - `theme`: An optional ThemeData object that defines the visual styling of the FilterEditor widget.
  /// - `configs`: The image editor configs.
  /// - `transformConfigs` The transform configurations how the image should be initialized.
  /// - `convertToUint8List`: Determines whether to return the image as a Uint8List when closing the editor.
  ///
  /// Returns:
  /// A FilterEditor widget configured with the provided parameters and the image loaded from the asset.
  ///
  /// Example Usage:
  /// ```dart
  /// final String assetPath = 'assets/image.png'; // Provide the asset path.
  /// final filterEditor = FilterEditor.asset(
  ///   assetPath,
  ///   theme: ThemeData.light(),
  /// );
  /// ```
  factory FilterEditor.asset(
    String assetPath, {
    Key? key,
    required ThemeData theme,
    TransformConfigs? transformConfigs,
    ProImageEditorConfigs configs = const ProImageEditorConfigs(),
    Function? onUpdateUI,
    bool convertToUint8List = false,
    Size? imageSizeWithLayers,
    Size? bodySizeWithLayers,
    List<Layer>? layers,
    List<FilterStateHistory>? activeFilters,
    BlurStateHistory? blur,
  }) {
    return FilterEditor._(
      key: key,
      assetPath: assetPath,
      theme: theme,
      transformConfigs: transformConfigs,
      configs: configs,
      onUpdateUI: onUpdateUI,
      imageSizeWithLayers: imageSizeWithLayers,
      bodySizeWithLayers: bodySizeWithLayers,
      layers: layers,
      activeFilters: activeFilters,
      convertToUint8List: convertToUint8List,
      blur: blur,
    );
  }

  /// Create a FilterEditor widget with an image loaded from a network URL.
  ///
  /// This factory method allows you to create a FilterEditor widget that can be used to apply various image filters and edit an image loaded from a network URL. The provided parameters allow you to customize the appearance and behavior of the FilterEditor widget.
  ///
  /// Parameters:
  /// - `networkUrl`: A String representing the network URL of the image to be loaded.
  /// - `key`: An optional Key to uniquely identify this widget in the widget tree.
  /// - `theme`: An optional ThemeData object that defines the visual styling of the FilterEditor widget.
  /// - `configs`: The image editor configs.
  /// - `transformConfigs` The transform configurations how the image should be initialized.
  /// - `convertToUint8List`: Determines whether to return the image as a Uint8List when closing the editor.
  ///
  /// Returns:
  /// A FilterEditor widget configured with the provided parameters and the image loaded from the network URL.
  ///
  /// Example Usage:
  /// ```dart
  /// final String imageUrl = 'https://example.com/image.jpg'; // Provide the network URL.
  /// final filterEditor = FilterEditor.network(
  ///   imageUrl,
  ///   theme: ThemeData.light(),
  /// );
  /// ```
  factory FilterEditor.network(
    String networkUrl, {
    Key? key,
    required ThemeData theme,
    TransformConfigs? transformConfigs,
    ProImageEditorConfigs configs = const ProImageEditorConfigs(),
    Function? onUpdateUI,
    bool convertToUint8List = false,
    Size? imageSizeWithLayers,
    Size? bodySizeWithLayers,
    List<Layer>? layers,
    List<FilterStateHistory>? activeFilters,
    BlurStateHistory? blur,
  }) {
    return FilterEditor._(
      key: key,
      networkUrl: networkUrl,
      theme: theme,
      transformConfigs: transformConfigs,
      configs: configs,
      onUpdateUI: onUpdateUI,
      imageSizeWithLayers: imageSizeWithLayers,
      bodySizeWithLayers: bodySizeWithLayers,
      layers: layers,
      activeFilters: activeFilters,
      blur: blur,
      convertToUint8List: convertToUint8List,
    );
  }

  /// Create a FilterEditor widget with automatic image source detection.
  ///
  /// This factory method allows you to create a FilterEditor widget with automatic detection of the image source type (Uint8List, File, asset, or network URL). Based on the provided parameters, it selects the appropriate source type and creates the FilterEditor widget accordingly.
  ///
  /// Parameters:
  /// - `key`: An optional Key to uniquely identify this widget in the widget tree.
  /// - `theme`: An optional ThemeData object that defines the visual styling of the FilterEditor widget.
  /// - `byteArray`: An optional Uint8List representing the image data in memory.
  /// - `file`: An optional File object representing the image file to be loaded.
  /// - `assetPath`: An optional String representing the asset path of the image to be loaded.
  /// - `networkUrl`: An optional String representing the network URL of the image to be loaded.
  /// - `convertToUint8List`: Determines whether to return the image as a Uint8List when closing the editor.
  ///
  /// Returns:
  /// A FilterEditor widget configured with the provided parameters and the detected image source.
  ///
  /// Example Usage:
  /// ```dart
  /// // Provide one of the image sources: byteArray, file, assetPath, or networkUrl.
  /// final filterEditor = FilterEditor.autoSource(
  ///   byteArray: imageBytes,
  ///   theme: ThemeData.light(),
  /// );
  /// ```
  factory FilterEditor.autoSource({
    Key? key,
    required ThemeData theme,
    TransformConfigs? transformConfigs,
    ProImageEditorConfigs configs = const ProImageEditorConfigs(),
    Function? onUpdateUI,
    bool convertToUint8List = false,
    Size? imageSizeWithLayers,
    Size? bodySizeWithLayers,
    List<Layer>? layers,
    List<FilterStateHistory>? activeFilters,
    BlurStateHistory? blur,
    Uint8List? byteArray,
    File? file,
    String? assetPath,
    String? networkUrl,
  }) {
    if (byteArray != null) {
      return FilterEditor.memory(
        byteArray,
        key: key,
        theme: theme,
        transformConfigs: transformConfigs,
        configs: configs,
        onUpdateUI: onUpdateUI,
        imageSizeWithLayers: imageSizeWithLayers,
        bodySizeWithLayers: bodySizeWithLayers,
        layers: layers,
        activeFilters: activeFilters,
        blur: blur,
        convertToUint8List: convertToUint8List,
      );
    } else if (file != null) {
      return FilterEditor.file(
        file,
        key: key,
        theme: theme,
        transformConfigs: transformConfigs,
        configs: configs,
        onUpdateUI: onUpdateUI,
        imageSizeWithLayers: imageSizeWithLayers,
        bodySizeWithLayers: bodySizeWithLayers,
        layers: layers,
        activeFilters: activeFilters,
        blur: blur,
        convertToUint8List: convertToUint8List,
      );
    } else if (networkUrl != null) {
      return FilterEditor.network(
        networkUrl,
        key: key,
        theme: theme,
        transformConfigs: transformConfigs,
        configs: configs,
        onUpdateUI: onUpdateUI,
        imageSizeWithLayers: imageSizeWithLayers,
        bodySizeWithLayers: bodySizeWithLayers,
        layers: layers,
        activeFilters: activeFilters,
        blur: blur,
        convertToUint8List: convertToUint8List,
      );
    } else if (assetPath != null) {
      return FilterEditor.asset(
        assetPath,
        key: key,
        theme: theme,
        transformConfigs: transformConfigs,
        configs: configs,
        onUpdateUI: onUpdateUI,
        imageSizeWithLayers: imageSizeWithLayers,
        bodySizeWithLayers: bodySizeWithLayers,
        layers: layers,
        activeFilters: activeFilters,
        blur: blur,
        convertToUint8List: convertToUint8List,
      );
    } else {
      throw ArgumentError("Either 'byteArray', 'file', 'networkUrl' or 'assetPath' must be provided.");
    }
  }

  @override
  createState() => FilterEditorState();
}

/// The state class for the `FilterEditor` widget.
class FilterEditorState extends State<FilterEditor> {
  /// Manages the capturing a screenshot of the image.
  ScreenshotController screenshotController = ScreenshotController();

  /// The selected filter.
  ColorFilterGenerator selectedFilter = PresetFilters.none;

  /// Represents the dimensions of the body.
  Size _bodySize = Size.zero;

  /// The opacity of the selected filter.
  double filterOpacity = 1;

  /// Indicates it create a screenshot or not.
  bool _createScreenshot = false;

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
          message: widget.configs.i18n.filterEditor.applyFilterDialogMsg,
          imageEditorTheme: widget.configs.imageEditorTheme,
        );
      var data = await screenshotController.capture();
      _createScreenshot = false;
      if (mounted) {
        loading.hide(context);
        Navigator.pop(context, data);
      }
    } else {
      FilterStateHistory filter = FilterStateHistory(
        filter: selectedFilter,
        opacity: filterOpacity,
      );
      Navigator.pop(context, filter);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: widget.theme.copyWith(tooltipTheme: widget.theme.tooltipTheme.copyWith(preferBelow: true)),
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: widget.configs.imageEditorTheme.uiOverlayStyle,
        child: Scaffold(
          backgroundColor: widget.configs.imageEditorTheme.filterEditor.background,
          appBar: _buildAppBar(),
          body: _buildBody(),
          bottomNavigationBar: _buildBottomNavBar(),
        ),
      ),
    );
  }

  /// Builds the app bar for the filter editor.
  PreferredSizeWidget _buildAppBar() {
    return widget.configs.customWidgets.appBarFilterEditor ??
        AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: widget.configs.imageEditorTheme.filterEditor.appBarBackgroundColor,
          foregroundColor: widget.configs.imageEditorTheme.filterEditor.appBarForegroundColor,
          actions: [
            IconButton(
              tooltip: widget.configs.i18n.filterEditor.back,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              icon: Icon(widget.configs.icons.backButton),
              onPressed: close,
            ),
            const Spacer(),
            IconButton(
              tooltip: widget.configs.i18n.filterEditor.done,
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
            children: [
              Hero(
                tag: widget.configs.heroTag,
                createRectTween: (begin, end) => RectTween(begin: begin, end: end),
                child: TransformedContentGenerator(
                  configs: widget.transformConfigs ?? TransformConfigs.empty(),
                  child: ImageWithFilter(
                    image: EditorImage(
                      file: widget.file,
                      byteArray: widget.byteArray,
                      networkUrl: widget.networkUrl,
                      assetPath: widget.assetPath,
                    ),
                    activeFilters: widget.activeFilters,
                    designMode: widget.configs.designMode,
                    filter: selectedFilter,
                    blur: widget.blur,
                    fit: BoxFit.contain,
                    opacity: filterOpacity,
                  ),
                ),
              ),
              if (widget.configs.filterEditorConfigs.showLayers && widget.layers != null)
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

  /// Builds the bottom navigation bar with filter options.
  Widget _buildBottomNavBar() {
    return SafeArea(
      child: SizedBox(
        height: 160,
        child: Column(
          children: [
            SizedBox(
              height: 40,
              child: selectedFilter == PresetFilters.none
                  ? null
                  : Slider(
                      min: 0,
                      max: 1,
                      divisions: 100,
                      value: filterOpacity,
                      onChanged: (value) {
                        filterOpacity = value;
                        setState(() {});
                        widget.onUpdateUI?.call();
                      },
                    ),
            ),
            FilterEditorItemList(
              byteArray: widget.byteArray,
              file: widget.file,
              assetPath: widget.assetPath,
              networkUrl: widget.networkUrl,
              activeFilters: widget.activeFilters,
              blur: widget.blur,
              configs: widget.configs,
              transformConfigs: widget.transformConfigs,
              selectedFilter: selectedFilter,
              onSelectFilter: (filter) {
                selectedFilter = filter;
                setState(() {});
                widget.onUpdateUI?.call();
              },
            ),
          ],
        ),
      ),
    );
  }
}
