// Dart imports:
import 'dart:ui' show ImageByteFormat;

import 'package:flutter/services.dart';
// Package imports:
import 'package:flutter_test/flutter_test.dart';
// Flutter imports:
import 'package:material_ui/material_ui.dart';
// Project imports:
import 'package:pro_image_editor/pro_image_editor.dart';
import 'package:pro_image_editor/shared/services/content_recorder/widgets/content_recorder.dart';
import 'package:pro_image_editor/shared/widgets/layer/layer_widget.dart';

import '../../mock/mock_image.dart';

void main() {
  const configs = ProImageEditorConfigs(
    progressIndicatorConfigs: ProgressIndicatorConfigs(
      widgets: ProgressIndicatorWidgets(
        circularProgressIndicator: SizedBox.shrink(),
      ),
    ),
    imageGeneration: ImageGenerationConfigs(
      enableIsolateGeneration: false,
      enableBackgroundGeneration: false,
    ),
    mainEditor: MainEditorConfigs(enablePaintLayerRasterCache: true),
  );

  PaintLayer buildPaintLayer(Offset offset) {
    return PaintLayer(
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
  }

  Future<ProImageEditorState> pumpEditor(WidgetTester tester) async {
    final key = GlobalKey<ProImageEditorState>();
    await tester.pumpWidget(
      MaterialApp(
        home: ProImageEditor.memory(
          mockMemoryImage,
          key: key,
          configs: configs,
          callbacks: ProImageEditorCallbacks(
            onImageEditingComplete: (Uint8List bytes) async {},
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    return key.currentState!;
  }

  /// Whether each mounted layer currently draws from the cache, by layer id.
  Map<String, bool> cachedByLayer(WidgetTester tester) => {
    for (final widget in tester.widgetList<LayerWidget>(
      find.byType(LayerWidget),
    ))
      widget.layer.id: widget.isRasterCached,
  };

  /// Pumps until [done] holds, driving the real event loop so the cache's
  /// raster callback — genuine engine work — can complete.
  Future<void> pumpUntil(WidgetTester tester, bool Function() done) async {
    await tester.runAsync(() async {
      for (var i = 0; i < 100 && !done(); i++) {
        await Future<void>.delayed(const Duration(milliseconds: 20));
        await tester.pump();
      }
    });
    await tester.pump();
  }

  bool allCached(WidgetTester tester) {
    final cached = cachedByLayer(tester);
    return cached.isNotEmpty && cached.values.every((value) => value);
  }

  /// Adds [layers] without selecting them and waits until the cache draws
  /// them.
  Future<void> addAndCache(
    WidgetTester tester,
    ProImageEditorState state,
    List<Layer> layers,
  ) async {
    for (final layer in layers) {
      state.addLayer(
        layer,
        blockSelectLayer: true,
        autoCorrectZoomOffset: false,
        autoCorrectZoomScale: false,
      );
    }
    state.layerInteractionManager.clearSelectedLayers();
    state.setState(() {});
    await tester.pump();
    await pumpUntil(tester, () => allCached(tester));
  }

  testWidgets('draws static paint layers from one cached image', (
    tester,
  ) async {
    final state = await pumpEditor(tester);
    final rawImagesBefore = find.byType(RawImage).evaluate().length;
    await addAndCache(tester, state, [
      buildPaintLayer(const Offset(-40, 0)),
      buildPaintLayer(const Offset(40, 0)),
    ]);

    // One image for the run, on top of whatever the editor drew before.
    expect(find.byType(RawImage).evaluate().length, rawImagesBefore + 1);
    // Both layers are still mounted for hit-testing but paint nothing.
    expect(cachedByLayer(tester).values, [true, true]);
  });

  testWidgets('drops its images while a sub-editor is open', (tester) async {
    final state = await pumpEditor(tester);
    await addAndCache(tester, state, [
      buildPaintLayer(const Offset(-40, 0)),
      buildPaintLayer(const Offset(40, 0)),
    ]);

    // Opening a sub-editor flips this flag and rebuilds; the layers render
    // live for the hero flight either way, so the images are dead weight.
    state
      ..isSubEditorOpen = true
      ..setState(() {});
    await tester.pump();
    expect(cachedByLayer(tester).values, [false, false]);

    // Back in the main editor the run has to be rendered anew — its image
    // was released, not merely bypassed — and then takes over again.
    state
      ..isSubEditorOpen = false
      ..setState(() {});
    await tester.pump();
    expect(cachedByLayer(tester).values, [false, false]);
    await pumpUntil(tester, () => allCached(tester));
    expect(cachedByLayer(tester).values, [true, true]);
  });

  testWidgets('a selected layer renders live while the rest stay cached', (
    tester,
  ) async {
    final state = await pumpEditor(tester);
    final a = buildPaintLayer(const Offset(-40, 0));
    final b = buildPaintLayer(const Offset(40, 0));
    await addAndCache(tester, state, [a, b]);

    state.layerInteractionManager.addSelectedLayer(b.id);
    state.setState(() {});
    await tester.pump();

    // The image for the remaining run (just `a`) has to be rendered anew;
    // until then `a` is live as well, so wait for it.
    await pumpUntil(tester, () => cachedByLayer(tester)[a.id] ?? false);

    expect(cachedByLayer(tester)[a.id], isTrue);
    expect(cachedByLayer(tester)[b.id], isFalse);

    state.layerInteractionManager.clearSelectedLayers();
    state.setState(() {});
    await tester.pump();
    await pumpUntil(tester, () => allCached(tester));

    expect(cachedByLayer(tester).values, everyElement(isTrue));
  });

  /// Runs [action], pumping frames until it completes, and reports whether
  /// every layer rendered live in one of them.
  Future<({T result, bool sawLive})> runCapture<T>(
    WidgetTester tester,
    Future<T> Function() action,
  ) async {
    var sawLive = false;
    late final T result;
    await tester.runAsync(() async {
      var done = false;
      final future = action().whenComplete(() => done = true);
      while (!done) {
        await Future<void>.delayed(const Duration(milliseconds: 20));
        await tester.pump();
        final cached = cachedByLayer(tester).values;
        if (cached.isNotEmpty && cached.every((value) => !value)) {
          sawLive = true;
        }
      }
      result = await future;
    });
    return (result: result, sawLive: sawLive);
  }

  testWidgets('captures every layer although its paint is cached', (
    tester,
  ) async {
    final state = await pumpEditor(tester);
    final layers = [
      buildPaintLayer(const Offset(-40, 0)),
      buildPaintLayer(const Offset(40, 0)),
    ];
    for (final layer in layers) {
      state.addLayer(
        layer,
        blockSelectLayer: true,
        autoCorrectZoomOffset: false,
        autoCorrectZoomScale: false,
      );
    }
    state.layerInteractionManager.clearSelectedLayers();
    // Live: the cache has not been given a frame to land yet.
    state.setState(() {});
    await tester.pump();
    expect(cachedByLayer(tester).values, [false, false]);
    Future<List<ExportedLayer>> capture() =>
        state.captureAllLayersWithMeta(format: ImageByteFormat.rawRgba);
    final live = (await runCapture(tester, capture)).result;

    await pumpUntil(tester, () => allCached(tester));
    expect(cachedByLayer(tester).values, [true, true]);
    final cached = await runCapture(tester, capture);

    // A cached layer paints nothing into its repaint boundary; its capture is
    // rendered from the model and has to be what the boundary held before.
    expect(cached.result, hasLength(2));
    for (var i = 0; i < 2; i++) {
      expect(cached.result[i].bytes, live[i].bytes, reason: 'layer $i');
      expect(cached.result[i].bytes.any((byte) => byte > 0), isTrue);
    }
    // The capture did not need the cache to step aside.
    expect(cached.sawLive, isFalse);
    expect(cachedByLayer(tester).values, [true, true]);
  });

  testWidgets('captures the canvas from a frame with live layers', (
    tester,
  ) async {
    final state = await pumpEditor(tester);
    await addAndCache(tester, state, [
      buildPaintLayer(const Offset(-40, 0)),
      buildPaintLayer(const Offset(40, 0)),
    ]);

    // Every canvas screenshot — state history, final image, thumbnail —
    // reads the editor's recorder at the output pixel ratio; a cached image
    // rendered for the screen would be upscaled into it, so the recorder
    // asks the layers for a live frame first.
    final recorder = ContentRecorder.maybeControllerOf(
      tester.element(find.byType(LayerWidget).first),
    )!;
    final body = state.sizesManager.bodySize;
    final capture = await runCapture(
      tester,
      () => recorder.getRawRenderedImage(
        imageInfos: ImageInfos(
          rawSize: body,
          renderedSize: body,
          originalRenderedSize: body,
          cropRectSize: body,
          pixelRatio: 1,
          isRotated: false,
        ),
      ),
    );

    expect(capture.result, isNotNull);
    capture.result!.dispose();
    expect(capture.sawLive, isTrue);
    await pumpUntil(tester, () => allCached(tester));
    expect(cachedByLayer(tester).values, [true, true]);
  });
}
