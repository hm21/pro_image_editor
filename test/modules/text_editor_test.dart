import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pro_image_editor/models/editor_configs/text_editor_configs.dart';
import 'package:pro_image_editor/modules/text_editor.dart';
import 'package:pro_image_editor/utils/design_mode.dart';
import 'package:pro_image_editor/widgets/layer_widget.dart';

void main() {
  group('TextEditor Tests', () {
    testWidgets('TextEditor should build without error', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TextEditor(
              theme: ThemeData.dark(),
              designMode: ImageEditorDesignModeE.material,
            ),
          ),
        ),
      );

      expect(find.byType(TextEditor), findsOneWidget);
    });
    testWidgets('TextEditor set text correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TextEditor(
              theme: ThemeData.dark(),
              designMode: ImageEditorDesignModeE.material,
            ),
          ),
        ),
      );

      expect(find.byType(TextEditor), findsOneWidget);

      await tester.enterText(find.byType(TextField), 'Hello, World!');

      expect(find.text('Hello, World!'), findsOneWidget);
    });

    testWidgets('TextEditor toggleTextAlign toggles text alignment correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TextEditor(
              configs: const TextEditorConfigs(initialTextAlign: TextAlign.left),
              theme: ThemeData.dark(),
              designMode: ImageEditorDesignModeE.material,
            ),
          ),
        ),
      );

      // Find the TextEditor widget.
      final textEditorFinder = find.byType(TextEditor);

      // Verify that the TextEditor widget is found.
      expect(textEditorFinder, findsOneWidget);

      // Tap the TextEditor widget to trigger its state change.
      await tester.tap(textEditorFinder);
      await tester.pump();

      // Verify that the initial alignment is TextAlign.left.
      expect(
        (tester.state<TextEditorState>(find.byType(TextEditor))).align,
        TextAlign.left,
      );

      // Tap a button that triggers toggleTextAlign.
      await tester.tap(find.byKey(const ValueKey('TextAlignIconButton')));

      // Verify that the alignment is now TextAlign.center.
      expect(
        (tester.state<TextEditorState>(find.byType(TextEditor))).align,
        TextAlign.center,
      );

      // Tap the button again to toggle the alignment to TextAlign.right.
      await tester.tap(find.byKey(const ValueKey('TextAlignIconButton')));

      // Verify that the alignment is TextAlign.right.
      expect(
        (tester.state<TextEditorState>(find.byType(TextEditor))).align,
        TextAlign.right,
      );
    });

    testWidgets('TextEditor toggleBackgroundMode toggles background mode correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TextEditor(
              theme: ThemeData.dark(),
              designMode: ImageEditorDesignModeE.material,
              configs: const TextEditorConfigs(initialBackgroundColorMode: LayerBackgroundColorModeE.onlyColor),
            ),
          ),
        ),
      );

      // Find the TextEditor widget.
      final textEditorFinder = find.byType(TextEditor);

      // Verify that the TextEditor widget is found.
      expect(textEditorFinder, findsOneWidget);

      // Tap the TextEditor widget to trigger its state change.
      await tester.tap(textEditorFinder);
      await tester.pump();

      // Verify that the initial color mode is ColorMode.onlyColor.
      expect(
        (tester.state<TextEditorState>(find.byType(TextEditor))).backgroundColorMode,
        LayerBackgroundColorModeE.onlyColor,
      );

      // Tap a button that triggers toggleBackgroundMode.
      await tester.tap(find.byKey(const ValueKey('BackgroundModeColorIconButton')));

      // Verify that the color mode is now ColorMode.backgroundAndColor.
      expect(
        (tester.state<TextEditorState>(find.byType(TextEditor))).backgroundColorMode,
        LayerBackgroundColorModeE.backgroundAndColor,
      );

      // Tap the button again to toggle the color mode to ColorMode.background.
      await tester.tap(find.byKey(const ValueKey('BackgroundModeColorIconButton')));

      expect(
        (tester.state<TextEditorState>(find.byType(TextEditor))).backgroundColorMode,
        LayerBackgroundColorModeE.background,
      );
    });
  });
}
