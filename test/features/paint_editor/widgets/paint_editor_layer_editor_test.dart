import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pro_image_editor/features/paint_editor/widgets/paint_editor_layer_editor.dart';
import 'package:pro_image_editor/pro_image_editor.dart';
import 'package:pro_image_editor/shared/widgets/layer/widgets/layer_widget_paint_item.dart';

void main() {
  group('PaintEditorLayerEditor', () {
    late PaintLayer testLayer;
    late ProImageEditorConfigs testConfigs;

    setUp(() {
      testLayer = PaintLayer(
        rawSize: const Size.square(200),
        opacity: 1,
        item: PaintedModel(
          color: Colors.blue,
          strokeWidth: 5.0,
          fill: false,
          mode: PaintMode.rect,
          offsets: [const Offset(0, 0), const Offset(200, 200)],
          erasedOffsets: [],
          opacity: 1,
        ),
      );

      testConfigs = const ProImageEditorConfigs(
        i18n: I18n(
          paintEditor: I18nPaintEditor(
            color: 'Color',
            opacity: 'Opacity',
            strokeWidth: 'Stroke Width',
            fill: 'Fill',
            cancel: 'Cancel',
            done: 'Done',
          ),
        ),
        paintEditor: PaintEditorConfigs(
          maxOpacity: 1.0,
          minOpacity: 0.0,
          divisionsOpacity: 10,
          maxStrokeWidth: 10.0,
          minStrokeWidth: 1.0,
          divisionsStrokeWidth: 10,
          widgets: PaintEditorWidgets(),
        ),
      );
    });

    testWidgets('renders correctly', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PaintEditorLayerEditor(
              layer: testLayer,
              configs: testConfigs,
            ),
          ),
        ),
      );

      expect(find.byType(Slider), findsNWidgets(2));
      expect(find.byType(LayerWidgetPaintItem), findsOneWidget);
      expect(find.text(testConfigs.i18n.paintEditor.color), findsOneWidget);
      expect(find.text(testConfigs.i18n.paintEditor.opacity), findsOneWidget);
      expect(
          find.text(testConfigs.i18n.paintEditor.strokeWidth), findsOneWidget);
    });

    testWidgets('changes opacity on slider interaction', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: PaintEditorLayerEditor(
            layer: testLayer,
            configs: testConfigs,
          ),
        ),
      ));

      final opacitySlider = find.byType(Slider).at(0);
      await tester.drag(opacitySlider, const Offset(100, 0));
      await tester.pumpAndSettle();

      // Basic validation
      expect(
          testLayer.opacity, greaterThan(testConfigs.paintEditor.minOpacity));
    });

    testWidgets('toggles fill mode', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: PaintEditorLayerEditor(
            layer: testLayer,
            configs: testConfigs,
          ),
        ),
      ));

      final switchTile = find.byType(SwitchListTile);
      expect(switchTile, findsOneWidget);

      await tester.tap(switchTile);
      await tester.pumpAndSettle();

      expect(testLayer.item.fill, isTrue);
    });

    testWidgets('returns layer on done button via bottom sheet',
        (tester) async {
      PaintLayer? resultLayer;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return Center(
                  child: ElevatedButton(
                    onPressed: () async {
                      final result = await showModalBottomSheet<PaintLayer>(
                        context: context,
                        isScrollControlled: true,
                        builder: (_) => PaintEditorLayerEditor(
                          layer: testLayer,
                          configs: testConfigs,
                        ),
                      );
                      resultLayer = result;
                    },
                    child: const Text('Open Editor'),
                  ),
                );
              },
            ),
          ),
        ),
      );

      // Tap the button to open the bottom sheet
      await tester.tap(find.text('Open Editor'));
      await tester.pumpAndSettle();

      // Tap the 'Done' button in the bottom sheet
      await tester.tap(find.text(testConfigs.i18n.paintEditor.done));
      await tester.pumpAndSettle();

      // The returned resultLayer should be the same as testLayer
      expect(resultLayer, isNotNull);
      expect(resultLayer, equals(testLayer));
    });
  });
}
