// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_test/flutter_test.dart';

// Project imports:
import 'package:pro_image_editor/modules/text_editor/text_editor.dart';

void main() {
  group('TextEditor Tests', () {
    testWidgets('should build without error', (WidgetTester tester) async {
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
    testWidgets('set text correctly', (WidgetTester tester) async {
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

      await tester.enterText(find.byType(EditableText), 'Hello, World!');

      expect(find.text('Hello, World!'), findsOneWidget);
    });
  });
}
