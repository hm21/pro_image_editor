// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:pro_image_editor/pro_image_editor.dart';
import 'frosted_glass_effect.dart';

/// A custom app bar widget that creates a frosted glass effect for the
/// Tune Editor.
///
/// This widget is used to display the app bar with a frosted glass style
/// on top of the Tune Editor.
class FrostedGlassTuneAppbar extends StatelessWidget {
  /// Creates a [FrostedGlassTuneAppbar] with the provided [tuneEditor] state.
  ///
  /// The [tuneEditor] parameter is required to access the state of the
  /// Tune Editor.
  const FrostedGlassTuneAppbar({
    super.key,
    required this.tuneEditor,
  });

  /// The current state of the [TuneEditor].
  ///
  /// This provides access to the Tune Editor's state and enables
  /// interaction with its features.
  final TuneEditorState tuneEditor;

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
                    tooltip: tuneEditor.configs.i18n.cancel,
                    onPressed: tuneEditor.close,
                    icon: Icon(
                      tuneEditor.configs.icons.closeEditor,
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
                        tooltip: tuneEditor.configs.i18n.undo,
                        onPressed: tuneEditor.undo,
                        icon: Icon(
                          tuneEditor.configs.icons.undoAction,
                          color: tuneEditor.canUndo
                              ? Colors.white
                              : Colors.white.withAlpha(80),
                        ),
                      ),
                      const SizedBox(width: 3),
                      IconButton(
                        tooltip: tuneEditor.configs.i18n.redo,
                        onPressed: tuneEditor.redo,
                        icon: Icon(
                          tuneEditor.configs.icons.redoAction,
                          color: tuneEditor.canRedo
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
                    tooltip: tuneEditor.configs.i18n.done,
                    onPressed: tuneEditor.done,
                    icon: Icon(
                      tuneEditor.configs.icons.doneIcon,
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
