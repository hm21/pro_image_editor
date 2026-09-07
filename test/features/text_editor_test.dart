// Flutter imports:
// Package imports:
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:pro_image_editor/features/text_editor/text_editor.dart';
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
}
