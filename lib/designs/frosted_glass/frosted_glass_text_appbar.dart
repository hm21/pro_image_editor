// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:pro_image_editor/pro_image_editor.dart';
import 'frosted_glass_effect.dart';

/// A stateless widget that represents an app bar with a frosted glass effect.
///
/// This app bar is designed for use in a text editor interface, providing
/// a stylish and functional header that integrates with text editing
/// operations.
class FrostedGlassTextAppbar extends StatelessWidget {
  /// Creates a [FrostedGlassTextAppbar].
  ///
  /// This app bar utilizes a frosted glass effect to enhance the visual design
  /// of a text editor, offering controls and options relevant to text editing.
  ///
  /// Example:
  /// ```
  /// FrostedGlassTextAppbar(
  ///   textEditor: myTextEditorState,
  /// )
  /// ```
  const FrostedGlassTextAppbar({super.key, required this.textEditor});

  /// The state of the text editor associated with this app bar.
  ///
  /// This state allows the app bar to interact with the text editor,
  /// providing necessary controls and options to manage text editing
  /// activities.
  final TextEditorState textEditor;

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
