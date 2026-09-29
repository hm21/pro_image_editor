import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:pro_image_editor/core/models/editor_configs/text_editor_configs.dart';
import 'package:pro_image_editor/features/text_editor/utils/rounded_background_painter.dart';
import 'package:pro_image_editor/features/text_editor/widgets/rounded_background_text/rounded_background_text.dart';
import 'package:pro_image_editor/features/text_editor/widgets/rounded_background_text/rounded_background_text_field.dart';

void main() {
  const style = TextStyle(fontSize: 40, color: Color(0xFFFFFFFF));
  const shadow = Shadow(
    color: Color(0x80000000),
    blurRadius: 0,
    offset: Offset(2, 4),
  );

  Future<void> pumpText(WidgetTester tester, RoundedBackgroundText text) {
    return tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: Center(child: text)),
      ),
    );
  }

  RenderObject textRenderObject(WidgetTester tester) {
    return tester.renderObject(
      find.descendant(
        of: find.byType(RoundedBackgroundText),
        matching: find.byType(CustomPaint),
      ),
    );
  }

  Size textSize(WidgetTester tester) {
    return tester.getSize(find.byType(RoundedBackgroundText));
  }

  group('RoundedBackgroundText', () {
    group('without an outline', () {
      testWidgets('paints the text in a single pass', (tester) async {
        await pumpText(
          tester,
          RoundedBackgroundText(
            'Hello',
            style: style.copyWith(shadows: const [shadow]),
            maxTextWidth: 400,
          ),
        );

        expect(
          textRenderObject(tester),
          paintsExactlyCountTimes(#drawParagraph, 1),
        );
        expect(
          textRenderObject(tester),
          paintsExactlyCountTimes(#saveLayer, 0),
        );
      });
    });

    group('with an outline', () {
      testWidgets('paints the outline pass under the text', (tester) async {
        await pumpText(
          tester,
          RoundedBackgroundText(
            'Hello',
            style: style,
            maxTextWidth: 400,
            outlineWidth: 3,
          ),
        );

        expect(
          textRenderObject(tester),
          paintsExactlyCountTimes(#drawParagraph, 2),
        );
      });

      testWidgets('casts its shadows from the outlined glyphs', (tester) async {
        await pumpText(
          tester,
          RoundedBackgroundText(
            'Hello',
            style: style.copyWith(shadows: const [shadow]),
            maxTextWidth: 400,
            outlineWidth: 3,
          ),
        );

        expect(
          textRenderObject(tester),
          paints
            ..something((method, arguments) => method == #saveLayer)
            ..paragraph()
            ..paragraph()
            ..restore()
            ..paragraph()
            ..paragraph(),
        );
      });

      testWidgets('keeps the shadow of glyphs that paint beyond their line', (
        tester,
      ) async {
        final boundaryKey = GlobalKey();
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Center(
                child: RepaintBoundary(
                  key: boundaryKey,
                  child: Padding(
                    padding: const EdgeInsets.all(60),
                    child: RoundedBackgroundText(
                      'H',
                      // A line height of 20 for a glyph that is 40 tall, so
                      // the glyph reaches 15 above its line.
                      style: style.copyWith(
                        height: 0.5,
                        shadows: const [
                          Shadow(
                            color: Color(0xFFFF0000),
                            offset: Offset(50, 0),
                          ),
                        ],
                      ),
                      maxTextWidth: 400,
                      outlineWidth: 2,
                    ),
                  ),
                ),
              ),
            ),
          ),
        );

        final boundary =
            boundaryKey.currentContext!.findRenderObject()!
                as RenderRepaintBoundary;
        final pixels = (await tester.runAsync(() async {
          final image = await boundary.toImage();
          final bytes = await image.toByteData();
          image.dispose();
          return bytes;
        }))!;

        // A point of the shadow 10 above the line, beside the glyph.
        const x = 60 + 70;
        const y = 60 - 10;
        final index = (y * boundary.size.width.round() + x) * 4;
        expect(pixels.getUint8(index), 0xFF, reason: 'red');
        expect(pixels.getUint8(index + 3), 0xFF, reason: 'alpha');
      });

      testWidgets('draws nothing extra for a transparent outline color', (
        tester,
      ) async {
        await pumpText(
          tester,
          RoundedBackgroundText(
            'Hello',
            style: style,
            maxTextWidth: 400,
            outlineWidth: 3,
            outlineColor: const Color(0x00000000),
          ),
        );

        expect(
          textRenderObject(tester),
          paintsExactlyCountTimes(#drawParagraph, 1),
        );
      });
    });

    group('reserveEffectSpace', () {
      testWidgets('grows by the outline and shadow reach on both sides', (
        tester,
      ) async {
        await pumpText(
          tester,
          RoundedBackgroundText('Hello', style: style, maxTextWidth: 400),
        );
        final plainSize = textSize(tester);

        await pumpText(
          tester,
          RoundedBackgroundText(
            'Hello',
            style: style.copyWith(shadows: const [shadow]),
            maxTextWidth: 400,
            outlineWidth: 3,
            reserveEffectSpace: true,
          ),
        );

        // Outline 3 plus the shadow offset on each axis, on both sides.
        expect(textSize(tester), plainSize + const Offset(10, 14));
      });

      testWidgets('keeps the size of text without effects', (tester) async {
        await pumpText(
          tester,
          RoundedBackgroundText('Hello', style: style, maxTextWidth: 400),
        );
        final plainSize = textSize(tester);

        await pumpText(
          tester,
          RoundedBackgroundText(
            'Hello',
            style: style,
            maxTextWidth: 400,
            reserveEffectSpace: true,
          ),
        );

        expect(textSize(tester), plainSize);
      });

      testWidgets('is not reserved unless requested', (tester) async {
        await pumpText(
          tester,
          RoundedBackgroundText('Hello', style: style, maxTextWidth: 400),
        );
        final plainSize = textSize(tester);

        await pumpText(
          tester,
          RoundedBackgroundText(
            'Hello',
            style: style.copyWith(shadows: const [shadow]),
            maxTextWidth: 400,
            outlineWidth: 3,
          ),
        );

        expect(textSize(tester), plainSize);
      });
    });
  });

  group('RoundedBackgroundTextField', () {
    testWidgets('lines the outline up with the editable glyphs', (
      tester,
    ) async {
      final controller = TextEditingController(text: 'Hello\nWorld');
      final focusNode = FocusNode();
      addTearDown(controller.dispose);
      addTearDown(focusNode.dispose);

      // The editable text lays its glyphs out with `TextEditorStyle
      // .textHeight`, which overrides a line height set on the style.
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: IntrinsicWidth(
                child: RoundedBackgroundTextField(
                  controller: controller,
                  focusNode: focusNode,
                  configs: const TextEditorConfigs(),
                  style: style.copyWith(height: 1.5),
                  maxTextWidth: 400,
                  textAlign: TextAlign.center,
                  backgroundColor: const Color(0xFF000000),
                  outlineWidth: 3,
                ),
              ),
            ),
          ),
        ),
      );

      // The first glyph of the second line, where a different line height
      // adds up.
      const selection = TextSelection(baseOffset: 6, extentOffset: 7);
      final editable = tester
          .state<EditableTextState>(find.byType(EditableText))
          .renderEditable;
      final editableBox = editable.getBoxesForSelection(selection).first;
      final editableGlyph = editable.localToGlobal(
        Offset(editableBox.left, editableBox.top),
      );

      final background = textRenderObject(tester) as RenderCustomPaint;
      final painter = background.painter! as RoundedBackgroundTextPainter;
      final outlineBox = painter.outlinePainter!
          .getBoxesForSelection(selection)
          .first;
      final outlineGlyph = background.localToGlobal(
        painter.hitBoxCorrectionOffset +
            Offset(outlineBox.left, outlineBox.top),
      );

      expect(outlineGlyph.dx, moreOrLessEquals(editableGlyph.dx, epsilon: 1));
      expect(outlineGlyph.dy, moreOrLessEquals(editableGlyph.dy, epsilon: 1));
    });
  });
}
