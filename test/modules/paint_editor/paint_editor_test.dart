// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_test/flutter_test.dart';
import 'package:network_image_mock/network_image_mock.dart';
import 'package:pro_image_editor/core/models/init_configs/paint_editor_init_configs.dart';
import 'package:pro_image_editor/features/paint_editor/paint_editor.dart';
import 'package:pro_image_editor/features/paint_editor/widgets/paint_canvas.dart';
import 'package:pro_image_editor/shared/widgets/color_picker/bar_color_picker.dart';

// Project imports:
import '../../fake/fake_image.dart';

void main() {
  group('PaintEditor Tests', () {
    testWidgets('Initializes with memory constructor',
        (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(
        home: PaintEditor.memory(
          fakeMemoryImage,
          initConfigs: PaintEditorInitConfigs(
            theme: ThemeData(),
          ),
        ),
      ));

      expect(find.byType(PaintEditor), findsOneWidget);
    });
    testWidgets('Initializes with network constructor',
        (WidgetTester tester) async {
      await mockNetworkImagesFor(() async {
        await tester.pumpWidget(MaterialApp(
          home: PaintEditor.network(
            fakeNetworkImage,
            initConfigs: PaintEditorInitConfigs(
              theme: ThemeData(),
            ),
          ),
        ));

        expect(find.byType(PaintEditor), findsOneWidget);
      });
    });

    testWidgets('should render BarColorPicker', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(
        home: PaintEditor.memory(
          fakeMemoryImage,
          initConfigs: PaintEditorInitConfigs(
            theme: ThemeData(),
          ),
        ),
      ));

      expect(find.byType(BarColorPicker), findsOneWidget);
    });
    testWidgets('should render Canvas', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(
        home: PaintEditor.memory(
          fakeMemoryImage,
          initConfigs: PaintEditorInitConfigs(
            theme: ThemeData(),
          ),
        ),
      ));

      expect(find.byType(PaintCanvas), findsOneWidget);
    });
    testWidgets('should change paint-mode', (WidgetTester tester) async {
      var key = GlobalKey<PaintEditorState>();
      await tester.pumpWidget(MaterialApp(
        home: PaintEditor.memory(
          fakeMemoryImage,
          key: key,
          initConfigs: PaintEditorInitConfigs(
            theme: ThemeData(),
          ),
        ),
      ));

      /// Test if paintModes will change correctly
      key.currentState!.setMode(PaintMode.freeStyle);
      expect(key.currentState!.paintMode, PaintMode.freeStyle);

      key.currentState!.setMode(PaintMode.dashLine);
      expect(key.currentState!.paintMode, PaintMode.dashLine);

      key.currentState!.setMode(PaintMode.arrow);
      expect(key.currentState!.paintMode, PaintMode.arrow);
    });
    testWidgets('should change stroke width', (WidgetTester tester) async {
      var key = GlobalKey<PaintEditorState>();
      await tester.pumpWidget(MaterialApp(
        home: PaintEditor.memory(
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
      var key = GlobalKey<PaintEditorState>();
      await tester.pumpWidget(MaterialApp(
        home: PaintEditor.memory(
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
