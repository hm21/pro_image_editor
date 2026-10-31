import 'dart:math';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:pro_image_editor/core/models/layers/layer_interaction.dart';
import 'package:pro_image_editor/pro_image_editor.dart';

import '../../mock/mock_image.dart';

/// A layer with [LayerInteraction.bounds] stays inside them however it is
/// dragged, pinched or turned, and [LayerInteraction.minScale] and
/// [LayerInteraction.maxScale] limit how far it is scaled.
void main() {
  // How far a few floating point steps may put a layer past an edge.
  const tolerance = 0.01;

  ProImageEditorConfigs configsWith({
    HelperLineConfigs helperLines = const HelperLineConfigs(
      showVerticalLine: false,
      showHorizontalLine: false,
      showLayerAlignLine: false,
      showRotateLine: false,
    ),
    EmojiEditorConfigs emojiEditor = const EmojiEditorConfigs(),
  }) {
    return ProImageEditorConfigs(
      progressIndicatorConfigs: const ProgressIndicatorConfigs(
        widgets: ProgressIndicatorWidgets(
          circularProgressIndicator: SizedBox.shrink(),
        ),
      ),
      imageGeneration: const ImageGenerationConfigs(
        enableIsolateGeneration: false,
        enableBackgroundGeneration: false,
      ),
      helperLines: helperLines,
      emojiEditor: emojiEditor,
    );
  }

  Future<ProImageEditorState> pumpEditor(
    WidgetTester tester, {
    ProImageEditorConfigs? configs,
  }) async {
    final key = GlobalKey<ProImageEditorState>();
    await tester.pumpWidget(
      MaterialApp(
        home: ProImageEditor.memory(
          mockMemoryImage,
          key: key,
          configs: configs ?? configsWith(),
          callbacks: ProImageEditorCallbacks(
            onImageEditingComplete: (Uint8List bytes) async {},
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    return key.currentState!;
  }

  /// A 300 x 240 area around the center of the body.
  Rect centeredBounds(Size editorBodySize) => Rect.fromCenter(
    center: editorBodySize.center(Offset.zero),
    width: 300,
    height: 240,
  );

  /// Adds a selected emoji, 96 px wide at its scale of 4, so both fingers of
  /// a pinch land on it.
  Future<EmojiLayer> addSelectedLayer(
    WidgetTester tester,
    ProImageEditorState state, {
    Offset offset = Offset.zero,
    LayerInteraction? interaction,
  }) async {
    final layer = EmojiLayer(
      emoji: '😀',
      offset: offset,
      scale: 4,
      interaction: interaction,
    );
    state.addLayer(
      layer,
      autoCorrectZoomOffset: false,
      autoCorrectZoomScale: false,
    );
    await tester.pump();
    state.layerInteractionManager
      ..clearSelectedLayers()
      ..addSelectedLayer(layer.id);
    await tester.pump();
    return layer;
  }

  Layer liveLayer(ProImageEditorState state, String id) =>
      state.activeLayers.singleWhere((layer) => layer.id == id);

  /// The area [layer] covers on the body as it is laid out: its box turned
  /// by its rotation.
  Rect coverOf(ProImageEditorState state, Layer layer) {
    final size = layer.renderSize!;
    final cosine = cos(layer.rotation).abs();
    final sine = sin(layer.rotation).abs();
    return Rect.fromCenter(
      center: state.sizesManager.bodySize.center(layer.offset),
      width: size.width * cosine + size.height * sine,
      height: size.width * sine + size.height * cosine,
    );
  }

  void expectInside(Rect cover, Rect bounds, {String? reason}) {
    expect(
      cover.left,
      greaterThanOrEqualTo(bounds.left - tolerance),
      reason: reason,
    );
    expect(
      cover.top,
      greaterThanOrEqualTo(bounds.top - tolerance),
      reason: reason,
    );
    expect(
      cover.right,
      lessThanOrEqualTo(bounds.right + tolerance),
      reason: reason,
    );
    expect(
      cover.bottom,
      lessThanOrEqualTo(bounds.bottom + tolerance),
      reason: reason,
    );
  }

  Offset layerCenter(WidgetTester tester, Layer layer) =>
      tester.getCenter(find.byKey(layer.keyInternalSize));

  group('bounds', () {
    for (final smartAlignment in [false, true]) {
      testWidgets('a dragged layer stops at the edge and follows the finger '
          'again once it is back (smart alignment: $smartAlignment)', (
        tester,
      ) async {
        final state = await pumpEditor(
          tester,
          configs: configsWith(
            helperLines: HelperLineConfigs(
              showVerticalLine: false,
              showHorizontalLine: false,
              showLayerAlignLine: false,
              showRotateLine: false,
              enableSmartAlignment: smartAlignment,
            ),
          ),
        );
        final layer = await addSelectedLayer(
          tester,
          state,
          interaction: LayerInteraction(bounds: centeredBounds),
        );
        final bounds = centeredBounds(state.sizesManager.bodySize);
        final halfWidth = layer.renderSize!.width / 2;
        final edge = bounds.right - state.sizesManager.bodySize.width / 2;

        var finger = layerCenter(tester, layer);
        final gesture = await tester.startGesture(finger);
        Future<void> moveBy(double dx) async {
          finger += Offset(dx, 0);
          await gesture.moveTo(finger);
          await tester.pump();
        }

        // Far enough for the gesture to start, still inside.
        for (var i = 0; i < 4; i++) {
          await moveBy(10);
        }
        final grab = liveLayer(state, layer.id).offset.dx - finger.dx;

        // Past the right edge.
        for (var i = 0; i < 20; i++) {
          await moveBy(10);
          final live = liveLayer(state, layer.id);
          expectInside(coverOf(state, live), bounds, reason: 'step $i');
        }
        final stopped = liveLayer(state, layer.id).offset;
        expect(stopped.dx + halfWidth, moreOrLessEquals(edge));
        expect(stopped.dy, 0);

        // The finger keeps going: the layer stays exactly where it stopped.
        for (var i = 0; i < 5; i++) {
          await moveBy(7);
          expect(liveLayer(state, layer.id).offset, stopped);
        }

        // Coming back, it waits until the finger is back where it stopped.
        while (finger.dx + grab - 10 > stopped.dx) {
          await moveBy(-10);
          expect(liveLayer(state, layer.id).offset, stopped);
        }
        for (var i = 0; i < 3; i++) {
          await moveBy(-10);
          expect(
            liveLayer(state, layer.id).offset.dx,
            moreOrLessEquals(finger.dx + grab),
          );
        }

        await gesture.up();
        await tester.pumpAndSettle();
        final released = liveLayer(state, layer.id);
        expect(released.offset.dx, moreOrLessEquals(finger.dx + grab));
        expectInside(coverOf(state, released), bounds);
      });
    }

    testWidgets('a layer without bounds is dragged as before', (tester) async {
      final state = await pumpEditor(tester);
      final layer = await addSelectedLayer(tester, state);

      var finger = layerCenter(tester, layer);
      final gesture = await tester.startGesture(finger);
      for (var i = 0; i < 4; i++) {
        finger += const Offset(10, 0);
        await gesture.moveTo(finger);
        await tester.pump();
      }
      final grab = liveLayer(state, layer.id).offset.dx - finger.dx;
      for (var i = 0; i < 30; i++) {
        finger += const Offset(10, 0);
        await gesture.moveTo(finger);
        await tester.pump();
      }
      await gesture.up();
      await tester.pumpAndSettle();

      final bounds = centeredBounds(state.sizesManager.bodySize);
      final live = liveLayer(state, layer.id);
      expect(live.offset.dx, moreOrLessEquals(finger.dx + grab));
      expect(coverOf(state, live).right, greaterThan(bounds.right));
    });

    testWidgets('a helper line the bounds move the layer off is hidden', (
      tester,
    ) async {
      final hits = <String>[];
      final key = GlobalKey<ProImageEditorState>();
      await tester.pumpWidget(
        MaterialApp(
          home: ProImageEditor.memory(
            mockMemoryImage,
            key: key,
            configs: configsWith(
              helperLines: const HelperLineConfigs(
                showLayerAlignLine: false,
                showRotateLine: false,
              ),
            ),
            callbacks: ProImageEditorCallbacks(
              mainEditorCallbacks: MainEditorCallbacks(
                helperLines: HelperLinesCallbacks(
                  onHitVerticalLine: () => hits.add('vertical'),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      final state = key.currentState!;

      // Bounds right of the center line: the layer can never sit on it.
      Rect rightHalf(Size size) =>
          Rect.fromLTRB(size.width / 2 + 10, 0, size.width, size.height);
      final layer = await addSelectedLayer(
        tester,
        state,
        offset: const Offset(150, 0),
        interaction: LayerInteraction(bounds: rightHalf),
      );

      var finger = layerCenter(tester, layer);
      final gesture = await tester.startGesture(finger);
      for (var i = 0; i < 30; i++) {
        finger -= const Offset(10, 0);
        await gesture.moveTo(finger);
        await tester.pump();
        expect(
          state.layerInteractionManager.showVerticalHelperLine,
          isFalse,
          reason: 'step $i',
        );
      }
      await gesture.up();
      await tester.pumpAndSettle();

      expect(hits, isEmpty);
      final live = liveLayer(state, layer.id);
      expectInside(
        coverOf(state, live),
        rightHalf(state.sizesManager.bodySize),
      );
    });

    testWidgets('a layer pinched at an edge is pushed inwards, does not grow '
        'past the bounds and moves back as it shrinks', (tester) async {
      final state = await pumpEditor(tester);
      const start = Offset(80, 0);
      final layer = await addSelectedLayer(
        tester,
        state,
        offset: start,
        interaction: LayerInteraction(bounds: centeredBounds),
      );
      final bounds = centeredBounds(state.sizesManager.bodySize);

      final center = layerCenter(tester, liveLayer(state, layer.id));
      final finger1 = await tester.startGesture(
        center - const Offset(20, 0),
        pointer: 1,
      );
      final finger2 = await tester.startGesture(
        center + const Offset(20, 0),
        pointer: 2,
      );
      await tester.pump();

      Future<void> spreadTo(double halfDistance) async {
        await finger1.moveTo(center - Offset(halfDistance, 0));
        await finger2.moveTo(center + Offset(halfDistance, 0));
        await tester.pump(const Duration(milliseconds: 16));
      }

      for (var half = 25.0; half <= 120; half += 5) {
        await spreadTo(half);
        final live = liveLayer(state, layer.id);
        expectInside(coverOf(state, live), bounds, reason: 'spread $half');
      }
      final grown = liveLayer(state, layer.id);
      expect(grown.offset.dx, lessThan(start.dx));
      // As tall as the bounds, and no taller.
      expect(coverOf(state, grown).height, moreOrLessEquals(bounds.height));

      for (var half = 115.0; half >= 20; half -= 5) {
        await spreadTo(half);
        final live = liveLayer(state, layer.id);
        expectInside(coverOf(state, live), bounds, reason: 'shrink $half');
      }
      expect(liveLayer(state, layer.id).offset, start);

      await finger1.up();
      await finger2.up();
      await tester.pumpAndSettle();
    });

    testWidgets('a layer turned at an edge stays inside', (tester) async {
      final state = await pumpEditor(tester);
      final bounds = centeredBounds(state.sizesManager.bodySize);
      // Its right edge near the right edge of the bounds.
      final layer = await addSelectedLayer(
        tester,
        state,
        offset: Offset(bounds.width / 2 - 50, 0),
        interaction: LayerInteraction(bounds: centeredBounds),
      );

      final center = layerCenter(tester, layer);
      final finger1 = await tester.startGesture(
        center - const Offset(30, 0),
        pointer: 1,
      );
      final finger2 = await tester.startGesture(
        center + const Offset(30, 0),
        pointer: 2,
      );
      await tester.pump();
      for (var i = 1; i <= 16; i++) {
        final angle = (pi / 32) * i;
        final arm = Offset(30 * cos(angle), 30 * sin(angle));
        await finger1.moveTo(center - arm);
        await finger2.moveTo(center + arm);
        await tester.pump(const Duration(milliseconds: 16));
        final live = liveLayer(state, layer.id);
        expectInside(coverOf(state, live), bounds, reason: 'step $i');
      }
      final turned = liveLayer(state, layer.id);
      // The gesture starts a little late, so the layer turns less.
      expect(turned.rotation, greaterThan(pi / 4));
      // Pushed inwards by the corners it turned out.
      expect(
        coverOf(state, turned).right,
        moreOrLessEquals(bounds.right, epsilon: 0.5),
      );

      await finger1.up();
      await finger2.up();
      await tester.pumpAndSettle();
    });

    testWidgets('the rotation helper line stays on a layer the bounds push', (
      tester,
    ) async {
      final state = await pumpEditor(
        tester,
        configs: configsWith(
          helperLines: const HelperLineConfigs(
            showVerticalLine: false,
            showHorizontalLine: false,
            showLayerAlignLine: false,
          ),
        ),
      );
      final manager = state.layerInteractionManager;
      final bounds = centeredBounds(state.sizesManager.bodySize);
      final layer = await addSelectedLayer(
        tester,
        state,
        offset: Offset(bounds.width / 2 - 50, 0),
        interaction: LayerInteraction(bounds: centeredBounds),
      );

      final center = layerCenter(tester, layer);
      final finger1 = await tester.startGesture(
        center - const Offset(30, 0),
        pointer: 1,
      );
      final finger2 = await tester.startGesture(
        center + const Offset(30, 0),
        pointer: 2,
      );
      await tester.pump();
      var lineShown = false;
      for (var i = 1; i <= 40; i++) {
        final angle = (pi / 64) * i;
        final arm = Offset(30 * cos(angle), 30 * sin(angle));
        await finger1.moveTo(center - arm);
        await finger2.moveTo(center + arm);
        await tester.pump(const Duration(milliseconds: 16));
        if (!manager.showRotationHelperLine) continue;
        lineShown = true;
        final live = liveLayer(state, layer.id);
        final layerCenter = state.sizesManager.bodySize.center(live.offset);
        expect(live.offset.dx, lessThan(bounds.width / 2 - 50));
        expect(
          Offset(manager.rotationHelperLineX, manager.rotationHelperLineY),
          offsetMoreOrLessEquals(layerCenter, epsilon: tolerance),
          reason: 'step $i',
        );
      }
      expect(lineShown, isTrue);

      await finger1.up();
      await finger2.up();
      await tester.pumpAndSettle();
    });

    testWidgets('applyLayerLimits moves a layer changed by code inside', (
      tester,
    ) async {
      final state = await pumpEditor(tester);
      final layer = await addSelectedLayer(
        tester,
        state,
        offset: const Offset(400, -300),
        interaction: LayerInteraction(bounds: centeredBounds),
      );
      final bounds = centeredBounds(state.sizesManager.bodySize);
      expect(bounds.overlaps(coverOf(state, layer)), isFalse);

      state.layerInteractionManager.applyLayerLimits(
        layer,
        editorBodySize: state.sizesManager.bodySize,
      );
      await tester.pump();

      final cover = coverOf(state, layer);
      expectInside(cover, bounds);
      expect(cover.right, moreOrLessEquals(bounds.right));
      expect(cover.top, moreOrLessEquals(bounds.top));
    });
  });

  group('scale limits', () {
    Future<double> pinchScale(
      WidgetTester tester,
      ProImageEditorState state,
      Layer layer, {
      required double toHalfDistance,
    }) async {
      final center = layerCenter(tester, liveLayer(state, layer.id));
      // Both fingers on the layer, 96 px wide at least.
      const fromHalfDistance = 40.0;
      final finger1 = await tester.startGesture(
        center - const Offset(fromHalfDistance, 0),
        pointer: 1,
      );
      final finger2 = await tester.startGesture(
        center + const Offset(fromHalfDistance, 0),
        pointer: 2,
      );
      await tester.pump();
      for (var i = 1; i <= 10; i++) {
        final half =
            fromHalfDistance + (toHalfDistance - fromHalfDistance) * i / 10;
        await finger1.moveTo(center - Offset(half, 0));
        await finger2.moveTo(center + Offset(half, 0));
        await tester.pump(const Duration(milliseconds: 16));
      }
      final scale = liveLayer(state, layer.id).scale;
      await finger1.up();
      await finger2.up();
      await tester.pumpAndSettle();
      return scale;
    }

    testWidgets('a pinch keeps the scale between minScale and maxScale', (
      tester,
    ) async {
      final state = await pumpEditor(tester);
      final layer = await addSelectedLayer(
        tester,
        state,
        interaction: LayerInteraction(minScale: 3, maxScale: 5),
      );

      expect(await pinchScale(tester, state, layer, toHalfDistance: 140), 5);
      state.layerInteractionManager
        ..clearSelectedLayers()
        ..addSelectedLayer(layer.id);
      await tester.pump();
      expect(await pinchScale(tester, state, layer, toHalfDistance: 8), 3);
    });

    testWidgets('the limits of a layer replace those of its type', (
      tester,
    ) async {
      final state = await pumpEditor(
        tester,
        configs: configsWith(
          emojiEditor: const EmojiEditorConfigs(minScale: 3.5, maxScale: 4.5),
        ),
      );
      final limited = await addSelectedLayer(
        tester,
        state,
        interaction: LayerInteraction(maxScale: 6),
      );
      expect(await pinchScale(tester, state, limited, toHalfDistance: 140), 6);

      state.layerInteractionManager
        ..clearSelectedLayers()
        ..addSelectedLayer(limited.id);
      await tester.pump();
      // The minimum of the type still applies.
      expect(await pinchScale(tester, state, limited, toHalfDistance: 8), 3.5);
    });

    testWidgets('without limits on the layer, those of its type apply', (
      tester,
    ) async {
      final state = await pumpEditor(
        tester,
        configs: configsWith(
          emojiEditor: const EmojiEditorConfigs(maxScale: 4.5),
        ),
      );
      final layer = await addSelectedLayer(tester, state);
      expect(await pinchScale(tester, state, layer, toHalfDistance: 140), 4.5);
    });

    testWidgets('the bounds do not shrink a layer below its minScale', (
      tester,
    ) async {
      final state = await pumpEditor(tester);
      // 96 px tall at its scale of 4, so 80 px tall bounds fit it at 3.33.
      Rect flat(Size size) => Rect.fromCenter(
        center: size.center(Offset.zero),
        width: 300,
        height: 80,
      );
      final layer = await addSelectedLayer(
        tester,
        state,
        interaction: LayerInteraction(minScale: 3.5, bounds: flat),
      );

      var finger = layerCenter(tester, layer);
      final gesture = await tester.startGesture(finger);
      for (var i = 0; i < 5; i++) {
        finger += const Offset(0, 10);
        await gesture.moveTo(finger);
        await tester.pump();
      }
      await gesture.up();
      await tester.pumpAndSettle();

      final live = liveLayer(state, layer.id);
      expect(live.scale, 3.5);
      // Too tall to fit, so it is centered on the bounds.
      expect(live.offset.dy, moreOrLessEquals(0));
    });
  });
}
