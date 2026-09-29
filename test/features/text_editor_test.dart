// Flutter imports:
// Package imports:
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:pro_image_editor/core/models/layers/layer.dart';
import 'package:pro_image_editor/features/text_editor/text_editor.dart';
import 'package:pro_image_editor/features/text_editor/widgets/rounded_background_text/rounded_background_text.dart';
import 'package:pro_image_editor/shared/widgets/slider_bottom_sheet.dart';

void main() {
  const testText = 'Hello World!';
  var key = GlobalKey<TextEditorState>();

  Future<void> pumpEditor(WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: TextEditor(key: key, theme: ThemeData.dark()),
        ),
      ),
    );
    expect(find.byType(TextEditor), findsOneWidget);
  }

  group('TextEditor Behavior', () {
    testWidgets('should build without error', (tester) async {
      await pumpEditor(tester);
    });

    testWidgets('should set text correctly', (tester) async {
      await pumpEditor(tester);

      await tester.enterText(find.byType(EditableText), testText);

      expect(find.text(testText), findsOneWidget);
    });
    testWidgets('should set text via textCtrl', (tester) async {
      await pumpEditor(tester);

      final editor = key.currentState!;
      editor.textCtrl.value = const TextEditingValue(text: testText);

      expect(find.text(testText), findsOneWidget);
    });
    testWidgets('should toggle textAlign via toggleTextAlign', (tester) async {
      await pumpEditor(tester);

      final editor = key.currentState!;
      final initAlign = editor.align;
      editor.toggleTextAlign();

      expect(editor.align, isNot(initAlign));
    });
    testWidgets('should toggle backgroundMode via toggleBackgroundMode', (
      tester,
    ) async {
      await pumpEditor(tester);

      final editor = key.currentState!;
      final backgroundColorMode = editor.backgroundColorMode;
      editor.toggleBackgroundMode();

      expect(editor.backgroundColorMode, isNot(backgroundColorMode));
    });
    testWidgets(
      'should open fontScaleBottomSheet via openFontScaleBottomSheet',
      (tester) async {
        await pumpEditor(tester);

        key.currentState!.openFontScaleBottomSheet();
        await tester.pump();

        expect(find.byType(SliderBottomSheet<TextEditorState>), findsOneWidget);
      },
    );
    testWidgets('should set textStyle via setTextStyle', (tester) async {
      await pumpEditor(tester);

      final editor = key.currentState!;
      final initialStyle = editor.selectedTextStyle;
      final newStyle = initialStyle.copyWith(
        fontSize: (initialStyle.fontSize ?? 0) + 10,
      );

      editor.setTextStyle(newStyle);

      expect(newStyle.fontSize, editor.selectedTextStyle.fontSize);
    });
  });

  group('TextEditor outline', () {
    testWidgets('writes the outline set via setOutline onto the layer', (
      tester,
    ) async {
      TextLayer? result;
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => TextButton(
              onPressed: () async {
                result = await Navigator.of(context).push<TextLayer>(
                  MaterialPageRoute(
                    builder: (_) =>
                        TextEditor(key: key, theme: ThemeData.dark()),
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
      editor.textCtrl.text = testText;
      editor
        ..setOutline(width: 2, color: const Color(0xFFFF0000))
        ..done();
      await tester.pumpAndSettle();

      expect(result?.outlineWidth, 2);
      expect(result?.outlineColor, const Color(0xFFFF0000));
    });

    testWidgets('previews the outline at the current font scale', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TextEditor(
              key: key,
              theme: ThemeData.dark(),
              layer: TextLayer(
                text: testText,
                fontScale: 2,
                outlineWidth: 3,
                outlineColor: const Color(0xFFFF0000),
              ),
            ),
          ),
        ),
      );
      await tester.pump();

      expect(key.currentState!.outlineWidth, 3);
      final preview = tester.widget<RoundedBackgroundText>(
        find.byType(RoundedBackgroundText),
      );
      expect(preview.outlineWidth, 6);
      expect(preview.outlineColor, const Color(0xFFFF0000));
    });
  });

  group('TextEditor timeline', () {
    const highlight = TextHighlight(
      start: 0,
      end: 5,
      startTime: Duration.zero,
      endTime: Duration(milliseconds: 400),
    );
    const animation = LayerAnimation(
      type: LayerAnimationType.fade,
      phase: AnimationPhase.animateIn,
      duration: Duration(milliseconds: 300),
    );

    Future<TextLayer?> edit(
      WidgetTester tester,
      TextLayer layer, {
      String? text,
    }) async {
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
      if (text != null) editor.textCtrl.text = text;
      editor.done();
      await tester.pumpAndSettle();
      return result;
    }

    TextLayer timedLayer() => TextLayer(
      text: 'Hello world',
      startTime: const Duration(seconds: 1),
      endTime: const Duration(seconds: 3),
      animations: [animation],
      highlights: [highlight],
      highlightColor: const Color(0xFF00FF00),
    );

    testWidgets('keeps the time range, animations and highlights', (
      tester,
    ) async {
      final result = await edit(tester, timedLayer());

      expect(result?.startTime, const Duration(seconds: 1));
      expect(result?.endTime, const Duration(seconds: 3));
      expect(result?.animations, [animation]);
      expect(result?.highlights, [highlight]);
      expect(result?.highlightColor, const Color(0xFF00FF00));
    });

    testWidgets('drops the highlights when the text changes', (tester) async {
      final result = await edit(tester, timedLayer(), text: 'Hi world');

      expect(result?.startTime, const Duration(seconds: 1));
      expect(result?.highlights, isEmpty);
      expect(result?.highlightColor, const Color(0xFF00FF00));
    });
  });

  group('TextEditor dispose', () {
    testWidgets('setState after dispose is a no-op', (tester) async {
      await pumpEditor(tester);
      final state = key.currentState!;

      await tester.pumpWidget(const SizedBox());

      expect(() => state.setState(() {}), returnsNormally);
    });
  });
}
