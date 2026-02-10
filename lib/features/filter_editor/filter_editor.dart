// Dart imports:
import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '/core/constants/image_constants.dart';
import '/core/mixins/converted_callbacks.dart';
import '/core/mixins/converted_configs.dart';
import '/core/mixins/standalone_editor.dart';
import '/core/models/transform_helper.dart';
import '/core/utils/size_utils.dart';
import '/features/filter_editor/widgets/filter_editor_appbar.dart';
import '/pro_image_editor.dart';
import '/shared/services/content_recorder/widgets/content_recorder.dart';
import '/shared/utils/file_constructor_utils.dart';
import '/shared/widgets/layer/layer_stack.dart';
import '/shared/widgets/transform/transformed_content_generator.dart';
import 'constants/identity_matrix_constant.dart';
import 'utils/lerp_color_matrix_utils.dart';

export 'types/filter_matrix.dart';
export 'utils/filter_generator/filter_addons.dart';
export 'utils/filter_generator/filter_model.dart';
export 'utils/filter_generator/filter_presets.dart';
export 'widgets/filter_editor_item_list.dart';
export 'widgets/filtered_widget.dart';

/// The `FilterEditor` widget allows users to editing images with filters
///
/// You can create a `FilterEditor` using one of the factory methods provided:
/// - `FilterEditor.file`: Loads an image from a file.
/// - `FilterEditor.asset`: Loads an image from an asset.
/// - `FilterEditor.network`: Loads an image from a network URL.
/// - `FilterEditor.memory`: Loads an image from memory as a `Uint8List`.
/// - `FilterEditor.autoSource`: Automatically selects the source based on
/// provided parameters.
class FilterEditor extends StatefulWidget
    with StandaloneEditor<FilterEditorInitConfigs> {
  /// Constructs a `FilterEditor` widget.
  ///
  /// The [key] parameter is used to provide a key for the widget.
  /// The [editorImage] parameter specifies the image to be edited.
  /// The [initConfigs] parameter specifies the initialization configurations
  /// for the editor.
  const FilterEditor._({
    super.key,
    required this.initConfigs,
    this.editorImage,
    this.videoController,
  }) : assert(editorImage != null || videoController != null,
            'Either editorImage or videoController must be provided.');

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
    dynamic file, {
    Key? key,
    required FilterEditorInitConfigs initConfigs,
  }) {
    return FilterEditor._(
      key: key,
      editorImage: EditorImage(file: ensureFileInstance(file)),
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

  /// Constructs a `FilterEditor` widget with an image loaded from a network
  /// URL.
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

  /// Constructs a `FilterEditor` widget with an image loaded automatically
  /// based on the provided source.
  ///
  /// Either [byteArray], [file], [networkUrl], or [assetPath] must be provided.
  factory FilterEditor.autoSource({
    Key? key,
    Uint8List? byteArray,
    dynamic file,
    String? assetPath,
    String? networkUrl,
    EditorImage? editorImage,
    ProVideoController? videoController,
    required FilterEditorInitConfigs initConfigs,
  }) {
    return FilterEditor._(
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

  /// Constructs a `FilterEditor` widget with an video player.
  factory FilterEditor.video(
    ProVideoController videoController, {
    Key? key,
    required FilterEditorInitConfigs initConfigs,
  }) {
    return FilterEditor._(
      key: key,
      videoController: videoController,
      initConfigs: initConfigs,
    );
  }

  @override
  final FilterEditorInitConfigs initConfigs;
  @override
  final EditorImage? editorImage;
  @override
  final ProVideoController? videoController;

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
  late final StreamController<void> _uiFilterStream;

  /// The selected filter.
  FilterModel get selectedFilter => _selectedFilter;
  FilterModel _selectedFilter = PresetFilters.none;
  set selectedFilter(FilterModel filter) {
    setFilter(filter);
  }

  /// The opacity of the selected filter, ranging
  /// from 0 (fully transparent) to 1 (fully opaque).
  double get filterOpacity => _filterOpacity;
  double _filterOpacity = 1;
  set filterOpacity(double value) {
    setFilterOpacity(value);
  }

  @override
  void initState() {
    super.initState();
    _uiFilterStream = StreamController.broadcast();
    _uiFilterStream.stream.listen((_) => rebuildController.add(null));

    final isMultiSelectionDisabled = !filterEditorConfigs.enableMultiSelection;
    if (isMultiSelectionDisabled && appliedFilters.isNotEmpty) {
      _initializeFilterFromApplied();
    }

    filterEditorCallbacks?.onInit?.call();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      filterEditorCallbacks?.onAfterViewInit?.call();
    });
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

  /// Handles the "Done" action, either by applying changes or closing the
  /// editor.
  void done() async {
    doneEditing(
      editorImage: widget.editorImage,
      returnValue: _getActiveFilters(),
      blur: appliedBlurFactor,
      matrixFilterList: _getActiveFilters(),
      matrixTuneAdjustmentsList:
          appliedTuneAdjustments.map((item) => item.matrix).toList(),
      transform: initialTransformConfigs,
    );
    filterEditorCallbacks?.handleDone();
  }

  FilterMatrix _getActiveFilters() {
    if (!filterEditorConfigs.enableMultiSelection) {
      if (selectedFilter.filters.isEmpty) {
        return [
          [1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 0]
        ];
      }
    }

    return [
      if (filterEditorConfigs.enableMultiSelection) ...appliedFilters,
      ...selectedFilter.filters.map(
        (matrix) => lerpColorMatrix(identityMatrix, matrix, filterOpacity),
      ),
    ];
  }

  /// Initializes the selected filter from previously applied filters.
  ///
  /// Searches through the available filter list to find a filter whose matrix
  /// matches the first applied filter. If found, sets it as the selected
  /// filter.
  void _initializeFilterFromApplied() {
    final filterList = filterEditorConfigs.filterList ?? presetFiltersList;
    final firstApplied = appliedFilters.first;

    for (final filter in filterList) {
      if (filter.filters.isNotEmpty &&
          listEquals(filter.filters.first, firstApplied)) {
        setFilter(filter);
        return;
      }
    }
    setFilter(FilterModel(name: 'Not-Found', filters: [firstApplied]));
  }

  /// Set the current filter.
  void setFilter(FilterModel filter) {
    _selectedFilter = filter;
    _uiFilterStream.add(null);
  }

  /// Set the current filter opacity.
  void setFilterOpacity(double value) {
    _filterOpacity = value.clamp(0, 1);
    _uiFilterStream.add(null);
  }

  /// Handles changes in the filter factor value.
  void _onChanged(double value) {
    setFilterOpacity(value);
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
      child: ExtendedPopScope(
        canPop: filterEditorConfigs.enableGesturePop,
        child: AnnotatedRegion<SystemUiOverlayStyle>(
          value: filterEditorConfigs.style.uiOverlayStyle,
          child: SafeArea(
            top: filterEditorConfigs.safeArea.top,
            bottom: filterEditorConfigs.safeArea.bottom,
            left: filterEditorConfigs.safeArea.left,
            right: filterEditorConfigs.safeArea.right,
            child: RecordInvisibleWidget(
              controller: screenshotCtrl,
              child: Scaffold(
                backgroundColor: filterEditorConfigs.style.background,
                appBar: _buildAppBar(),
                body: _buildBody(),
                bottomNavigationBar: _buildBottomNavBar(),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Builds the app bar for the filter editor.
  PreferredSizeWidget? _buildAppBar() {
    if (filterEditorConfigs.widgets.appBar != null) {
      return filterEditorConfigs.widgets.appBar!
          .call(this, rebuildController.stream);
    }
    return FilterEditorAppBar(
      filterEditorConfigs: filterEditorConfigs,
      i18n: i18n.filterEditor,
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
                if (filterEditorConfigs.showLayers && layers != null)
                  LayerStack(
                    transformHelper: TransformHelper(
                      mainBodySize:
                          getValidSizeOrDefault(mainBodySize, editorBodySize),
                      mainImageSize:
                          getValidSizeOrDefault(mainImageSize, editorBodySize),
                      editorBodySize: editorBodySize,
                      transformConfigs: initialTransformConfigs,
                    ),
                    configs: configs,
                    layers: layers!,
                    clipBehavior: Clip.none,
                    overlayColor: filterEditorConfigs.style.background,
                  ),
                if (filterEditorConfigs.widgets.bodyItemsRecorded != null)
                  ...filterEditorConfigs.widgets.bodyItemsRecorded!(
                      this, rebuildController.stream),
              ],
            ),
          ),
          if (filterEditorConfigs.widgets.bodyItems != null)
            ...filterEditorConfigs.widgets.bodyItems!(
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
            stream: _uiFilterStream.stream,
            builder: (context, snapshot) {
              return FilteredWidget(
                width:
                    getValidSizeOrDefault(mainImageSize, editorBodySize).width,
                height:
                    getValidSizeOrDefault(mainImageSize, editorBodySize).height,
                configs: configs,
                image: editorImage,
                videoPlayer: videoController?.videoPlayer,
                blankSize: initConfigs.mainImageSize,
                filters: _getActiveFilters(),
                tuneAdjustments: appliedTuneAdjustments,
                blurFactor: appliedBlurFactor,
              );
            }),
      ),
    );
  }

  /// Builds the bottom navigation bar with filter options.
  Widget? _buildBottomNavBar() {
    if (filterEditorConfigs.widgets.bottomBar != null) {
      return filterEditorConfigs.widgets.bottomBar!
          .call(this, rebuildController.stream);
    }

    return SafeArea(
      child: Container(
        color: filterEditorConfigs.style.background,
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
                            : filterEditorConfigs.widgets.slider?.call(
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
                mainBodySize:
                    getValidSizeOrDefault(mainBodySize, editorBodySize),
                mainImageSize:
                    getValidSizeOrDefault(mainImageSize, editorBodySize),
                editorImage: editorImage,
                image: editorImage != null
                    ? null
                    : widget.videoController!.thumbnails?.isNotEmpty == true
                        ? Image(
                            image: widget.videoController!.thumbnails!.first,
                          )
                        : Image.memory(kImageEditorTransparentBytes),
                activeFilters: filterEditorConfigs.enableMultiSelection
                    ? appliedFilters
                    : null,
                blurFactor: appliedBlurFactor,
                configs: configs,
                transformConfigs: initialTransformConfigs,
                selectedFilter: selectedFilter.filters,
                onSelectFilter: (filter) {
                  setFilter(filter);
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

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty<FilterEditorInitConfigs>(
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
      ..add(DiagnosticsProperty<FilterModel>(
        'selectedFilter',
        _selectedFilter,
      ))
      ..add(DoubleProperty(
        'filterOpacity',
        _filterOpacity,
      ))
      ..add(IterableProperty<TuneAdjustmentMatrix>(
        'appliedTuneAdjustments',
        appliedTuneAdjustments,
      ))
      ..add(DoubleProperty(
        'appliedBlurFactor',
        appliedBlurFactor,
      ))
      ..add(IterableProperty<List<double>>(
        'appliedFilters',
        filterEditorConfigs.enableMultiSelection ? appliedFilters : [],
      ));
  }
}
