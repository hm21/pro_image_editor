import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:pro_image_editor/models/aspect_ratio_item.dart';
import 'package:pro_image_editor/models/editor_configs/pro_image_editor_configs.dart';
import 'package:pro_image_editor/modules/crop_rotate_editor/widgets/crop_aspect_ratio_button.dart';
import 'package:pro_image_editor/modules/crop_rotate_editor/widgets/crop_aspect_ratio_options.dart';

class MockProImageEditorConfigs extends Mock implements ProImageEditorConfigs {}

void main() {
  group('CropAspectRatioOptions Tests', () {
    testWidgets('Initializes with correct aspect ratio',
        (WidgetTester tester) async {
      const String ratioText = 'Ratio-Text';
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CropAspectRatioOptions(
              aspectRatio: 1.0,
              originalAspectRatio: 1.0,
              configs: ProImageEditorConfigs(
                  cropRotateEditorConfigs:
                      CropRotateEditorConfigs(aspectRatios: [
                AspectRatioItem(text: ratioText, value: 1),
              ])),
            ),
          ),
        ),
      );

      expect(find.byType(AspectRatioButton), findsWidgets);
      expect(find.text(ratioText), findsOneWidget);
    });
  });
}
