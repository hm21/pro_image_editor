import 'package:flutter/material.dart';
import 'package:pro_image_editor/pro_image_editor.dart';

/// Represents the bottom bar for the text-editor.
class TextEditorBottomBar extends StatefulWidget {
  /// The configuration for the image editor.
  final ProImageEditorConfigs configs;

  /// The currently selected text style.
  final TextStyle selectedStyle;

  /// Callback function for changing the text font style.
  final Function(TextStyle style) onFontChange;

  const TextEditorBottomBar({
    super.key,
    required this.configs,
    required this.selectedStyle,
    required this.onFontChange,
  });

  @override
  State<TextEditorBottomBar> createState() => _TextEditorBottomBarState();
}

class _TextEditorBottomBarState extends State<TextEditorBottomBar> {
  final double _space = 10;

  bool get _isSimpleEditor =>
      widget.configs.imageEditorTheme.editorMode == ThemeEditorMode.simple;

  @override
  Widget build(BuildContext context) {
    if (widget.configs.textEditorConfigs.customTextStyles == null) {
      return const SizedBox.shrink();
    }

    return Positioned(
      bottom: _isSimpleEditor ? 0 : _space,
      left: 0,
      right: 0,
      height: _isSimpleEditor ? kBottomNavigationBarHeight : null,
      child: Container(
        color: _isSimpleEditor
            ? widget
                .configs.imageEditorTheme.textEditor.bottomBarBackgroundColor
            : null,
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
      ),
    );
  }

  List<Widget> _buildIconBtns() {
    var items = widget.configs.textEditorConfigs.customTextStyles!;
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
