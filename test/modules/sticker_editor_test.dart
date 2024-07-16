// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_test/flutter_test.dart';

// Project imports:
import 'package:pro_image_editor/pro_image_editor.dart';

void main() {
  group('StickerEditor Tests', () {
    testWidgets('widget should be created', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(
        home: StickerEditor(
          scrollController: ScrollController(),
          configs: ProImageEditorConfigs(
            stickerEditorConfigs: StickerEditorConfigs(
              enabled: true,
              buildStickers: (setLayer, scrollController) {
                return Container();
              },
            ),
          ),
        ),
      ));

      expect(find.byType(StickerEditor), findsOneWidget);
    });
  });
}
