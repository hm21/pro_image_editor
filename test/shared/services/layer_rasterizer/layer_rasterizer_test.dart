import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pro_image_editor/pro_image_editor.dart';
import 'package:pro_image_editor/shared/widgets/layer/layer_widget.dart';

import '../../../mock/layers/text_layer_mock.dart';

void main() {
  group(LayerRasterizer, () {
    const bodySize = Size(300, 500);

    Widget buildHost(LayerRasterizer rasterizer) {
      return MaterialApp(
        home: LayerRasterizerHost(
          rasterizer: rasterizer,
          // Opaque and full-bleed: the host paints captured layers behind this
          // child, and the child is what keeps them off screen.
          child: const ColoredBox(
            color: Colors.white,
            child: SizedBox.expand(),
          ),
        ),
      );
    }

    test(
      'returns an empty list without mounting anything when layers is empty',
      () async {
        final rasterizer = LayerRasterizer();
        addTearDown(rasterizer.dispose);

        expect(rasterizer.hasHost, isFalse);
        await expectLater(
          rasterizer.capture(layers: const [], editorBodySize: bodySize),
          completion(isEmpty),
        );
      },
    );

    test('throws a StateError when no host is mounted', () async {
      final rasterizer = LayerRasterizer();
      addTearDown(rasterizer.dispose);

      await expectLater(
        rasterizer.capture(layers: [textLayerMock], editorBodySize: bodySize),
        throwsA(isStateError),
      );
    });

    testWidgets('reports a host while one is mounted', (tester) async {
      final rasterizer = LayerRasterizer();
      addTearDown(rasterizer.dispose);

      await tester.pumpWidget(buildHost(rasterizer));
      expect(rasterizer.hasHost, isTrue);

      await tester.pumpWidget(const SizedBox.shrink());
      expect(rasterizer.hasHost, isFalse);
    });

    testWidgets('renders no layers while idle', (tester) async {
      final rasterizer = LayerRasterizer();
      addTearDown(rasterizer.dispose);

      await tester.pumpWidget(buildHost(rasterizer));

      expect(find.byType(LayerWidget), findsNothing);
    });

    testWidgets('mounts the requested layers for the duration of the capture', (
      tester,
    ) async {
      final rasterizer = LayerRasterizer();
      addTearDown(rasterizer.dispose);

      await tester.pumpWidget(buildHost(rasterizer));

      final capture = rasterizer.capture(
        layers: [textLayerMock],
        editorBodySize: bodySize,
        // rawRgba encodes on the main thread; PNG would route through the
        // isolate-backed recorder, which a widget test cannot drive.
        format: ui.ImageByteFormat.rawRgba,
      );

      await tester.pump();
      expect(
        find.byType(LayerWidget),
        findsOneWidget,
        reason: 'the layer must be in the tree for its boundary to paint',
      );

      await tester.pump();
      final captured = await tester.runAsync(() => capture);

      expect(captured, hasLength(1));
      expect(captured!.single.layer, same(textLayerMock));
      expect(
        captured.single.bytes,
        isNotEmpty,
        reason: 'an unmounted layer captures as null and is dropped',
      );
      expect(captured.single.logicalSize.isEmpty, isFalse);

      await tester.pump();
      expect(
        find.byType(LayerWidget),
        findsNothing,
        reason: 'the host must stop rendering once the capture is done',
      );
    });

    testWidgets('awaits awaitContentReady before capturing', (tester) async {
      final rasterizer = LayerRasterizer();
      addTearDown(rasterizer.dispose);

      await tester.pumpWidget(buildHost(rasterizer));

      var readyCalled = false;
      var layerWasMountedWhenReadyRan = false;

      final capture = rasterizer.capture(
        layers: [textLayerMock],
        editorBodySize: bodySize,
        format: ui.ImageByteFormat.rawRgba,
        awaitContentReady: () async {
          readyCalled = true;
          layerWasMountedWhenReadyRan = find
              .byType(LayerWidget)
              .evaluate()
              .isNotEmpty;
        },
      );

      // Pump generously rather than matching the rasterizer's exact frame
      // count: extra frames are harmless, and a missing one would hang.
      for (var i = 0; i < 6; i++) {
        await tester.pump();
      }
      await tester.runAsync(() => capture);

      expect(readyCalled, isTrue);
      expect(
        layerWasMountedWhenReadyRan,
        isTrue,
        reason: 'the hook exists to resolve content of already-mounted layers',
      );
    });
  });
}
