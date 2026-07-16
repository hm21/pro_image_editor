import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pro_image_editor/core/models/editor_configs/text_editor_configs.dart';
import 'package:pro_image_editor/features/text_editor/widgets/rounded_background_text/rounded_background_text.dart';
import 'package:pro_image_editor/features/text_editor/widgets/rounded_background_text/rounded_background_text_field.dart';

/// The in-editor text preview ([RoundedBackgroundTextField]) must render its
/// rounded background the same way the placed layer does — the layer renders a
/// [RoundedBackgroundText] with `enableHitBoxCorrection: true`. Before the fix
/// the preview passed `enableHitBoxCorrection: false`, so its background hugged
/// the glyphs and grew (becoming symmetric) the moment editing completed.
///
/// These tests lock the two halves of the fix:
///  * the background reserves the same hit-box padding (vertical + horizontal);
///  * the editable glyphs are inset by that padding and wrap at the same column
///    as the background, so nothing shifts or re-wraps on done.
void main() {
  Widget wrapPreview({
    required TextEditingController controller,
    required FocusNode focusNode,
    required TextStyle style,
    required double width,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: SizedBox(
            width: width,
            child: RoundedBackgroundTextField(
              controller: controller,
              focusNode: focusNode,
              configs: const TextEditorConfigs(),
              style: style,
              backgroundColor: Colors.white,
              textAlign: TextAlign.center,
              maxTextWidth: width,
            ),
          ),
        ),
      ),
    );
  }

  double preferredLineHeight(TextStyle style) {
    final painter = TextPainter(
      text: TextSpan(text: 'A', style: style),
      textDirection: TextDirection.ltr,
    )..layout();
    final h = painter.preferredLineHeight;
    painter.dispose();
    return h;
  }

  testWidgets(
    'preview background matches hit-box reference and insets glyphs',
    (tester) async {
      const text = 'Aaaaa';
      const style = TextStyle(fontSize: 40, color: Colors.black);
      const maxWidth = 400.0;
      final lineHeight = preferredLineHeight(style);
      final hitBoxHorizontal = lineHeight * 0.3;
      final hitBoxVertical = lineHeight * 0.1;

      // Reference: a bare RoundedBackgroundText with hit-box correction on,
      // i.e. exactly what the placed layer renders.
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
      final referenceHeight = tester
          .getSize(find.byType(RoundedBackgroundText))
          .height;

      // Preview.
      final controller = TextEditingController(text: text);
      final focusNode = FocusNode();
      addTearDown(controller.dispose);
      addTearDown(focusNode.dispose);

      await tester.pumpWidget(
        wrapPreview(
          controller: controller,
          focusNode: focusNode,
          style: style,
          width: maxWidth,
        ),
      );
      await tester.pump();

      // 1) The background reserves the same room as the reference.
      final previewBgRect = tester.getRect(find.byType(RoundedBackgroundText));
      expect(
        previewBgRect.height,
        moreOrLessEquals(referenceHeight, epsilon: 0.5),
        reason:
            'Preview background height must match the hit-box-corrected '
            'reference; a mismatch means the padding was not reserved.',
      );

      // 2) The editable glyphs are inset by the hit-box padding, so they stay
      //    centered inside the box instead of shifting on done.
      final editableRect = tester.getRect(find.byType(EditableText));
      expect(
        editableRect.left - previewBgRect.left,
        moreOrLessEquals(hitBoxHorizontal, epsilon: 1.0),
        reason:
            'Editable glyphs must be inset horizontally by the hit-box pad.',
      );
      expect(
        editableRect.top - previewBgRect.top,
        moreOrLessEquals(hitBoxVertical, epsilon: 1.0),
        reason: 'Editable glyphs must be inset vertically by the hit-box pad.',
      );
    },
  );

  testWidgets(
    'editable text and background wrap at the same column across widths',
    (tester) async {
      const text = 'one two three four five six seven eight nine ten';
      const style = TextStyle(fontSize: 30, color: Colors.black);

      final controller = TextEditingController();
      final focusNode = FocusNode();
      addTearDown(controller.dispose);
      addTearDown(focusNode.dispose);

      // Returns (editableWrapWidth, backgroundHeight) for the given text/width.
      Future<(double, double)> measure(String txt, double width) async {
        controller.text = txt;
        await tester.pumpWidget(
          wrapPreview(
            controller: controller,
            focusNode: focusNode,
            style: style,
            width: width,
          ),
        );
        await tester.pump();
        return (
          tester.getSize(find.byType(EditableText)).width,
          tester.getSize(find.byType(RoundedBackgroundText)).height,
        );
      }

      // Line count for the editable text: re-lay it at the editable's measured
      // wrap width. EditableText's own height is non-linear in line count
      // (constant caret/strut padding), so dividing it is unsafe; line breaking
      // depends only on width and glyph advances.
      int editableLineCount(double wrapWidth) {
        final painter = TextPainter(
          text: const TextSpan(text: text, style: style),
          textDirection: TextDirection.ltr,
          textAlign: TextAlign.center,
        )..layout(maxWidth: wrapWidth);
        final count = painter.computeLineMetrics().length;
        painter.dispose();
        return count;
      }

      // The background box height is linear in line count; calibrate
      // `height = lines * perLine + constant` from explicit 1- and 2-line
      // renders (the Positioned background's rect width can't reveal its wrap
      // column, so height is the reliable signal here).
      final (_, bg1) = await measure('A', 4000);
      final (_, bg2) = await measure('A\nA', 4000);
      final bgPerLine = bg2 - bg1;
      final bgConst = bg1 - bgPerLine;
      int backgroundLineCount(double height) =>
          ((height - bgConst) / bgPerLine).round();

      var sawWrapping = false;

      // Sweep a band of widths straddling wrap boundaries. The editable glyphs
      // and the background box that should hug them must break into the same
      // number of lines. The horizontal-jump regression makes the background
      // wrap at a different column than the editable text.
      for (final width in [140.0, 160.0, 180.0, 200.0, 220.0, 240.0]) {
        final (edWidth, bgHeight) = await measure(text, width);
        final editableLines = editableLineCount(edWidth);
        final backgroundLines = backgroundLineCount(bgHeight);

        if (editableLines > 1) sawWrapping = true;

        expect(
          editableLines,
          backgroundLines,
          reason:
              'At width=$width the editable text wrapped into '
              '$editableLines lines but the background box into '
              '$backgroundLines: the two disagree on the wrap column.',
        );
      }

      expect(
        sawWrapping,
        isTrue,
        reason: 'Test is vacuous unless the text actually wraps at some width.',
      );
    },
  );
}
