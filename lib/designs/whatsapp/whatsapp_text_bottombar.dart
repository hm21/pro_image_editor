// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:pro_image_editor/designs/whatsapp/whatsapp_color_picker.dart';
import 'package:pro_image_editor/pro_image_editor.dart';
import '../../modules/text_editor/widgets/text_editor_bottom_bar.dart';

class WhatsAppTextBottomBar extends StatefulWidget {
  /// The configuration for the image editor.
  final ProImageEditorConfigs configs;

  final Color initColor;
  final ValueChanged<Color> onColorChanged;

  /// The currently selected text style.
  final TextStyle selectedStyle;

  /// Callback function for changing the text font style.
  final Function(TextStyle style) onFontChange;

  const WhatsAppTextBottomBar({
    super.key,
    required this.configs,
    required this.initColor,
    required this.onColorChanged,
    required this.selectedStyle,
    required this.onFontChange,
  });

  @override
  State<WhatsAppTextBottomBar> createState() => _WhatsAppTextBottomBarState();
}

class _WhatsAppTextBottomBarState extends State<WhatsAppTextBottomBar> {
  final double _space = 10;

  bool _showColorPicker = true;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: _space + MediaQuery.of(context).viewPadding.bottom,
      left: _space,
      right: 0,
      height: 40,
      child: widget.configs.designMode == ImageEditorDesignModeE.cupertino
          ? TextEditorBottomBar(
              configs: widget.configs,
              selectedStyle: widget.selectedStyle,
              onFontChange: widget.onFontChange,
            )
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
                  icon: !_showColorPicker
                      ? const Icon(Icons.color_lens)
                      : Text(
                          'Aa',
                          style: widget.configs.textEditorConfigs
                              .customTextStyles?.first,
                        ),
                  style: IconButton.styleFrom(backgroundColor: Colors.black38),
                ),
                Container(
                  margin: const EdgeInsets.fromLTRB(14.0, 4, 0, 4),
                  width: 1.5,
                  decoration: BoxDecoration(
                    color: Colors.white54,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                _showColorPicker
                    ? Expanded(
                        child: WhatsAppColorPicker(
                          onColorChanged: widget.onColorChanged,
                          initColor: widget.initColor,
                        ),
                      )
                    : Expanded(
                        child: TextEditorBottomBar(
                          configs: widget.configs,
                          selectedStyle: widget.selectedStyle,
                          onFontChange: widget.onFontChange,
                        ),
                      ),
              ],
            ),
    );
  }
}
