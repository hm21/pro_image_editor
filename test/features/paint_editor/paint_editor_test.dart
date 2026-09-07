// Flutter imports:
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_test/flutter_test.dart';
import 'package:network_image_mock/network_image_mock.dart';
import 'package:pro_image_editor/features/paint_editor/widgets/paint_canvas.dart';
import 'package:pro_image_editor/pro_image_editor.dart';
import 'package:pro_image_editor/shared/widgets/extended/interactive_viewer/extended_interactive_viewer.dart';
import 'package:pro_image_editor/shared/widgets/layer/layer_widget.dart';
import 'package:pro_image_editor/shared/widgets/slider_bottom_sheet.dart';

// Project imports:
import '../../mock/mock_image.dart';

void main() {
  const opacityBottomSheetBackground = Colors.red;
  const lineWidthBottomSheetBackground = Colors.green;
  const opacityBottomSheetTitle = 'Test-Opacity-Title';
  const lineWidthBottomSheetTitle = 'Test-Line-Width-Title';

  final initConfigs = PaintEditorInitConfigs(
    theme: ThemeData(),
    configs: const ProImageEditorConfigs(
      i18n: I18n(
        paintEditor: I18nPaintEditor(
          changeOpacity: opacityBottomSheetTitle,
          lineWidth: lineWidthBottomSheetTitle,
        ),
      ),
      paintEditor: PaintEditorConfigs(
        style: PaintEditorStyle(
          opacityBottomSheetBackground: opacityBottomSheetBackground,
          lineWidthBottomSheetBackground: lineWidthBottomSheetBackground,
        ),
      ),
    ),
  );
  var key = GlobalKey<PaintEditorState>();
  Future<void> pumpEditor(WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: PaintEditor.memory(
            mockMemoryImage,
            key: key,
            initConfigs: initConfigs,
          ),
        ),
      ),
    );
    expect(find.byType(PaintEditor), findsOneWidget);
  }

  group('PaintEditor Initialization', () {
    testWidgets('creates PaintEditor using memory image', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: PaintEditor.memory(mockMemoryImage, initConfigs: initConfigs),
        ),
      );

      expect(find.byType(PaintEditor), findsOneWidget);
    });
    testWidgets('creates PaintEditor using network image', (
      WidgetTester tester,
    ) async {
      await mockNetworkImagesFor(() async {
        await tester.pumpWidget(
          MaterialApp(
            home: PaintEditor.network(
              mockNetworkImage,
              initConfigs: initConfigs,
            ),
          ),
        );
      });

      expect(find.byType(PaintEditor), findsOneWidget);
    });
    testWidgets('creates PaintEditor using file image', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: PaintEditor.file(mockFileImage, initConfigs: initConfigs),
        ),
      );

      expect(find.byType(PaintEditor), findsOneWidget);
    });
    testWidgets('creates PaintEditor using file path', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(home: PaintEditor.file('', initConfigs: initConfigs)),
      );

      expect(find.byType(PaintEditor), findsOneWidget);
    });
    group('creates PaintEditor using autoSource constructor', () {
      testWidgets('Auto-detects from memory image', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          MaterialApp(
            home: PaintEditor.autoSource(
              byteArray: mockMemoryImage,
              initConfigs: initConfigs,
            ),
          ),
        );

        expect(find.byType(PaintEditor), findsOneWidget);
      });
      testWidgets('Auto-detects from network image', (
        WidgetTester tester,
      ) async {
        await mockNetworkImagesFor(() async {
          await tester.pumpWidget(
            MaterialApp(
              home: PaintEditor.autoSource(
                networkUrl: mockNetworkImage,
                initConfigs: initConfigs,
              ),
            ),
          );
        });

        expect(find.byType(PaintEditor), findsOneWidget);
      });
      testWidgets('Auto-detects from file image', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: PaintEditor.autoSource(
              file: mockFileImage,
              initConfigs: initConfigs,
            ),
          ),
        );

        expect(find.byType(PaintEditor), findsOneWidget);
      });
      testWidgets('Auto-detects from file path', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: PaintEditor.autoSource(file: '', initConfigs: initConfigs),
          ),
        );

        expect(find.byType(PaintEditor), findsOneWidget);
      });
    });
  });

  group('PaintEditor UI Components', () {
    testWidgets('should render BarColorPicker', (WidgetTester tester) async {
      await pumpEditor(tester);

      expect(find.byType(BarColorPicker), findsOneWidget);
    });
    testWidgets('should render Canvas', (WidgetTester tester) async {
      await pumpEditor(tester);

      expect(find.byType(PaintCanvas), findsOneWidget);
    });
  });

  group('PaintEditor Sheets', () {
    testWidgets('should open linWidthBottomSheet via openLinWidthBottomSheet', (
      tester,
    ) async {
      await pumpEditor(tester);

      key.currentState!.openLinWidthBottomSheet();
      await tester.pump();

      expect(find.byType(SliderBottomSheet<PaintEditorState>), findsOneWidget);
    });
    testWidgets('should open opacityBottomSheet via openOpacityBottomSheet', (
      tester,
    ) async {
      await pumpEditor(tester);

      key.currentState!.openOpacityBottomSheet();
      await tester.pump();

      expect(find.byType(SliderBottomSheet<PaintEditorState>), findsOneWidget);
    });

    testWidgets('Line width bottom sheet has correct background color', (
      WidgetTester tester,
    ) async {
      await pumpEditor(tester);

      key.currentState!.openLinWidthBottomSheet();

      await tester.pumpAndSettle(); // Wait for bottom sheet to appear

      final modalMaterial = tester.widget<Material>(
        find.byWidgetPredicate(
          (widget) =>
              widget is Material &&
              widget.color == lineWidthBottomSheetBackground,
        ),
      );

      expect(modalMaterial.color, lineWidthBottomSheetBackground);
    });

    testWidgets('Opacity bottom sheet has correct background color', (
      WidgetTester tester,
    ) async {
      await pumpEditor(tester);

      key.currentState!.openOpacityBottomSheet();

      await tester.pumpAndSettle(); // Wait for bottom sheet to appear

      final modalMaterial = tester.widget<Material>(
        find.byWidgetPredicate(
          (widget) =>
              widget is Material &&
              widget.color == opacityBottomSheetBackground,
        ),
      );

      expect(modalMaterial.color, opacityBottomSheetBackground);
    });

    testWidgets('Line width bottom sheet has correct title', (
      WidgetTester tester,
    ) async {
      await pumpEditor(tester);

      key.currentState!.openLinWidthBottomSheet();

      await tester.pumpAndSettle(); // Wait for bottom sheet to appear

      expect(find.text(lineWidthBottomSheetTitle), findsOneWidget);
    });

    testWidgets('Opacity bottom sheet has correct title', (
      WidgetTester tester,
    ) async {
      await pumpEditor(tester);

      key.currentState!.openOpacityBottomSheet();

      await tester.pumpAndSettle(); // Wait for bottom sheet to appear

      expect(find.text(opacityBottomSheetTitle), findsOneWidget);
    });
  });

  group('PaintEditor State Manipulation', () {
    testWidgets('should change paint-mode', (WidgetTester tester) async {
      await pumpEditor(tester);

      /// Test if paintModes will change correctly
      key.currentState!.setMode(PaintMode.freeStyle);
      expect(key.currentState!.paintMode, PaintMode.freeStyle);

      key.currentState!.setMode(PaintMode.dashLine);
      expect(key.currentState!.paintMode, PaintMode.dashLine);

      key.currentState!.setMode(PaintMode.dashDotLine);
      expect(key.currentState!.paintMode, PaintMode.dashDotLine);

      key.currentState!.setMode(PaintMode.arrow);
      expect(key.currentState!.paintMode, PaintMode.arrow);
    });
    testWidgets('should change stroke width', (WidgetTester tester) async {
      await pumpEditor(tester);

      /// Test if paintModes will change correctly
      for (double i = 1; i <= 10; i++) {
        key.currentState!.setStrokeWidth(i);
        expect(key.currentState!.strokeWidth, i);
      }
    });
    testWidgets('should toggle fill state', (WidgetTester tester) async {
      await pumpEditor(tester);

      bool filled = key.currentState!.fillBackground;

      key.currentState!.toggleFill();
      expect(key.currentState!.fillBackground, !filled);

      key.currentState!.toggleFill();
      expect(key.currentState!.fillBackground, filled);
    });
    testWidgets('should set fill via setFill', (WidgetTester tester) async {
      await pumpEditor(tester);

      final editor = key.currentState!;
      bool initialIsFilled = editor.fillBackground;

      editor.setFill(!initialIsFilled);

      expect(editor.fillBackground, isNot(initialIsFilled));
    });
    testWidgets('should set opacity via setOpacity', (
      WidgetTester tester,
    ) async {
      await pumpEditor(tester);

      final editor = key.currentState!;
      double newOpacity = 0.21;

      editor.setOpacity(newOpacity);

      expect(editor.opacity, newOpacity);
    });
    testWidgets('should add custom paintings', (WidgetTester tester) async {
      await pumpEditor(tester);

      final editor = key.currentState!;

      /// The first history are the initial layers
      expect(editor.stateHistory.length, 1);

      editor.addPainting(
        PaintedModel(
          mode: PaintMode.rect,
          offsets: [const Offset(0, 0), const Offset(100, 100)],
          erasedOffsets: [],
          color: Colors.red,
          strokeWidth: 5,
          opacity: 1,
        ),
      );

      await tester.pump();

      expect(editor.stateHistory.length, 2);
      expect(find.byType(LayerWidget), findsAtLeast(1));
    });

    testWidgets('should undo the last action', (WidgetTester tester) async {
      await pumpEditor(tester);

      final editor = key.currentState!
        // Add a painting
        ..addPainting(
          PaintedModel(
            mode: PaintMode.rect,
            offsets: [const Offset(0, 0), const Offset(100, 100)],
            erasedOffsets: [],
            color: Colors.red,
            strokeWidth: 5,
            opacity: 1,
          ),
        );

      await tester.pump();

      // Verify the painting was added
      expect(editor.stateHistory.length, 2);
      expect(editor.canUndo, isTrue);

      // Perform undo
      editor.undoAction();
      await tester.pump();

      // Verify the painting was undone
      expect(editor.stateHistory.length, 2);
      expect(editor.historyPointer, 0);
      expect(editor.canUndo, isFalse);
    });

    testWidgets('should redo the last undone action', (
      WidgetTester tester,
    ) async {
      await pumpEditor(tester);

      final editor = key.currentState!
        // Add a painting
        ..addPainting(
          PaintedModel(
            mode: PaintMode.rect,
            offsets: [const Offset(0, 0), const Offset(100, 100)],
            erasedOffsets: [],
            color: Colors.red,
            strokeWidth: 5,
            opacity: 1,
          ),
        );

      await tester.pump();

      // Perform undo
      editor.undoAction();
      await tester.pump();

      // Verify the painting was undone
      expect(editor.historyPointer, 0);
      expect(editor.canRedo, isTrue);

      // Perform redo
      editor.redoAction();
      await tester.pump();

      // Verify the painting was redone
      expect(editor.historyPointer, 1);
      expect(editor.canRedo, isFalse);
    });

    testWidgets('should not redo if no actions were undone', (
      WidgetTester tester,
    ) async {
      await pumpEditor(tester);

      final editor = key.currentState!;

      // Verify initial state
      expect(editor.canRedo, isFalse);

      // Attempt redo
      editor.redoAction();
      await tester.pump();

      // Verify no changes occurred
      expect(editor.historyPointer, 0);
      expect(editor.canRedo, isFalse);
    });

    testWidgets('should not undo if no actions were performed', (
      WidgetTester tester,
    ) async {
      await pumpEditor(tester);

      final editor = key.currentState!;

      // Verify initial state
      expect(editor.canUndo, isFalse);

      // Attempt undo
      editor.undoAction();
      await tester.pump();

      // Verify no changes occurred
      expect(editor.historyPointer, 0);
      expect(editor.canUndo, isFalse);
    });
  });

  group('PaintEditor zoom while drawing', () {
    Future<void> pumpZoomEditor(
      WidgetTester tester, {
      bool enableZoomWhileDrawing = true,
      EdgeInsets boundaryMargin = EdgeInsets.zero,
      PaintEditorCallbacks? paintEditorCallbacks,
    }) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PaintEditor.memory(
              mockMemoryImage,
              key: key,
              initConfigs: PaintEditorInitConfigs(
                theme: ThemeData(),
                configs: ProImageEditorConfigs(
                  paintEditor: PaintEditorConfigs(
                    enableZoom: true,
                    enableZoomWhileDrawing: enableZoomWhileDrawing,
                    boundaryMargin: boundaryMargin,
                  ),
                ),
                callbacks: ProImageEditorCallbacks(
                  paintEditorCallbacks: paintEditorCallbacks,
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pump();
    }

    Future<void> expectMouseButtonPansWithoutDrawing(
      WidgetTester tester,
      int buttons,
    ) async {
      await pumpZoomEditor(
        tester,
        boundaryMargin: const EdgeInsets.all(double.infinity),
      );

      final editor = key.currentState!;
      expect(editor.paintMode, PaintMode.freeStyle);

      final Offset center = tester.getCenter(
        find.byKey(editor.interactiveViewer),
      );
      final TestGesture gesture = await tester.startGesture(
        center,
        kind: PointerDeviceKind.mouse,
        buttons: buttons,
      );
      await gesture.moveBy(const Offset(80, 40));
      expect(
        editor.interactiveViewer.currentState!.transformMatrix4
            .getTranslation()
            .x,
        isNot(0),
      );
      await gesture.up();
      await tester.pump();
      expect(
        editor.interactiveViewer.currentState!.transformMatrix4
            .getTranslation()
            .x,
        isNot(0),
      );
      expect(editor.canUndo, isFalse);
    }

    testWidgets('keeps scale on and pan off in a drawing tool', (tester) async {
      await pumpZoomEditor(tester);

      final viewer = key.currentState!.interactiveViewer.currentState!;
      expect(key.currentState!.paintMode, PaintMode.freeStyle);
      expect(viewer.isPanEnabled, isFalse);
      expect(viewer.isScaleEnabled, isTrue);
    });

    testWidgets('enables pan and scale in moveAndZoom', (tester) async {
      await pumpZoomEditor(tester);

      key.currentState!.setMode(PaintMode.moveAndZoom);
      await tester.pump();

      final viewer = key.currentState!.interactiveViewer.currentState!;
      expect(viewer.isPanEnabled, isTrue);
      expect(viewer.isScaleEnabled, isTrue);
    });

    testWidgets('keeps the viewer frozen by default in a drawing tool', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PaintEditor.memory(
              mockMemoryImage,
              key: key,
              initConfigs: PaintEditorInitConfigs(
                theme: ThemeData(),
                configs: const ProImageEditorConfigs(
                  paintEditor: PaintEditorConfigs(enableZoom: true),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pump();

      final viewer = key.currentState!.interactiveViewer.currentState!;
      expect(key.currentState!.paintMode, PaintMode.freeStyle);
      expect(viewer.isPanEnabled, isFalse);
      expect(viewer.isScaleEnabled, isFalse);
    });

    testWidgets('freezes the viewer when enableZoomWhileDrawing is false', (
      tester,
    ) async {
      await pumpZoomEditor(tester, enableZoomWhileDrawing: false);

      final viewer = key.currentState!.interactiveViewer.currentState!;
      expect(viewer.isPanEnabled, isFalse);
      expect(viewer.isScaleEnabled, isFalse);
    });

    testWidgets('right mouse button pans without drawing', (tester) async {
      await expectMouseButtonPansWithoutDrawing(tester, kSecondaryMouseButton);
    });

    testWidgets('middle mouse button pans without drawing', (tester) async {
      await expectMouseButtonPansWithoutDrawing(tester, kMiddleMouseButton);
    });

    testWidgets('a stroke is not reported as a zoom interaction', (
      tester,
    ) async {
      var starts = 0;
      var updates = 0;
      var ends = 0;
      await pumpZoomEditor(
        tester,
        paintEditorCallbacks: PaintEditorCallbacks(
          onEditorZoomScaleStart: (_) => starts++,
          onEditorZoomScaleUpdate: (_) => updates++,
          onEditorZoomScaleEnd: (_) => ends++,
        ),
      );

      final editor = key.currentState!;
      expect(editor.paintMode, PaintMode.freeStyle);

      final Offset center = tester.getCenter(find.byType(PaintCanvas));
      final TestGesture gesture = await tester.startGesture(center);
      for (var i = 0; i < 5; i++) {
        await gesture.moveBy(const Offset(12, 12));
        await tester.pump();
      }
      await gesture.up();
      await tester.pump();

      // The viewer keeps its gesture detector alive so a pinch can still zoom,
      // but a one-finger drag is a stroke - not navigation.
      expect(starts, 0);
      expect(updates, 0);
      expect(ends, 0);
      expect(editor.canUndo, isTrue);
    });

    testWidgets('a pinch is reported as a zoom interaction', (tester) async {
      var starts = 0;
      var updates = 0;
      var ends = 0;
      await pumpZoomEditor(
        tester,
        boundaryMargin: const EdgeInsets.all(double.infinity),
        paintEditorCallbacks: PaintEditorCallbacks(
          onEditorZoomScaleStart: (_) => starts++,
          onEditorZoomScaleUpdate: (_) => updates++,
          onEditorZoomScaleEnd: (_) => ends++,
        ),
      );

      final Offset center = tester.getCenter(find.byType(PaintCanvas));
      final TestGesture first = await tester.startGesture(
        center - const Offset(20, 0),
      );
      final TestGesture second = await tester.startGesture(
        center + const Offset(20, 0),
      );
      for (var i = 0; i < 5; i++) {
        await first.moveBy(const Offset(-10, 0));
        await second.moveBy(const Offset(10, 0));
        await tester.pump();
      }
      await first.up();
      await second.up();
      await tester.pump();

      expect(starts, 1);
      expect(updates, greaterThan(0));
      expect(ends, 1);
    });

    testWidgets('right mouse button pans when click-drag pan is disabled', (
      tester,
    ) async {
      final viewerKey = GlobalKey<ExtendedInteractiveViewerState>();
      const childKey = Key('aux-pan-child');
      await tester.pumpWidget(
        MaterialApp(
          home: SizedBox(
            width: 400,
            height: 400,
            child: ExtendedInteractiveViewer(
              key: viewerKey,
              panEnabled: false,
              scaleEnabled: true,
              zoomConfigs: const PaintEditorConfigs(
                enableZoom: true,
                boundaryMargin: EdgeInsets.all(double.infinity),
              ),
              onInteractionStart: (_) {},
              onInteractionUpdate: (_) {},
              onInteractionEnd: (_) {},
              child: const ColoredBox(key: childKey, color: Colors.red),
            ),
          ),
        ),
      );
      await tester.pump();

      final viewer = viewerKey.currentState!;
      final Offset center = tester.getCenter(find.byKey(childKey));
      final TestGesture gesture = await tester.startGesture(
        center,
        kind: PointerDeviceKind.mouse,
        buttons: kSecondaryMouseButton,
      );
      await gesture.moveBy(const Offset(50, 0));
      await tester.pump();
      await gesture.up();

      expect(viewer.transformMatrix4.getTranslation().x, isNot(0));
    });
  });
}
