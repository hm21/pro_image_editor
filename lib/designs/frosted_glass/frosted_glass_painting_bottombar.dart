// Flutter imports:
import 'package:flutter/material.dart';
import 'package:pro_image_editor/designs/frosted_glass/frosted_glass.dart';

// Project imports:
import 'package:pro_image_editor/designs/whatsapp/whatsapp_color_picker.dart';
import 'package:pro_image_editor/pro_image_editor.dart';
import 'package:pro_image_editor/utils/pro_image_editor_icons.dart';

/// Represents the bottom bar for the paint functionality in the Frosted-Glass theme.
class FrostedGlassPaintBottomBar extends StatefulWidget {
  /// The configuration for the image editor.
  final ProImageEditorConfigs configs;

  /// The current stroke width.
  final double strokeWidth;

  /// Callback function for setting the stroke width.
  final Function(double value) onChangeLineWidth;
  final Function(PaintModeE value) onChangePaintMode;
  final Color initColor;
  final ValueChanged<Color> onColorChanged;

  final IconData iconStrokeWidthThin;
  final IconData iconStrokeWidthMedium;
  final IconData iconStrokeWidthBold;

  final List<PaintModeBottomBarItem> paintModes;
  final PaintModeE selectedPaintMode;

  const FrostedGlassPaintBottomBar({
    super.key,
    required this.configs,
    required this.strokeWidth,
    required this.onChangeLineWidth,
    required this.onChangePaintMode,
    required this.initColor,
    required this.onColorChanged,
    required this.paintModes,
    required this.selectedPaintMode,
    this.iconStrokeWidthThin = ProImageEditorIcons.penSize1,
    this.iconStrokeWidthMedium = ProImageEditorIcons.penSize2,
    this.iconStrokeWidthBold = ProImageEditorIcons.penSize3,
  });

  @override
  State<FrostedGlassPaintBottomBar> createState() =>
      _FrostedGlassPaintBottomBarState();
}

class _FrostedGlassPaintBottomBarState
    extends State<FrostedGlassPaintBottomBar> {
  _Mode _mode = _Mode.color;

  late ButtonStyle _buttonStyle;

  @override
  void initState() {
    _buttonStyle = IconButton.styleFrom(
      backgroundColor: Colors.black38,
      foregroundColor: widget
          .configs.imageEditorTheme.paintingEditor.bottomBarInactiveItemColor,
      padding: const EdgeInsets.all(10),
      iconSize: 22,
      minimumSize: const Size.fromRadius(10),
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      height: 48,
      child: FrostedGlassEffect(
        radius: BorderRadius.zero,
        child: Padding(
          padding: const EdgeInsets.all(3),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              IconButton(
                onPressed: () {
                  setState(() {
                    _mode = _mode == _Mode.color
                        ? _Mode.lineWidth
                        : _mode == _Mode.lineWidth
                            ? _Mode.mode
                            : _Mode.color;
                  });
                },
                icon: Icon(
                  _mode == _Mode.color
                      ? Icons.draw
                      : _mode == _Mode.lineWidth
                          ? Icons.category
                          : Icons.color_lens,
                ),
                style: IconButton.styleFrom(backgroundColor: Colors.black38),
              ),
              Container(
                margin: const EdgeInsets.fromLTRB(14, 2, 0, 2),
                width: 1.5,
                decoration: BoxDecoration(
                  color: Colors.white54,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              _mode == _Mode.color
                  ? Expanded(
                      child: WhatsAppColorPicker(
                        onColorChanged: widget.onColorChanged,
                        initColor: widget.initColor,
                      ),
                    )
                  : _mode == _Mode.lineWidth
                      ? _buildLineWidth()
                      : _buildModes(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLineWidth() {
    return Expanded(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 14),
        child: Wrap(
          alignment: WrapAlignment.start,
          runAlignment: WrapAlignment.center,
          spacing: 10,
          children: [
            IconButton(
              onPressed: () {
                widget.onChangeLineWidth(2);
              },
              icon: Icon(widget.iconStrokeWidthThin),
              style: _buttonStyle.copyWith(
                backgroundColor: widget.strokeWidth != 2
                    ? null
                    : const WidgetStatePropertyAll(Colors.white),
                foregroundColor: widget.strokeWidth != 2
                    ? null
                    : const WidgetStatePropertyAll(Colors.black),
              ),
            ),
            IconButton(
              onPressed: () {
                widget.onChangeLineWidth(5);
              },
              icon: Icon(widget.iconStrokeWidthMedium),
              style: _buttonStyle.copyWith(
                backgroundColor: widget.strokeWidth != 5
                    ? null
                    : const WidgetStatePropertyAll(Colors.white),
                foregroundColor: widget.strokeWidth != 5
                    ? null
                    : const WidgetStatePropertyAll(Colors.black),
              ),
            ),
            IconButton(
              onPressed: () {
                widget.onChangeLineWidth(10);
              },
              icon: Icon(widget.iconStrokeWidthBold),
              style: _buttonStyle.copyWith(
                backgroundColor: widget.strokeWidth != 10
                    ? null
                    : const WidgetStatePropertyAll(Colors.white),
                foregroundColor: widget.strokeWidth != 10
                    ? null
                    : const WidgetStatePropertyAll(Colors.black),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModes() {
    return Expanded(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 14),
        scrollDirection: Axis.horizontal,
        child: Wrap(
          alignment: WrapAlignment.start,
          runAlignment: WrapAlignment.center,
          spacing: 10,
          children: List.generate(widget.paintModes.length, (i) {
            PaintModeBottomBarItem item = widget.paintModes[i];
            bool isSelected = widget.selectedPaintMode == item.mode;
            return IconButton(
              onPressed: () {
                widget.onChangePaintMode(item.mode);
              },
              tooltip: item.label,
              icon: Icon(item.icon),
              style: _buttonStyle.copyWith(
                  backgroundColor: !isSelected
                      ? null
                      : const WidgetStatePropertyAll(Colors.white),
                  foregroundColor: !isSelected
                      ? null
                      : const WidgetStatePropertyAll(Colors.black)),
            );
          }),
        ),
      ),
    );
  }
}

enum _Mode { color, lineWidth, mode }
