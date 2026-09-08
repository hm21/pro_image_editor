import 'package:flutter/gestures.dart';
// Package imports:
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
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
                eraserMode: EraserMode.partial,
                eraserRadius: 8.0,
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
      },
    );

    testWidgets('Handles gestures and updates paint-items in freestyle-mode', (
      WidgetTester tester,
    ) async {
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
              eraserMode: EraserMode.partial,
              eraserRadius: 8.0,
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

    testWidgets('cancelActiveDrawing discards an in-progress stroke', (
      WidgetTester tester,
    ) async {
      final GlobalKey<PaintCanvasState> canvasKey = GlobalKey();
      var created = 0;
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
              eraserMode: EraserMode.partial,
              eraserRadius: 8.0,
              paintEditorConfigs: const PaintEditorConfigs(),
              onRefresh: () {},
              onCreated: (PaintedModel item) {
                created++;
              },
              onRemoveLayer: (List<String> value) {},
              onRemovePartialStart: () {},
              onRemovePartialEnd: (bool hasRemovedAreas) {},
              onTap: (TapDownDetails details) {},
            ),
          ),
        ),
      );

      Offset center = tester.getCenter(find.byKey(canvasKey));
      final TestGesture gesture = await tester.startGesture(center);
      await gesture.moveTo(center + const Offset(40, 40));
      expect(ctrl.start, isNotNull);
      expect(ctrl.offsets, isNotEmpty);

      canvasKey.currentState!.cancelActiveDrawing();
      expect(ctrl.start, isNull);
      expect(ctrl.offsets, isEmpty);
      expect(ctrl.busy, isFalse);

      await gesture.moveTo(center + const Offset(80, 80));
      await gesture.up();
      expect(ctrl.start, isNull);
      expect(created, 0);
    });

    testWidgets('right and middle mouse buttons do not start a stroke', (
      WidgetTester tester,
    ) async {
      final GlobalKey<PaintCanvasState> canvasKey = GlobalKey();
      var created = 0;
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
              eraserMode: EraserMode.partial,
              eraserRadius: 8.0,
              paintEditorConfigs: const PaintEditorConfigs(
                enableZoom: true,
                enableZoomWhileDrawing: true,
              ),
              onRefresh: () {},
              onCreated: (PaintedModel item) {
                created++;
              },
              onRemoveLayer: (List<String> value) {},
              onRemovePartialStart: () {},
              onRemovePartialEnd: (bool hasRemovedAreas) {},
              onTap: (TapDownDetails details) {},
            ),
          ),
        ),
      );

      Offset center = tester.getCenter(find.byKey(canvasKey));
      for (final int buttons in <int>[
        kSecondaryMouseButton,
        kMiddleMouseButton,
      ]) {
        final TestGesture gesture = await tester.startGesture(
          center,
          kind: PointerDeviceKind.mouse,
          buttons: buttons,
        );
        await gesture.moveTo(center + const Offset(40, 40));
        expect(ctrl.start, isNull);
        expect(ctrl.offsets, isEmpty);
        await gesture.up();
        expect(created, 0);
      }
    });

    testWidgets('an auxiliary button pressed mid-stroke discards the stroke', (
      WidgetTester tester,
    ) async {
      final GlobalKey<PaintCanvasState> canvasKey = GlobalKey();
      var created = 0;
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
              eraserMode: EraserMode.partial,
              eraserRadius: 8.0,
              paintEditorConfigs: const PaintEditorConfigs(
                enableZoom: true,
                enableZoomWhileDrawing: true,
              ),
              onRefresh: () {},
              onCreated: (PaintedModel item) {
                created++;
              },
              onRemoveLayer: (List<String> value) {},
              onRemovePartialStart: () {},
              onRemovePartialEnd: (bool hasRemovedAreas) {},
              onTap: (TapDownDetails details) {},
            ),
          ),
        ),
      );

      final Offset center = tester.getCenter(find.byKey(canvasKey));
      final TestPointer pointer = TestPointer(
        1,
        PointerDeviceKind.mouse,
        null,
        kPrimaryMouseButton,
      );
      await tester.sendEventToBinding(pointer.down(center));
      await tester.sendEventToBinding(
        pointer.move(center + const Offset(30, 30)),
      );
      expect(ctrl.offsets, isNotEmpty);

      // Pressing a second mouse button mid-drag arrives as a move event with
      // the extra button set, not as a new pointer.
      await tester.sendEventToBinding(
        pointer.move(
          center + const Offset(60, 60),
          buttons: kPrimaryMouseButton | kSecondaryMouseButton,
        ),
      );
      expect(ctrl.start, isNull);
      expect(ctrl.offsets, isEmpty);

      // Releasing the auxiliary button must not resume the discarded stroke
      // with a jump.
      await tester.sendEventToBinding(
        pointer.move(
          center + const Offset(90, 90),
          buttons: kPrimaryMouseButton,
        ),
      );
      expect(ctrl.offsets, isEmpty);
      await tester.sendEventToBinding(pointer.up());
      expect(created, 0);
    });

    testWidgets(
      'right and middle mouse buttons still draw when the view cannot pan',
      (WidgetTester tester) async {
        for (final PaintEditorConfigs configs in <PaintEditorConfigs>[
          const PaintEditorConfigs(),
          const PaintEditorConfigs(
            enableZoom: true,
            enableZoomWhileDrawing: false,
          ),
        ]) {
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
                  eraserMode: EraserMode.partial,
                  eraserRadius: 8.0,
                  paintEditorConfigs: configs,
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
          for (final int buttons in <int>[
            kSecondaryMouseButton,
            kMiddleMouseButton,
          ]) {
            ctrl
              ..setInProgress(false)
              ..reset();
            final TestGesture gesture = await tester.startGesture(
              center,
              kind: PointerDeviceKind.mouse,
              buttons: buttons,
            );
            await gesture.moveTo(center + const Offset(40, 40));
            expect(ctrl.start, isNotNull);
            await gesture.up();
          }
        }
      },
    );
  });
}
