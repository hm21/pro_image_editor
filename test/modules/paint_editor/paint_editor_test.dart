import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:network_image_mock/network_image_mock.dart';
import 'package:pro_image_editor/models/init_configs/paint_editor_init_configs.dart';
import 'package:pro_image_editor/modules/paint_editor/paint_editor.dart';
import 'package:pro_image_editor/modules/paint_editor/painting_canvas.dart';
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
            imageSize: const Size(200, 200),
          ),
        ),
      ));

      expect(find.byType(PaintingEditor), findsOneWidget);
    });
    testWidgets('Initializes with network constructor',
        (WidgetTester tester) async {
      mockNetworkImagesFor(() async {
        await tester.pumpWidget(MaterialApp(
          home: PaintingEditor.network(
            fakeNetworkImage,
            initConfigs: PaintEditorInitConfigs(
              theme: ThemeData(),
              imageSize: const Size(200, 200),
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
            imageSize: const Size(200, 200),
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
            imageSize: const Size(200, 200),
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
            imageSize: const Size(200, 200),
          ),
        ),
      ));

      expect(find.byType(PaintingCanvas), findsOneWidget);
    });
  });
}
