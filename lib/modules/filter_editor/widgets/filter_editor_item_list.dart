// Dart imports:
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:colorfilter_generator/colorfilter_generator.dart';
import 'package:colorfilter_generator/presets.dart';

// Project imports:
import 'package:pro_image_editor/models/editor_configs/pro_image_editor_configs.dart';
import 'package:pro_image_editor/models/theme/theme.dart';
import 'package:pro_image_editor/modules/filter_editor/widgets/image_with_filters.dart';
import 'package:pro_image_editor/widgets/pro_image_editor_desktop_mode.dart';
import '../../../models/crop_rotate_editor/transform_factors.dart';
import '../../../models/editor_image.dart';
import '../../../models/history/filter_state_history.dart';

class FilterEditorItemList extends StatefulWidget {
  /// A byte array representing the image data.
  final Uint8List? byteArray;

  /// The file representing the image.
  final File? file;

  /// The asset path of the image.
  final String? assetPath;

  /// The network URL of the image.
  final String? networkUrl;

  /// The image editor configs.
  final ProImageEditorConfigs configs;

  /// Specifies the scale factor for items.
  ///
  /// If provided, this value scales the items in the editor by the specified factor.
  final double? itemScaleFactor;

  /// Specifies the list of active filter state histories.
  ///
  /// If provided, this list contains the history of active filters applied to the image.
  final List<FilterStateHistory>? activeFilters;

  /// Specifies the blur factor.
  final double? blurFactor;

  /// Specifies the selected filter.
  ///
  /// This property represents the currently selected filter for the image editor.
  final ColorFilterGenerator selectedFilter;

  /// The transform configurations how the image should be initialized.
  final TransformConfigs? transformConfigs;

  /// Callback function for selecting a filter.
  ///
  /// This function is called when a filter is selected in the editor. It takes a [ColorFilterGenerator] as a parameter, representing the selected filter.
  final Function(ColorFilterGenerator filter) onSelectFilter;

  /// The size of the image with layers applied.
  final Size mainImageSize;

  /// The size of the body with layers applied.
  final Size mainBodySize;

  const FilterEditorItemList({
    super.key,
    this.byteArray,
    this.file,
    this.assetPath,
    this.networkUrl,
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
  List<ColorFilterGenerator> get _filters =>
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
  SizedBox _buildFilterList() {
    return SizedBox(
      height: 120,
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
                  EdgeInsets.fromLTRB(8, _isWhatsAppDesign ? 15 : 8, 8, 10),
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
    required ColorFilterGenerator filter,
    required String name,
    required int index,
    List<FilterStateHistory>? activeFilters,
  }) {
    if (_isWhatsAppDesign) {
      return _buildWhatsAppFilterButton(
        filter: filter,
        name: name,
        index: index,
        activeFilters: activeFilters,
      );
    }
    return GestureDetector(
      key: ValueKey('Filter-$name-$index'),
      onTap: () {
        widget.onSelectFilter(filter);
      },
      child: Column(
        children: [
          _buildPreviewImage(const Size(64, 64), filter),
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
    ColorFilterGenerator filter,
  ) {
    TransformConfigs transformConfigs =
        widget.transformConfigs ?? TransformConfigs.empty();

    Size imageSize = transformConfigs.cropRect == Rect.largest
        ? widget.mainImageSize
        : transformConfigs.cropRect.size;

    double offsetFactor = widget.mainImageSize.longestSide / size.shortestSide;
    double fitCoverScale = max(
      max(widget.mainImageSize.aspectRatio,
          1 / widget.mainImageSize.aspectRatio),
      max(imageSize.aspectRatio, 1 / imageSize.aspectRatio),
    );

    double scale = fitCoverScale * transformConfigs.scaleUser;

    return Container(
      height: size.height,
      width: size.width,
      margin: const EdgeInsets.only(bottom: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: const Color(0xFF242424),
          width: 1,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: Transform.rotate(
          angle: transformConfigs.angle,
          alignment: Alignment.center,
          child: Transform.flip(
            flipX: transformConfigs.flipX,
            flipY: transformConfigs.flipY,
            child: Transform.scale(
              scale: scale,
              child: Transform.translate(
                offset: transformConfigs.offset / offsetFactor,
                child: ImageWithFilters(
                  image: EditorImage(
                    file: widget.file,
                    byteArray: widget.byteArray,
                    networkUrl: widget.networkUrl,
                    assetPath: widget.assetPath,
                  ),
                  width: size.width,
                  height: size.height,
                  filters: [
                    ...(widget.activeFilters ?? []),
                    FilterStateHistory(filter: filter, opacity: 1),
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
    required ColorFilterGenerator filter,
    required String name,
    required int index,
    List<FilterStateHistory>? activeFilters,
  }) {
    bool isSelected = widget.selectedFilter.hashCode == filter.hashCode ||
        (widget.selectedFilter.filters.isEmpty && filter.filters.isEmpty);
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
                  /*  ImageWithFilters(
                    image: EditorImage(
                      file: widget.file,
                      byteArray: widget.byteArray,
                      networkUrl: widget.networkUrl,
                      assetPath: widget.assetPath,
                    ),
                    designMode: widget.configs.designMode,
                    blurFactor: widget.blurFactor ?? 0,
                    width: size.width,
                    height: size.height,
                    filters: [
                      ...(widget.activeFilters ?? []),
                      FilterStateHistory(filter: filter, opacity: 1),
                    ],
                  ), */
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
