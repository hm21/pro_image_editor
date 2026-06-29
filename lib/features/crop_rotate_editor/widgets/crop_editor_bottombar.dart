import 'dart:math';

import 'package:flutter/material.dart';

import '/core/models/editor_configs/pro_image_editor_configs.dart';
import '/shared/widgets/editor_scrollbar.dart';
import '/shared/widgets/flat_icon_text_button.dart';
import '../providers/tilt_provider.dart';
import 'tilt/tilt_item_row.dart';

/// A widget representing the bottom bar for the crop editor, providing
/// options like rotate, flip, aspect ratio, and reset.
class CropEditorBottombar extends StatelessWidget {
  /// Creates a `CropEditorBottombar` with the provided configurations and
  /// callbacks.
  ///
  /// - [bottomBarScrollCtrl]: Controls the scroll behavior of the bottom bar.
  /// - [i18n]: Provides localized strings for tooltips and labels.
  /// - [configs]: Contains configurations for the crop and rotate editor.
  /// - [theme]: Defines the theme to style the bottom bar.
  /// - [onRotate]: Callback invoked when the rotate option is selected.
  /// - [onFlip]: Callback invoked when the flip option is selected.
  /// - [onOpenAspectRatioOptions]: Callback invoked when the aspect ratio
  /// options are opened.
  /// - [onReset]: Callback invoked when the reset option is selected.
  const CropEditorBottombar({
    super.key,
    required this.bottomBarScrollCtrl,
    required this.i18n,
    required this.configs,
    required this.theme,
    required this.tools,
    required this.onRotate,
    required this.onFlip,
    required this.onOpenAspectRatioOptions,
    required this.onReset,
    this.onTilt,
  });

  /// Controls the scroll behavior of the bottom bar.
  final ScrollController bottomBarScrollCtrl;

  /// Provides localized strings for tooltips and labels.
  final I18nCropRotateEditor i18n;

  /// Configurations for the crop and rotate editor.
  final CropRotateEditorConfigs configs;

  /// Theme data for styling the bottom bar.
  final ThemeData theme;

  /// Defines which paint tools are available in the editor.
  final List<CropRotateTool> tools;

  /// Callback for the rotate option.
  final Function() onRotate;

  /// Callback for the flip option.
  final Function() onFlip;

  /// Callback for opening the aspect ratio options.
  final Function() onOpenAspectRatioOptions;

  /// Callback for resetting the editor.
  final Function() onReset;

  /// Callback for opening the tilt (perspective/skew) editor.
  final Function()? onTilt;

  _ToolItem _getItem(CropRotateTool tool) {
    switch (tool) {
      case CropRotateTool.rotate:
        return _ToolItem(
          key: const ValueKey('crop-rotate-editor-rotate-btn'),
          label: i18n.rotate,
          icon: configs.icons.rotate,
          onTap: onRotate,
        );
      case CropRotateTool.flip:
        return _ToolItem(
          key: const ValueKey('crop-rotate-editor-flip-btn'),
          label: i18n.flip,
          icon: configs.icons.flip,
          onTap: onFlip,
        );
      case CropRotateTool.tilt:
        return _ToolItem(
          key: const ValueKey('crop-rotate-editor-tilt-btn'),
          label: i18n.tilt,
          icon: configs.icons.tilt,
          onTap: onTilt ?? () {},
        );
      case CropRotateTool.aspectRatio:
        return _ToolItem(
          key: const ValueKey('crop-rotate-editor-ratio-btn'),
          label: i18n.ratio,
          icon: configs.icons.aspectRatio,
          onTap: onOpenAspectRatioOptions,
        );
      case CropRotateTool.reset:
        return _ToolItem(
          key: const ValueKey('crop-rotate-editor-reset-btn'),
          label: i18n.reset,
          icon: configs.icons.reset,
          onTap: onReset,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool showTiltRow =
        TiltProvider.maybeOf(context)?.isTiltEditorVisible ?? false;
    return Theme(
      data: theme,
      child: EditorScrollbar(
        controller: bottomBarScrollCtrl,
        child: BottomAppBar(
          height: kToolbarHeight,
          color: configs.style.bottomBarBackground,
          padding: EdgeInsets.zero,
          child: Center(
            child: SingleChildScrollView(
              controller: bottomBarScrollCtrl,
              scrollDirection: Axis.horizontal,
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minWidth: min(MediaQuery.sizeOf(context).width, 500),
                  maxWidth: 500,
                ),
                child: showTiltRow
                    ? const TiltItemRow()
                    : Wrap(
                        direction: Axis.horizontal,
                        alignment: WrapAlignment.spaceAround,
                        children: tools
                            .map((tool) => _buildTool(_getItem(tool)))
                            .toList(),
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTool(_ToolItem item) {
    Color foregroundColor = configs.style.appBarColor;
    return FlatIconTextButton(
      key: item.key,
      label: Text(
        item.label,
        style: TextStyle(fontSize: 10.0, color: foregroundColor),
      ),
      icon: Icon(item.icon, color: foregroundColor),
      onPressed: item.onTap,
    );
  }
}

class _ToolItem {
  const _ToolItem({
    required this.key,
    required this.label,
    required this.icon,
    required this.onTap,
  });

  final Key key;
  final String label;
  final IconData icon;
  final Function() onTap;
}
