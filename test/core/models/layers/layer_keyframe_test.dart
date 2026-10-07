import 'dart:math' as math;

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:pro_image_editor/features/main_editor/services/layer_copy_manager.dart';
import 'package:pro_image_editor/pro_image_editor.dart';

void main() {
  const ms = Duration(milliseconds: 1);

  LayerKeyframe keyframe(
    int timeMs, {
    Offset offset = Offset.zero,
    double scale = 1,
    double rotation = 0,
    double opacity = 1,
    AnimationCurve curve = AnimationCurve.linear,
  }) => LayerKeyframe(
    time: ms * timeMs,
    offset: offset,
    scale: scale,
    rotation: rotation,
    opacity: opacity,
    curve: curve,
  );

  group(LayerKeyframe, () {
    group('toMap / fromMap', () {
      test('round-trips every field', () {
        final original = keyframe(
          1500,
          offset: const Offset(12.5, -40),
          scale: 2.25,
          rotation: 1.2,
          opacity: 0.4,
          curve: AnimationCurve.elasticOut,
        );

        final restored = LayerKeyframe.fromMap(original.toMap());

        expect(restored, equals(original));
        expect(original.toMap()['timeUs'], equals(1500000));
      });

      test('falls back to an opaque, unscaled, linear keyframe', () {
        final restored = LayerKeyframe.fromMap(const {
          'timeUs': 40,
          'x': 1,
          'y': 2,
          'curve': 'not-a-curve',
        });

        expect(restored.time, equals(const Duration(microseconds: 40)));
        expect(restored.offset, equals(const Offset(1, 2)));
        expect(restored.scale, equals(1));
        expect(restored.rotation, equals(0));
        expect(restored.opacity, equals(1));
        expect(restored.curve, equals(AnimationCurve.linear));
        expect(restored.effects, isEmpty);
      });

      test('round-trips the effects and leaves them out when there are '
          'none', () {
        const wiggle = LayerAnimation(
          type: LayerAnimationType.wiggle,
          phase: AnimationPhase.loop,
          duration: Duration(milliseconds: 600),
          curve: AnimationCurve.easeIn,
          wiggleAngle: 0.3,
        );
        final original = keyframe(0).copyWith(effects: const [wiggle]);

        final restored = LayerKeyframe.fromMap(original.toMap());

        expect(restored, equals(original));
        expect(restored.effects.single, equals(wiggle));
        expect(keyframe(0).toMap(), isNot(contains('effects')));
      });
    });
  });

  group('layerKeyframeEffects', () {
    const bounce = LayerAnimation(
      type: LayerAnimationType.bounce,
      phase: AnimationPhase.loop,
      duration: Duration(milliseconds: 300),
    );

    test('fits a whole number of cycles between the two keyframes', () {
      final effects = layerKeyframeEffects([
        keyframe(500).copyWith(effects: const [bounce]),
        keyframe(1500),
      ], origin: ms * 2000);

      final effect = effects.single;
      expect(effect.start, equals(ms * 2500));
      expect(effect.end, equals(ms * 3500));
      // 1 s holds 3.33 cycles of 300 ms; three of 333 ms fill it.
      expect(effect.cycles, equals(3));
      expect(
        effect.animation.duration,
        equals(const Duration(microseconds: 333333)),
      );
      expect(effect.animation.type, equals(LayerAnimationType.bounce));
    });

    test('plays at least one cycle on a short stretch', () {
      final effect = layerKeyframeEffects([
        keyframe(0).copyWith(effects: const [bounce]),
        keyframe(100),
      ], origin: Duration.zero).single;

      expect(effect.cycles, equals(1));
      expect(effect.animation.duration, equals(ms * 100));
      expect(effect.playsAt(ms * 99), isTrue);
      expect(effect.playsAt(ms * 100), isFalse);
    });

    test('plays only loops, and nothing after the last keyframe', () {
      final effects = layerKeyframeEffects([
        keyframe(0).copyWith(
          effects: const [
            LayerAnimation(
              type: LayerAnimationType.fade,
              phase: AnimationPhase.animateIn,
              duration: Duration(milliseconds: 300),
            ),
          ],
        ),
        keyframe(1000).copyWith(effects: const [bounce]),
      ], origin: Duration.zero);

      expect(effects, isEmpty);
    });
  });

  group('layerKeyframePlacementAt', () {
    final keyframes = [
      keyframe(1000, offset: const Offset(-100, 0), opacity: 0.5),
      keyframe(
        3000,
        offset: const Offset(100, 200),
        scale: 3,
        rotation: 2 * math.pi,
      ),
    ];

    test('is null without keyframes', () {
      expect(layerKeyframePlacementAt(const [], Duration.zero), isNull);
    });

    test('holds the first keyframe before it', () {
      final placement = layerKeyframePlacementAt(keyframes, Duration.zero);

      expect(placement, equals(keyframes.first.placement));
    });

    test('holds the last keyframe after it', () {
      final placement = layerKeyframePlacementAt(keyframes, ms * 9000);

      expect(placement, equals(keyframes.last.placement));
    });

    test('mixes the two keyframes around the time linearly', () {
      final placement = layerKeyframePlacementAt(keyframes, ms * 2000)!;

      expect(placement.offset, equals(const Offset(0, 100)));
      expect(placement.scale, equals(2));
      expect(placement.opacity, equals(0.75));
      // A full turn stays a full turn rather than taking the short way.
      expect(placement.rotation, closeTo(math.pi, 1e-9));
    });

    test('eases with the curve of the earlier keyframe', () {
      final eased = [
        keyframe(0, curve: AnimationCurve.easeIn),
        keyframe(1000, offset: const Offset(100, 0)),
      ];

      final placement = layerKeyframePlacementAt(eased, ms * 500)!;

      expect(placement.offset.dx, closeTo(25, 1e-9));
    });

    test('keeps the opacity within 0–1 when a curve overshoots', () {
      final springy = [
        keyframe(0, opacity: 0, curve: AnimationCurve.elasticOut),
        keyframe(1000, scale: 0, opacity: 1),
      ];

      for (var t = 0; t <= 1000; t += 10) {
        final placement = layerKeyframePlacementAt(springy, ms * t)!;
        expect(placement.opacity, inInclusiveRange(0, 1));
        expect(placement.scale, greaterThanOrEqualTo(0));
      }
    });
  });

  group('sortLayerKeyframes', () {
    test('orders by time and keeps equal times in their order', () {
      final a = keyframe(500, offset: const Offset(1, 0));
      final b = keyframe(500, offset: const Offset(2, 0));
      final c = keyframe(100);

      expect(sortLayerKeyframes([a, b, c]), equals([c, a, b]));
    });
  });

  group('Layer keyframes', () {
    test('are sorted and cannot be changed in place', () {
      final layer = Layer(keyframes: [keyframe(800), keyframe(200)]);

      expect(layer.keyframes.map((k) => k.time), equals([ms * 200, ms * 800]));
      expect(() => layer.keyframes.add(keyframe(1)), throwsUnsupportedError);

      layer.keyframes = [keyframe(900), keyframe(100)];
      expect(layer.keyframes.first.time, equals(ms * 100));
    });

    test('are measured from the start time', () {
      final layer = Layer(
        startTime: ms * 2000,
        keyframes: [
          keyframe(0, offset: const Offset(0, 0)),
          keyframe(1000, offset: const Offset(10, 0)),
        ],
      );

      expect(layer.keyframePlacementAt(ms * 2500)!.offset.dx, equals(5));
    });

    group('setKeyframeAt', () {
      test('adds a keyframe with the rest placement and the previous '
          'keyframe curve', () {
        final layer = Layer(
          startTime: ms * 1000,
          offset: const Offset(30, 40),
          scale: 2,
          rotation: 0.5,
          keyframes: [
            keyframe(0, curve: AnimationCurve.easeOutCubic, opacity: 0.2),
            keyframe(2000, opacity: 0.6),
          ],
        )..setKeyframeAt(ms * 2000);

        final added = layer.keyframes[1];
        expect(added.time, equals(ms * 1000));
        expect(added.offset, equals(const Offset(30, 40)));
        expect(added.scale, equals(2));
        expect(added.rotation, equals(0.5));
        // The opacity the keyframes already gave the layer there.
        expect(added.opacity, closeTo(0.6 - 0.4 * math.pow(0.5, 3), 1e-9));
        expect(added.curve, equals(AnimationCurve.easeOutCubic));
      });

      test('replaces a keyframe within the tolerance and keeps its time '
          'and curve', () {
        final layer = Layer(
          offset: const Offset(5, 5),
          keyframes: [keyframe(1000, curve: AnimationCurve.bounceOut)],
        )..setKeyframeAt(ms * 1004);

        expect(layer.keyframes, hasLength(1));
        expect(layer.keyframes.single.time, equals(ms * 1000));
        expect(layer.keyframes.single.offset, equals(const Offset(5, 5)));
        expect(layer.keyframes.single.curve, equals(AnimationCurve.bounceOut));
      });

      test('adds a second keyframe outside the tolerance', () {
        final layer = Layer(keyframes: [keyframe(1000)])
          ..setKeyframeAt(ms * 1020);

        expect(layer.keyframes, hasLength(2));
      });
    });

    test('removeKeyframeAt removes the keyframe at the time', () {
      final layer = Layer(keyframes: [keyframe(0), keyframe(1000)]);

      expect(layer.removeKeyframeAt(ms * 1003), isTrue);
      expect(layer.keyframes.map((k) => k.time), equals([Duration.zero]));
      expect(layer.removeKeyframeAt(ms * 500), isFalse);
    });

    test('applyKeyframePlacement lays the layer out at the keyframed '
        'placement', () {
      final layer = Layer(
        keyframes: [
          keyframe(0, offset: const Offset(10, 20), scale: 3, rotation: 1),
        ],
      )..applyKeyframePlacement(ms * 400);

      expect(layer.offset, equals(const Offset(10, 20)));
      expect(layer.scale, equals(3));
      expect(layer.rotation, equals(1));
    });

    test('keyframeCaptureGrowth is the largest keyframed scale over the '
        'layer scale, within 1 and the cap', () {
      expect(Layer().keyframeCaptureGrowth, 1);
      expect(
        Layer(
          scale: 2,
          keyframes: [keyframe(0, scale: 3), keyframe(9, scale: 1)],
        ).keyframeCaptureGrowth,
        1.5,
      );
      expect(
        Layer(keyframes: [keyframe(0, scale: 0.5)]).keyframeCaptureGrowth,
        1,
      );
      expect(
        Layer(keyframes: [keyframe(0, scale: 40)]).keyframeCaptureGrowth,
        Layer.kMaxKeyframeCaptureGrowth,
      );
    });

    test('transformKeyframes moves every keyframe like the layer', () {
      final layer =
          Layer(
            keyframes: [
              keyframe(0, offset: const Offset(10, 20), scale: 2),
              keyframe(500, offset: const Offset(-4, 8)),
            ],
          )..transformKeyframes(
            (p) => p
              ..offset *= 2
              ..scale *= 2,
          );

      expect(
        layer.keyframes.map((k) => (k.offset, k.scale)),
        equals([(const Offset(20, 40), 4.0), (const Offset(-8, 16), 2.0)]),
      );
    });
  });

  group('Layer opacity and keyframes serialization', () {
    final keyframes = [
      keyframe(0, offset: const Offset(1, 2), opacity: 0.5),
      keyframe(750, rotation: 1, curve: AnimationCurve.easeInOut),
    ];

    final layers = <String, Layer Function()>{
      'TextLayer': () =>
          TextLayer(text: 'Hi', opacity: 0.3, keyframes: keyframes),
      'EmojiLayer': () =>
          EmojiLayer(emoji: '😀', opacity: 0.3, keyframes: keyframes),
      'PaintLayer': () => PaintLayer(
        item: PaintedModel(
          mode: PaintMode.freeStyle,
          offsets: const [Offset.zero, Offset(4, 4)],
          erasedOffsets: const [],
          color: const Color(0xFF000000),
          strokeWidth: 2,
          opacity: 1,
        ),
        rawSize: const Size(4, 4),
        opacity: 0.3,
        keyframes: keyframes,
      ),
    };

    for (final MapEntry(key: name, value: create) in layers.entries) {
      test('$name keeps both through toMap / fromMap', () {
        final restored = Layer.fromMap(create().toMap());

        expect(restored.opacity, equals(0.3));
        expect(restored.keyframes, equals(keyframes));
      });

      test('$name keeps both through copyWith and LayerCopyManager', () {
        final layer = create();

        expect(layer.copyWith().keyframes, equals(keyframes));
        expect(layer.copyWith().opacity, equals(0.3));
        final copy = LayerCopyManager().copyLayer(layer);
        expect(copy.keyframes, equals(keyframes));
        expect(copy.opacity, equals(0.3));
      });
    }

    test('toMapFromReference writes removed keyframes as an empty list', () {
      final reference = TextLayer(text: 'Hi', keyframes: keyframes);
      final updated = TextLayer(text: 'Hi', id: reference.id);

      final map = updated.toMapFromReference(reference);

      expect(map['keyframes'], equals(<Map<String, dynamic>>[]));
    });

    test('toMap leaves out the defaults', () {
      final map = Layer().toMap();

      expect(map.containsKey('opacity'), isFalse);
      expect(map.containsKey('keyframes'), isFalse);
    });
  });
}
