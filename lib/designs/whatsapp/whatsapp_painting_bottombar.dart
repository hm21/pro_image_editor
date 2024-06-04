// Flutter imports:
import 'package:flutter/material.dart';
import 'package:pro_image_editor/designs/whatsapp/whatsapp_color_picker.dart';

// Project imports:
import 'package:pro_image_editor/pro_image_editor.dart';

/// Represents the bottom bar for the paint functionality in the WhatsApp theme.
class WhatsAppPaintBottomBar extends StatefulWidget {
  /// The configuration for the image editor.
  final ProImageEditorConfigs configs;

  /// The current stroke width.
  final double strokeWidth;

  /// Callback function for setting the stroke width.
  final Function(double value) onSetLineWidth;
  final Color initColor;
  final ValueChanged<Color> onColorChanged;

  const WhatsAppPaintBottomBar({
    super.key,
    required this.configs,
    required this.strokeWidth,
    required this.onSetLineWidth,
    required this.initColor,
    required this.onColorChanged,
  });

  @override
  State<WhatsAppPaintBottomBar> createState() => _WhatsAppPaintBottomBarState();
}

class _WhatsAppPaintBottomBarState extends State<WhatsAppPaintBottomBar> {
  final double _space = 10;

  bool _showColorPicker = true;

  bool get _isMaterial =>
      widget.configs.designMode == ImageEditorDesignModeE.material;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: _space,
      left: _space,
      right: 0,
      height: 40,
      child: !_isMaterial
          ? _buildPaintModes()
          : Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                IconButton(
                  onPressed: () {
                    setState(() {
                      _showColorPicker = !_showColorPicker;
                    });
                  },
                  icon: Icon(
                    _showColorPicker ? Icons.draw : Icons.color_lens,
                  ),
                  style: IconButton.styleFrom(backgroundColor: Colors.black38),
                ),
                Container(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 14.0, vertical: 4),
                  width: 1.5,
                  decoration: BoxDecoration(
                    color: Colors.white54,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                _showColorPicker
                    ? Expanded(
                        child: WhatsappColorPicker(
                          onColorChanged: widget.onColorChanged,
                          initColor: widget.initColor,
                        ),
                      )
                    : _buildPaintModes(),
              ],
            ),
    );
  }

  Widget _buildPaintModes() {
    ButtonStyle buttonStyle = IconButton.styleFrom(
      backgroundColor: Colors.black38,
      foregroundColor: widget
          .configs.imageEditorTheme.paintingEditor.bottomBarInactiveItemColor,
      padding: const EdgeInsets.all(10),
      iconSize: 22,
      minimumSize: const Size.fromRadius(10),
    );
    return Wrap(
      alignment: _isMaterial ? WrapAlignment.start : WrapAlignment.spaceEvenly,
      runAlignment: WrapAlignment.center,
      spacing: 10,
      children: [
        IconButton(
          onPressed: () {
            widget.onSetLineWidth(2);
          },
          icon:
              Icon(widget.configs.icons.paintingEditor.whatsAppStrokeWidthThin),
          style: buttonStyle.copyWith(
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
            widget.onSetLineWidth(5);
          },
          icon: Icon(
            widget.configs.icons.paintingEditor.whatsAppStrokeWidthMedium,
          ),
          style: buttonStyle.copyWith(
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
            widget.onSetLineWidth(10);
          },
          icon:
              Icon(widget.configs.icons.paintingEditor.whatsAppStrokeWidthBold),
          style: buttonStyle.copyWith(
            backgroundColor: widget.strokeWidth != 10
                ? null
                : const WidgetStatePropertyAll(Colors.white),
            foregroundColor: widget.strokeWidth != 10
                ? null
                : const WidgetStatePropertyAll(Colors.black),
          ),
        ),

        /// TODO: Add pixelate button
      ],
    );
  }
}
