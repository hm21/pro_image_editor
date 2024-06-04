// Dart imports:
import 'dart:math';

// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:pro_image_editor/models/editor_configs/pro_image_editor_configs.dart';
import 'package:pro_image_editor/models/theme/theme.dart';
import 'package:pro_image_editor/modules/filter_editor/widgets/filtered_image.dart';
import 'package:pro_image_editor/utils/pro_image_editor_mode.dart';
import '../../../models/crop_rotate_editor/transform_factors.dart';
import '../../../models/editor_image.dart';
import '../types/filter_matrix.dart';
import '../utils/filter_generator/filter_model.dart';
import '../utils/filter_generator/filter_presets.dart';

class FilterEditorItemList extends StatefulWidget {
  /// The EditorImage class represents an image with multiple sources,
  /// including bytes, file, network URL, and asset path.
  final EditorImage editorImage;

  /// The image editor configs.
  final ProImageEditorConfigs configs;

  /// Specifies the scale factor for items.
  ///
  /// If provided, this value scales the items in the editor by the specified factor.
  final double? itemScaleFactor;

  /// Specifies the list of active filter state histories.
  ///
  /// If provided, this list contains the history of active filters applied to the image.
  final FilterMatrix? activeFilters;

  /// Specifies the blur factor.
  final double? blurFactor;

  /// Specifies the selected filter.
  ///
  /// This property represents the currently selected filter for the image editor.
  final FilterMatrix selectedFilter;

  /// The transform configurations how the image should be initialized.
  final TransformConfigs? transformConfigs;

  /// Callback function for selecting a filter.
  ///
  /// This function is called when a filter is selected in the editor. It takes a [FilterModel] as a parameter, representing the selected filter.
  final Function(FilterModel filter) onSelectFilter;

  /// The size of the image with layers applied.
  final Size mainImageSize;

  /// The size of the body with layers applied.
  final Size mainBodySize;

  const FilterEditorItemList({
    super.key,
    required this.editorImage,
    this.activeFilters,
    this.blurFactor,
    this.itemScaleFactor,
    this.transformConfigs,
    this.mainImageSize = Size.zero,
    this.mainBodySize = Size.zero,
    required this.selectedFilter,
    required this.onSelectFilter,
    required this.configs,
  });

  @override
  State<FilterEditorItemList> createState() => _FilterEditorItemListState();
}

class _FilterEditorItemListState extends State<FilterEditorItemList> {
  late ScrollController _scrollCtrl;

  /// A list of `ColorFilterGenerator` objects that define the image filters available in the editor.
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

  bool get _isWhatsAppDesign =>
      widget.configs.imageEditorTheme.editorMode == ThemeEditorMode.whatsapp;

  @override
  Widget build(BuildContext context) {
    return _buildFilterList();
  }

  /// Builds a horizontal list of filter preview buttons.
  Widget _buildFilterList() {
    return SizedBox(
      height: 104,
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
                  EdgeInsets.fromLTRB(8, _isWhatsAppDesign ? 15 : 4, 8, 10),
              child: Wrap(
                crossAxisAlignment: WrapCrossAlignment.end,
                alignment: WrapAlignment.spaceAround,
                spacing: _isWhatsAppDesign ? 7 : 15,
                children: <Widget>[
                  for (int i = 0; i < _filters.length; i++)
                    buildFilterButton(
                      filter: _filters[i],
                      name: _filters[i].name,
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
    required String name,
    required int index,
    FilterMatrix? activeFilters,
  }) {
    if (_isWhatsAppDesign) {
      return _buildWhatsAppFilterButton(
        filter: filter,
        name: name,
        index: index,
      );
    }
    return GestureDetector(
      key: ValueKey('Filter-$name-$index'),
      onTap: () {
        widget.onSelectFilter(filter);
      },
      child: Column(
        children: [
          _buildPreviewImage(
            const Size(64, 64),
            filter,
            margin: const EdgeInsets.only(bottom: 4),
            borderRadius: BorderRadius.circular(4),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
              border: Border.all(
                color: const Color(0xFF242424),
                width: 1,
              ),
            ),
          ),
          Text(
            widget.configs.i18n.filterEditor.filters.getFilterI18n(name),
            style: TextStyle(
              fontSize: 11,
              color:
                  widget.configs.imageEditorTheme.filterEditor.previewTextColor,
            ),
          ),
        ],
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
                  fit:
                      !transformConfigs.isEmpty ? BoxFit.contain : BoxFit.cover,
                  width: size.width,
                  height: size.height,
                  filters: [
                    ...(widget.activeFilters ?? []),
                    ...filter.filters,
                  ],
                  designMode: widget.configs.designMode,
                  blurFactor: widget.blurFactor ?? 0,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWhatsAppFilterButton({
    required FilterModel filter,
    required String name,
    required int index,
  }) {
    bool isSelected = widget.selectedFilter.hashCode == filter.hashCode ||
        (widget.selectedFilter.isEmpty && filter.filters.isEmpty);
    var size = const Size(58, 88);

    return Transform.scale(
      scale: widget.itemScaleFactor,
      child: GestureDetector(
        key: ValueKey('Filter-$name-$index'),
        onTap: () {
          widget.onSelectFilter(filter);
        },
        child: AnimatedScale(
          scale: isSelected ? 1.05 : 1,
          alignment: Alignment.bottomCenter,
          duration: const Duration(milliseconds: 200),
          child: Container(
            clipBehavior: Clip.hardEdge,
            height: size.height,
            width: size.width,
            decoration: const BoxDecoration(),
            child: Center(
              child: Stack(
                clipBehavior: Clip.hardEdge,
                children: [
                  _buildPreviewImage(size, filter),
                  Align(
                    alignment: Alignment.bottomLeft,
                    child: Container(
                      color: Colors.black54,
                      width: double.infinity,
                      padding: const EdgeInsets.fromLTRB(2, 3, 2, 3),
                      child: Text(
                        widget.configs.i18n.filterEditor.filters
                            .getFilterI18n(name),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: widget.configs.imageEditorTheme.filterEditor
                              .previewTextColor,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.topRight,
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 200),
                      transitionBuilder: (child, animation) => FadeTransition(
                        opacity: animation,
                        child: ScaleTransition(
                          scale: animation,
                          child: child,
                        ),
                      ),
                      child: isSelected
                          ? Container(
                              margin: const EdgeInsets.all(2),
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: Colors.black,
                                  width: 2.5,
                                ),
                                borderRadius: BorderRadius.circular(100),
                                color: const Color(0xFF13A589),
                              ),
                              child: const Padding(
                                padding: EdgeInsets.all(2.0),
                                child: Icon(
                                  Icons.check,
                                  size: 18,
                                  color: Colors.black,
                                ),
                              ),
                            )
                          : const SizedBox.shrink(),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
