// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '/features/audio_editor/audio_editor_page.dart';
import '../frosted_glass_effect.dart';

/// A frosted glass-style app bar for the audio editor.
class FrostedGlassAudioAppbar extends StatelessWidget {
  /// Creates a [FrostedGlassAudioAppbar].
  const FrostedGlassAudioAppbar({
    super.key,
    required this.editorState,
  });

  /// The current audio editor state.
  final AudioEditorPageState editorState;

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
                      editorState.audioEditorConfigs.icons.backButton,
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
                      editorState.audioEditorConfigs.icons.applyChanges,
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
