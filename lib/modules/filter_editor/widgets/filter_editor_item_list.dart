// Dart imports:
import 'dart:math';

// Flutter imports:
import 'package:flutter/material.dart';
import 'package:pro_image_editor/models/tune_editor/tune_adjustment_matrix.dart';
import 'package:pro_image_editor/pro_image_editor.dart';

// Project imports:
import '../../../models/crop_rotate_editor/transform_factors.dart';
import '../types/filter_matrix.dart';
import 'filtered_image.dart';

/// A widget for displaying a list of filter editor items, allowing users
/// to select and apply filters to an image.
class FilterEditorItemList extends StatefulWidget {
  /// Constructor for creating an instance of FilterEditorItemList.
  const FilterEditorItemList({
    super.key,
    required this.editorImage,
    this.activeFilters,
    this.activeTuneAdjustments = const [],
    this.blurFactor,
    this.itemScaleFactor,
    this.transformConfigs,
    this.mainImageSize = Size.zero,
    this.mainBodySize = Size.zero,
    required this.selectedFilter,
    required this.onSelectFilter,
    required this.configs,
    this.borderRadius,
    this.listHeight = 104.0,
    this.previewImageSize = const Size(64, 64),
  });

  /// The EditorImage class represents an image with multiple sources,
  /// including bytes, file, network URL, and asset path.
  final EditorImage editorImage;

  /// The image editor configs.
  final ProImageEditorConfigs configs;

  /// Specifies the scale factor for items.
  ///
  /// If provided, this value scales the items in the editor by the specified
  /// factor.
  final double? itemScaleFactor;

  /// Specifies the list of active filter state histories.
  ///
  /// If provided, this list contains the history of active filters applied to
  /// the image.
  final FilterMatrix? activeFilters;

  /// Specifies the list of active tune adjustments state histories.
  final List<TuneAdjustmentMatrix> activeTuneAdjustments;

  /// Specifies the blur factor.
  final double? blurFactor;

  /// Specifies the selected filter.
  ///
  /// This property represents the currently selected filter for the image
  /// editor.
  final FilterMatrix selectedFilter;

  /// The transform configurations how the image should be initialized.
  final TransformConfigs? transformConfigs;

  /// Callback function for selecting a filter.
  ///
  /// This function is called when a filter is selected in the editor. It takes
  /// a [FilterModel] as a parameter, representing the selected filter.
  final Function(FilterModel filter) onSelectFilter;

  /// The size of the image with layers applied.
  final Size mainImageSize;

  /// The size of the body with layers applied.
  final Size mainBodySize;

  /// The size of the preview image displayed in the editor.
  final Size previewImageSize;

  /// The border radius applied to the preview image or UI element.
  final BorderRadius? borderRadius;

  /// The height of the list in the editor's UI.
  final double listHeight;

  @override
  State<FilterEditorItemList> createState() => _FilterEditorItemListState();
}

class _FilterEditorItemListState extends State<FilterEditorItemList> {
  late ScrollController _scrollCtrl;

  /// A list of `ColorFilterGenerator` objects that define the image filters
  /// available in the editor.
  List<FilterModel> get _filters =>
      widget.configs.filterEditorConfigs.filterList ?? presetFiltersList;

  @override
  void initState() {
    _scrollCtrl = ScrollController();
    super.initState();
  }

  @override
  void dispose() {
    _scrollCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _buildFilterList();
  }

  /// Builds a horizontal list of filter preview buttons.
  Widget _buildFilterList() {
    return SizedBox(
      height: widget.listHeight,
      child: Scrollbar(
        controller: _scrollCtrl,
        scrollbarOrientation: ScrollbarOrientation.bottom,
        thumbVisibility: isDesktop,
        trackVisibility: isDesktop,
        child: SingleChildScrollView(
          controller: _scrollCtrl,
          scrollDirection: Axis.horizontal,
          child: ConstrainedBox(
            constraints:
                BoxConstraints(minWidth: MediaQuery.of(context).size.width),
            child: Padding(
              padding:
                  widget.configs.imageEditorTheme.filterEditor.filterListMargin,
              child: Wrap(
                crossAxisAlignment: WrapCrossAlignment.end,
                alignment: WrapAlignment.spaceAround,
                spacing: widget
                    .configs.imageEditorTheme.filterEditor.filterListSpacing,
                children: <Widget>[
                  for (int i = 0; i < _filters.length; i++)
                    buildFilterButton(
                      filter: _filters[i],
                      index: i,
                      activeFilters: widget.activeFilters,
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Create a button for filter preview.
  Widget buildFilterButton({
    required FilterModel filter,
    required int index,
    FilterMatrix? activeFilters,
  }) {
    bool isSelected =
        widget.selectedFilter.hashCode == filter.filters.hashCode ||
            (widget.selectedFilter.isEmpty && filter.filters.isEmpty);

    if (widget.configs.customWidgets.filterEditor.filterButton != null) {
      return widget.configs.customWidgets.filterEditor.filterButton!.call(
        FilterModel(
          name: widget.configs.i18n.filterEditor.filters
              .getFilterI18n(filter.name),
          filters: filter.filters,
        ),
        isSelected,
        widget.itemScaleFactor,
        () => setState(() => widget.onSelectFilter(filter)),
        _buildPreviewImage(
          widget.previewImageSize,
          filter,
        ),
        ValueKey('Filter-${filter.name}-$index'),
      );
    }

    return FadeInUp(
      duration: widget.configs.filterEditorConfigs.fadeInUpDuration,
      delay: widget.configs.filterEditorConfigs.fadeInUpStaggerDelayDuration *
          index,
      child: GestureDetector(
        key: ValueKey('Filter-${filter.name}-$index'),
        onTap: () {
          widget.onSelectFilter(filter);
        },
        child: Column(
          children: [
            _buildPreviewImage(
              widget.previewImageSize,
              filter,
              margin: const EdgeInsets.only(bottom: 4),
              borderRadius: widget.borderRadius ?? BorderRadius.circular(4),
              decoration: BoxDecoration(
                borderRadius: widget.borderRadius ?? BorderRadius.circular(4),
                border: Border.all(
                  color: const Color(0xFF242424),
                  width: 1,
                ),
              ),
            ),
            ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: widget.previewImageSize.width,
              ),
              child: Text(
                widget.configs.i18n.filterEditor.filters
                    .getFilterI18n(filter.name),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 11,
                  color: isSelected
                      ? widget.configs.imageEditorTheme.filterEditor
                          .previewSelectedTextColor
                      : widget.configs.imageEditorTheme.filterEditor
                          .previewTextColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPreviewImage(
    Size size,
    FilterModel filter, {
    EdgeInsets? margin,
    Decoration? decoration,
    BorderRadius borderRadius = BorderRadius.zero,
  }) {
    TransformConfigs transformConfigs =
        widget.transformConfigs ?? TransformConfigs.empty();

    bool emptyConfigs = transformConfigs.isEmpty;

    Size imageSize = emptyConfigs || transformConfigs.cropRect == Rect.largest
        ? widget.mainImageSize
        : transformConfigs.cropRect.size;

    double offsetFactor =
        emptyConfigs ? 1 : widget.mainImageSize.longestSide / size.shortestSide;
    double fitCoverScale = emptyConfigs
        ? 1
        : max(
            max(widget.mainImageSize.aspectRatio,
                1 / widget.mainImageSize.aspectRatio),
            max(imageSize.aspectRatio, 1 / imageSize.aspectRatio),
          );

    Offset offset = transformConfigs.offset / offsetFactor;
    double scale = fitCoverScale * transformConfigs.scaleUser;
    if (scale.isInfinite || scale.isNaN) scale = 1;
    if (offset.isInfinite) offset = Offset.zero;

    return Container(
      height: size.height,
      width: size.width,
      margin: margin,
      decoration: decoration,
      child: ClipRRect(
        borderRadius: borderRadius,
        child: Transform.rotate(
          angle: transformConfigs.angle,
          alignment: Alignment.center,
          child: Transform.flip(
            flipX: transformConfigs.flipX,
            flipY: transformConfigs.flipY,
            child: Transform.scale(
              scale: scale,
              child: Transform.translate(
                offset: offset,
                child: FilteredImage(
                  image: widget.editorImage,
                  fit: transformConfigs.isNotEmpty
                      ? BoxFit.contain
                      : BoxFit.cover,
                  width: size.width,
                  height: size.height,
                  filters: [
                    ...(widget.activeFilters ?? []),
                    ...filter.filters,
                  ],
                  tuneAdjustments: widget.activeTuneAdjustments,
                  configs: widget.configs,
                  blurFactor: widget.blurFactor ?? 0,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
