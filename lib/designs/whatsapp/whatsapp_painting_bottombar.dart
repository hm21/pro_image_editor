import 'package:flutter/material.dart';
import 'package:pro_image_editor/models/editor_configs/pro_image_editor_configs.dart';

/// Represents the bottom bar for the paint functionality in the WhatsApp theme.
class WhatsAppPaintBottomBar extends StatefulWidget {
  /// The configuration for the image editor.
  final ProImageEditorConfigs configs;

  /// The current stroke width.
  final double strokeWidth;

  /// Callback function for setting the stroke width.
  final Function(double value) onSetLineWidth;

  const WhatsAppPaintBottomBar({
    super.key,
    required this.configs,
    required this.strokeWidth,
    required this.onSetLineWidth,
  });

  @override
  State<WhatsAppPaintBottomBar> createState() => _WhatsAppPaintBottomBarState();
}

class _WhatsAppPaintBottomBarState extends State<WhatsAppPaintBottomBar> {
  final double _space = 10;

  @override
  Widget build(BuildContext context) {
    ButtonStyle buttonStyle = IconButton.styleFrom(
      backgroundColor: Colors.transparent,
      foregroundColor: widget
          .configs.imageEditorTheme.paintingEditor.bottomBarInactiveItemColor,
      padding: const EdgeInsets.all(10),
      iconSize: 22,
      minimumSize: const Size.fromRadius(10),
    );

    return Positioned(
      bottom: _space,
      left: _space,
      right: _space,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          IconButton(
            onPressed: () {
              widget.onSetLineWidth(2);
            },
            icon: Icon(
                widget.configs.icons.paintingEditor.whatsAppStrokeWidthThin),
            style: buttonStyle.copyWith(
              backgroundColor: widget.strokeWidth != 2
                  ? null
                  : const WidgetStatePropertyAll(Colors.white24),
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
                  : const WidgetStatePropertyAll(Colors.white24),
            ),
          ),
          IconButton(
            onPressed: () {
              widget.onSetLineWidth(10);
            },
            icon: Icon(
                widget.configs.icons.paintingEditor.whatsAppStrokeWidthBold),
            style: buttonStyle.copyWith(
              backgroundColor: widget.strokeWidth != 10
                  ? null
                  : const WidgetStatePropertyAll(Colors.white24),
            ),
          ),

          /// TODO: Add pixelate button
        ],
      ),
    );
  }
}
