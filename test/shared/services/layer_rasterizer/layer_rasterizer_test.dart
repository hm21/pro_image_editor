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

    testWidgets('keeps its result when disposed mid-capture', (tester) async {
      // No `addTearDown(dispose)`: this test disposes it itself.
      final rasterizer = LayerRasterizer();

      await tester.pumpWidget(buildHost(rasterizer));

      final capture = rasterizer.capture(
        layers: [textLayerMock],
        editorBodySize: bodySize,
        format: ui.ImageByteFormat.rawRgba,
      );

      await tester.pump();
      await tester.pump();
      // Navigating away disposes the rasterizer while the capture runs. The
      // notification the capture ends with must not turn the result into a
      // "used after being disposed" error.
      rasterizer.dispose();

      final captured = await tester.runAsync(() => capture);
      expect(captured, hasLength(1));
    });

    testWidgets('throws when the host stops rendering mid-capture', (
      tester,
    ) async {
      final rasterizer = LayerRasterizer();
      addTearDown(rasterizer.dispose);

      await tester.pumpWidget(buildHost(rasterizer));

      final capture = rasterizer.capture(
        layers: [textLayerMock],
        editorBodySize: bodySize,
        format: ui.ImageByteFormat.rawRgba,
      );

      await tester.pump();
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump();

      await expectLater(
        capture,
        throwsA(isStateError),
        reason:
            'an unmounted host captures nothing, so failing beats '
            'returning an empty list',
      );
    });

    testWidgets('asserts when two hosts share one rasterizer', (tester) async {
      final rasterizer = LayerRasterizer();
      addTearDown(rasterizer.dispose);

      await tester.pumpWidget(
        MaterialApp(
          home: LayerRasterizerHost(
            rasterizer: rasterizer,
            child: LayerRasterizerHost(
              rasterizer: rasterizer,
              child: const ColoredBox(
                color: Colors.white,
                child: SizedBox.expand(),
              ),
            ),
          ),
        ),
      );

      // Both hosts would render the same layer, so its GlobalKeys would be
      // mounted twice.
      await expectLater(
        rasterizer.capture(layers: [textLayerMock], editorBodySize: bodySize),
        throwsAssertionError,
      );
    });

    testWidgets('asserts when a layer is already mounted elsewhere', (
      tester,
    ) async {
      final rasterizer = LayerRasterizer();
      addTearDown(rasterizer.dispose);

      await tester.pumpWidget(
        MaterialApp(
          home: LayerRasterizerHost(
            rasterizer: rasterizer,
            child: Stack(
              children: [
                LayerWidget(
                  layer: textLayerMock,
                  configs: const ProImageEditorConfigs(),
                  editorBodySize: bodySize,
                ),
              ],
            ),
          ),
        ),
      );

      await expectLater(
        rasterizer.capture(layers: [textLayerMock], editorBodySize: bodySize),
        throwsAssertionError,
      );
    });

    testWidgets('stays usable after a failed capture', (tester) async {
      final rasterizer = LayerRasterizer();
      addTearDown(rasterizer.dispose);

      await tester.pumpWidget(buildHost(rasterizer));

      final failing = rasterizer.capture(
        layers: [textLayerMock],
        editorBodySize: bodySize,
        format: ui.ImageByteFormat.rawRgba,
        awaitContentReady: () async => throw StateError('content failed'),
      );

      for (var i = 0; i < 4; i++) {
        await tester.pump();
      }
      await expectLater(failing, throwsStateError);

      await tester.pump();
      expect(
        find.byType(LayerWidget),
        findsNothing,
        reason: 'a failed capture must still unmount its layers',
      );

      final second = rasterizer.capture(
        layers: [textLayerMock],
        editorBodySize: bodySize,
        format: ui.ImageByteFormat.rawRgba,
      );

      // The queued capture only starts once the failed one settled, so it takes
      // a frame more than a capture that runs on its own.
      await tester.pump();
      await tester.pump();
      expect(
        find.byType(LayerWidget),
        findsOneWidget,
        reason: 'the queue must not stay blocked by the failed capture',
      );

      await tester.pump();
      expect(await tester.runAsync(() => second), hasLength(1));
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
