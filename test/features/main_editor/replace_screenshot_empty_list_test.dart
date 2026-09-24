// Flutter imports:
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
// Package imports:
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
// Project imports:
import 'package:pro_image_editor/core/models/multi_threading/thread_capture_model.dart';
import 'package:pro_image_editor/pro_image_editor.dart';

import '../../mock/mock_image.dart';

// Scale-end replaces the screenshot reserved at scale-start. A canvas pan or a
// drag selection that ends with a layer selected never reserved one, so it
// must leave the screenshots alone. With background generation off, capture()
// never appends, so removeLast used to throw on an empty list.
void main() {
  const configs = ProImageEditorConfigs(
    progressIndicatorConfigs: ProgressIndicatorConfigs(
      widgets: ProgressIndicatorWidgets(
        circularProgressIndicator: SizedBox.shrink(),
      ),
    ),
    mainEditor: MainEditorConfigs(enableZoom: true),
    imageGeneration: ImageGenerationConfigs(
      enableIsolateGeneration: false,
      enableBackgroundGeneration: false,
    ),
  );

  Future<ProImageEditorState> pumpEditor(
    WidgetTester tester, {
    VoidCallback? onEditorZoomScaleEnd,
  }) async {
    final key = GlobalKey<ProImageEditorState>();
    await tester.pumpWidget(
      MaterialApp(
        home: ProImageEditor.memory(
          mockMemoryImage,
          key: key,
          configs: configs,
          callbacks: ProImageEditorCallbacks(
            onImageEditingComplete: (Uint8List bytes) async {},
            mainEditorCallbacks: MainEditorCallbacks(
              onEditorZoomScaleEnd: (_) => onEditorZoomScaleEnd?.call(),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    return key.currentState!;
  }

  EmojiLayer addEmoji(ProImageEditorState state) {
    final layer = EmojiLayer(
      emoji: '😀',
      offset: Offset.zero,
      scale: 1,
      rotation: 0,
    );
    state.addLayer(
      layer,
      autoCorrectZoomOffset: false,
      autoCorrectZoomScale: false,
    );
    return layer;
  }

  void select(ProImageEditorState state, Layer layer) {
    state.layerInteractionManager
      ..clearSelectedLayers()
      ..addSelectedLayer(layer.id);
  }

  Future<void> mouseDrag(
    WidgetTester tester, {
    required Offset from,
    required Offset by,
    int buttons = kPrimaryMouseButton,
  }) async {
    final TestGesture gesture = await tester.startGesture(
      from,
      kind: PointerDeviceKind.mouse,
      buttons: buttons,
    );
    await tester.pump();
    // Two steps, so the first one passes the slop and the gesture starts
    // where the pointer went down.
    await gesture.moveBy(by / 2);
    await tester.pump();
    await gesture.moveBy(by / 2);
    await tester.pump();
    await gesture.up();
    await tester.pumpAndSettle();
  }

  testWidgets(
    'panning with a selected layer does not throw when screenshots are empty',
    (tester) async {
      final state = await pumpEditor(tester);

      final layer = addEmoji(state);
      await tester.pump();
      select(state, layer);
      await tester.pump();

      expect(state.stateManager.screenshots, isEmpty);

      await mouseDrag(
        tester,
        from: tester.getCenter(find.byType(ProImageEditor)),
        by: const Offset(40, 20),
        buttons: kMiddleMouseButton,
      );

      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('panning with a selected layer keeps the last screenshot and '
      'ends the canvas gesture', (tester) async {
    int zoomScaleEnds = 0;
    final state = await pumpEditor(
      tester,
      onEditorZoomScaleEnd: () => zoomScaleEnds++,
    );

    final layer = addEmoji(state);
    await tester.pump();
    select(state, layer);
    await tester.pump();

    final lastScreenshot = ThreadCaptureState();
    state.stateManager.screenshots.add(lastScreenshot);
    final int historyLength = state.stateManager.stateHistory.length;

    await mouseDrag(
      tester,
      from: tester.getCenter(find.byType(ProImageEditor)),
      by: const Offset(40, 20),
      buttons: kMiddleMouseButton,
    );

    expect(state.stateManager.screenshots, [lastScreenshot]);
    expect(state.stateManager.stateHistory, hasLength(historyLength));
    expect(zoomScaleEnds, 1);
  });

  testWidgets('a drag selection keeps the last screenshot', (tester) async {
    final state = await pumpEditor(tester);

    final layer = addEmoji(state);
    await tester.pumpAndSettle();

    final lastScreenshot = ThreadCaptureState();
    state.stateManager.screenshots.add(lastScreenshot);

    // Draw the selection rect from an empty spot across the emoji.
    final Offset emoji = tester.getCenter(find.text('😀'));
    await mouseDrag(
      tester,
      from: emoji - const Offset(120, 120),
      by: const Offset(240, 240),
    );

    expect(tester.takeException(), isNull);
    expect(state.selectedLayers.map((el) => el.id), [layer.id]);
    expect(state.stateManager.screenshots, [lastScreenshot]);
  });

  testWidgets(
    'moving a selected layer still replaces its reserved screenshot',
    (tester) async {
      final state = await pumpEditor(tester);

      final layer = addEmoji(state);
      await tester.pumpAndSettle();
      select(state, layer);
      await tester.pump();

      final lastScreenshot = ThreadCaptureState();
      state.stateManager.screenshots.add(lastScreenshot);
      final int historyLength = state.stateManager.stateHistory.length;

      await mouseDrag(
        tester,
        from: tester.getCenter(find.text('😀')),
        by: const Offset(40, 20),
      );

      expect(state.stateManager.stateHistory, hasLength(historyLength + 1));
      expect(state.activeLayers.single.offset, isNot(Offset.zero));
      // The placeholder reserved at scale-start is gone; with background
      // generation off, capture() adds nothing in its place.
      expect(state.stateManager.screenshots, [lastScreenshot]);
    },
  );
}
