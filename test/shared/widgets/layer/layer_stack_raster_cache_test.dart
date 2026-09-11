// Flutter imports:
// Package imports:
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:pro_image_editor/core/models/transform_helper.dart';
import 'package:pro_image_editor/pro_image_editor.dart';
import 'package:pro_image_editor/shared/widgets/layer/layer_stack.dart';
import 'package:pro_image_editor/shared/widgets/layer/layer_widget.dart';

const Size _body = Size(200, 300);

PaintLayer _stroke(Offset offset) => PaintLayer(
  item: PaintedModel(
    mode: PaintMode.freeStyle,
    offsets: const [Offset(0, 0), Offset(10, 20), Offset(20, 5)],
    erasedOffsets: const [],
    color: Colors.red,
    strokeWidth: 4,
    opacity: 1,
  ),
  rawSize: const Size(20, 20),
  opacity: 1,
  offset: offset,
);

Widget _stack(
  List<Layer> layers, {
  bool enableCache = true,
  bool suspend = false,
}) {
  return MaterialApp(
    home: Center(
      child: SizedBox.fromSize(
        size: _body,
        child: LayerStack(
          configs: ProImageEditorConfigs(
            mainEditor: MainEditorConfigs(
              enablePaintLayerRasterCache: enableCache,
            ),
          ),
          layers: layers,
          overlayColor: Colors.black,
          transformHelper: const TransformHelper(
            editorBodySize: _body,
            mainBodySize: _body,
            mainImageSize: _body,
          ),
          suspendPaintLayerRasterCache: suspend,
        ),
      ),
    ),
  );
}

Iterable<bool> _cachedFlags(WidgetTester tester) => tester
    .widgetList<LayerWidget>(find.byType(LayerWidget))
    .map((widget) => widget.isRasterCached);

Future<void> _pumpUntilCached(WidgetTester tester) async {
  await tester.runAsync(() async {
    for (var i = 0; i < 100 && !_cachedFlags(tester).every((c) => c); i++) {
      await Future<void>.delayed(const Duration(milliseconds: 20));
      await tester.pump();
    }
  });
  await tester.pump();
}

void main() {
  group('LayerStack raster cache', () {
    testWidgets('draws paint layers from one image once it is rendered', (
      tester,
    ) async {
      final layers = [
        _stroke(const Offset(-30, 0)),
        _stroke(const Offset(30, 0)),
      ];
      await tester.pumpWidget(_stack(layers));

      // Live until the image lands.
      expect(_cachedFlags(tester), [false, false]);
      expect(find.byType(PaintRunImage), findsNothing);

      await _pumpUntilCached(tester);

      expect(_cachedFlags(tester), [true, true]);
      expect(find.byType(PaintRunImage), findsOneWidget);
    });

    testWidgets('stays live while suspended', (tester) async {
      final layers = [_stroke(const Offset(-30, 0))];
      await tester.pumpWidget(_stack(layers, suspend: true));
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 100)),
      );
      await tester.pump();

      expect(_cachedFlags(tester), [false]);
      expect(find.byType(PaintRunImage), findsNothing);
    });

    testWidgets('does nothing when the feature is off', (tester) async {
      final layers = [_stroke(const Offset(-30, 0))];
      await tester.pumpWidget(_stack(layers, enableCache: false));
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 100)),
      );
      await tester.pump();

      expect(_cachedFlags(tester), [false]);
      expect(find.byType(PaintRunImage), findsNothing);
    });
  });
}
