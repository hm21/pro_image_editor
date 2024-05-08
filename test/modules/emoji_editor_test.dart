import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pro_image_editor/models/editor_configs/pro_image_editor_configs.dart';
import 'package:pro_image_editor/models/theme/theme.dart';
import 'package:pro_image_editor/modules/emoji_editor/emoji_editor.dart';

void main() {
  group('EmojiEditor Tests', () {
    testWidgets('EmojiEditor should build without error',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: EmojiEditor(),
          ),
        ),
      );

      expect(find.byType(EmojiEditor), findsOneWidget);
    });

    testWidgets('EmojiEditor should have EmojiPicker',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: EmojiEditor(),
          ),
        ),
      );
      expect(find.byType(EmojiPicker), findsOneWidget);
    });

    testWidgets('EmojiEditor should set custom configs for EmojiPicker',
        (WidgetTester tester) async {
      const swapCategoryAndBottomBar = false;
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: EmojiEditor(
              configs: ProImageEditorConfigs(
                imageEditorTheme: ImageEditorTheme(
                  emojiEditor: EmojiEditorTheme(
                      swapCategoryAndBottomBar: swapCategoryAndBottomBar),
                ),
              ),
            ),
          ),
        ),
      );
      final EmojiPicker emojiPicker =
          tester.widget<EmojiPicker>(find.byType(EmojiPicker).first);
      expect(emojiPicker.config.swapCategoryAndBottomBar,
          swapCategoryAndBottomBar);
    });
  });
}
