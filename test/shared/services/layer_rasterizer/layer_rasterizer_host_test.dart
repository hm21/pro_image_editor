import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pro_image_editor/pro_image_editor.dart';
import 'package:pro_image_editor/shared/utils/default_editor_theme.dart';
import 'package:pro_image_editor/shared/widgets/layer/layer_widget.dart';

/// Drives the host directly so a request can be replaced without the frames a
/// real capture waits for — which is exactly what two queued captures do.
class _ManualRasterizer extends LayerRasterizer {
  LayerRasterizationRequest? _request;

  @override
  LayerRasterizationRequest? get request => _request;

  void emit(LayerRasterizationRequest? value) {
    _request = value;
    notifyListeners();
  }
}

void main() {
  group(LayerRasterizerHost, () {
    const bodySize = Size(300, 500);

    LayerRasterizationRequest requestFor(List<Layer> layers) {
      return LayerRasterizationRequest(
        layers: layers,
        editorBodySize: bodySize,
        configs: const ProImageEditorConfigs(),
      );
    }

    Widget buildHost(LayerRasterizer rasterizer) {
      return MaterialApp(
        home: LayerRasterizerHost(
          rasterizer: rasterizer,
          child: const ColoredBox(
            color: Colors.white,
            child: SizedBox.expand(),
          ),
        ),
      );
    }

    testWidgets('rebuilds layers of a follow-up request from scratch', (
      tester,
    ) async {
      final rasterizer = _ManualRasterizer();
      addTearDown(rasterizer.dispose);

      await tester.pumpWidget(buildHost(rasterizer));

      rasterizer.emit(requestFor([TextLayer(text: 'hello')]));
      await tester.pump();
      expect(tester.takeException(), isNull);

      // A queued capture replaces the layers without the host ever rebuilding
      // with no request in between. Unkeyed, the LayerWidget element would be
      // reused and keep the layer type it resolved in `initState`.
      rasterizer.emit(requestFor([EmojiLayer(emoji: '😀')]));
      await tester.pump();

      expect(
        tester.takeException(),
        isNull,
        reason: 'the emoji layer must not be built as the previous text layer',
      );
      expect(find.byType(LayerWidget), findsOneWidget);
    });

    testWidgets('gives the layers the editor theme and a Material ancestor', (
      tester,
    ) async {
      final rasterizer = _ManualRasterizer();
      addTearDown(rasterizer.dispose);

      await tester.pumpWidget(buildHost(rasterizer));
      rasterizer.emit(requestFor([TextLayer(text: 'hello')]));
      await tester.pump();

      final context = tester.element(find.byType(LayerWidget));
      expect(
        Material.maybeOf(context),
        isNotNull,
        reason: 'widget layers built from Material widgets assert without one',
      );
      expect(
        Theme.of(context).brightness,
        defaultEditorTheme().brightness,
        reason: 'emoji metrics are read from the editor theme, not the app one',
      );
      expect(
        DefaultTextStyle.of(context).style.fontFamily,
        isNot('monospace'),
        reason: "MaterialApp's 48px error text style must not leak into layers",
      );
    });

    testWidgets('hides the captured layers from the semantics tree', (
      tester,
    ) async {
      final rasterizer = _ManualRasterizer();
      addTearDown(rasterizer.dispose);
      final handle = tester.ensureSemantics();

      await tester.pumpWidget(buildHost(rasterizer));
      // IgnorePointer only blocks user actions, it keeps the subtree in the
      // semantics tree — so a screen reader would announce layers the user
      // cannot even see.
      rasterizer.emit(
        requestFor([
          WidgetLayer(
            widget: Semantics(
              label: 'secret',
              child: const SizedBox.square(dimension: 20),
            ),
          ),
        ]),
      );
      await tester.pump();

      expect(find.byType(LayerWidget), findsOneWidget);
      expect(find.bySemanticsLabel('secret'), findsNothing);
      handle.dispose();
    });
  });
}
