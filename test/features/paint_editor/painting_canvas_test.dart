import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_test/flutter_test.dart';
import 'package:pro_image_editor/features/paint_editor/controllers/paint_controller.dart';
import 'package:pro_image_editor/features/paint_editor/widgets/paint_canvas.dart';
import 'package:pro_image_editor/pro_image_editor.dart';

void main() {
  group('PaintCanvas Tests', () {
    testWidgets(
        'Handles gestures and updates paint-items with start/stop offsets',
        (WidgetTester tester) async {
      final GlobalKey<PaintCanvasState> canvasKey = GlobalKey();
      PaintController ctrl = PaintController(
        color: Colors.red,
        mode: PaintMode.arrow,
        fill: false,
        strokeWidth: 1,
        strokeMultiplier: 1,
        opacity: 1,
      );
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PaintCanvas(
              layers: const [],
              key: canvasKey,
              drawAreaSize: const Size(1000, 1000),
              editorBodySize: const Size(1000, 1000),
              layerStackScaleFactor: 1,
              paintCtrl: ctrl,
              paintEditorConfigs: const PaintEditorConfigs(),
              onRefresh: () {},
              onCreated: (PaintedModel item) {},
              onRemoveLayer: (List<String> value) {},
              onRemovePartialStart: () {},
              onRemovePartialEnd: (bool hasRemovedAreas) {},
              onTap: (TapDownDetails details) {},
            ),
          ),
        ),
      );

      Offset center = tester.getCenter(find.byKey(canvasKey));

      // Simulate scale start gesture
      final TestGesture gesture = await tester.startGesture(center);

      // Simulate scale update gesture
      Offset updatedPoint = center + const Offset(50, 50);
      await gesture.moveTo(updatedPoint);

      /// Assuming the start point is not null
      expect(ctrl.start, isNotNull);

      /// Assuming the end point is not null
      expect(ctrl.end, isNotNull);

      // Simulate scale end gesture
      await gesture.up();

      // Assuming the paintMode didn't change
      expect(ctrl.mode, PaintMode.arrow);
    });

    testWidgets('Handles gestures and updates paint-items in freestyle-mode',
        (WidgetTester tester) async {
      final GlobalKey<PaintCanvasState> canvasKey = GlobalKey();
      PaintController ctrl = PaintController(
        color: Colors.red,
        mode: PaintMode.freeStyle,
        fill: false,
        strokeWidth: 1,
        strokeMultiplier: 1,
        opacity: 1,
      );
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PaintCanvas(
              layers: const [],
              key: canvasKey,
              drawAreaSize: const Size(1000, 1000),
              editorBodySize: const Size(1000, 1000),
              layerStackScaleFactor: 1,
              paintCtrl: ctrl,
              paintEditorConfigs: const PaintEditorConfigs(),
              onRefresh: () {},
              onCreated: (PaintedModel item) {},
              onRemoveLayer: (List<String> value) {},
              onRemovePartialStart: () {},
              onRemovePartialEnd: (bool hasRemovedAreas) {},
              onTap: (TapDownDetails details) {},
            ),
          ),
        ),
      );

      Offset center = tester.getCenter(find.byKey(canvasKey));

      // Simulate scale start gesture
      final TestGesture gesture = await tester.startGesture(center);

      // Simulate scale update gesture
      await gesture.moveTo(center + const Offset(0, 50));
      await gesture.moveTo(center + const Offset(50, 0));
      await gesture.moveTo(center + const Offset(50, 50));

      /// Assuming the offset length is correct
      expect(ctrl.offsets.length, 4);

      // Simulate scale end gesture
      await gesture.up();

      // Assuming the paintMode didn't change
      expect(ctrl.mode, PaintMode.freeStyle);
    });
  });
}
