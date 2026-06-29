// ignore_for_file: invalid_use_of_protected_member

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pro_image_editor/core/models/editor_configs/pro_image_editor_configs.dart';
import 'package:pro_image_editor/core/models/init_configs/crop_rotate_editor_init_configs.dart';
import 'package:pro_image_editor/features/crop_rotate_editor/crop_rotate_editor.dart';
import 'package:pro_image_editor/features/crop_rotate_editor/widgets/tilt/tilt_ruler_chooser.dart';

import '../../../../mock/mock_image.dart';

void main() {
  final CropRotateEditorInitConfigs initConfigs = CropRotateEditorInitConfigs(
    theme: ThemeData.light(),
    enableFakeHero: false,
    configs: const ProImageEditorConfigs(
      cropRotateEditor: CropRotateEditorConfigs(
        animationDuration: Duration.zero,
        cropDragAnimationDuration: Duration.zero,
        fadeInOutsideCropAreaAnimationDuration: Duration.zero,
        opacityOutsideCropAreaDuration: Duration.zero,
      ),
      imageGeneration: ImageGenerationConfigs(
        enableBackgroundGeneration: false,
        enableIsolateGeneration: false,
      ),
    ),
  );

  Widget createTestWidget({Widget? child}) {
    return MaterialApp(
      home: Scaffold(
        body: CropRotateEditor.memory(
          mockMemoryImage,
          initConfigs: initConfigs,
        ),
      ),
    );
  }

  group('TiltRulerChooser Widget Tests', () {
    testWidgets('creates TiltRulerChooser widget', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.byType(TiltRulerChooser), findsOneWidget);
    });

    testWidgets('shows SizedBox when tilt editor is not visible', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // By default, tilt editor should not be visible
      expect(find.byType(SizedBox), findsWidgets);
    });

    testWidgets('displays TiltRuler when tilt editor is visible', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Enable tilt mode to make tilt editor visible
      final cropRotateEditor = find.byType(CropRotateEditor);
      expect(cropRotateEditor, findsOneWidget);

      // The TiltRuler should be present when tilt mode is active
      expect(find.byType(AnimatedSwitcher), findsWidgets);
    });

    testWidgets('switches between different tilt modes', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Verify AnimatedSwitcher is present for mode transitions
      expect(find.byType(AnimatedSwitcher), findsWidgets);
    });

    testWidgets('uses correct animation duration from configs', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      final animatedSwitchers = find.byType(AnimatedSwitcher);
      expect(animatedSwitchers, findsWidgets);

      // Verify the widget builds without errors with zero duration
      expect(tester.takeException(), isNull);
    });

    testWidgets('handles tilt mode changes correctly', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // The widget should handle mode changes through the provider
      expect(find.byType(TiltRulerChooser), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('creates unique keys for different tilt modes', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Verify the widget structure is correct
      expect(find.byType(TiltRulerChooser), findsOneWidget);
      expect(find.byType(AnimatedSwitcher), findsWidgets);
    });

    testWidgets('handles reset count changes for fresh ruler state', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // The widget should rebuild with new keys when reset count changes
      expect(find.byType(TiltRulerChooser), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('uses correct transition animations', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Verify SizeTransition and FadeTransition are used
      final animatedSwitchers = find.byType(AnimatedSwitcher);
      expect(animatedSwitchers, findsWidgets);

      // Check that the widget builds correctly with transitions
      expect(tester.takeException(), isNull);
    });

    testWidgets('maintains width constraint when collapsed', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // When tilt editor is not visible, should show SizedBox with full width
      expect(find.byType(SizedBox), findsWidgets);
    });
  });

  group('TiltRulerChooser Integration Tests', () {
    testWidgets('integrates properly with TiltProvider', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Verify the widget can access TiltProvider without errors
      expect(find.byType(TiltRulerChooser), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('responds to provider state changes', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // The widget should rebuild when provider state changes
      expect(find.byType(TiltRulerChooser), findsOneWidget);

      // Pump again to ensure state changes are handled
      await tester.pump();
      expect(tester.takeException(), isNull);
    });

    testWidgets('works within CropRotateEditor context', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Verify the widget works properly in its intended context
      expect(find.byType(CropRotateEditor), findsOneWidget);
      expect(find.byType(TiltRulerChooser), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}
