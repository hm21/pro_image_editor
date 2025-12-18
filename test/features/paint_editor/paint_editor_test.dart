// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_test/flutter_test.dart';
import 'package:network_image_mock/network_image_mock.dart';
import 'package:pro_image_editor/features/paint_editor/widgets/paint_canvas.dart';
import 'package:pro_image_editor/pro_image_editor.dart';
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
    testWidgets('creates PaintEditor using memory image',
        (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(
        home: PaintEditor.memory(mockMemoryImage, initConfigs: initConfigs),
      ));

      expect(find.byType(PaintEditor), findsOneWidget);
    });
    testWidgets('creates PaintEditor using network image',
        (WidgetTester tester) async {
      await mockNetworkImagesFor(() async {
        await tester.pumpWidget(MaterialApp(
          home: PaintEditor.network(mockNetworkImage, initConfigs: initConfigs),
        ));
      });

      expect(find.byType(PaintEditor), findsOneWidget);
    });
    testWidgets('creates PaintEditor using file image',
        (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(
        home: PaintEditor.file(mockFileImage, initConfigs: initConfigs),
      ));

      expect(find.byType(PaintEditor), findsOneWidget);
    });
    testWidgets('creates PaintEditor using file path',
        (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(
        home: PaintEditor.file('', initConfigs: initConfigs),
      ));

      expect(find.byType(PaintEditor), findsOneWidget);
    });
    group('creates PaintEditor using autoSource constructor', () {
      testWidgets('Auto-detects from memory image',
          (WidgetTester tester) async {
        await tester.pumpWidget(MaterialApp(
          home: PaintEditor.autoSource(
            byteArray: mockMemoryImage,
            initConfigs: initConfigs,
          ),
        ));

        expect(find.byType(PaintEditor), findsOneWidget);
      });
      testWidgets('Auto-detects from network image',
          (WidgetTester tester) async {
        await mockNetworkImagesFor(() async {
          await tester.pumpWidget(MaterialApp(
            home: PaintEditor.autoSource(
              networkUrl: mockNetworkImage,
              initConfigs: initConfigs,
            ),
          ));
        });

        expect(find.byType(PaintEditor), findsOneWidget);
      });
      testWidgets('Auto-detects from file image', (WidgetTester tester) async {
        await tester.pumpWidget(MaterialApp(
          home: PaintEditor.autoSource(
            file: mockFileImage,
            initConfigs: initConfigs,
          ),
        ));

        expect(find.byType(PaintEditor), findsOneWidget);
      });
      testWidgets('Auto-detects from file path', (WidgetTester tester) async {
        await tester.pumpWidget(MaterialApp(
          home: PaintEditor.autoSource(file: '', initConfigs: initConfigs),
        ));

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
    testWidgets('should open linWidthBottomSheet via openLinWidthBottomSheet',
        (tester) async {
      await pumpEditor(tester);

      key.currentState!.openLinWidthBottomSheet();
      await tester.pump();

      expect(find.byType(SliderBottomSheet<PaintEditorState>), findsOneWidget);
    });
    testWidgets('should open opacityBottomSheet via openOpacityBottomSheet',
        (tester) async {
      await pumpEditor(tester);

      key.currentState!.openOpacityBottomSheet();
      await tester.pump();

      expect(find.byType(SliderBottomSheet<PaintEditorState>), findsOneWidget);
    });

    testWidgets('Line width bottom sheet has correct background color',
        (WidgetTester tester) async {
      await pumpEditor(tester);

      key.currentState!.openLinWidthBottomSheet();

      await tester.pumpAndSettle(); // Wait for bottom sheet to appear

      final modalMaterial = tester.widget<Material>(
        find.byWidgetPredicate((widget) =>
            widget is Material &&
            widget.color == lineWidthBottomSheetBackground),
      );

      expect(modalMaterial.color, lineWidthBottomSheetBackground);
    });

    testWidgets('Opacity bottom sheet has correct background color',
        (WidgetTester tester) async {
      await pumpEditor(tester);

      key.currentState!.openOpacityBottomSheet();

      await tester.pumpAndSettle(); // Wait for bottom sheet to appear

      final modalMaterial = tester.widget<Material>(
        find.byWidgetPredicate((widget) =>
            widget is Material && widget.color == opacityBottomSheetBackground),
      );

      expect(modalMaterial.color, opacityBottomSheetBackground);
    });

    testWidgets('Line width bottom sheet has correct title',
        (WidgetTester tester) async {
      await pumpEditor(tester);

      key.currentState!.openLinWidthBottomSheet();

      await tester.pumpAndSettle(); // Wait for bottom sheet to appear

      expect(find.text(lineWidthBottomSheetTitle), findsOneWidget);
    });

    testWidgets('Opacity bottom sheet has correct title',
        (WidgetTester tester) async {
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
    testWidgets('should set opacity via setOpacity',
        (WidgetTester tester) async {
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

    testWidgets('should redo the last undone action',
        (WidgetTester tester) async {
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

    testWidgets('should not redo if no actions were undone',
        (WidgetTester tester) async {
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

    testWidgets('should not undo if no actions were performed',
        (WidgetTester tester) async {
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
}
