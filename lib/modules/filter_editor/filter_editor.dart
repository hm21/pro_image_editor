import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pro_image_editor/models/transform_helper.dart';
import 'package:pro_image_editor/pro_image_editor.dart';
import 'package:pro_image_editor/widgets/transformed_content_generator.dart';
import 'package:screenshot/screenshot.dart';

import '../../models/crop_rotate_editor/transform_factors.dart';
import '../../models/editor_image.dart';
import '../../models/history/filter_state_history.dart';
import '../../mixins/converted_configs.dart';
import '../../mixins/standalone_editor.dart';
import '../../widgets/layer_stack.dart';
import '../../widgets/loading_dialog.dart';
import 'widgets/filter_editor_item_list.dart';
import 'widgets/image_with_filter.dart';

/// The `FilterEditor` widget allows users to editing images with painting tools.
///
/// You can create a `FilterEditor` using one of the factory methods provided:
/// - `FilterEditor.file`: Loads an image from a file.
/// - `FilterEditor.asset`: Loads an image from an asset.
/// - `FilterEditor.network`: Loads an image from a network URL.
/// - `FilterEditor.memory`: Loads an image from memory as a `Uint8List`.
/// - `FilterEditor.autoSource`: Automatically selects the source based on provided parameters.
class FilterEditor extends StatefulWidget
    with StandaloneEditor<FilterEditorInitConfigs> {
  @override
  final FilterEditorInitConfigs initConfigs;
  @override
  final EditorImage editorImage;

  /// Constructs a `FilterEditor` widget.
  ///
  /// The [key] parameter is used to provide a key for the widget.
  /// The [editorImage] parameter specifies the image to be edited.
  /// The [initConfigs] parameter specifies the initialization configurations for the editor.
  const FilterEditor._({
    super.key,
    required this.editorImage,
    required this.initConfigs,
  });

  /// Constructs a `FilterEditor` widget with image data loaded from memory.
  factory FilterEditor.memory(
    Uint8List byteArray, {
    Key? key,
    required FilterEditorInitConfigs initConfigs,
  }) {
    return FilterEditor._(
      key: key,
      editorImage: EditorImage(byteArray: byteArray),
      initConfigs: initConfigs,
    );
  }

  /// Constructs a `FilterEditor` widget with an image loaded from a file.
  factory FilterEditor.file(
    File file, {
    Key? key,
    required FilterEditorInitConfigs initConfigs,
  }) {
    return FilterEditor._(
      key: key,
      editorImage: EditorImage(file: file),
      initConfigs: initConfigs,
    );
  }

  /// Constructs a `FilterEditor` widget with an image loaded from an asset.
  factory FilterEditor.asset(
    String assetPath, {
    Key? key,
    required FilterEditorInitConfigs initConfigs,
  }) {
    return FilterEditor._(
      key: key,
      editorImage: EditorImage(assetPath: assetPath),
      initConfigs: initConfigs,
    );
  }

  /// Constructs a `FilterEditor` widget with an image loaded from a network URL.
  factory FilterEditor.network(
    String networkUrl, {
    Key? key,
    required FilterEditorInitConfigs initConfigs,
  }) {
    return FilterEditor._(
      key: key,
      editorImage: EditorImage(networkUrl: networkUrl),
      initConfigs: initConfigs,
    );
  }

  /// Constructs a `FilterEditor` widget with an image loaded automatically based on the provided source.
  ///
  /// Either [byteArray], [file], [networkUrl], or [assetPath] must be provided.
  factory FilterEditor.autoSource({
    Key? key,
    required FilterEditorInitConfigs initConfigs,
    Uint8List? byteArray,
    File? file,
    String? assetPath,
    String? networkUrl,
  }) {
    if (byteArray != null) {
      return FilterEditor.memory(
        byteArray,
        key: key,
        initConfigs: initConfigs,
      );
    } else if (file != null) {
      return FilterEditor.file(
        file,
        key: key,
        initConfigs: initConfigs,
      );
    } else if (networkUrl != null) {
      return FilterEditor.network(
        networkUrl,
        key: key,
        initConfigs: initConfigs,
      );
    } else if (assetPath != null) {
      return FilterEditor.asset(
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
  createState() => FilterEditorState();
}

/// The state class for the `FilterEditor` widget.
class FilterEditorState extends State<FilterEditor>
    with
        ImageEditorConvertedConfigs,
        StandaloneEditorState<FilterEditor, FilterEditorInitConfigs> {
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

    if (widget.initConfigs.convertToUint8List) {
      _createScreenshot = true;
      LoadingDialog loading = LoadingDialog()
        ..show(
          context,
          i18n: i18n,
          theme: theme,
          designMode: designMode,
          message: i18n.filterEditor.applyFilterDialogMsg,
          imageEditorTheme: imageEditorTheme,
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
      data: theme.copyWith(
          tooltipTheme: theme.tooltipTheme.copyWith(preferBelow: true)),
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: imageEditorTheme.uiOverlayStyle,
        child: Scaffold(
          backgroundColor: imageEditorTheme.filterEditor.background,
          appBar: _buildAppBar(),
          body: _buildBody(),
          bottomNavigationBar: _buildBottomNavBar(),
        ),
      ),
    );
  }

  /// Builds the app bar for the filter editor.
  PreferredSizeWidget _buildAppBar() {
    return customWidgets.appBarFilterEditor ??
        AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: imageEditorTheme.filterEditor.appBarBackgroundColor,
          foregroundColor: imageEditorTheme.filterEditor.appBarForegroundColor,
          actions: [
            IconButton(
              tooltip: i18n.filterEditor.back,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              icon: Icon(icons.backButton),
              onPressed: close,
            ),
            const Spacer(),
            IconButton(
              tooltip: i18n.filterEditor.done,
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
            children: [
              Hero(
                tag: heroTag,
                createRectTween: (begin, end) =>
                    RectTween(begin: begin, end: end),
                child: TransformedContentGenerator(
                  configs: transformConfigs ?? TransformConfigs.empty(),
                  child: ImageWithFilter(
                    image: editorImage,
                    activeFilters: appliedFilters,
                    designMode: designMode,
                    filter: selectedFilter,
                    blurFactor: appliedBlurFactor,
                    fit: BoxFit.contain,
                    opacity: filterOpacity,
                  ),
                ),
              ),
              if (filterEditorConfigs.showLayers && layers != null)
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
                        onUpdateUI?.call();
                      },
                    ),
            ),
            FilterEditorItemList(
              byteArray: widget.editorImage.byteArray,
              file: widget.editorImage.file,
              assetPath: widget.editorImage.assetPath,
              networkUrl: widget.editorImage.networkUrl,
              activeFilters: appliedFilters,
              blurFactor: appliedBlurFactor,
              configs: configs,
              transformConfigs: transformConfigs,
              selectedFilter: selectedFilter,
              onSelectFilter: (filter) {
                selectedFilter = filter;
                setState(() {});
                onUpdateUI?.call();
              },
            ),
          ],
        ),
      ),
    );
  }
}
