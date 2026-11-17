import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:pro_image_editor/pro_image_editor.dart';

import '../../mock/mock_image.dart';

void main() {
  Future<ProImageEditorState> pumpEditor(
    WidgetTester tester, {
    required bool mergeNewLayersOnDone,
  }) async {
    final key = GlobalKey<ProImageEditorState>();
    await tester.pumpWidget(
      MaterialApp(
        home: ProImageEditor.memory(
          mockMemoryImage,
          key: key,
          configs: ProImageEditorConfigs(
            progressIndicatorConfigs: const ProgressIndicatorConfigs(
              widgets: ProgressIndicatorWidgets(
                circularProgressIndicator: SizedBox.shrink(),
              ),
            ),
            imageGeneration: const ImageGenerationConfigs(
              enableIsolateGeneration: false,
              enableBackgroundGeneration: false,
            ),
            paintEditor: PaintEditorConfigs(
              mergeNewLayersOnDone: mergeNewLayersOnDone,
            ),
          ),
          callbacks: ProImageEditorCallbacks(
            onImageEditingComplete: (Uint8List bytes) async {},
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    return key.currentState!;
  }

  PaintedModel stroke(Offset start, {PaintMode mode = PaintMode.freeStyle}) {
    return PaintedModel(
      mode: mode,
      offsets: [start, start + const Offset(20, 20)],
      erasedOffsets: [],
      color: Colors.red,
      strokeWidth: 4,
      opacity: 1,
    );
  }

  /// Opens the paint editor, draws two strokes, a blur area and one more
  /// stroke, and closes it again.
  Future<void> drawSession(
    WidgetTester tester,
    ProImageEditorState state,
  ) async {
    state.openPaintEditor();
    await tester.pumpAndSettle();

    state.paintEditor.currentState!
      ..addPainting(stroke(const Offset(10, 10)))
      ..addPainting(stroke(const Offset(60, 10)))
      ..addPainting(stroke(const Offset(30, 30), mode: PaintMode.blur))
      ..addPainting(stroke(const Offset(80, 60)))
      ..done();
    await tester.pumpAndSettle();
  }

  group('PaintEditorConfigs.mergeNewLayersOnDone', () {
    testWidgets('returns the strokes of a session as one layer per run', (
      tester,
    ) async {
      final state = await pumpEditor(tester, mergeNewLayersOnDone: true);

      await drawSession(tester, state);

      final layers = state.activeLayers.cast<PaintLayer>();
      expect(layers.map((layer) => layer.items.length), [2, 1, 1]);
      expect(layers.map((layer) => layer.isCensor), [false, true, false]);
    });

    testWidgets('returns a layer per stroke when off', (tester) async {
      final state = await pumpEditor(tester, mergeNewLayersOnDone: false);

      await drawSession(tester, state);

      expect(state.activeLayers, hasLength(4));
    });

    testWidgets('draws every merged stroke where it drew on its own', (
      tester,
    ) async {
      /// The canvas position and on-canvas stroke width of every point of
      /// every non-censor stroke, bottom-most first. Fresh and merged layers
      /// are never rotated or flipped.
      List<(Offset, double)> drawnPoints(ProImageEditorState state) => [
        for (final layer in state.activeLayers.cast<PaintLayer>())
          if (!layer.isCensor)
            for (final item in layer.items)
              for (final point in item.offsets.nonNulls)
                (
                  layer.offset +
                      (point -
                              Offset(
                                layer.rawSize.width / 2,
                                layer.rawSize.height / 2,
                              )) *
                          layer.scale,
                  item.strokeWidth * layer.scale,
                ),
      ];

      final separate = await pumpEditor(tester, mergeNewLayersOnDone: false);
      await drawSession(tester, separate);
      final expected = drawnPoints(separate);
      // Tear the first editor down so the second one starts from scratch.
      await tester.pumpWidget(const SizedBox.shrink());

      final merged = await pumpEditor(tester, mergeNewLayersOnDone: true);
      await drawSession(tester, merged);
      final actual = drawnPoints(merged);

      expect(actual, hasLength(expected.length));
      for (var i = 0; i < expected.length; i++) {
        final (point, width) = actual[i];
        final (expectedPoint, expectedWidth) = expected[i];
        expect(point.dx, closeTo(expectedPoint.dx, 1e-6));
        expect(point.dy, closeTo(expectedPoint.dy, 1e-6));
        expect(width, closeTo(expectedWidth, 1e-6));
      }
    });
  });
}
