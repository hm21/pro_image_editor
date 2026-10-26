import 'dart:ui' show Offset, Size;

import 'package:flutter_test/flutter_test.dart';
import 'package:pro_image_editor/pro_image_editor.dart';

void main() {
  group(LayerMaskKeyframe, () {
    const keyframe = LayerMaskKeyframe(
      time: Duration(milliseconds: 1500),
      center: Offset(0.25, 0.75),
      size: Size(0.4, 0.2),
      rotation: 0.5,
      feather: 0.1,
      curve: AnimationCurve.easeInOut,
    );

    group('fromMap', () {
      test('reads what toMap writes', () {
        expect(LayerMaskKeyframe.fromMap(keyframe.toMap()), keyframe);
      });

      test('falls back to a linear curve it does not know and no negative '
          'softness', () {
        final read = LayerMaskKeyframe.fromMap({
          ...keyframe.toMap(),
          'curve': 'wobble',
          'feather': -1,
        });

        expect(read.curve, AnimationCurve.linear);
        expect(read.feather, 0);
      });
    });

    test('fromMask holds the geometry of the mask', () {
      const mask = LayerMask(
        shape: LayerMaskShape.star,
        center: Offset(0.1, 0.2),
        size: Size(0.3, 0.4),
        rotation: 1,
        feather: 0.05,
      );

      final read = LayerMaskKeyframe.fromMask(
        mask,
        time: const Duration(seconds: 2),
        curve: AnimationCurve.bounceOut,
      );

      expect(
        read,
        const LayerMaskKeyframe(
          time: Duration(seconds: 2),
          center: Offset(0.1, 0.2),
          size: Size(0.3, 0.4),
          rotation: 1,
          feather: 0.05,
          curve: AnimationCurve.bounceOut,
        ),
      );
    });

    test('sortLayerMaskKeyframes sorts by time and keeps ties in order', () {
      const a = LayerMaskKeyframe(time: Duration(seconds: 2));
      const b = LayerMaskKeyframe(
        time: Duration(seconds: 1),
        center: Offset(0.1, 0.1),
      );
      const c = LayerMaskKeyframe(
        time: Duration(seconds: 1),
        center: Offset(0.9, 0.9),
      );

      expect(sortLayerMaskKeyframes([a, b, c]), [b, c, a]);
    });
  });

  group('layerMaskKeyframeAt', () {
    const from = LayerMaskKeyframe(
      time: Duration(seconds: 1),
      center: Offset(0.2, 0.4),
      size: Size(0.2, 0.2),
      feather: 0,
    );
    const to = LayerMaskKeyframe(
      time: Duration(seconds: 3),
      center: Offset(0.6, 0.8),
      size: Size(1, 0.6),
      rotation: 2,
      feather: 0.4,
    );

    test('is null without keyframes', () {
      expect(layerMaskKeyframeAt(const [], Duration.zero), isNull);
    });

    test('holds the first keyframe before it and the last after it', () {
      expect(
        layerMaskKeyframeAt([from, to], Duration.zero),
        from.copyWith(time: Duration.zero),
      );
      expect(
        layerMaskKeyframeAt([from, to], const Duration(seconds: 9)),
        to.copyWith(time: const Duration(seconds: 9)),
      );
    });

    test('mixes the two keyframes around the time linearly', () {
      final mid = layerMaskKeyframeAt([from, to], const Duration(seconds: 2))!;

      expect(mid.center.dx, closeTo(0.4, 1e-9));
      expect(mid.center.dy, closeTo(0.6, 1e-9));
      expect(mid.size.width, closeTo(0.6, 1e-9));
      expect(mid.size.height, closeTo(0.4, 1e-9));
      expect(mid.rotation, closeTo(1, 1e-9));
      expect(mid.feather, closeTo(0.2, 1e-9));
    });

    test("eases along the earlier keyframe's curve", () {
      final eased = layerMaskKeyframeAt([
        from.copyWith(curve: AnimationCurve.easeIn),
        to,
      ], const Duration(milliseconds: 1500))!;

      // A quarter of the way in time, an ease in has come less far.
      expect(eased.center.dx, lessThan(0.3));
      expect(eased.curve, AnimationCurve.easeIn);
    });

    test('keeps the size and the softness at 0 or more when a curve '
        'overshoots', () {
      final shrinking = [
        to.copyWith(time: Duration.zero, curve: AnimationCurve.elasticOut),
        from.copyWith(
          time: const Duration(seconds: 1),
          size: Size.zero,
          feather: 0,
        ),
      ];

      for (var ms = 0; ms <= 1000; ms += 20) {
        final keyframe = layerMaskKeyframeAt(
          shrinking,
          Duration(milliseconds: ms),
        )!;
        expect(keyframe.size.width, greaterThanOrEqualTo(0), reason: '$ms');
        expect(keyframe.size.height, greaterThanOrEqualTo(0), reason: '$ms');
        expect(keyframe.feather, greaterThanOrEqualTo(0), reason: '$ms');
      }
    });
  });
}
