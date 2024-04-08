import 'package:flutter/material.dart';
import 'package:pro_image_editor/models/editor_configs/pro_image_editor_configs.dart';

/// Represents the bottom bar for the text-editor in the WhatsApp theme.
class WhatsAppTextBottomBar extends StatefulWidget {
  /// The configuration for the image editor.
  final ProImageEditorConfigs configs;

  /// The currently selected text style.
  final TextStyle selectedStyle;

  /// Callback function for changing the text font style.
  final Function(TextStyle style) onFontChange;

  const WhatsAppTextBottomBar({
    super.key,
    required this.configs,
    required this.selectedStyle,
    required this.onFontChange,
  });

  @override
  State<WhatsAppTextBottomBar> createState() => _WhatsAppTextBottomBarState();
}

class _WhatsAppTextBottomBarState extends State<WhatsAppTextBottomBar> {
  final double _space = 10;

  @override
  Widget build(BuildContext context) {
    if (widget.configs.textEditorConfigs.whatsAppCustomTextStyles == null) {
      return const SizedBox.shrink();
    }

    return Positioned(
      bottom: _space,
      left: 0,
      right: 0,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: ConstrainedBox(
          constraints:
              BoxConstraints(minWidth: MediaQuery.of(context).size.width),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: _buildIconBtns(),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildIconBtns() {
    var items = widget.configs.textEditorConfigs.whatsAppCustomTextStyles!;
    return List.generate(
      items.length,
      (index) {
        var selected = widget.selectedStyle;
        bool isSelected = selected.hashCode == items[index].hashCode;

        return Padding(
          padding: EdgeInsets.symmetric(horizontal: _space / 2),
          child: IconButton(
            onPressed: () => widget.onFontChange(items[index]),
            icon: Text(
              'Aa',
              style: items[index].copyWith(
                color: isSelected ? Colors.black : Colors.white,
              ),
            ),
            style: IconButton.styleFrom(
              backgroundColor: isSelected ? Colors.white : Colors.black38,
              foregroundColor: isSelected ? Colors.black : Colors.white,
            ),
          ),
        );
      },
    );
  }
}
