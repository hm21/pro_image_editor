import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:pro_image_editor/features/text_editor/widgets/rounded_background_text/rounded_background_text.dart';
import 'package:pro_image_editor/pro_image_editor.dart';

import '../../mock/mock_image.dart';

/// Dragging a box handle in the editor resizes the box of a text layer and
/// leaves its scale alone.
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
    layerInteraction: LayerInteractionConfigs(
      selectable: LayerInteractionSelectable.enabled,
      enableTextBoxResize: true,
    ),
  );

  // Placed by its top-left corner, so resizing from the right or bottom
  // edge leaves the layer's offset alone.
  final topLeftConfigs = configs.copyWith(
    textEditor: const TextEditorConfigs(layerFractionalOffset: Offset.zero),
  );

  Future<ProImageEditorState> pumpEditor(
    WidgetTester tester, {
    ProImageEditorConfigs editorConfigs = configs,
  }) async {
    final key = GlobalKey<ProImageEditorState>();
    await tester.pumpWidget(
      MaterialApp(
        home: ProImageEditor.memory(
          mockMemoryImage,
          key: key,
          configs: editorConfigs,
          callbacks: ProImageEditorCallbacks(
            onImageEditingComplete: (Uint8List bytes) async {},
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    return key.currentState!;
  }

  Future<void> mouseDrag(
    WidgetTester tester, {
    required Offset from,
    required Offset by,
  }) async {
    final gesture = await tester.startGesture(
      from,
      kind: PointerDeviceKind.mouse,
      buttons: kPrimaryMouseButton,
    );
    await tester.pump();
    await gesture.moveBy(by / 2);
    await tester.pump();
    await gesture.moveBy(by / 2);
    await tester.pump();
    await gesture.up();
    await tester.pumpAndSettle();
  }

  testWidgets('a box handle resizes the box, not the layer', (tester) async {
    final state = await pumpEditor(tester);
    final layer = TextLayer(
      text: 'Name',
      scale: 1,
      box: const TextLayerBox(size: Size(120, 40)),
    );
    state.addLayer(
      layer,
      autoCorrectZoomOffset: false,
      autoCorrectZoomScale: false,
    );
    await tester.pumpAndSettle();
    state.selectLayerById(layer.id);
    await tester.pumpAndSettle();

    expect(find.byType(TextLayerBoxHandles), findsOneWidget);
    final text = tester.getRect(find.byType(RoundedBackgroundText));

    await mouseDrag(
      tester,
      from: Offset(text.right, text.center.dy),
      by: const Offset(40, 0),
    );

    final live = state.activeLayers.single as TextLayer;
    expect(live.scale, 1);
    // The edge follows the whole drag: 40 px, at a scale of 1.
    expect(live.box!.size.width, closeTo(160, 0.001));
    expect(live.box!.size.height, 40);

    // The drag was one history step.
    state.undoAction();
    await tester.pumpAndSettle();
    expect(
      (state.activeLayers.single as TextLayer).box!.size,
      const Size(120, 40),
    );
  }, variant: TargetPlatformVariant.only(TargetPlatform.linux));

  testWidgets('a box handle keeps the opposite edge of a layer with '
      'keyframes where they show it', (tester) async {
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
    final state = key.currentState!;
    final layer = TextLayer(
      text: 'Name',
      scale: 1,
      startTime: Duration.zero,
      endTime: const Duration(seconds: 10),
      box: const TextLayerBox(size: Size(120, 40)),
      keyframes: const [
        LayerKeyframe(time: Duration.zero, offset: Offset(-30, 0)),
        LayerKeyframe(time: Duration(seconds: 4), offset: Offset(30, 0)),
      ],
    );
    state.addLayer(
      layer,
      autoCorrectZoomOffset: false,
      autoCorrectZoomScale: false,
    );
    // Half way between the keyframes, which show the layer at the center.
    controller.setPlayTime(const Duration(seconds: 2));
    await tester.pump(const Duration(seconds: 1));
    state.selectLayerById(layer.id);
    // The overlay shows after the frame that selects the layer.
    await tester.pump(const Duration(seconds: 1));
    await tester.pump();
    await tester.pump();
    final before = tester.getRect(find.byType(RoundedBackgroundText));

    final gesture = await tester.startGesture(
      Offset(before.right, before.center.dy),
      kind: PointerDeviceKind.mouse,
      buttons: kPrimaryMouseButton,
    );
    await tester.pump();
    await gesture.moveBy(const Offset(20, 0));
    await tester.pump();
    await gesture.moveBy(const Offset(20, 0));
    await tester.pump();
    await gesture.up();
    await tester.pump(const Duration(seconds: 1));

    final after = tester.getRect(find.byType(RoundedBackgroundText));
    final live = state.activeLayers.single as TextLayer;
    expect(live.box!.size.width, closeTo(160, 0.001));
    expect(after.left, closeTo(before.left, 0.001));
    expect(
      live.keyframes.map((keyframe) => keyframe.time),
      contains(const Duration(seconds: 2)),
    );
  }, variant: TargetPlatformVariant.only(TargetPlatform.linux));

  group('a held box handle', () {
    Future<(ProImageEditorState, TextLayer)> pumpBoxedLayer(
      WidgetTester tester,
    ) async {
      final state = await pumpEditor(tester, editorConfigs: topLeftConfigs);
      final layer = TextLayer(
        text: 'Name',
        scale: 1,
        box: const TextLayerBox(size: Size(120, 40)),
      );
      state.addLayer(
        layer,
        autoCorrectZoomOffset: false,
        autoCorrectZoomScale: false,
      );
      await tester.pumpAndSettle();
      state.selectLayerById(layer.id);
      await tester.pumpAndSettle();
      return (state, layer);
    }

    TextLayer live(ProImageEditorState state) =>
        state.activeLayers.single as TextLayer;

    Future<TestGesture> press(WidgetTester tester, Offset at) async {
      final gesture = await tester.startGesture(
        at,
        kind: PointerDeviceKind.mouse,
        buttons: kPrimaryMouseButton,
      );
      await tester.pump();
      return gesture;
    }

    testWidgets('keeps resizing when held still past a long press', (
      tester,
    ) async {
      final (state, layer) = await pumpBoxedLayer(tester);
      final text = tester.getRect(find.byType(RoundedBackgroundText));
      final offset = layer.offset;

      final gesture = await press(tester, Offset(text.right, text.center.dy));
      await tester.pump(const Duration(milliseconds: 700));
      expect(state.selectedLayers.map((l) => l.id), [layer.id]);

      await gesture.moveBy(const Offset(20, 0));
      await tester.pump();
      await gesture.moveBy(const Offset(20, 0));
      await tester.pump();
      expect(live(state).box!.size.width, closeTo(160, 0.001));
      expect(live(state).offset, offset);
      expect(state.selectedLayers.map((l) => l.id), [layer.id]);

      await gesture.up();
      await tester.pumpAndSettle();
      expect(state.selectedLayers.map((l) => l.id), [layer.id]);
    }, variant: TargetPlatformVariant.only(TargetPlatform.linux));

    testWidgets('keeps resizing through pauses longer than a long press', (
      tester,
    ) async {
      final (state, layer) = await pumpBoxedLayer(tester);
      final text = tester.getRect(find.byType(RoundedBackgroundText));

      final gesture = await press(tester, Offset(text.center.dx, text.bottom));
      for (var step = 1; step <= 3; step++) {
        await gesture.moveBy(const Offset(0, 10));
        await tester.pump(const Duration(milliseconds: 600));
        expect(live(state).box!.size.height, closeTo(40 + step * 10, 0.001));
        expect(state.selectedLayers.map((l) => l.id), [layer.id]);
      }
      expect(live(state).box!.size.width, 120);

      await gesture.up();
      await tester.pumpAndSettle();
      expect(live(state).box!.size.height, closeTo(70, 0.001));
      expect(state.selectedLayers.map((l) => l.id), [layer.id]);
    }, variant: TargetPlatformVariant.only(TargetPlatform.linux));
  });
}
