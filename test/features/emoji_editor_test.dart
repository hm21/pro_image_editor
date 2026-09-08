import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:pro_image_editor/features/emoji_editor/emoji_editor.dart';
import 'package:pro_image_editor/plugins/emoji_picker_flutter/emoji_picker_flutter.dart';

void main() {
  group('EmojiEditor Tests', () {
    testWidgets('EmojiEditor should build without error', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: EmojiEditor())),
      );

      expect(find.byType(EmojiEditor), findsOneWidget);
    });

    testWidgets('EmojiEditor should have EmojiPicker', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: EmojiEditor())),
      );
      expect(find.byType(EmojiPicker), findsOneWidget);
    });
  });
}
