import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:pro_image_editor/features/text_editor/utils/rounded_background_painter.dart';
import 'package:pro_image_editor/features/text_editor/widgets/rounded_background_text/rounded_background_text.dart';
import 'package:pro_image_editor/pro_image_editor.dart';
import 'package:pro_image_editor/shared/widgets/layer/widgets/layer_widget_text_item.dart';

void main() {
  const style = TextStyle(fontSize: 20, color: Color(0xFF000000));

  Future<void> pumpText(WidgetTester tester, Widget text) {
    return tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: Center(child: text)),
      ),
    );
  }

  RoundedBackgroundTextPainter textPainter(WidgetTester tester) {
    final paint = tester.widget<CustomPaint>(
      find.descendant(
        of: find.byType(RoundedBackgroundText),
        matching: find.byType(CustomPaint),
      ),
    );
    return paint.painter! as RoundedBackgroundTextPainter;
  }

  RoundedBackgroundText boxedText(
    String text,
    TextLayerBox box, {
    Function(bool hasHit)? onHitTestResult,
  }) {
    return RoundedBackgroundText(
      text,
      style: style,
      maxTextWidth: double.infinity,
      enableHitBoxCorrection: true,
      backgroundColor: const Color(0x80000000),
      onHitTestResult: onHitTestResult,
      box: box,
    );
  }

  group('RoundedBackgroundText.box', () {
    testWidgets('takes the size of the box, not of its text', (tester) async {
      await pumpText(
        tester,
        boxedText('Hi', const TextLayerBox(size: Size(300, 120))),
      );

      expect(
        tester.getSize(find.byType(RoundedBackgroundText)),
        const Size(300, 120),
      );
    });

    testWidgets('wraps the text at the box width', (tester) async {
      await pumpText(
        tester,
        boxedText(
          'one two three four',
          const TextLayerBox(size: Size(80, 200)),
        ),
      );

      final painter = textPainter(tester).painter;
      expect(painter.computeLineMetrics().length, greaterThan(1));
      expect(
        painter.width,
        80 - textPainter(tester).hitBoxCorrectionOffset.dx * 2,
      );
    });

    for (final (align, factor) in [
      (TextLayerBoxVerticalAlign.top, 0.0),
      (TextLayerBoxVerticalAlign.center, 0.5),
      (TextLayerBoxVerticalAlign.bottom, 1.0),
    ]) {
      testWidgets('places short text at the ${align.name}', (tester) async {
        await pumpText(
          tester,
          boxedText(
            'Hi',
            TextLayerBox(size: const Size(300, 120), verticalAlign: align),
          ),
        );

        final painter = textPainter(tester);
        final lineHeight = painter.painter.preferredLineHeight;
        final padding = lineHeight * 0.1;
        final free = 120 - padding * 2 - painter.painter.height;
        expect(
          painter.hitBoxCorrectionOffset.dy,
          closeTo(padding + free * factor, 0.001),
        );
      });
    }

    testWidgets('keeps the font size of text that fits when shrinking', (
      tester,
    ) async {
      await pumpText(
        tester,
        boxedText(
          'Hi',
          const TextLayerBox(
            size: Size(300, 120),
            overflow: TextLayerBoxOverflow.shrink,
          ),
        ),
      );

      expect(textPainter(tester).painter.textScaler, TextScaler.noScaling);
    });

    testWidgets('shrinks text taller than the box until it fits', (
      tester,
    ) async {
      const box = TextLayerBox(
        size: Size(120, 60),
        overflow: TextLayerBoxOverflow.shrink,
      );
      await pumpText(
        tester,
        boxedText('one two three four five six seven eight', box),
      );

      final painter = textPainter(tester);
      final factor = painter.painter.textScaler.scale(1);
      expect(factor, lessThan(1));
      expect(factor, greaterThanOrEqualTo(TextLayerBox.minShrinkFactor));
      final padding = painter.painter.preferredLineHeight * 0.1;
      expect(painter.painter.height, lessThanOrEqualTo(60 - padding * 2));
    });

    for (final outlineWidth in [0.0, 4.0]) {
      testWidgets('shrinks the shadows and an outline of $outlineWidth with '
          'the text', (tester) async {
        const shadow = Shadow(offset: Offset(4, 4), blurRadius: 2);
        await pumpText(
          tester,
          RoundedBackgroundText(
            'one two three four five six seven eight',
            style: style.copyWith(shadows: const [shadow]),
            maxTextWidth: double.infinity,
            enableHitBoxCorrection: true,
            outlineWidth: outlineWidth,
            box: const TextLayerBox(
              size: Size(120, 60),
              overflow: TextLayerBoxOverflow.shrink,
            ),
          ),
        );

        final painter = textPainter(tester);
        final factor = painter.painter.textScaler.scale(1);
        expect(factor, lessThan(1));
        if (outlineWidth == 0) {
          expect(painter.painter.text!.style!.shadows, [shadow.scale(factor)]);
        } else {
          final outline = painter.outlinePainter!.text!.style!.foreground!;
          expect(outline.strokeWidth, closeTo(outlineWidth * 2 * factor, 1e-9));
          expect(painter.silhouetteShadows, [shadow.scale(factor)]);
        }
      });
    }

    testWidgets('clips text taller than the box by default', (tester) async {
      await pumpText(
        tester,
        boxedText(
          'one two three four five six seven eight',
          const TextLayerBox(size: Size(120, 60)),
        ),
      );

      final painter = textPainter(tester);
      expect(painter.painter.textScaler, TextScaler.noScaling);
      expect(painter.painter.height, greaterThan(60));
      expect(
        tester.renderObject(find.byType(RoundedBackgroundText)),
        paints..clipRect(rect: const Rect.fromLTWH(0, 0, 120, 60)),
      );
    });

    testWidgets('draws text taller than the box past it, at its own size, '
        'when the overflow is visible', (tester) async {
      await pumpText(
        tester,
        boxedText(
          'one two three four five six seven eight',
          const TextLayerBox(
            size: Size(120, 60),
            overflow: TextLayerBoxOverflow.visible,
          ),
        ),
      );

      final painter = textPainter(tester);
      expect(painter.painter.textScaler, TextScaler.noScaling);
      expect(painter.painter.height, greaterThan(60));
      expect(painter.clipToBox, isFalse);
      expect(
        tester.renderObject(find.byType(RoundedBackgroundText)),
        isNot(paints..clipRect()),
      );
      expect(
        tester.getSize(find.byType(RoundedBackgroundText)),
        const Size(120, 60),
      );
      expect(painter.hitTest(const Offset(60, 70)), isFalse);
    });

    testWidgets('counts a hit anywhere in the box', (tester) async {
      final hits = <bool>[];
      await pumpText(
        tester,
        boxedText(
          'Hi',
          const TextLayerBox(size: Size(300, 120)),
          onHitTestResult: hits.add,
        ),
      );

      final painter = textPainter(tester);
      expect(painter.hitTest(const Offset(290, 110)), isTrue);
      expect(painter.hitTest(const Offset(310, 110)), isFalse);
      expect(hits, [true, false]);
    });
  });

  group('LayerWidgetTextItem with a box', () {
    testWidgets('scales the box with the layer', (tester) async {
      final showMoveCursor = ValueNotifier(false);
      addTearDown(showMoveCursor.dispose);

      await pumpText(
        tester,
        LayerWidgetTextItem(
          layer: TextLayer(
            text: 'Name',
            scale: 1.5,
            box: const TextLayerBox(size: Size(200, 40)),
          ),
          textEditorConfigs: const TextEditorConfigs(),
          showMoveCursor: showMoveCursor,
          onHitChanged: (_) {},
        ),
      );

      expect(
        tester.getSize(find.byType(RoundedBackgroundText)),
        const Size(300, 60),
      );
    });

    for (final outlineWidth in [0.0, 4.0]) {
      testWidgets(
        outlineWidth == 0
            ? 'a shrinking box keeps its shadows while it is edited'
            : 'a shrinking box keeps its outline while it is edited',
        (tester) async {
          const shadow = Shadow(offset: Offset(4, 4), blurRadius: 2);
          const background = Color(0xFF336699);
          final showMoveCursor = ValueNotifier(false);
          addTearDown(showMoveCursor.dispose);
          final layer = TextLayer(
            text: 'one two three four five six seven eight',
            textStyle: const TextStyle(shadows: [shadow]),
            outlineWidth: outlineWidth,
            // A filled background shows a shrink or offset that disagrees
            // with the painted layer. The inline session uses this color
            // only when the layer keeps its own secondary color.
            background: outlineWidth == 0
                ? background
                : const Color(0xFFFFFFFF),
            customSecondaryColor: outlineWidth == 0,
            box: const TextLayerBox(
              size: Size(120, 60),
              overflow: TextLayerBoxOverflow.shrink,
            ),
          );
          final session = InlineTextEditSession.start(
            layer: layer,
            configs: const TextEditorConfigs(),
            onChanged: () {},
            onTextChanged: () {},
            onDone: () {},
            onCancel: () {},
          );
          addTearDown(session.dispose);

          Future<void> pumpItem({required bool editing}) {
            return pumpText(
              tester,
              LayerWidgetTextItem(
                layer: layer,
                textEditorConfigs: const TextEditorConfigs(),
                inlineEdit: editing ? session : null,
                showMoveCursor: showMoveCursor,
                onHitChanged: (_) {},
              ),
            );
          }

          await pumpItem(editing: false);
          final committed = textPainter(tester);
          final factor = committed.painter.textScaler.scale(1);
          expect(factor, lessThan(1));
          expect(factor, greaterThanOrEqualTo(TextLayerBox.minShrinkFactor));

          await pumpItem(editing: true);
          final editingPainter = textPainter(tester);
          expect(
            editingPainter.painter.textScaler.scale(1),
            closeTo(factor, 1e-9),
          );
          expect(
            editingPainter.hitBoxCorrectionOffset.dx,
            closeTo(committed.hitBoxCorrectionOffset.dx, 0.01),
          );
          expect(
            editingPainter.hitBoxCorrectionOffset.dy,
            closeTo(committed.hitBoxCorrectionOffset.dy, 0.01),
          );

          if (outlineWidth == 0) {
            // The field paints these. The background keeps their space and
            // draws none, so a filled background does not shift or double.
            expect(committed.backgroundColor, background);
            expect(editingPainter.backgroundColor, background);
            final shadows = committed.painter.text!.style!.shadows;
            expect(shadows, [shadow.scale(factor)]);
            expect(
              tester.widget<TextField>(find.byType(TextField)).style?.shadows,
              shadows,
            );
            expect(editingPainter.painter.text!.style!.shadows, isEmpty);
          } else {
            final stroke =
                committed.outlinePainter!.text!.style!.foreground!.strokeWidth;
            expect(stroke, closeTo(outlineWidth * 2 * factor, 1e-9));
            expect(
              editingPainter
                  .outlinePainter!
                  .text!
                  .style!
                  .foreground!
                  .strokeWidth,
              closeTo(stroke, 1e-9),
            );
            expect(committed.silhouetteShadows, [shadow.scale(factor)]);
            expect(
              editingPainter.silhouetteShadows,
              committed.silhouetteShadows,
            );
          }
        },
      );
    }
  });
}
