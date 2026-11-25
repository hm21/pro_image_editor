import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:pro_image_editor/core/models/layers/text_layer_box.dart';
import 'package:pro_image_editor/features/text_editor/utils/rounded_background_painter.dart';
import 'package:pro_image_editor/features/text_editor/widgets/rounded_background_text/rounded_background_text.dart';

void main() {
  const shadow = Shadow(
    color: Color(0x80000000),
    blurRadius: 6,
    offset: Offset(4, 8),
  );

  Future<void> pumpText(WidgetTester tester, RoundedBackgroundText text) {
    return tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: OverflowBox(
            maxWidth: double.infinity,
            maxHeight: double.infinity,
            child: text,
          ),
        ),
      ),
    );
  }

  RoundedBackgroundTextPainter painterOf(WidgetTester tester) {
    final renderObject = tester.renderObject<RenderCustomPaint>(
      find.descendant(
        of: find.byType(RoundedBackgroundText),
        matching: find.byType(CustomPaint),
      ),
    );
    return renderObject.painter! as RoundedBackgroundTextPainter;
  }

  group('RoundedBackgroundText', () {
    group('large text', () {
      testWidgets('draws text up to 64 pixels from its own font', (
        tester,
      ) async {
        await pumpText(
          tester,
          RoundedBackgroundText(
            'Hello',
            style: const TextStyle(fontSize: 64),
            maxTextWidth: double.infinity,
          ),
        );

        expect(painterOf(tester).scaledText, isEmpty);
      });

      testWidgets('draws larger text from a smaller font', (tester) async {
        await pumpText(
          tester,
          RoundedBackgroundText(
            'Hello',
            style: const TextStyle(fontSize: 65),
            maxTextWidth: double.infinity,
            outlineWidth: 4,
          ),
        );

        final painter = painterOf(tester);
        expect(painter.scaledText.keys, [
          painter.painter,
          painter.outlinePainter,
        ]);
      });

      testWidgets('counts a text shrunk to fit its box at its shown size', (
        tester,
      ) async {
        await pumpText(
          tester,
          const RoundedBackgroundText.rich(
            text: TextSpan(text: 'Hello', style: TextStyle(fontSize: 65)),
            maxTextWidth: double.infinity,
            box: TextLayerBox(
              size: Size(200, 100),
              overflow: TextLayerBoxOverflow.shrink,
            ),
          ),
        );

        expect(painterOf(tester).scaledText, isEmpty);
      });

      testWidgets('lays the text out at its own font', (tester) async {
        await pumpText(
          tester,
          RoundedBackgroundText(
            'Hello',
            style: const TextStyle(fontSize: 200),
            maxTextWidth: double.infinity,
          ),
        );

        expect(painterOf(tester).painter.preferredLineHeight, 200);
      });

      testWidgets('casts its shadows from silhouettes', (tester) async {
        await pumpText(
          tester,
          RoundedBackgroundText(
            'Hello',
            style: const TextStyle(fontSize: 200, shadows: [shadow]),
            maxTextWidth: double.infinity,
          ),
        );

        final painter = painterOf(tester);
        expect(painter.silhouetteShadows, [shadow]);
        expect(painter.silhouettePainters, hasLength(1));
        expect(painter.painter.text!.style!.shadows, isEmpty);
        expect(
          tester.renderObject(
            find.descendant(
              of: find.byType(RoundedBackgroundText),
              matching: find.byType(CustomPaint),
            ),
          ),
          paintsExactlyCountTimes(#saveLayer, 1),
        );
      });

      testWidgets('leaves its shadows to the caller that paints them', (
        tester,
      ) async {
        await pumpText(
          tester,
          RoundedBackgroundText(
            'Hello',
            style: const TextStyle(fontSize: 200, shadows: [shadow]),
            maxTextWidth: double.infinity,
            paintShadows: false,
          ),
        );

        expect(painterOf(tester).silhouetteShadows, isEmpty);
      });

      testWidgets('leaves justified text to its paragraph', (tester) async {
        await pumpText(
          tester,
          RoundedBackgroundText(
            'Hello world',
            style: const TextStyle(fontSize: 200),
            textAlign: TextAlign.justify,
            maxTextWidth: double.infinity,
          ),
        );

        expect(painterOf(tester).scaledText, isEmpty);
      });
    });
  });
}
