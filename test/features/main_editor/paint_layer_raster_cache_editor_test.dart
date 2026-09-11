// Dart imports:
import 'dart:ui' show ImageByteFormat;

import 'package:flutter/services.dart';
// Package imports:
import 'package:flutter_test/flutter_test.dart';
// Flutter imports:
import 'package:material_ui/material_ui.dart';
// Project imports:
import 'package:pro_image_editor/pro_image_editor.dart';
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
    state.isSubEditorOpen = true;
    state.setState(() {});
    await tester.pump();
    expect(cachedByLayer(tester).values, [false, false]);

    // Back in the main editor the run has to be rendered anew — its image
    // was released, not merely bypassed — and then takes over again.
    state.isSubEditorOpen = false;
    state.setState(() {});
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

  testWidgets('captures every layer although its paint is cached', (
    tester,
  ) async {
    final state = await pumpEditor(tester);
    await addAndCache(tester, state, [
      buildPaintLayer(const Offset(-40, 0)),
      buildPaintLayer(const Offset(40, 0)),
    ]);
    expect(cachedByLayer(tester).values, [true, true]);

    // The capture waits for a frame in which every layer paints live, and
    // frames only happen when the test pumps them.
    late final List<ExportedLayer> captured;
    await tester.runAsync(() async {
      var done = false;
      final future = state
          .captureAllLayersWithMeta(format: ImageByteFormat.rawRgba)
          .whenComplete(() => done = true);
      while (!done) {
        await Future<void>.delayed(const Duration(milliseconds: 20));
        await tester.pump();
      }
      captured = await future;
    });

    expect(captured, hasLength(2));
    for (final layer in captured) {
      // A capture taken from a boundary that painted nothing is fully
      // transparent; a real one carries the red stroke.
      final bytes = layer.bytes;
      var opaque = 0;
      for (var i = 3; i < bytes.length; i += 4) {
        if (bytes[i] > 0) opaque++;
      }
      expect(opaque, greaterThan(0), reason: 'layer ${layer.layer.id}');
    }
    // The cache takes over again once the capture is done.
    await pumpUntil(tester, () => allCached(tester));
    expect(cachedByLayer(tester).values, [true, true]);
  });
}
