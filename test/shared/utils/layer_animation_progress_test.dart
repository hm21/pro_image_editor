import 'dart:math' as math;

import 'package:flutter_test/flutter_test.dart';
import 'package:pro_image_editor/core/models/layers/layer_animation.dart';
import 'package:pro_image_editor/shared/utils/layer_animation_progress.dart';

void main() {
  Duration ms(int value) => Duration(milliseconds: value);

  LayerAnimation animation(
    LayerAnimationType type,
    AnimationPhase phase, {
    AnimationCurve curve = AnimationCurve.linear,
  }) => LayerAnimation(
    type: type,
    phase: phase,
    duration: ms(1000),
    curve: curve,
    slideDirection: SlideDirection.left,
  );

  group('applyLayerAnimationCurve', () {
    // Values of the native renderer's applyEasing in pro_video_editor.
    test('eases with the polynomials the export uses', () {
      expect(applyLayerAnimationCurve(AnimationCurve.easeIn, 0.5), 0.25);
      expect(applyLayerAnimationCurve(AnimationCurve.easeOut, 0.5), 0.75);
      expect(applyLayerAnimationCurve(AnimationCurve.easeInOut, 0.25), 0.125);
      expect(applyLayerAnimationCurve(AnimationCurve.easeInOut, 0.75), 0.875);
      expect(applyLayerAnimationCurve(AnimationCurve.easeInCubic, 0.5), 0.125);
      expect(applyLayerAnimationCurve(AnimationCurve.easeOutCubic, 0.5), 0.875);
    });

    test('springs with the period the export uses', () {
      const t = 0.2;
      final expected =
          math.pow(2, -10 * t) * math.sin((t - 0.075) * 2 * math.pi / 0.3) + 1;
      expect(
        applyLayerAnimationCurve(AnimationCurve.elasticOut, t),
        closeTo(expected, 1e-12),
      );
      expect(
        applyLayerAnimationCurve(AnimationCurve.elasticIn, 0.8),
        closeTo(1 - expected, 1e-12),
      );
    });

    test('bounces like the export', () {
      expect(
        applyLayerAnimationCurve(AnimationCurve.bounceOut, 0.5),
        closeTo(7.5625 * math.pow(0.5 - 1.5 / 2.75, 2) + 0.75, 1e-12),
      );
    });

    test('starts at 0 and ends at 1 on every curve', () {
      for (final curve in AnimationCurve.values) {
        expect(applyLayerAnimationCurve(curve, 0), closeTo(0, 1e-9));
        expect(applyLayerAnimationCurve(curve, 1), closeTo(1, 1e-9));
      }
    });
  });

  group('layerAnimationProgress', () {
    test('plays an in-animation from the layer start', () {
      final fade = animation(LayerAnimationType.fade, AnimationPhase.animateIn);
      LayerAnimationProgress? at(int t) =>
          layerAnimationProgress(fade, ms(t), start: ms(2000), end: null);
      expect(at(2000)!.value, 0);
      expect(at(2500)!.value, 0.5);
      expect(at(3000), isNull);
    });

    test('plays an out-animation only with an end', () {
      final fade = animation(
        LayerAnimationType.fade,
        AnimationPhase.animateOut,
      );
      expect(
        layerAnimationProgress(
          fade,
          ms(4500),
          start: null,
          end: ms(5000),
        )!.value,
        0.5,
      );
      expect(
        layerAnimationProgress(fade, ms(4500), start: null, end: null),
        isNull,
      );
    });

    test('lets the part further from rest win in and out', () {
      final fade = LayerAnimation(
        type: LayerAnimationType.fade,
        phase: AnimationPhase.animateInOut,
        duration: ms(1000),
      );
      // 0.2 s into a 1.5 s layer the in-part is at 0.2, the out-part has
      // not begun.
      final progress = layerAnimationProgress(
        fade,
        ms(200),
        start: Duration.zero,
        end: ms(1500),
      )!;
      expect(progress.value, closeTo(0.2, 1e-12));
    });

    test('loops from rest to fully away and back once per cycle', () {
      final scale = animation(LayerAnimationType.scale, AnimationPhase.loop);
      double at(int t) =>
          layerAnimationProgress(scale, ms(t), start: ms(0), end: null)!.value;
      expect(at(0), 1);
      expect(at(250), 0.5);
      expect(at(500), 0);
      expect(at(750), 0.5);
      expect(at(7000), 1);
      expect(at(7500), 0);
    });

    test('shapes a loop like an out-animation on the way out', () {
      final fade = animation(
        LayerAnimationType.fade,
        AnimationPhase.loop,
        curve: AnimationCurve.easeIn,
      );
      expect(
        layerAnimationProgress(fade, ms(250), start: null, end: null)!.value,
        0.25,
      );
    });

    test('swings a wiggle to one side and then the other', () {
      final wiggle = animation(LayerAnimationType.wiggle, AnimationPhase.loop);
      LayerAnimationProgress at(int t) =>
          layerAnimationProgress(wiggle, ms(t), start: null, end: null)!;
      expect(at(250), const LayerAnimationProgress(0));
      expect(at(500), const LayerAnimationProgress(1, swing: -1));
      expect(at(750), const LayerAnimationProgress(0, swing: -1));
      expect(at(1000), const LayerAnimationProgress(1));
    });

    test('does not play without a duration', () {
      const wiggle = LayerAnimation(
        type: LayerAnimationType.wiggle,
        phase: AnimationPhase.loop,
        duration: Duration.zero,
      );
      expect(
        layerAnimationProgress(wiggle, ms(10), start: null, end: null),
        isNull,
      );
    });
  });
}
