// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '/features/clips_editor/pages/clips_editor_page.dart';
import '../frosted_glass_effect.dart';

/// A frosted glass-style app bar for the clips editor.
class FrostedGlassClipsAppbar extends StatelessWidget {
  /// Creates a [FrostedGlassClipsAppbar].
  const FrostedGlassClipsAppbar({
    super.key,
    required this.editorState,
  });

  /// The current clips editor state.
  final ClipsEditorPageState editorState;

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
