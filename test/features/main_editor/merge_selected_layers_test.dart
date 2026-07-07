// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Package imports:
import 'package:flutter_test/flutter_test.dart';

// Project imports:
import 'package:pro_image_editor/pro_image_editor.dart';

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
  );

  PaintLayer buildPaintLayer(Offset offset) {
    return PaintLayer(
      item: PaintedModel(
        mode: PaintMode.freeStyle,
        offsets: const [Offset(0, 0), Offset(20, 20)],
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

  void selectAll(ProImageEditorState state, List<Layer> layers) {
    state.layerInteractionManager.clearSelectedLayers();
    for (final layer in layers) {
      state.layerInteractionManager.addSelectedLayer(layer.id);
    }
  }

  testWidgets('merges two selected paint layers into one', (tester) async {
    final state = await pumpEditor(tester);

    final layerA = buildPaintLayer(const Offset(-40, 0));
    final layerB = buildPaintLayer(const Offset(40, 0));
    state
      ..addLayer(
        layerA,
        autoCorrectZoomOffset: false,
        autoCorrectZoomScale: false,
      )
      ..addLayer(
        layerB,
        autoCorrectZoomOffset: false,
        autoCorrectZoomScale: false,
      );
    await tester.pump();

    expect(state.activeLayers.length, 2);

    selectAll(state, [layerA, layerB]);
    expect(state.canMergeSelectedLayers, isTrue);

    final merged = state.mergeSelectedLayers();
    await tester.pump();

    expect(merged, isNotNull);
    expect(state.activeLayers.length, 1);
    expect(state.activeLayers.first, isA<PaintLayer>());
    expect((state.activeLayers.first as PaintLayer).items.length, 2);
    expect(
      state.layerInteractionManager.selectedLayerIds.contains(merged!.id),
      isTrue,
    );
  });

  testWidgets('merge is a single undo entry restoring the originals', (
    tester,
  ) async {
    final state = await pumpEditor(tester);

    final layerA = buildPaintLayer(const Offset(-40, 0));
    final layerB = buildPaintLayer(const Offset(40, 0));
    state
      ..addLayer(
        layerA,
        autoCorrectZoomOffset: false,
        autoCorrectZoomScale: false,
      )
      ..addLayer(
        layerB,
        autoCorrectZoomOffset: false,
        autoCorrectZoomScale: false,
      );
    await tester.pump();

    selectAll(state, [layerA, layerB]);

    final historyLengthBefore = state.stateHistory.length;
    state.mergeSelectedLayers();
    await tester.pump();

    // Exactly one new history entry was recorded for the merge.
    expect(state.stateHistory.length, historyLengthBefore + 1);
    expect(state.activeLayers.length, 1);

    // A single undo restores both original layers.
    state.undoAction();
    await tester.pump();

    expect(state.activeLayers.length, 2);
    expect(state.activeLayers.map((layer) => layer.id).toSet(), {
      layerA.id,
      layerB.id,
    });
    for (final layer in state.activeLayers) {
      expect(layer, isA<PaintLayer>());
      expect((layer as PaintLayer).items.length, 1);
    }
  });

  testWidgets('mergeSelectedLayers returns null for fewer than two', (
    tester,
  ) async {
    final state = await pumpEditor(tester);

    final layerA = buildPaintLayer(const Offset(-40, 0));
    state.addLayer(
      layerA,
      autoCorrectZoomOffset: false,
      autoCorrectZoomScale: false,
    );
    await tester.pump();

    selectAll(state, [layerA]);
    expect(state.canMergeSelectedLayers, isFalse);
    expect(state.mergeSelectedLayers(), isNull);
    expect(state.activeLayers.length, 1);
  });
}
