// Package imports:
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
// Project imports:
import 'package:pro_image_editor/pro_image_editor.dart';

/// A layer outside its video time range is invisible, but it kept catching
/// touches: the pointer meant for the visible layer underneath went to the
/// hidden one, so dragging moved the layer nobody could see.
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

  /// Pumps a video editor and records the id of every layer that receives a
  /// pointer down.
  Future<(ProImageEditorState, ProVideoController)> pumpVideoEditor(
    WidgetTester tester,
    List<String> tappedLayerIds,
  ) async {
    final key = GlobalKey<ProImageEditorState>();
    const videoKey = ValueKey('video');
    final controller = ProVideoController(
      videoPlayer: const SizedBox.expand(key: videoKey),
      videoDuration: const Duration(seconds: 15),
      initialResolution: const Size(108, 192),
      fileSize: 1,
    );
    await tester.pumpWidget(
      MaterialApp(
        home: ProImageEditor.video(
          controller,
          key: key,
          configs: configs,
          callbacks: ProImageEditorCallbacks(
            mainEditorCallbacks: MainEditorCallbacks(
              onLayerTapDown: (layer) => tappedLayerIds.add(layer.id),
            ),
          ),
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

  WidgetLayer timedLayer(String id, Duration start, Duration end) {
    return WidgetLayer(
      id: id,
      // Opaque like the image or text of a real layer, so the topmost layer
      // under the pointer is the only one that gets it.
      widget: ColoredBox(
        key: ValueKey('content-$id'),
        color: const Color(0xFF000000),
        child: const SizedBox(width: 100, height: 100),
      ),
      startTime: start,
      endTime: end,
    );
  }

  /// Where the layer's content is drawn. The layer widget's own box is
  /// offset from it by the layer's fractional translation.
  Offset contentCenter(WidgetTester tester, String id) =>
      tester.getCenter(find.byKey(ValueKey('content-$id')).first);

  group('timed layers', () {
    late List<String> tappedLayerIds;

    setUp(() => tappedLayerIds = []);

    /// Stacks two layers on the same spot with adjacent time ranges, so the
    /// later one is on top, and moves the video to [playTime].
    Future<void> pumpStackedLayers(
      WidgetTester tester,
      Duration playTime,
    ) async {
      final (state, controller) = await pumpVideoEditor(tester, tappedLayerIds);
      state
        ..addLayer(
          timedLayer(
            'lower',
            const Duration(seconds: 5),
            const Duration(seconds: 10),
          ),
          blockSelectLayer: true,
        )
        ..addLayer(
          timedLayer(
            'upper',
            const Duration(seconds: 10),
            const Duration(seconds: 15),
          ),
          blockSelectLayer: true,
        );
      controller.setPlayTime(playTime);
      // Let the layers' hero flights land; the video editor never settles.
      await tester.pump(const Duration(seconds: 1));
    }

    testWidgets('a hidden upper layer lets the pointer reach the layer '
        'underneath', (tester) async {
      await pumpStackedLayers(tester, const Duration(seconds: 7));

      await tester.tapAt(contentCenter(tester, 'lower'));
      await tester.pump();

      expect(tappedLayerIds, equals(['lower']));
    });

    testWidgets('a visible upper layer still takes the pointer', (
      tester,
    ) async {
      await pumpStackedLayers(tester, const Duration(seconds: 12));

      await tester.tapAt(contentCenter(tester, 'upper'));
      await tester.pump();

      expect(tappedLayerIds, equals(['upper']));
    });

    testWidgets('a layer coming back into its time range stays below the '
        'layer drawn on top of it', (tester) async {
      final (state, controller) = await pumpVideoEditor(tester, tappedLayerIds);
      state
        ..addLayer(
          timedLayer(
            'lower',
            const Duration(seconds: 5),
            const Duration(seconds: 15),
          ),
          blockSelectLayer: true,
        )
        ..addLayer(
          timedLayer('upper', Duration.zero, const Duration(seconds: 15)),
          blockSelectLayer: true,
        );
      // The lower layer is built hidden first and is rebuilt when it shows up.
      await tester.pump(const Duration(seconds: 1));
      controller.setPlayTime(const Duration(seconds: 7));
      await tester.pump(const Duration(seconds: 1));

      await tester.tapAt(contentCenter(tester, 'upper'));
      await tester.pump();

      expect(tappedLayerIds, equals(['upper']));
    });
  });
}
