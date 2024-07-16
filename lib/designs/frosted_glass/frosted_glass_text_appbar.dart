// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:pro_image_editor/pro_image_editor.dart';
import 'frosted_glass_effect.dart';

class FrostedGlassTextAppbar extends StatelessWidget {
  final TextEditorState textEditor;

  const FrostedGlassTextAppbar({super.key, required this.textEditor});

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
                  color: Colors.white12,
                  child: IconButton(
                    tooltip: textEditor.configs.i18n.cancel,
                    onPressed: textEditor.close,
                    icon: Icon(
                      textEditor.configs.icons.closeEditor,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              Hero(
                tag: 'frosted-glass-top-center-bar',
                child: FrostedGlassEffect(
                  color: Colors.white12,
                  padding: const EdgeInsets.symmetric(horizontal: 7),
                  child: Row(
                    children: [
                      IconButton(
                        tooltip: textEditor.i18n.textEditor.textAlign,
                        onPressed: textEditor.toggleTextAlign,
                        icon: Icon(textEditor.align == TextAlign.left
                            ? textEditor.icons.textEditor.alignLeft
                            : textEditor.align == TextAlign.right
                                ? textEditor.icons.textEditor.alignRight
                                : textEditor.icons.textEditor.alignCenter),
                      ),
                      const SizedBox(width: 3),
                      IconButton(
                        tooltip: textEditor.i18n.textEditor.backgroundMode,
                        onPressed: textEditor.toggleBackgroundMode,
                        icon: Icon(textEditor.icons.textEditor.backgroundMode),
                      ),
                    ],
                  ),
                ),
              ),
              Hero(
                tag: 'frosted-glass-done-btn',
                child: FrostedGlassEffect(
                  color: Colors.white12,
                  child: IconButton(
                    tooltip: textEditor.configs.i18n.done,
                    onPressed: textEditor.done,
                    icon: Icon(
                      textEditor.configs.icons.doneIcon,
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
