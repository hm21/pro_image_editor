// ignore_for_file: invalid_use_of_protected_member

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_test/flutter_test.dart';

// Project imports:
import 'package:pro_image_editor/models/editor_configs/pro_image_editor_configs.dart';
import 'package:pro_image_editor/models/init_configs/crop_rotate_editor_init_configs.dart';
import 'package:pro_image_editor/modules/crop_rotate_editor/crop_rotate_editor.dart';
import 'package:pro_image_editor/modules/crop_rotate_editor/widgets/crop_aspect_ratio_options.dart';
import '../../fake/fake_image.dart';

void main() {
  final CropRotateEditorInitConfigs initConfigs = CropRotateEditorInitConfigs(
      theme: ThemeData.light(),
      enableFakeHero: false,
      configs: const ProImageEditorConfigs(
        cropRotateEditorConfigs: CropRotateEditorConfigs(
          animationDuration: Duration.zero,
          cropDragAnimationDuration: Duration.zero,
          fadeInOutsideCropAreaAnimationDuration: Duration.zero,
        ),
      ));
  group('CropRotateEditor Tests', () {
    Future<void> zoom(
        WidgetTester tester, GlobalKey<CropRotateEditorState> editorKey) async {
      final Offset centerPoint =
          tester.getCenter(find.byType(CropRotateEditor));
      final TestGesture gesture = await tester.startGesture(centerPoint);
      await gesture.moveBy(const Offset(10.0, 10.0)); // Simulate pinch zoom

      // Simulate pinch gesture start (two fingers)
      final TestGesture gestureStart =
          await tester.startGesture(const Offset(100, 100));
      await gestureStart
          .moveBy(const Offset(0.0, -100.0)); // Move fingers apart

      // Simulate pinch gesture update
      final TestGesture gestureUpdate =
          await tester.startGesture(const Offset(10, 10));
      await gestureUpdate
          .moveBy(const Offset(0.0, -50.0)); // Move fingers further apart
      // Simulate pinch gesture end
      await gestureUpdate.up();
      await gestureStart.up();

      await tester.pumpAndSettle(const Duration(milliseconds: 500));

      expect(editorKey.currentState!.userZoom, greaterThan(1));
    }

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
      await tester.pumpAndSettle();

      expect(find.byType(CropRotateEditor), findsOneWidget);
    });

    testWidgets('Handles rotation correctly', (WidgetTester tester) async {
      final editorKey = GlobalKey<CropRotateEditorState>();
      await tester.pumpWidget(MaterialApp(
        home: CropRotateEditor.memory(
          fakeMemoryImage,
          key: editorKey,
          initConfigs: initConfigs,
        ),
      ));
      await tester
          .tap(find.byKey(const ValueKey('crop-rotate-editor-rotate-btn')));
      await tester.pumpAndSettle();

      expect(editorKey.currentState!.rotationCount == 1, isTrue);
    });

    testWidgets('Handles flip correctly', (WidgetTester tester) async {
      final editorKey = GlobalKey<CropRotateEditorState>();
      await tester.pumpWidget(MaterialApp(
        home: CropRotateEditor.memory(
          fakeMemoryImage,
          key: editorKey,
          initConfigs: initConfigs,
        ),
      ));
      await tester
          .tap(find.byKey(const ValueKey('crop-rotate-editor-flip-btn')));
      await tester.pumpAndSettle();
      expect(editorKey.currentState!.flipX, isTrue);
    });

    testWidgets('Handles zoom correctly', (WidgetTester tester) async {
      final editorKey = GlobalKey<CropRotateEditorState>();
      await tester.pumpWidget(MaterialApp(
        home: CropRotateEditor.memory(
          fakeMemoryImage,
          key: editorKey,
          initConfigs: initConfigs,
        ),
      ));

      await zoom(tester, editorKey);

      /// Fake tap that widget will stay alive until loop finish
      await tester
          .tap(find.byKey(const ValueKey('crop-rotate-editor-reset-btn')));
      await tester.pumpAndSettle();
    });

    testWidgets('Handles reset correctly', (WidgetTester tester) async {
      final editorKey = GlobalKey<CropRotateEditorState>();
      await tester.pumpWidget(MaterialApp(
        home: CropRotateEditor.memory(
          fakeMemoryImage,
          key: editorKey,
          initConfigs: initConfigs,
        ),
      ));

      await tester
          .tap(find.byKey(const ValueKey('crop-rotate-editor-flip-btn')));
      await tester.pumpAndSettle();
      expect(editorKey.currentState!.flipX, isTrue);

      await tester
          .tap(find.byKey(const ValueKey('crop-rotate-editor-rotate-btn')));
      await tester.pumpAndSettle();
      expect(editorKey.currentState!.rotationCount == 1, isTrue);

      await zoom(tester, editorKey);

      await tester
          .tap(find.byKey(const ValueKey('crop-rotate-editor-reset-btn')));
      await tester.pumpAndSettle();

      expect(editorKey.currentState!.rotationCount == 0, isTrue);
      expect(editorKey.currentState!.flipX, isFalse);
      expect(editorKey.currentState!.userZoom, equals(1));
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
          find.byKey(const ValueKey('crop-rotate-editor-ratio-btn'));
      await tester.tap(openDialogButtonFinder);

      // Rebuild the widget and open the dialog
      await tester.pumpAndSettle();

      expect(find.byType(CropAspectRatioOptions), findsOneWidget);

      // Ensure to draw ratios
      expect(find.text('16*9'), findsOneWidget);
    });
  });
}
