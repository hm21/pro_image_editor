import 'dart:math' as math;

import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:pro_image_editor/features/text_editor/widgets/rounded_background_text/rounded_background_text.dart';
import 'package:pro_image_editor/pro_image_editor.dart';

import '../../mock/mock_image.dart';

/// Selection padding and its position compensation must change together.
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

  // Text anchored by its top-left corner instead of its center.
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

  for (final topLeft in [false, true]) {
    for (final boxed in [false, true]) {
      for (final transformed in [false, true]) {
        for (final kind in [PointerDeviceKind.mouse, PointerDeviceKind.touch]) {
          testWidgets(
            'text selection stays put on every frame '
            '(topLeft: $topLeft, boxed: $boxed, '
            'transformed: $transformed, pointer: ${kind.name})',
            (tester) async {
              final state = await pumpEditor(
                tester,
                editorConfigs: topLeft ? topLeftConfigs : configs,
              );
              final layer = TextLayer(
                text: 'Name',
                rotation: transformed ? math.pi / 6 : 0,
                flipX: transformed,
                flipY: false,
                scale: transformed ? 1.4 : 1,
                box: boxed ? const TextLayerBox(size: Size(160, 60)) : null,
              );
              state
                ..addLayer(
                  layer,
                  autoCorrectZoomOffset: false,
                  autoCorrectZoomScale: false,
                )
                ..unselectAllLayers();
              await tester.pumpAndSettle();
              final text = find.byType(RoundedBackgroundText);
              Rect screenRect() {
                final render = tester.renderObject<RenderBox>(text);
                return MatrixUtils.transformRect(
                  render.getTransformTo(null),
                  Offset.zero & render.size,
                );
              }

              final before = screenRect();
              final originalOffset = layer.offset;
              void expectPosition(String reason) {
                final after = screenRect();
                expect(
                  (after.topLeft - before.topLeft).distance,
                  lessThan(0.001),
                  reason: reason,
                );
                expect(
                  (after.bottomRight - before.bottomRight).distance,
                  lessThan(0.001),
                  reason: reason,
                );
              }

              // The first tap selects the layer. Neither it nor the taps after
              // it may move the content, on any frame.
              for (var attempt = 0; attempt < 3; attempt++) {
                final gesture = await tester.startGesture(
                  before.center,
                  kind: kind,
                );
                for (var frame = 0; frame < 3; frame++) {
                  await tester.pump();
                  expectPosition('attempt $attempt, pointer down frame $frame');
                }
                await gesture.up();
                for (var frame = 0; frame < 3; frame++) {
                  await tester.pump();
                  expectPosition('attempt $attempt, pointer up frame $frame');
                }
                await tester.pumpAndSettle();
                expectPosition('settled');
                expect(state.activeLayers.single.offset, originalOffset);
              }
            },
            variant: TargetPlatformVariant.only(
              kind == PointerDeviceKind.mouse
                  ? TargetPlatform.linux
                  : TargetPlatform.android,
            ),
          );
        }
      }
    }
  }

  testWidgets('multi-selection keeps text, emoji and widget content in place', (
    tester,
  ) async {
    final state = await pumpEditor(tester, editorConfigs: topLeftConfigs);
    final layers = <Layer>[
      TextLayer(text: 'Name', offset: const Offset(-140, -60)),
      EmojiLayer(emoji: 'X', offset: const Offset(0, 40)),
      WidgetLayer(
        widget: const SizedBox(width: 60, height: 40),
        offset: const Offset(140, -60),
        rotation: math.pi / 6,
        flipY: true,
      ),
    ];
    for (final layer in layers) {
      state.addLayer(
        layer,
        autoCorrectZoomOffset: false,
        autoCorrectZoomScale: false,
      );
    }
    state.unselectAllLayers();
    await tester.pumpAndSettle();

    Rect screenRect(Layer layer) {
      final render = tester.renderObject<RenderBox>(
        find.byKey(
          state.activeLayers
              .firstWhere((item) => item.id == layer.id)
              .repaintBoundaryKey,
        ),
      );
      return MatrixUtils.transformRect(
        render.getTransformTo(null),
        Offset.zero & render.size,
      );
    }

    final before = [for (final layer in layers) screenRect(layer)];
    for (final select in [true, false, true]) {
      if (select) {
        state.selectAllLayers();
      } else {
        state.unselectAllLayers();
      }
      for (var frame = 0; frame < 4; frame++) {
        await tester.pump();
        for (var i = 0; i < layers.length; i++) {
          final after = screenRect(layers[i]);
          expect(
            (after.topLeft - before[i].topLeft).distance,
            lessThan(0.001),
            reason: 'layer $i, frame $frame',
          );
          expect(
            (after.bottomRight - before[i].bottomRight).distance,
            lessThan(0.001),
            reason: 'layer $i, frame $frame',
          );
        }
      }
      expect(state.selectedLayers.length, select ? layers.length : 0);
    }
  });
}
