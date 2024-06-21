// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:pro_image_editor/pro_image_editor.dart';
import 'frosted_glass_effect.dart';

class FrostedGlassPaintingAppbar extends StatelessWidget {
  final PaintingEditorState paintEditor;

  const FrostedGlassPaintingAppbar({
    super.key,
    required this.paintEditor,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Hero(
              tag: 'frosted-glass-close-btn',
              child: FrostedGlassEffect(
                child: IconButton(
                  tooltip: paintEditor.configs.i18n.cancel,
                  onPressed: paintEditor.close,
                  icon: Icon(
                    paintEditor.configs.icons.closeEditor,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            Hero(
              tag: 'frosted-glass-top-center-bar',
              child: FrostedGlassEffect(
                padding: const EdgeInsets.symmetric(horizontal: 7),
                child: Row(
                  children: [
                    IconButton(
                      tooltip: paintEditor.configs.i18n.undo,
                      onPressed: paintEditor.undoAction,
                      icon: Icon(
                        paintEditor.configs.icons.undoAction,
                        color: paintEditor.canUndo
                            ? Colors.white
                            : Colors.white.withAlpha(80),
                      ),
                    ),
                    const SizedBox(width: 3),
                    IconButton(
                      tooltip: paintEditor.configs.i18n.redo,
                      onPressed: paintEditor.redoAction,
                      icon: Icon(
                        paintEditor.configs.icons.redoAction,
                        color: paintEditor.canRedo
                            ? Colors.white
                            : Colors.white.withAlpha(80),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Hero(
              tag: 'frosted-glass-done-btn',
              child: FrostedGlassEffect(
                child: IconButton(
                  tooltip: paintEditor.configs.i18n.done,
                  onPressed: paintEditor.done,
                  icon: Icon(
                    paintEditor.configs.icons.doneIcon,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
