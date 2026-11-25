import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:pro_image_editor/core/models/layers/layer.dart';
import 'package:pro_image_editor/core/models/layers/paint_layer_timeline.dart';
import 'package:pro_image_editor/features/paint_editor/paint_editor.dart';

void main() {
  Duration ms(int value) => Duration(milliseconds: value);

  PaintLayer drawing({
    Duration? start = const Duration(seconds: 1),
    Duration? end = const Duration(seconds: 3),
    List<LayerAnimation> animations = const [],
    PaintMode mode = PaintMode.freeStyle,
  }) => PaintLayer(
    item: PaintedModel(
      mode: mode,
      offsets: const [Offset(0, 0), Offset(100, 0)],
      erasedOffsets: const [],
      color: const Color(0xFF000000),
      strokeWidth: 4,
      opacity: 1,
    ),
    rawSize: const Size(100, 10),
    opacity: 1,
    startTime: start,
    endTime: end,
    animations: animations,
  );

  LayerAnimation drawOn(
    AnimationPhase phase, {
    int durationMs = 500,
    AnimationCurve curve = AnimationCurve.linear,
  }) => LayerAnimation(
    type: LayerAnimationType.drawOn,
    phase: phase,
    duration: ms(durationMs),
    curve: curve,
  );

  group('PaintLayer.drawnFractionAt', () {
    test('draws the strokes over the start of the layer', () {
      final layer = drawing(animations: [drawOn(AnimationPhase.animateIn)]);

      expect(layer.drawnFractionAt(ms(1000)), 0);
      expect(layer.drawnFractionAt(ms(1250)), 0.5);
      expect(layer.drawnFractionAt(ms(1500)), isNull);
      expect(layer.drawnFractionAt(ms(2900)), isNull);
    });

    test('takes the strokes away over the end of the layer', () {
      final layer = drawing(animations: [drawOn(AnimationPhase.animateOut)]);

      expect(layer.drawnFractionAt(ms(2000)), isNull);
      expect(layer.drawnFractionAt(ms(2750)), 0.5);
    });

    test('shows the whole drawing where a curve overshoots', () {
      final layer = drawing(
        animations: [
          drawOn(AnimationPhase.animateIn, curve: AnimationCurve.elasticOut),
        ],
      );

      // Elastic out passes 1 before it settles.
      expect(layer.drawnFractionAt(ms(1100)), isNull);
    });

    test('ignores other animations and censor areas', () {
      final moving = drawing(
        animations: [
          LayerAnimation(
            type: LayerAnimationType.fade,
            phase: AnimationPhase.animateIn,
            duration: ms(500),
          ),
        ],
      );
      final censor = drawing(
        mode: PaintMode.blur,
        animations: [drawOn(AnimationPhase.animateIn)],
      );

      expect(moving.drawsOn, isFalse);
      expect(moving.drawnFractionAt(ms(1250)), isNull);
      expect(censor.drawsOn, isFalse);
      expect(censor.drawnFractionAt(ms(1250)), isNull);
    });
  });

  group('paintLayerTimeline', () {
    /// Each span as (drawn fraction, start, end).
    List<(double?, Duration?, Duration?)> describe(
      List<PaintLayerTimelineSpan> spans,
    ) => [
      for (final span in spans)
        (span.drawnFraction, span.startTime, span.endTime),
    ];

    test('cuts the drawing at every frame while it draws', () {
      final layer = drawing(animations: [drawOn(AnimationPhase.animateIn)]);

      final spans = paintLayerTimeline(layer, frameRate: 10);

      expect(describe(spans), [
        (0.0, ms(1000), ms(1100)),
        (0.2, ms(1100), ms(1200)),
        (0.4, ms(1200), ms(1300)),
        (0.6, ms(1300), ms(1400)),
        (0.8, ms(1400), ms(1500)),
        (null, ms(1500), ms(3000)),
      ]);
    });

    test('cuts on the frames of the video, not of the layer', () {
      final layer = drawing(
        start: ms(1050),
        animations: [drawOn(AnimationPhase.animateIn)],
      );

      final spans = paintLayerTimeline(layer, frameRate: 10);

      expect(spans.map((span) => span.startTime).take(3), [
        ms(1050),
        ms(1100),
        ms(1200),
      ]);
      expect(spans[1].drawnFraction, 0.1);
    });

    test('cuts where a renderer rounding down to microseconds draws', () {
      final layer = drawing(
        start: Duration.zero,
        animations: [drawOn(AnimationPhase.animateIn, durationMs: 100)],
      );

      final spans = paintLayerTimeline(layer, frameRate: 30);

      expect(spans.map((span) => span.startTime), [
        Duration.zero,
        const Duration(microseconds: 33333),
        const Duration(microseconds: 66666),
        ms(100),
      ]);
    });

    test('takes the strokes away over the end', () {
      final layer = drawing(animations: [drawOn(AnimationPhase.animateOut)]);

      final spans = paintLayerTimeline(layer, frameRate: 10);

      expect(describe(spans).first, (null, ms(1000), ms(2600)));
      expect(describe(spans).last, (0.2, ms(2900), ms(3000)));
    });

    test('shows the whole drawing for a loop without an end', () {
      final layer = drawing(
        end: null,
        animations: [drawOn(AnimationPhase.loop)],
      );

      expect(describe(paintLayerTimeline(layer, frameRate: 30)), [
        (null, ms(1000), null),
      ]);
    });
  });
}
