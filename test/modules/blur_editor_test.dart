import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pro_image_editor/models/init_configs/blur_editor_init_configs.dart';
import 'package:pro_image_editor/modules/blur_editor.dart';

import '../fake/fake_image.dart';

void main() {
  group('BlurEditor Tests', () {
    testWidgets('BlurEditor should build without error',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BlurEditor.memory(
              fakeMemoryImage,
              initConfigs: BlurEditorInitConfigs(
                theme: ThemeData.light(),
              ),
            ),
          ),
        ),
      );

      expect(find.byType(BlurEditor), findsOneWidget);
    });
  });
}
