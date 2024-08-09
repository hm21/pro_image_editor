// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:pro_image_editor/pro_image_editor.dart';
import 'frosted_glass_effect.dart';

/// A stateless widget that represents an app bar with a frosted glass blur
/// effect.
/// This widget is specifically designed to be used within an image editing
/// application,
/// providing a visually appealing interface for interacting with the blur
/// editor.
class FrostedGlassBlurAppbar extends StatelessWidget {
  /// Creates a [FrostedGlassBlurAppbar].
  ///
  /// The [blurEditor] parameter is required to configure the app bar's
  /// behavior, allowing it to interact with the blur editor's state and manage
  /// image blur effects.
  ///
  /// Example:
  /// ```
  /// FrostedGlassBlurAppbar(
  ///   blurEditor: myBlurEditorState,
  /// )
  /// ```
  const FrostedGlassBlurAppbar({
    super.key,
    required this.blurEditor,
  });

  /// The configuration for the blur editor.
  ///
  /// This field provides access to the state of the [BlurEditorState] instance.
  /// It allows the app bar to interact with the blur editor, enabling
  /// functionality such as applying or modifying blur effects on the image.
  final BlurEditorState blurEditor;

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
                    tooltip: blurEditor.configs.i18n.cancel,
                    onPressed: blurEditor.close,
                    icon: Icon(
                      blurEditor.configs.icons.closeEditor,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              Hero(
                tag: 'frosted-glass-done-btn',
                child: FrostedGlassEffect(
                  child: IconButton(
                    tooltip: blurEditor.configs.i18n.done,
                    onPressed: blurEditor.done,
                    icon: Icon(
                      blurEditor.configs.icons.doneIcon,
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
