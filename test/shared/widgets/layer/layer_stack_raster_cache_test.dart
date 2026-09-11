// Dart imports:
import 'dart:async';

// Package imports:
import 'package:flutter_test/flutter_test.dart';
// Flutter imports:
import 'package:material_ui/material_ui.dart';
import 'package:pro_image_editor/core/models/transform_helper.dart';
import 'package:pro_image_editor/features/main_editor/services/paint_layer_raster_cache.dart';
import 'package:pro_image_editor/pro_image_editor.dart';
import 'package:pro_image_editor/shared/services/content_recorder/controllers/content_recorder_controller.dart';
import 'package:pro_image_editor/shared/services/content_recorder/widgets/content_recorder.dart';
import 'package:pro_image_editor/shared/widgets/layer/layer_stack.dart';
import 'package:pro_image_editor/shared/widgets/layer/layer_widget.dart';

const Size _body = Size(200, 300);

const _imageInfos = ImageInfos(
  rawSize: _body,
  renderedSize: _body,
  originalRenderedSize: _body,
  cropRectSize: _body,
  pixelRatio: 1,
  isRotated: false,
);

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

Widget _layerStack(
  List<Layer> layers, {
  bool enableCache = true,
  bool suspend = false,
}) {
  return LayerStack(
    configs: ProImageEditorConfigs(
      mainEditor: MainEditorConfigs(enablePaintLayerRasterCache: enableCache),
    ),
    layers: layers,
    overlayColor: Colors.black,
    transformHelper: const TransformHelper(
      editorBodySize: _body,
      mainBodySize: _body,
      mainImageSize: _body,
    ),
    suspendPaintLayerRasterCache: suspend,
  );
}

Widget _stack(
  List<Layer> layers, {
  bool enableCache = true,
  bool suspend = false,
  ContentRecorderController? recorder,
}) {
  Widget stack = _layerStack(
    layers,
    enableCache: enableCache,
    suspend: suspend,
  );
  if (recorder != null) {
    stack = ContentRecorder(
      controller: recorder,
      autoDestroyController: false,
      child: stack,
    );
  }
  return MaterialApp(
    home: Center(
      child: SizedBox.fromSize(size: _body, child: stack),
    ),
  );
}

Iterable<bool> _cachedFlags(WidgetTester tester) => tester
    .widgetList<LayerWidget>(find.byType(LayerWidget))
    .map((widget) => widget.isRasterCached);

bool _allCached(WidgetTester tester) {
  final flags = _cachedFlags(tester);
  return flags.isNotEmpty && flags.every((c) => c);
}

Future<void> _pumpUntilCached(WidgetTester tester) async {
  await tester.runAsync(() async {
    for (var i = 0; i < 100 && !_allCached(tester); i++) {
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

    testWidgets('renders live for the frame the enclosing recorder reads', (
      tester,
    ) async {
      final recorder = ContentRecorderController(
        configs: const ImageGenerationConfigs(
          enableIsolateGeneration: false,
          enableBackgroundGeneration: false,
        ),
        isVideoEditor: false,
        ignoreGeneration: true,
      );
      addTearDown(recorder.destroy);
      final layers = [_stroke(const Offset(-30, 0))];
      await tester.pumpWidget(_stack(layers, recorder: recorder));
      await _pumpUntilCached(tester);
      expect(recorder.liveLayerRequests.hasHost, isTrue);

      // The capture waits for a frame in which the strokes paint live — a
      // cached image would be upscaled into the output — and the cache takes
      // over again afterwards. Frames only happen when the test pumps them.
      var sawLive = false;
      await tester.runAsync(() async {
        var done = false;
        final future = recorder
            .getRawRenderedImage(imageInfos: _imageInfos)
            .whenComplete(() => done = true);
        // The request is raised at once; the host acts on it in the next
        // frame, and the read follows that frame.
        expect(recorder.liveLayerRequests.value, 1);
        expect(done, isFalse);
        while (!done) {
          await Future<void>.delayed(const Duration(milliseconds: 10));
          await tester.pump();
          if (!_allCached(tester)) sawLive = true;
        }
        (await future)?.dispose();
      });

      expect(sawLive, isTrue);
      expect(recorder.liveLayerRequests.value, 0);
      await _pumpUntilCached(tester);
      expect(_cachedFlags(tester), [true]);
    });

    testWidgets('does not delay a capture when no host listens', (
      tester,
    ) async {
      final recorder = ContentRecorderController(
        configs: const ImageGenerationConfigs(
          enableIsolateGeneration: false,
          enableBackgroundGeneration: false,
        ),
        isVideoEditor: false,
        ignoreGeneration: true,
      );
      addTearDown(recorder.destroy);
      await tester.pumpWidget(
        _stack([_stroke(Offset.zero)], enableCache: false, recorder: recorder),
      );

      expect(recorder.liveLayerRequests.hasHost, isFalse);
      // Completes without another frame being pumped.
      final image = await tester.runAsync(
        () => recorder.getRawRenderedImage(imageInfos: _imageInfos),
      );
      expect(image, isNotNull);
      image!.dispose();
    });

    testWidgets('renders live while its route is animating', (tester) async {
      final layers = [_stroke(const Offset(-30, 0))];
      final navigatorKey = GlobalKey<NavigatorState>();
      await tester.pumpWidget(
        MaterialApp(navigatorKey: navigatorKey, home: const SizedBox()),
      );

      // Hero shuttles fly in the overlay while their destination widgets are
      // hidden, so a cached image would show the strokes twice until the
      // transition ends.
      unawaited(
        navigatorKey.currentState!.push(
          PageRouteBuilder<void>(
            transitionDuration: const Duration(milliseconds: 300),
            pageBuilder: (_, _, _) => Center(
              child: SizedBox.fromSize(size: _body, child: _layerStack(layers)),
            ),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 100)),
      );
      await tester.pump(const Duration(milliseconds: 50));

      expect(_cachedFlags(tester), [false]);
      expect(find.byType(PaintRunImage), findsNothing);

      await tester.pumpAndSettle();
      await _pumpUntilCached(tester);

      expect(_cachedFlags(tester), [true]);
      expect(find.byType(PaintRunImage), findsOneWidget);
    });
  });
}
