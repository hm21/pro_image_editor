import 'dart:math';

import 'package:flutter/material.dart';

import '/core/models/editor_configs/pro_image_editor_configs.dart';
import '/shared/extensions/double_extension.dart';
import '/shared/widgets/flat_icon_text_button.dart';
import '../enums/tilt_mode_enum.dart';
import 'tilt_ruler.dart';

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
    required this.tiltRotate,
    required this.tiltVertical,
    required this.tiltHorizontal,
    required this.onTiltChangeUpdate,
    required this.onTiltChangeEnd,
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

  /// The current rotation angle applied during tilt interaction.
  final double tiltRotate;

  /// The current vertical tilt value (up/down).
  final double tiltVertical;

  /// The current horizontal tilt value (left/right).
  final double tiltHorizontal;

  /// Called while the tilt value is changing. Provides the active [TiltMode]
  /// and the updated tilt [value].
  final Function(TiltMode mode, double value) onTiltChangeUpdate;

  /// Called when the tilt gesture ends. Provides the last active [TiltMode]
  /// and the final tilt [value].
  final Function(TiltMode mode, double value) onTiltChangeEnd;

  @override
  State<CropEditorBottombar> createState() => _CropEditorBottombarState();
}

class _CropEditorBottombarState extends State<CropEditorBottombar> {
  TiltConfigs get _tiltConfigs => widget.configs.tiltConfigs;
  Color get _foregroundColor => widget.configs.style.bottomBarColor;

  bool _isTiltMode = false;
  TiltMode _tiltMode = TiltMode.rotate;

  late final _i18n = widget.i18n;
  late final _icons = widget.configs.icons;

  late final _defaultTextStyle =
      TextStyle(fontSize: 10.0, color: _foregroundColor);
  int _resetCount = 0;

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: widget.theme,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedSize(
            duration: const Duration(milliseconds: 300),
            child: _isTiltMode
                ? _buildTiltSlider()
                : const SizedBox(width: double.infinity),
          ),
          Scrollbar(
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
                        child: _isTiltMode ? _buildTiltItems() : _buildItems(),
                      ),
                    );
                  }),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _buttonColor(TiltMode mode) {
    return mode == _tiltMode
        ? widget.configs.style.tiltStyle.bottomBarSelectedColor
        : _foregroundColor;
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
              _isTiltMode = true;
              setState(() {});
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

  Widget _buildTiltItems() {
    return widget.configs.widgets.tiltWidgets.bottomBar ??
        Row(
          children: <Widget>[
            FlatIconTextButton(
              label: Text(_i18n.back, style: _defaultTextStyle),
              icon: Icon(_icons.backButton, color: _foregroundColor),
              onPressed: () {
                _isTiltMode = false;
                setState(() {});
              },
            ),
            _buildDivider(),
            if (widget.configs.tiltConfigs.showTiltRotate)
              FlatIconTextButton(
                label: Text(
                  _i18n.tiltRotate,
                  style: _defaultTextStyle.copyWith(
                    color: _buttonColor(TiltMode.rotate),
                  ),
                ),
                icon: Icon(
                  _icons.tiltRotate,
                  color: _buttonColor(TiltMode.rotate),
                ),
                onPressed: () {
                  _tiltMode = TiltMode.rotate;
                  setState(() {});
                },
              ),
            if (widget.configs.tiltConfigs.showTiltHorizontal)
              FlatIconTextButton(
                label: Text(
                  _i18n.tiltHorizontal,
                  style: _defaultTextStyle.copyWith(
                    color: _buttonColor(TiltMode.horizontal),
                  ),
                ),
                icon: Icon(
                  _icons.tiltHorizontal,
                  color: _buttonColor(TiltMode.horizontal),
                ),
                onPressed: () {
                  _tiltMode = TiltMode.horizontal;
                  setState(() {});
                },
              ),
            if (widget.configs.tiltConfigs.showTiltVertical)
              FlatIconTextButton(
                label: Text(
                  _i18n.tiltVertical,
                  style: _defaultTextStyle.copyWith(
                    color: _buttonColor(TiltMode.vertical),
                  ),
                ),
                icon: Icon(
                  _icons.tiltVertical,
                  color: _buttonColor(TiltMode.vertical),
                ),
                onPressed: () {
                  _tiltMode = TiltMode.vertical;
                  setState(() {});
                },
              ),
            _buildDivider(),
            FlatIconTextButton(
              label: Text(_i18n.reset, style: _defaultTextStyle),
              icon: Icon(_icons.reset, color: _foregroundColor),
              onPressed: () {
                widget.onTiltChangeUpdate(TiltMode.rotate, 0);
                widget.onTiltChangeUpdate(TiltMode.horizontal, 0);
                widget.onTiltChangeEnd(TiltMode.vertical, 0);
                _resetCount++;
                setState(() {});
              },
            ),
          ],
        );
  }

  Widget _buildTiltSlider() {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 100),
      child: switch (_tiltMode) {
        TiltMode.rotate => TiltRuler(
            key: ValueKey('Tilt-Ruler-Rotate-$_resetCount'),
            value: widget.tiltRotate,
            min: _tiltConfigs.tiltRotateMin.degToRad,
            max: _tiltConfigs.tiltRotateMax.degToRad,
            configs: widget.configs,
            onChangeUpdate: (val) => widget.onTiltChangeUpdate(_tiltMode, val),
            onChangeEnd: (val) => widget.onTiltChangeEnd(_tiltMode, val),
          ),
        TiltMode.horizontal => TiltRuler(
            key: ValueKey('Tilt-Ruler-Horizontal-$_resetCount'),
            value: widget.tiltHorizontal,
            min: _tiltConfigs.tiltHorizontalMin.degToRad,
            max: _tiltConfigs.tiltHorizontalMax.degToRad,
            configs: widget.configs,
            onChangeUpdate: (val) => widget.onTiltChangeUpdate(_tiltMode, val),
            onChangeEnd: (val) => widget.onTiltChangeEnd(_tiltMode, val),
          ),
        TiltMode.vertical => TiltRuler(
            key: ValueKey('Tilt-Ruler-Vertical-$_resetCount'),
            value: widget.tiltVertical,
            min: _tiltConfigs.tiltVerticalMin.degToRad,
            max: _tiltConfigs.tiltVerticalMax.degToRad,
            configs: widget.configs,
            onChangeUpdate: (val) => widget.onTiltChangeUpdate(_tiltMode, val),
            onChangeEnd: (val) => widget.onTiltChangeEnd(_tiltMode, val),
          ),
      },
    );
  }

  Widget _buildDivider() {
    return const VerticalDivider(indent: 10, endIndent: 10, width: 10);
  }
}
