// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:pro_image_editor/pro_image_editor.dart';
import 'frosted_glass_effect.dart';

/// A stateless widget that represents a dialog with a frosted glass effect,
/// designed to confirm closing an image editing session. This dialog provides
/// users with the option to close the editor or cancel the action.
class FrostedGlassCloseDialog extends StatelessWidget {
  /// Creates a [FrostedGlassCloseDialog].
  ///
  /// The [editor] parameter is required to interact with the image editor's
  /// state, allowing the dialog to access the current editing session's
  /// information.
  ///
  /// Example:
  /// ```
  /// FrostedGlassCloseDialog(
  ///   editor: myEditorState,
  /// )
  /// ```
  const FrostedGlassCloseDialog({
    super.key,
    required this.editor,
  });

  /// The configuration for the image editor.
  ///
  /// This field provides access to the state of the [ProImageEditorState]
  /// instance.
  /// It allows the dialog to interact with the image editor, ensuring that any
  /// changes or unsaved work can be considered before closing the session.
  final ProImageEditorState editor;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: DefaultTextStyle(
        style: const TextStyle(),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: FrostedGlassEffect(
            radius: BorderRadius.circular(16),
            child: Container(
              color: Colors.black26,
              constraints: const BoxConstraints(maxWidth: 350),
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Flexible(
                    child: Text(
                      editor.i18n.various.closeEditorWarningTitle,
                      style: const TextStyle(
                        fontSize: 20.0,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20.0),
                  Flexible(
                    child: Text(
                      editor.i18n.various.closeEditorWarningMessage,
                      style: const TextStyle(
                        fontSize: 14.0,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 26.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: Text(
                          editor.i18n.various.closeEditorWarningCancelBtn,
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                      const SizedBox(width: 10.0),
                      TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: Text(
                          editor.i18n.various.closeEditorWarningConfirmBtn,
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
