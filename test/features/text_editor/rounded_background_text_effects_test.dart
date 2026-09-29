import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:pro_image_editor/features/text_editor/widgets/rounded_background_text/rounded_background_text.dart';

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
}
