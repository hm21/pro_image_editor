// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:pro_image_editor/pro_image_editor.dart';
import 'frosted_glass_effect.dart';

class FrostedGlassFilterAppbar extends StatelessWidget {
  final FilterEditorState filterEditor;

  const FrostedGlassFilterAppbar({
    super.key,
    required this.filterEditor,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Hero(
                tag: 'frosted-glass-close-btn',
                child: FrostedGlassEffect(
                  child: IconButton(
                    tooltip: filterEditor.configs.i18n.cancel,
                    onPressed: filterEditor.close,
                    icon: Icon(
                      filterEditor.configs.icons.closeEditor,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              Hero(
                tag: 'frosted-glass-done-btn',
                child: FrostedGlassEffect(
                  child: IconButton(
                    tooltip: filterEditor.configs.i18n.done,
                    onPressed: filterEditor.done,
                    icon: Icon(
                      filterEditor.configs.icons.doneIcon,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
