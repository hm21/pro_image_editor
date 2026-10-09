import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:pro_image_editor/core/models/multi_threading/thread_capture_model.dart';
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
  );

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

  /// Adds three emoji layers, bottom-most first.
  Future<(ProImageEditorState, List<String>)> pumpThreeLayers(
    WidgetTester tester,
  ) async {
    final state = await pumpEditor(tester);
    final layers = [
      EmojiLayer(emoji: '🍎'),
      EmojiLayer(emoji: '🍌'),
      EmojiLayer(emoji: '🍒'),
    ];
    for (final layer in layers) {
      state.addLayer(
        layer,
        blockSelectLayer: true,
        autoCorrectZoomOffset: false,
        autoCorrectZoomScale: false,
      );
    }
    await tester.pumpAndSettle();
    return (state, [for (final layer in layers) layer.id]);
  }

  /// The ids of the layers the editor draws, bottom-most first.
  List<String> drawnLayerIds(WidgetTester tester) => [
    for (final widget in tester.widgetList<LayerWidget>(
      find.byType(LayerWidget),
    ))
      widget.layer.id,
  ];

  group('moveLayerListPosition', () {
    testWidgets('records a history step and redraws the layers', (
      tester,
    ) async {
      final (state, ids) = await pumpThreeLayers(tester);
      final steps = state.stateManager.stateHistory.length;

      state.moveLayerListPosition(oldIndex: 2, newIndex: 0);
      await tester.pump();

      expect(drawnLayerIds(tester), [ids[2], ids[0], ids[1]]);
      expect(state.stateManager.stateHistory, hasLength(steps + 1));
    });

    testWidgets('with skipUpdateHistory redraws the layers in their new '
        'order without a history step', (tester) async {
      final (state, ids) = await pumpThreeLayers(tester);
      expect(drawnLayerIds(tester), ids);
      final steps = state.stateManager.stateHistory.length;

      state.moveLayerListPosition(
        oldIndex: 2,
        newIndex: 0,
        skipUpdateHistory: true,
      );
      await tester.pumpAndSettle();

      expect(drawnLayerIds(tester), [ids[2], ids[0], ids[1]]);
      expect(state.stateManager.stateHistory, hasLength(steps));
    });

    testWidgets('with skipUpdateHistory after addHistory undoes in one step', (
      tester,
    ) async {
      final (state, ids) = await pumpThreeLayers(tester);

      state
        ..addHistory()
        ..moveLayerListPosition(
          oldIndex: 0,
          newIndex: 2,
          skipUpdateHistory: true,
        );
      await tester.pumpAndSettle();
      expect(drawnLayerIds(tester), [ids[1], ids[2], ids[0]]);

      state.undoAction();
      await tester.pump();

      expect(drawnLayerIds(tester), ids);
    });

    testWidgets('with skipUpdateHistory invalidates the screenshot of the '
        'current step only', (tester) async {
      final (state, _) = await pumpThreeLayers(tester);
      // Background generation is off here, so stand in one screenshot per
      // recorded step, as the editor keeps them with it on.
      final screenshots = [
        for (var i = 1; i < state.stateManager.stateHistory.length; i++)
          ThreadCaptureState(),
      ];
      state.stateManager.screenshots.addAll(screenshots);

      state.moveLayerListPosition(
        oldIndex: 2,
        newIndex: 0,
        skipUpdateHistory: true,
      );
      await tester.pumpAndSettle();

      expect(state.stateManager.activeScreenshot, same(screenshots.last));
      expect(
        [for (final item in screenshots) item.broken],
        [false, false, true],
      );
    });

    testWidgets('ignores an index past the last layer', (tester) async {
      final (state, ids) = await pumpThreeLayers(tester);
      final steps = state.stateManager.stateHistory.length;

      state.moveLayerListPosition(oldIndex: 0, newIndex: 3);
      await tester.pump();

      expect(drawnLayerIds(tester), ids);
      expect(state.stateManager.stateHistory, hasLength(steps));
    });
  });
}
