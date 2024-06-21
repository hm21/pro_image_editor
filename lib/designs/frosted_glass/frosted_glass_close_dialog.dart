// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:pro_image_editor/pro_image_editor.dart';
import 'frosted_glass_effect.dart';

class FrostedGlassCloseDialog extends StatelessWidget {
  final ProImageEditorState editor;

  const FrostedGlassCloseDialog({
    super.key,
    required this.editor,
  });

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
