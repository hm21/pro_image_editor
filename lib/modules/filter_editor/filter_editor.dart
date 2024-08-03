// Dart imports:
import 'dart:async';
import 'dart:io';

// Flutter imports:
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Project imports:
import 'package:pro_image_editor/mixins/converted_callbacks.dart';
import 'package:pro_image_editor/models/transform_helper.dart';
import 'package:pro_image_editor/pro_image_editor.dart';
import 'package:pro_image_editor/utils/content_recorder.dart/utils/record_invisible_widget.dart';
import '../../mixins/converted_configs.dart';
import '../../mixins/standalone_editor.dart';
import '../../models/crop_rotate_editor/transform_factors.dart';
import '../../utils/content_recorder.dart/content_recorder.dart';
import '../../widgets/layer_stack.dart';
import '../../widgets/transform/transformed_content_generator.dart';
import 'types/filter_matrix.dart';
import 'widgets/filtered_image.dart';

export 'utils/filter_generator/filter_presets.dart';
export 'utils/filter_generator/filter_model.dart';
export 'utils/filter_generator/filter_addons.dart';
export 'widgets/filter_editor_item_list.dart';

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
        ImageEditorConvertedCallbacks,
        StandaloneEditorState<FilterEditor, FilterEditorInitConfigs> {
  /// Update the image with the applied filter and the slider value.
  late final StreamController _uiFilterStream;

  /// The selected filter.
  FilterModel selectedFilter = PresetFilters.none;

  /// The opacity of the selected filter.
  double filterOpacity = 1;

  @override
  void initState() {
    _uiFilterStream = StreamController.broadcast();
    _uiFilterStream.stream.listen((_) => rebuildController.add(null));

    filterEditorCallbacks?.onInit?.call();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      filterEditorCallbacks?.onAfterViewInit?.call();
    });
    super.initState();
  }

  @override
  void dispose() {
    _uiFilterStream.close();
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
      editorImage: widget.editorImage,
      returnValue: _getActiveFilters(),
    );
    filterEditorCallbacks?.handleDone();
  }

  FilterMatrix _getActiveFilters() {
    return [
      ...appliedFilters,
      ...selectedFilter.filters,
      ColorFilterAddons.opacity(filterOpacity),
    ];
  }

  void setFilter(FilterModel filter) {
    selectedFilter = filter;
    _uiFilterStream.add(null);
  }

  /// Handles changes in the filter factor value.
  void _onChanged(double value) {
    filterOpacity = value;
    _uiFilterStream.add(null);
    filterEditorCallbacks?.handleFilterFactorChange(value);
  }

  /// Handles the end of changes in the filter factor value.
  void _onChangedEnd(double value) {
    filterEditorCallbacks?.handleFilterFactorChangeEnd(value);
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
            backgroundColor: imageEditorTheme.filterEditor.background,
            appBar: _buildAppBar(),
            body: _buildBody(),
            bottomNavigationBar: _buildBottomNavBar(),
          ),
        ),
      ),
    );
  }

  /// Builds the app bar for the filter editor.
  PreferredSizeWidget? _buildAppBar() {
    if (customWidgets.filterEditor.appBar != null) {
      return customWidgets.filterEditor.appBar!
          .call(this, rebuildController.stream);
    }
    return AppBar(
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
                    stream: _uiFilterStream.stream,
                    builder: (context, snapshot) {
                      return FilteredImage(
                        width:
                            getMinimumSize(mainImageSize, editorBodySize).width,
                        height: getMinimumSize(mainImageSize, editorBodySize)
                            .height,
                        configs: configs,
                        image: editorImage,
                        filters: _getActiveFilters(),
                        blurFactor: appliedBlurFactor,
                      );
                    }),
              ),
            ),
            if (filterEditorConfigs.showLayers && layers != null)
              LayerStack(
                transformHelper: TransformHelper(
                  mainBodySize: getMinimumSize(mainBodySize, editorBodySize),
                  mainImageSize: getMinimumSize(mainImageSize, editorBodySize),
                  editorBodySize: editorBodySize,
                  transformConfigs: transformConfigs,
                ),
                configs: configs,
                layers: layers!,
                clipBehavior: Clip.none,
              ),
            if (customWidgets.filterEditor.bodyItems != null)
              ...customWidgets.filterEditor.bodyItems!(
                  this, rebuildController.stream),
          ],
        ),
      );
    });
  }

  /// Builds the bottom navigation bar with filter options.
  Widget? _buildBottomNavBar() {
    if (customWidgets.filterEditor.bottomBar != null) {
      return customWidgets.filterEditor.bottomBar!
          .call(this, rebuildController.stream);
    }

    return SafeArea(
      child: Container(
        color: imageEditorTheme.filterEditor.background,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 800),
              child: RepaintBoundary(
                child: StreamBuilder(
                    stream: _uiFilterStream.stream,
                    builder: (context, snapshot) {
                      return SizedBox(
                        height: 40,
                        child: selectedFilter == PresetFilters.none
                            ? null
                            : customWidgets.filterEditor.slider?.call(
                                  this,
                                  rebuildController.stream,
                                  filterOpacity,
                                  _onChanged,
                                  _onChangedEnd,
                                ) ??
                                Slider(
                                  min: 0,
                                  max: 1,
                                  divisions: 100,
                                  value: filterOpacity,
                                  onChanged: _onChanged,
                                  onChangeEnd: _onChangedEnd,
                                ),
                      );
                    }),
              ),
            ),
            StatefulBuilder(builder: (context, setStateFilterList) {
              return FilterEditorItemList(
                mainBodySize: getMinimumSize(mainBodySize, editorBodySize),
                mainImageSize: getMinimumSize(mainImageSize, editorBodySize),
                editorImage: editorImage,
                activeFilters: appliedFilters,
                blurFactor: appliedBlurFactor,
                configs: configs,
                transformConfigs: transformConfigs,
                selectedFilter: selectedFilter.filters,
                onSelectFilter: (filter) {
                  selectedFilter = filter;
                  _uiFilterStream.add(null);
                  setStateFilterList(() {});
                  filterEditorCallbacks?.handleFilterChanged(filter);
                  WidgetsBinding.instance.addPostFrameCallback((_) async {
                    takeScreenshot();
                  });
                },
              );
            }),
          ],
        ),
      ),
    );
  }
}
