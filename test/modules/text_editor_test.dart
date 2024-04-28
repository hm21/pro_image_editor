import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pro_image_editor/modules/text_editor/text_editor.dart';

void main() {
  group('TextEditor Tests', () {
    testWidgets('TextEditor should build without error',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TextEditor(
              theme: ThemeData.dark(),
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
            ),
          ),
        ),
      );

      expect(find.byType(TextEditor), findsOneWidget);

      await tester.enterText(find.byType(TextField), 'Hello, World!');

      expect(find.text('Hello, World!'), findsOneWidget);
    });
  });
}
