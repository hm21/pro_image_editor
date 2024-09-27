import 'package:flutter/material.dart';
import 'package:pro_image_editor/designs/grounded/grounded_design.dart';
import 'package:pro_image_editor/designs/grounded/utils/grounded_configs.dart';
import 'package:pro_image_editor/mixins/converted_configs.dart';
import 'package:pro_image_editor/mixins/editor_configs_mixin.dart';
import 'package:pro_image_editor/pro_image_editor.dart';

/// A widget that represents a filter bar in the image editor.
///
/// The [GroundedFilterBar] is designed to be used as part of the ProImageEditor
/// package, offering filtering capabilities for images. It works in conjunction
/// with the `GroundedBottomWrapper` and `GroundedBottomBar` to provide a
/// consistent UI for editing tasks.
class GroundedFilterBar extends StatefulWidget with SimpleConfigsAccess {
  /// Constructor for the [GroundedFilterBar].
  ///
  /// Accepts the required [configs], [callbacks], and [editor] parameters.
  const GroundedFilterBar({
    super.key,
    required this.configs,
    required this.callbacks,
    required this.editor,
  });

  /// The editor state that holds filter and editing information.
  final FilterEditorState editor;

  @override
  final ProImageEditorConfigs configs;

  @override
  final ProImageEditorCallbacks callbacks;

  @override
  State<GroundedFilterBar> createState() => _GroundedFilterBarState();
}

/// State class for [GroundedFilterBar].
///
/// This state manages the internal state of the filter bar, including the
/// scroll controller for the horizontal list of filters and the opacity slider.
class _GroundedFilterBarState extends State<GroundedFilterBar>
    with ImageEditorConvertedConfigs, SimpleConfigsAccessState {
  /// Controller for managing the scroll of the horizontal filter list.
  late final ScrollController _bottomBarScrollCtrl;

  @override
  void initState() {
    super.initState();
    _bottomBarScrollCtrl = ScrollController();
  }

  @override
  void dispose() {
    _bottomBarScrollCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GroundedBottomWrapper(
      theme: configs.theme,
      children: (constraints) => [
        Scrollbar(
          controller: _bottomBarScrollCtrl,
          scrollbarOrientation: ScrollbarOrientation.top,
          thickness: isDesktop ? null : 0,
          child: _buildFunctions(constraints),
        ),
        GroundedBottomBar(
          configs: configs,
          done: widget.editor.done,
          close: widget.editor.close,
        ),
      ],
    );
  }

  Widget _buildFunctions(BoxConstraints constraints) {
    return Container(
      color: imageEditorTheme.bottomBarBackgroundColor,
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        children: [
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            transitionBuilder: (child, animation) => FadeTransition(
              opacity: animation,
              child: SizeTransition(
                sizeFactor: animation,
                child: child,
              ),
            ),
            child: widget.editor.selectedFilter.filters.isNotEmpty
                ? StatefulBuilder(builder: (context, setState) {
                    return Slider(
                      min: 0,
                      max: 1,
                      divisions: 100,
                      value: widget.editor.filterOpacity,
                      onChanged: (value) {
                        widget.editor.setFilterOpacity(value);
                        setState(() {});
                      },
                    );
                  })
                : const SizedBox(height: 8),
          ),
          SingleChildScrollView(
            controller: _bottomBarScrollCtrl,
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: FilterEditorItemList(
              listHeight: GROUNDED_SUB_BAR_HEIGHT,
              previewImageSize: const Size(48, 48),
              borderRadius: BorderRadius.circular(2),
              mainBodySize: widget.editor.getMinimumSize(
                  widget.editor.mainBodySize, widget.editor.editorBodySize),
              mainImageSize: widget.editor.getMinimumSize(
                  widget.editor.mainImageSize, widget.editor.editorBodySize),
              editorImage: widget.editor.editorImage,
              activeFilters: widget.editor.appliedFilters,
              blurFactor: widget.editor.appliedBlurFactor,
              configs: configs,
              transformConfigs: widget.editor.initialTransformConfigs,
              selectedFilter: widget.editor.selectedFilter.filters,
              onSelectFilter: (filter) {
                widget.editor.setFilter(filter);
              },
            ),
          ),
        ],
      ),
    );
  }
}
