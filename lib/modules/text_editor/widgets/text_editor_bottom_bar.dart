// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:pro_image_editor/pro_image_editor.dart';

/// Represents the bottom bar for the text-editor.
class TextEditorBottomBar extends StatefulWidget {
  /// Bottom bar widget for the text editor.
  ///
  /// [configs] contains configuration settings for the text editor.
  /// [selectedStyle] represents the currently selected text style.
  /// [onFontChange] callback is invoked when the font is changed.
  const TextEditorBottomBar({
    super.key,
    required this.configs,
    required this.selectedStyle,
    required this.onFontChange,
  });

  /// The configuration for the image editor.
  final ProImageEditorConfigs configs;

  /// The currently selected text style.
  final TextStyle selectedStyle;

  /// Callback function for changing the text font style.
  final Function(TextStyle style) onFontChange;

  @override
  State<TextEditorBottomBar> createState() => _TextEditorBottomBarState();
}

class _TextEditorBottomBarState extends State<TextEditorBottomBar> {
  final double _space = 10;

  @override
  Widget build(BuildContext context) {
    if (widget.configs.textEditorConfigs.customTextStyles == null) {
      return const SizedBox.shrink();
    }

    return Container(
      color:
          widget.configs.imageEditorTheme.textEditor.bottomBarBackgroundColor,
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 14),
        scrollDirection: Axis.horizontal,
        child: ConstrainedBox(
          constraints:
              BoxConstraints(minWidth: MediaQuery.of(context).size.width),
          child: Row(
            mainAxisAlignment: widget
                .configs.imageEditorTheme.textEditor.bottomBarMainAxisAlignment,
            children: _buildIconButtons(),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildIconButtons() {
    var items = widget.configs.textEditorConfigs.customTextStyles!;
    return List.generate(
      items.length,
      (index) {
        var selected = widget.selectedStyle;
        bool isSelected = selected.hashCode == items[index].hashCode;

        return Padding(
          padding: EdgeInsets.symmetric(horizontal: _space),
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
