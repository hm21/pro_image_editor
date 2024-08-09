// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_test/flutter_test.dart';
import 'package:network_image_mock/network_image_mock.dart';

// Project imports:
import 'package:pro_image_editor/models/init_configs/paint_editor_init_configs.dart';
import 'package:pro_image_editor/modules/paint_editor/paint_editor.dart';
import 'package:pro_image_editor/modules/paint_editor/widgets/painting_canvas.dart';
import 'package:pro_image_editor/widgets/color_picker/bar_color_picker.dart';
import '../../fake/fake_image.dart';

void main() {
  group('PaintingEditor Tests', () {
    testWidgets('Initializes with memory constructor',
        (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(
        home: PaintingEditor.memory(
          fakeMemoryImage,
          initConfigs: PaintEditorInitConfigs(
            theme: ThemeData(),
          ),
        ),
      ));

      expect(find.byType(PaintingEditor), findsOneWidget);
    });
    testWidgets('Initializes with network constructor',
        (WidgetTester tester) async {
      await mockNetworkImagesFor(() async {
        await tester.pumpWidget(MaterialApp(
          home: PaintingEditor.network(
            fakeNetworkImage,
            initConfigs: PaintEditorInitConfigs(
              theme: ThemeData(),
            ),
          ),
        ));

        expect(find.byType(PaintingEditor), findsOneWidget);
      });
    });
    testWidgets('Initializes with file constructor',
        (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(
        home: PaintingEditor.file(
          fakeFileImage,
          initConfigs: PaintEditorInitConfigs(
            theme: ThemeData(),
          ),
        ),
      ));

      expect(find.byType(PaintingEditor), findsOneWidget);
    });

    testWidgets('should render BarColorPicker', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(
        home: PaintingEditor.memory(
          fakeMemoryImage,
          initConfigs: PaintEditorInitConfigs(
            theme: ThemeData(),
          ),
        ),
      ));

      expect(find.byType(BarColorPicker), findsOneWidget);
    });
    testWidgets('should render PaintingCanvas', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(
        home: PaintingEditor.memory(
          fakeMemoryImage,
          initConfigs: PaintEditorInitConfigs(
            theme: ThemeData(),
          ),
        ),
      ));

      expect(find.byType(PaintingCanvas), findsOneWidget);
    });
    testWidgets('should change painting-mode', (WidgetTester tester) async {
      var key = GlobalKey<PaintingEditorState>();
      await tester.pumpWidget(MaterialApp(
        home: PaintingEditor.memory(
          fakeMemoryImage,
          key: key,
          initConfigs: PaintEditorInitConfigs(
            theme: ThemeData(),
          ),
        ),
      ));

      /// Test if paintModes will change correctly
      key.currentState!.setMode(PaintModeE.freeStyle);
      expect(key.currentState!.paintMode, PaintModeE.freeStyle);

      key.currentState!.setMode(PaintModeE.dashLine);
      expect(key.currentState!.paintMode, PaintModeE.dashLine);

      key.currentState!.setMode(PaintModeE.arrow);
      expect(key.currentState!.paintMode, PaintModeE.arrow);
    });
    testWidgets('should change stroke width', (WidgetTester tester) async {
      var key = GlobalKey<PaintingEditorState>();
      await tester.pumpWidget(MaterialApp(
        home: PaintingEditor.memory(
          fakeMemoryImage,
          key: key,
          initConfigs: PaintEditorInitConfigs(
            theme: ThemeData(),
          ),
        ),
      ));

      /// Test if paintModes will change correctly
      for (double i = 1; i <= 10; i++) {
        key.currentState!.setStrokeWidth(i);
        expect(key.currentState!.strokeWidth, i);
      }
    });
    testWidgets('should toggle fill state', (WidgetTester tester) async {
      var key = GlobalKey<PaintingEditorState>();
      await tester.pumpWidget(MaterialApp(
        home: PaintingEditor.memory(
          fakeMemoryImage,
          key: key,
          initConfigs: PaintEditorInitConfigs(
            theme: ThemeData(),
          ),
        ),
      ));

      bool filled = key.currentState!.fillBackground;

      key.currentState!.toggleFill();
      expect(key.currentState!.fillBackground, !filled);

      key.currentState!.toggleFill();
      expect(key.currentState!.fillBackground, filled);
    });
  });
}
