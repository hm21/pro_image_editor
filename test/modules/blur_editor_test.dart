import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pro_image_editor/modules/blur_editor.dart';
import 'package:pro_image_editor/utils/design_mode.dart';

import '../fake/fake_image.dart';

void main() {
  group('FilterEditor Tests', () {
    testWidgets('FilterEditor should build without error',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BlurEditor.memory(
              fakeMemoryImage,
              theme: ThemeData.light(),
              designMode: ImageEditorDesignModeE.material,
              imageSize: const Size(200, 200),
              heroTag: 'unique_hero_tag',
            ),
          ),
        ),
      );

      expect(find.byType(BlurEditor), findsOneWidget);
    });
  });
}
