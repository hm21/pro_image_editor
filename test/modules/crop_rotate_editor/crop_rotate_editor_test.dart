import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pro_image_editor/models/editor_configs/pro_image_editor_configs.dart';
import 'package:pro_image_editor/models/init_configs/crop_rotate_editor_init_configs.dart';

import 'package:pro_image_editor/modules/crop_rotate_editor/crop_rotate_editor.dart';
import 'package:pro_image_editor/modules/crop_rotate_editor/widgets/crop_aspect_ratio_options.dart';

import '../../fake/fake_image.dart';

void main() {
  var initConfigs = CropRotateEditorInitConfigs(
      theme: ThemeData.light(),
      configs: const ProImageEditorConfigs(
        cropRotateEditorConfigs: CropRotateEditorConfigs(
          animationDuration: Duration.zero,
          cropDragAnimationDuration: Duration.zero,
        ),
      ));
  group('CropRotateEditor Tests', () {
    testWidgets('CropRotateEditor should build without error',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: CropRotateEditor.memory(
            fakeMemoryImage,
            initConfigs: initConfigs,
          ),
        ),
      );
      await tester.pumpAndSettle(const Duration(seconds: 500));

      expect(find.byType(CropRotateEditor), findsOneWidget);
    });
  });

  group('CropRotateEditor Aspect Ratio Dialog Tests', () {
    testWidgets('Opens and selects an aspect ratio',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: CropRotateEditor.memory(
            fakeMemoryImage,
            initConfigs: initConfigs,
          ),
        ),
      );

      // Wait for the widget to be built
      await tester.pumpAndSettle(const Duration(milliseconds: 200));

      var openDialogButtonFinder =
          find.byKey(const ValueKey('pro-image-editor-aspect-ratio-btn'));
      await tester.tap(openDialogButtonFinder);

      // Rebuild the widget and open the dialog
      await tester.pumpAndSettle();

      expect(find.byType(CropAspectRatioOptions), findsOneWidget);

      // Ensure to draw ratios
      expect(find.text('16*9'), findsOneWidget);
    });
  });
}
