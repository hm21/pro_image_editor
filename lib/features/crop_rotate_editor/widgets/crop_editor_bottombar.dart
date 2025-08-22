import 'dart:math';

import 'package:flutter/material.dart';

import '/core/models/editor_configs/pro_image_editor_configs.dart';
import '/shared/widgets/flat_icon_text_button.dart';
import '../providers/tilt_provider.dart';
import 'tilt/tilt_item_row.dart';

/// A widget representing the bottom bar for the crop editor, providing
/// options like rotate, flip, aspect ratio, and reset.
class CropEditorBottombar extends StatefulWidget {
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
    required this.onRotate,
    required this.onFlip,
    required this.onOpenAspectRatioOptions,
    required this.onReset,
  });

  /// Controls the scroll behavior of the bottom bar.
  final ScrollController bottomBarScrollCtrl;

  /// Provides localized strings for tooltips and labels.
  final I18nCropRotateEditor i18n;

  /// Configurations for the crop and rotate editor.
  final CropRotateEditorConfigs configs;

  /// Theme data for styling the bottom bar.
  final ThemeData theme;

  /// Callback for the rotate option.
  final Function() onRotate;

  /// Callback for the flip option.
  final Function() onFlip;

  /// Callback for opening the aspect ratio options.
  final Function() onOpenAspectRatioOptions;

  /// Callback for resetting the editor.
  final Function() onReset;

  @override
  State<CropEditorBottombar> createState() => _CropEditorBottombarState();
}

class _CropEditorBottombarState extends State<CropEditorBottombar> {
  Color get _foregroundColor => widget.configs.style.bottomBarColor;

  late final _i18n = widget.i18n;
  late final _icons = widget.configs.icons;

  late final _defaultTextStyle =
      TextStyle(fontSize: 10.0, color: _foregroundColor);

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: widget.theme,
      child: Scrollbar(
        controller: widget.bottomBarScrollCtrl,
        scrollbarOrientation: ScrollbarOrientation.top,
        thickness: isDesktop ? null : 0,
        child: BottomAppBar(
          height: kToolbarHeight,
          color: widget.configs.style.bottomBarBackground,
          padding: EdgeInsets.zero,
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 500),
              child: LayoutBuilder(builder: (_, constraints) {
                return SingleChildScrollView(
                  controller: widget.bottomBarScrollCtrl,
                  scrollDirection: Axis.horizontal,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minWidth: min(500, constraints.maxWidth),
                    ),
                    child: TiltProvider.of(context).isTiltEditorVisible
                        ? const TiltItemRow()
                        : _buildItems(),
                  ),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildItems() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: <Widget>[
        if (widget.configs.showRotateButton)
          FlatIconTextButton(
            key: const ValueKey('crop-rotate-editor-rotate-btn'),
            label: Text(_i18n.rotate, style: _defaultTextStyle),
            icon: Icon(_icons.rotate, color: _foregroundColor),
            onPressed: widget.onRotate,
          ),
        if (widget.configs.showFlipButton)
          FlatIconTextButton(
            key: const ValueKey('crop-rotate-editor-flip-btn'),
            label: Text(_i18n.flip, style: _defaultTextStyle),
            icon: Icon(_icons.flip, color: _foregroundColor),
            onPressed: widget.onFlip,
          ),
        if (widget.configs.tiltConfigs.showTiltButton)
          FlatIconTextButton(
            key: const ValueKey('crop-rotate-editor-Tilt-btn'),
            label: Text(_i18n.tilt, style: _defaultTextStyle),
            icon: Icon(_icons.tilt, color: _foregroundColor),
            onPressed: () {
              TiltProvider.of(context).setTiltEditorState(true);
            },
          ),
        if (widget.configs.showAspectRatioButton)
          FlatIconTextButton(
            key: const ValueKey('crop-rotate-editor-ratio-btn'),
            label: Text(_i18n.ratio, style: _defaultTextStyle),
            icon: Icon(_icons.aspectRatio, color: _foregroundColor),
            onPressed: widget.onOpenAspectRatioOptions,
          ),
        if (widget.configs.showResetButton)
          FlatIconTextButton(
            key: const ValueKey('crop-rotate-editor-reset-btn'),
            label: Text(_i18n.reset, style: _defaultTextStyle),
            icon: Icon(_icons.reset, color: _foregroundColor),
            onPressed: widget.onReset,
          ),
      ],
    );
  }
}
