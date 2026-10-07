import 'dart:math';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:pro_image_editor/pro_image_editor.dart';

/// A transform of a layer with keyframes has to land in the keyframe at the
/// playback position: the layer is drawn where its keyframes put it, so a
/// change of its own placement alone would not show at all.
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
    // A turn near a multiple of 45° would snap onto it.
    helperLines: HelperLineConfigs(showRotateLine: false),
  );

  Future<(ProImageEditorState, ProVideoController)> pumpVideoEditor(
    WidgetTester tester,
  ) async {
    final key = GlobalKey<ProImageEditorState>();
    const videoKey = ValueKey('video');
    final controller = ProVideoController(
      videoPlayer: const SizedBox.expand(key: videoKey),
      videoDuration: const Duration(seconds: 10),
      initialResolution: const Size(108, 192),
      fileSize: 1,
    );
    await tester.pumpWidget(
      MaterialApp(
        home: ProImageEditor.video(
          controller,
          key: key,
          configs: configs,
          callbacks: const ProImageEditorCallbacks(),
        ),
      ),
    );
    // The video canvas waits for a real image encode and decode, which fake
    // async never completes.
    await tester.runAsync(() async {
      for (var i = 0; i < 100 && find.byKey(videoKey).evaluate().isEmpty; i++) {
        await Future<void>.delayed(const Duration(milliseconds: 10));
        await tester.pump();
      }
    });
    expect(find.byKey(videoKey), findsOneWidget);
    return (key.currentState!, controller);
  }

  // Big enough for both fingers of a two-finger turn to land on the layer;
  // a drag that starts beside it selects layers instead on a desktop host.
  const layerScale = 4.0;

  const first = LayerKeyframe(
    time: Duration.zero,
    offset: Offset(-20, 0),
    scale: layerScale,
  );
  const last = LayerKeyframe(
    time: Duration(seconds: 4),
    offset: Offset(20, 0),
    scale: layerScale,
    rotation: 1,
  );

  /// Adds a selected emoji layer that moves between [first] and [last], and
  /// plays the video to 2 s, half way between them.
  Future<(ProImageEditorState, EmojiLayer)> pumpKeyframedLayer(
    WidgetTester tester,
  ) async {
    final (state, controller) = await pumpVideoEditor(tester);
    final layer = EmojiLayer(
      emoji: '😀',
      scale: layerScale,
      startTime: Duration.zero,
      endTime: const Duration(seconds: 10),
      keyframes: const [first, last],
    );
    state.addLayer(
      layer,
      autoCorrectZoomOffset: false,
      autoCorrectZoomScale: false,
    );
    controller.setPlayTime(const Duration(seconds: 2));
    await tester.pump(const Duration(seconds: 1));
    state.layerInteractionManager
      ..clearSelectedLayers()
      ..addSelectedLayer(layer.id);
    await tester.pump();
    return (state, layer);
  }

  Layer liveLayer(ProImageEditorState state, String id) =>
      state.activeLayers.singleWhere((layer) => layer.id == id);

  /// Turns the selected layer with two fingers around the editor's center.
  Future<void> turnWithTwoFingers(WidgetTester tester) async {
    final center = tester.getCenter(find.byType(ProImageEditor));
    final finger1 = await tester.startGesture(
      center + const Offset(-40, 0),
      pointer: 1,
    );
    final finger2 = await tester.startGesture(
      center + const Offset(40, 0),
      pointer: 2,
    );
    await tester.pump();
    for (var i = 1; i <= 4; i++) {
      final angle = (pi / 16) * i;
      await finger1.moveTo(center + Offset(-40 * cos(angle), -40 * sin(angle)));
      await finger2.moveTo(center + Offset(40 * cos(angle), 40 * sin(angle)));
      await tester.pump(const Duration(milliseconds: 16));
    }
    await finger1.up();
    await finger2.up();
    await tester.pump(const Duration(seconds: 1));
  }

  group('keyframed layer', () {
    testWidgets('a two-finger turn adds a keyframe at the playback position '
        'from where the layer is shown', (tester) async {
      // How far the gesture below turns a layer without keyframes.
      final (plainState, plainController) = await pumpVideoEditor(tester);
      final plain = EmojiLayer(emoji: '😀', scale: layerScale);
      plainState.addLayer(
        plain,
        autoCorrectZoomOffset: false,
        autoCorrectZoomScale: false,
      );
      plainController.setPlayTime(const Duration(seconds: 2));
      await tester.pump(const Duration(seconds: 1));
      plainState.layerInteractionManager
        ..clearSelectedLayers()
        ..addSelectedLayer(plain.id);
      await tester.pump();
      await turnWithTwoFingers(tester);
      final turn = liveLayer(plainState, plain.id).rotation;
      expect(turn, greaterThan(0.1));

      final (state, layer) = await pumpKeyframedLayer(tester);
      final shown = layer.keyframePlacementAt(const Duration(seconds: 2))!;
      await turnWithTwoFingers(tester);

      final keyframes = liveLayer(state, layer.id).keyframes;
      expect(keyframes, hasLength(3));
      expect(keyframes.first, equals(first));
      expect(keyframes.last, equals(last));
      final added = keyframes[1];
      expect(added.time, equals(const Duration(seconds: 2)));
      // The turn started from the half-turned layer on screen, not from the
      // layer's own unturned placement.
      expect(added.rotation, closeTo(shown.rotation + turn, 1e-6));
    });

    testWidgets('a turn by keyboard lands in the keyframe at the playback '
        'position', (tester) async {
      final (state, layer) = await pumpKeyframedLayer(tester);
      final shown = layer.keyframePlacementAt(const Duration(seconds: 2))!;

      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await tester.pump();

      final added = liveLayer(state, layer.id).keyframes[1];
      expect(added.time, equals(const Duration(seconds: 2)));
      expect(added.rotation, closeTo(shown.rotation + 0.087266, 1e-9));
      expect(added.offset, equals(shown.offset));
    });

    testWidgets('replaceLayer previews a layer without a history step', (
      tester,
    ) async {
      final (state, layer) = await pumpKeyframedLayer(tester);
      final steps = state.stateHistory.length;
      final index = state.activeLayers.indexWhere((l) => l.id == layer.id);

      state.replaceLayer(
        index: index,
        layer: layer.copyWith(opacity: 0.3),
        skipUpdateHistory: true,
      );
      await tester.pump();

      expect(state.stateHistory.length, steps);
      expect(state.activeLayers[index].opacity, 0.3);
      expect(state.selectedLayers.map((l) => l.id), [layer.id]);

      state.replaceLayer(index: index, layer: layer.copyWith(opacity: 0.6));
      await tester.pump();
      expect(state.stateHistory.length, steps + 1);
    });

    testWidgets('a layer without keyframes stays without them', (tester) async {
      final (state, controller) = await pumpVideoEditor(tester);
      final layer = EmojiLayer(emoji: '😀');
      state.addLayer(layer);
      controller.setPlayTime(const Duration(seconds: 2));
      await tester.pump(const Duration(seconds: 1));

      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await tester.pump();

      expect(liveLayer(state, layer.id).keyframes, isEmpty);
      expect(liveLayer(state, layer.id).rotation, closeTo(0.087266, 1e-9));
    });
  });
}
