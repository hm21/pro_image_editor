import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pro_image_editor/core/models/editor_configs/text_editor_configs.dart';
import 'package:pro_image_editor/features/text_editor/widgets/rounded_background_text/rounded_background_text.dart';
import 'package:pro_image_editor/features/text_editor/widgets/rounded_background_text/rounded_background_text_field.dart';

/// The in-editor text preview ([RoundedBackgroundTextField]) must reserve the
/// same hit-box padding around its rounded background as the finished layer
/// ([LayerWidgetTextItem], which renders [RoundedBackgroundText] with
/// `enableHitBoxCorrection: true`).
///
/// Previously the preview passed `enableHitBoxCorrection: false`, so the
/// background box hugged the glyphs and the reserved room differed from the
/// finished layer — the box visibly grew (and became left/right symmetric) the
/// moment editing completed. This test locks the preview and the finished
/// render to the same background box height.
void main() {
  const text = 'Aaaaa';
  const style = TextStyle(fontSize: 40, color: Colors.black);
  const maxWidth = 400.0;

  testWidgets(
    'editing preview reserves the same background height as the finished layer',
    (tester) async {
      // 1) Finished layer render (source of truth).
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: SizedBox(
                width: maxWidth,
                child: RoundedBackgroundText(
                  text,
                  style: style,
                  backgroundColor: Colors.white,
                  maxTextWidth: maxWidth,
                  enableHitBoxCorrection: true,
                ),
              ),
            ),
          ),
        ),
      );
      final finishedHeight =
          tester.getSize(find.byType(RoundedBackgroundText)).height;

      // 2) In-editor preview render.
      final controller = TextEditingController(text: text);
      final focusNode = FocusNode();
      addTearDown(controller.dispose);
      addTearDown(focusNode.dispose);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: SizedBox(
                width: maxWidth,
                child: RoundedBackgroundTextField(
                  controller: controller,
                  focusNode: focusNode,
                  configs: const TextEditorConfigs(),
                  style: style,
                  backgroundColor: Colors.white,
                  textAlign: TextAlign.center,
                  maxTextWidth: maxWidth,
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pump();

      final previewHeight =
          tester.getSize(find.byType(RoundedBackgroundText)).height;

      // The reserved hit-box room is line-height * 0.1 on top and bottom. If the
      // preview dropped the correction it would be ~0.2 * line-height shorter.
      expect(
        previewHeight,
        moreOrLessEquals(finishedHeight, epsilon: 0.5),
        reason:
            'Preview background height ($previewHeight) must match the finished '
            'layer ($finishedHeight); a mismatch means the hit-box padding was '
            'not reserved while editing.',
      );
    },
  );
}
