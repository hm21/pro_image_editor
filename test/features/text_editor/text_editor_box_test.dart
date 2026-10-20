import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:pro_image_editor/features/text_editor/utils/rounded_background_painter.dart';
import 'package:pro_image_editor/features/text_editor/widgets/rounded_background_text/rounded_background_text.dart';
import 'package:pro_image_editor/pro_image_editor.dart';

void main() {
  final key = GlobalKey<TextEditorState>();

  Future<TextLayer?> edit(
    WidgetTester tester,
    TextLayer? layer,
    void Function(TextEditorState editor) change,
  ) async {
    TextLayer? result;
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => TextButton(
            onPressed: () async {
              result = await Navigator.of(context).push<TextLayer>(
                MaterialPageRoute(
                  builder: (_) => TextEditor(
                    key: key,
                    theme: ThemeData.dark(),
                    layer: layer,
                  ),
                ),
              );
            },
            child: const Text('open'),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    final editor = key.currentState!;
    change(editor);
    editor.done();
    await tester.pumpAndSettle();
    return result;
  }

  group('TextEditor box', () {
    testWidgets('is off for a layer without a box', (tester) async {
      final result = await edit(
        tester,
        TextLayer(text: 'Hello'),
        (editor) => expect(editor.boxEnabled, isFalse),
      );

      expect(result!.box, isNull);
    });

    testWidgets('fits a new box around the text', (tester) async {
      final result = await edit(
        tester,
        TextLayer(text: 'Hello', scale: 2),
        (editor) => editor.setBoxEnabled(true),
      );

      final box = result!.box!;
      expect(box.size.width, greaterThan(0));
      expect(box.size.height, greaterThan(0));
      expect(box.overflow, TextLayerBoxOverflow.shrink);
      expect(box.verticalAlign, TextLayerBoxVerticalAlign.top);
    });

    testWidgets('keeps the size of an existing box', (tester) async {
      const box = TextLayerBox(size: Size(300, 90));
      final result = await edit(
        tester,
        TextLayer(text: 'Hello', box: box),
        (editor) {
          expect(editor.boxEnabled, isTrue);
          editor.textCtrl.text = 'Hello there';
        },
      );

      expect(result!.box, box);
    });

    testWidgets('takes the text out of its box', (tester) async {
      final result = await edit(
        tester,
        TextLayer(text: 'Hello', box: const TextLayerBox(size: Size(300, 90))),
        (editor) => editor.setBoxEnabled(false),
      );

      expect(result!.box, isNull);
    });
  });

  group('TextLayerBox.fit', () {
    testWidgets('shows the text as it was, at another scale', (tester) async {
      const text = 'Roll for initiative\nand hope';
      const style = TextStyle(fontSize: 20);
      final box = TextLayerBox.fit(text: text, style: style, slack: 1);

      // The layer drawn at three times its size.
      const scale = 3.0;
      await tester.pumpWidget(
        MaterialApp(
          home: Center(
            child: RoundedBackgroundText(
              text,
              style: style.copyWith(fontSize: 20 * scale),
              maxTextWidth: double.infinity,
              enableHitBoxCorrection: true,
              box: box.copyWith(size: box.size * scale),
            ),
          ),
        ),
      );

      final paint = tester.widget<CustomPaint>(
        find.descendant(
          of: find.byType(RoundedBackgroundText),
          matching: find.byType(CustomPaint),
        ),
      );
      final painter = (paint.painter! as RoundedBackgroundTextPainter).painter;
      expect(painter.textScaler, TextScaler.noScaling);
      expect(painter.computeLineMetrics(), hasLength(2));
    });
  });
}
