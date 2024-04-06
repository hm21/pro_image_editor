import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:pro_image_editor/modules/crop_rotate_editor/crop_rotate_editor.dart';

import '../../fake/fake_image.dart';

void main() {
  group('CropRotateEditor Tests', () {
    testWidgets(
        'CropRotateEditor should build without error and create ExtendedImage',
        (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(
        home: CropRotateEditor.memory(
          fakeMemoryImage,
          key: GlobalKey(),
          theme: ThemeData.light(),
          imageSize: const Size(300, 300),
        ),
      ));
      await tester.pumpAndSettle(const Duration(milliseconds: 200));

      expect(find.byType(CropRotateEditor), findsOneWidget);

      expect(find.byType(ExtendedImage), findsOneWidget);
    });
  });

  group('CropRotateEditor Aspect Ratio Dialog Tests', () {
    testWidgets('Opens and selects an aspect ratio',
        (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(
        home: CropRotateEditor.memory(
          fakeMemoryImage,
          key: GlobalKey(),
          theme: ThemeData.light(),
          imageSize: const Size(300, 300),
        ),
      ));

      // Wait for the widget to be built
      await tester.pumpAndSettle(const Duration(milliseconds: 200));

      var openDialogButtonFinder =
          find.byKey(const ValueKey('pro-image-editor-aspect-ratio-btn'));
      await tester.tap(openDialogButtonFinder);

      // Rebuild the widget and open the dialog
      await tester.pumpAndSettle();

      expect(
          find.byKey(
              const ValueKey('pro-image-editor-aspect-ratio-bottom-list')),
          findsOneWidget);

      // Ensure to draw ratios
      expect(find.text('16*9'), findsOneWidget);
    });
  });
}
