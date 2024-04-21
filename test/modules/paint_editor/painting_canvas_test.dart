import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:network_image_mock/network_image_mock.dart';
import 'package:pro_image_editor/models/editor_configs/paint_editor_configs.dart';
import 'package:pro_image_editor/models/i18n/i18n.dart';
import 'package:pro_image_editor/models/icons/icons.dart';
import 'package:pro_image_editor/models/init_configs/paint_canvas_init_configs.dart';
import 'package:pro_image_editor/models/layer.dart';
import 'package:pro_image_editor/models/theme/theme.dart';
import 'package:pro_image_editor/modules/paint_editor/painting_canvas.dart';
import 'package:pro_image_editor/modules/paint_editor/utils/paint_editor_enum.dart';
import 'package:pro_image_editor/utils/design_mode.dart';

import '../../fake/fake_image.dart';

void main() {
  group('PaintingCanvas Tests', () {
    PaintCanvasInitConfigs initConfigs = PaintCanvasInitConfigs(
      theme: ThemeData(),
      imageSize: const Size(200, 200),
      i18n: const I18n(),
      imageEditorTheme: const ImageEditorTheme(),
      icons: const ImageEditorIcons(),
      designMode: ImageEditorDesignModeE.material,
      configs: const PaintEditorConfigs(),
    );
    testWidgets('Initializes with memory constructor',
        (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(
        home: PaintingCanvas.memory(
          fakeMemoryImage,
          key: GlobalKey(),
          initConfigs: initConfigs,
        ),
      ));

      expect(find.byType(PaintingCanvas), findsOneWidget);
    });
    testWidgets('Initializes with network constructor',
        (WidgetTester tester) async {
      mockNetworkImagesFor(() async {
        await tester.pumpWidget(MaterialApp(
          home: PaintingCanvas.network(
            fakeNetworkImage,
            key: GlobalKey(),
            initConfigs: initConfigs,
          ),
        ));

        expect(find.byType(PaintingCanvas), findsOneWidget);
      });
    });
    testWidgets('Initializes with file constructor',
        (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(
        home: PaintingCanvas.file(
          fakeFileImage,
          key: GlobalKey(),
          initConfigs: initConfigs,
        ),
      ));

      expect(find.byType(PaintingCanvas), findsOneWidget);
    });

    testWidgets('Handles gestures and updates painting',
        (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(
        home: PaintingCanvas.memory(
          fakeMemoryImage,
          key: GlobalKey(),
          initConfigs: initConfigs,
        ),
      ));

      final PaintingCanvasState state =
          tester.state(find.byType(PaintingCanvas));

      // Simulate scale start gesture
      const Offset startPoint = Offset(50, 50);
      final TestGesture gesture = await tester.startGesture(startPoint);
      await tester.pump();

      // Simulate scale update gesture
      const Offset updatedPoint = Offset(70, 70);
      await gesture.moveTo(updatedPoint);
      await tester.pump();

      // Simulate scale end gesture
      await gesture.up();
      await tester.pump();

      expect(state.mode, PaintModeE.freeStyle);
      // Assuming the gesture creates an undoable action
      expect(state.canUndo, isTrue);
    });

    testWidgets('Performs undo and redo actions', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(
        home: PaintingCanvas.memory(
          fakeMemoryImage,
          key: GlobalKey(),
          initConfigs: initConfigs,
        ),
      ));

      final PaintingCanvasState state =
          tester.state(find.byType(PaintingCanvas));

      // Simulate scale start gesture
      const Offset startPoint = Offset(50, 50);
      final TestGesture gesture = await tester.startGesture(startPoint);
      await tester.pump();

      // Simulate scale update gesture
      const Offset updatedPoint = Offset(70, 70);
      await gesture.moveTo(updatedPoint);
      await tester.pump();

      // Simulate scale end gesture
      await gesture.up();
      await tester.pump();

      // Perform an undo action
      state.undo();
      await tester.pump();

      // Verify that undo action has an effect
      expect(state.canUndo, isFalse); // Assuming the undo clears the action
      expect(state.canRedo, isTrue); // There should be an action to redo now

      // Perform a redo action
      state.redo();
      await tester.pump();

      // Verify that redo action has an effect
      expect(state.canUndo, isTrue); // The action should be back in the history
      expect(state.canRedo, isFalse); // There should be no actions to redo now
    });

    testWidgets('Export painted items', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(
        home: PaintingCanvas.memory(
          fakeMemoryImage,
          key: GlobalKey(),
          initConfigs: initConfigs,
        ),
      ));

      final PaintingCanvasState state =
          tester.state(find.byType(PaintingCanvas));

      // Simulate scale start gesture
      const Offset startPoint = Offset(50, 50);
      final TestGesture gesture = await tester.startGesture(startPoint);
      await tester.pump();

      // Simulate scale update gesture
      const Offset updatedPoint = Offset(70, 70);
      await gesture.moveTo(updatedPoint);
      await tester.pump();

      // Simulate scale end gesture
      await gesture.up();
      await tester.pump();

      // Export the painted items
      final List<PaintingLayerData> exportedItems = state.exportPaintedItems();

      // Verify that the exported items match the expected result
      expect(exportedItems, isNotEmpty); // Assuming there are painted items
      expect(exportedItems.first,
          isA<PaintingLayerData>()); // Check the type of exported items
    });
  });
}
