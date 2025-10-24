// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '/features/clips_editor/pages/clips_editor_edit_page.dart';
import '../frosted_glass_effect.dart';

/// A frosted glass-style app bar for the clip-edit editor.
class FrostedGlassClipEditAppbar extends StatelessWidget {
  /// Creates a [FrostedGlassClipEditAppbar].
  const FrostedGlassClipEditAppbar({
    super.key,
    required this.editorState,
  });

  /// The current clip editor state.
  final ClipsEditorEditPageState editorState;

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
                    tooltip: editorState.configs.i18n.cancel,
                    onPressed: editorState.close,
                    icon: Icon(
                      editorState.clipsEditorConfigs.icons.backButton,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              Hero(
                tag: 'frosted-glass-done-btn',
                child: FrostedGlassEffect(
                  child: IconButton(
                    tooltip: editorState.configs.i18n.done,
                    onPressed: editorState.done,
                    icon: Icon(
                      editorState.clipsEditorConfigs.icons.applyChanges,
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
