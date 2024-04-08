import 'package:flutter/material.dart';
import 'package:pro_image_editor/models/editor_configs/pro_image_editor_configs.dart';

import 'utils/whatsapp_appbar_button_style.dart';
import 'whatsapp_done_btn.dart';

/// Represents the app bar for the text-editor in the WhatsApp theme.
class WhatsAppTextAppBar extends StatefulWidget {
  /// The configuration for the image editor.
  final ProImageEditorConfigs configs;

  /// The alignment of the text.
  final TextAlign align;

  /// Callback function for completing the text editing.
  final Function() onDone;

  /// Callback function for changing the text alignment.
  final Function() onAlignChange;

  /// Callback function for changing the background mode for the text.
  final Function() onBackgroundModeChange;

  const WhatsAppTextAppBar({
    super.key,
    required this.configs,
    required this.align,
    required this.onDone,
    required this.onAlignChange,
    required this.onBackgroundModeChange,
  });

  @override
  State<WhatsAppTextAppBar> createState() => _WhatsAppTextAppBarState();
}

class _WhatsAppTextAppBarState extends State<WhatsAppTextAppBar> {
  final double _space = 10;

  @override
  Widget build(BuildContext context) {
    var gap = SizedBox(width: _space);

    return Positioned(
      top: _space,
      left: _space,
      right: _space,
      child: SafeArea(
        child: Stack(
          alignment: Alignment.center,
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: WhatsAppDoneBtn(
                foregroundColor: widget.configs.imageEditorTheme.paintingEditor
                    .appBarForegroundColor,
                configs: widget.configs,
                onPressed: widget.onDone,
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                IconButton(
                  style: whatsAppButtonStyle,
                  tooltip: widget.configs.i18n.textEditor.textAlign,
                  onPressed: widget.onAlignChange,
                  icon: Icon(widget.align == TextAlign.left
                      ? widget.configs.icons.textEditor.alignLeft
                      : widget.align == TextAlign.right
                          ? widget.configs.icons.textEditor.alignRight
                          : widget.configs.icons.textEditor.alignCenter),
                ),
                gap,
                IconButton(
                  style: whatsAppButtonStyle,
                  tooltip: widget.configs.i18n.textEditor.backgroundMode,
                  onPressed: widget.onBackgroundModeChange,
                  icon: Icon(widget.configs.icons.textEditor.backgroundMode),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
