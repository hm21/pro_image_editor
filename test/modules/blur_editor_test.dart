// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_test/flutter_test.dart';

// Project imports:
import 'package:pro_image_editor/models/init_configs/blur_editor_init_configs.dart';
import 'package:pro_image_editor/modules/blur_editor/blur_editor.dart';
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
    testWidgets('should change blur factor', (WidgetTester tester) async {
      var key = GlobalKey<BlurEditorState>();
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BlurEditor.memory(
              fakeMemoryImage,
              key: key,
              initConfigs: BlurEditorInitConfigs(
                theme: ThemeData.light(),
              ),
            ),
          ),
        ),
      );
      double initBlur = key.currentState!.blurFactor;

      // Find the slider widget
      final sliderFinder = find.byType(Slider);

      // Ensure the slider is found
      expect(sliderFinder, findsOneWidget);

      // Move the slider to a specific position
      await tester.drag(sliderFinder, const Offset(300.0, 0.0));

      expect(key.currentState!.blurFactor, isNot(initBlur));
    });
  });
}
