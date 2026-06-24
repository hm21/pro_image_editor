import 'package:flutter_test/flutter_test.dart';
import 'package:pro_image_editor/core/models/layers/layer_animation.dart';

void main() {
  group('LayerAnimation', () {
    group('constructor', () {
      test('creates fade animation with defaults', () {
        const anim = LayerAnimation(
          type: LayerAnimationType.fade,
          phase: AnimationPhase.animateIn,
          duration: Duration(milliseconds: 500),
        );

        expect(anim.type, LayerAnimationType.fade);
        expect(anim.phase, AnimationPhase.animateIn);
        expect(anim.duration, const Duration(milliseconds: 500));
        expect(anim.curve, AnimationCurve.linear);
        expect(anim.slideDirection, isNull);
        expect(anim.scaleFrom, isNull);
      });

      test('creates slide animation with direction', () {
        const anim = LayerAnimation(
          type: LayerAnimationType.slide,
          phase: AnimationPhase.animateOut,
          duration: Duration(milliseconds: 300),
          slideDirection: SlideDirection.left,
          curve: AnimationCurve.easeOut,
        );

        expect(anim.type, LayerAnimationType.slide);
        expect(anim.slideDirection, SlideDirection.left);
        expect(anim.curve, AnimationCurve.easeOut);
      });

      test('creates scale animation with scaleFrom', () {
        const anim = LayerAnimation(
          type: LayerAnimationType.scale,
          phase: AnimationPhase.animateInOut,
          duration: Duration(milliseconds: 400),
          scaleFrom: 0.5,
        );

        expect(anim.type, LayerAnimationType.scale);
        expect(anim.phase, AnimationPhase.animateInOut);
        expect(anim.scaleFrom, 0.5);
      });
    });

    group('toMap', () {
      test('serializes fade animation', () {
        const anim = LayerAnimation(
          type: LayerAnimationType.fade,
          phase: AnimationPhase.animateIn,
          duration: Duration(milliseconds: 500),
        );
        final map = anim.toMap();

        expect(map['type'], 'fade');
        expect(map['phase'], 'animateIn');
        expect(map['durationUs'], 500000);
        expect(map['curve'], 'linear');
        expect(map['slideDirection'], isNull);
        expect(map['scaleFrom'], isNull);
      });

      test('serializes slide animation with all fields', () {
        const anim = LayerAnimation(
          type: LayerAnimationType.slide,
          phase: AnimationPhase.animateOut,
          duration: Duration(seconds: 1),
          curve: AnimationCurve.easeInOut,
          slideDirection: SlideDirection.bottom,
        );
        final map = anim.toMap();

        expect(map['type'], 'slide');
        expect(map['phase'], 'animateOut');
        expect(map['durationUs'], 1000000);
        expect(map['curve'], 'easeInOut');
        expect(map['slideDirection'], 'bottom');
      });

      test('serializes scale animation with scaleFrom', () {
        const anim = LayerAnimation(
          type: LayerAnimationType.scale,
          phase: AnimationPhase.animateInOut,
          duration: Duration(milliseconds: 250),
          scaleFrom: 0.3,
        );
        final map = anim.toMap();

        expect(map['scaleFrom'], 0.3);
      });
    });

    group('fromMap', () {
      test('deserializes fade animation', () {
        final map = <String, dynamic>{
          'type': 'fade',
          'phase': 'animateIn',
          'durationUs': 500000,
          'curve': 'linear',
          'slideDirection': null,
          'scaleFrom': null,
        };
        final anim = LayerAnimation.fromMap(map);

        expect(anim.type, LayerAnimationType.fade);
        expect(anim.phase, AnimationPhase.animateIn);
        expect(anim.duration, const Duration(milliseconds: 500));
        expect(anim.curve, AnimationCurve.linear);
        expect(anim.slideDirection, isNull);
        expect(anim.scaleFrom, isNull);
      });

      test('deserializes slide animation', () {
        final map = <String, dynamic>{
          'type': 'slide',
          'phase': 'animateOut',
          'durationUs': 300000,
          'curve': 'easeOut',
          'slideDirection': 'right',
          'scaleFrom': null,
        };
        final anim = LayerAnimation.fromMap(map);

        expect(anim.type, LayerAnimationType.slide);
        expect(anim.slideDirection, SlideDirection.right);
        expect(anim.curve, AnimationCurve.easeOut);
      });

      test('defaults curve to linear when missing', () {
        final map = <String, dynamic>{
          'type': 'fade',
          'phase': 'animateIn',
          'durationUs': 100000,
        };
        final anim = LayerAnimation.fromMap(map);

        expect(anim.curve, AnimationCurve.linear);
      });

      test('deserializes animateInOut phase', () {
        final map = <String, dynamic>{
          'type': 'scale',
          'phase': 'animateInOut',
          'durationUs': 400000,
          'scaleFrom': 0.5,
        };
        final anim = LayerAnimation.fromMap(map);

        expect(anim.phase, AnimationPhase.animateInOut);
        expect(anim.scaleFrom, 0.5);
      });

      test('falls back to defaults for unknown enum names', () {
        // Simulates data from a newer version with an unknown type/curve, or
        // hand-edited JSON: parsing must degrade gracefully instead of
        // throwing.
        final map = <String, dynamic>{
          'type': 'rotate',
          'phase': 'animateLater',
          'durationUs': 100000,
          'curve': 'easeInQuart',
          'slideDirection': 'diagonal',
        };
        final anim = LayerAnimation.fromMap(map);

        expect(anim.type, LayerAnimationType.fade);
        expect(anim.phase, AnimationPhase.animateIn);
        expect(anim.curve, AnimationCurve.linear);
        expect(anim.slideDirection, isNull);
      });

      test('defaults duration to zero when durationUs is missing', () {
        final map = <String, dynamic>{'type': 'fade', 'phase': 'animateIn'};
        final anim = LayerAnimation.fromMap(map);

        expect(anim.duration, Duration.zero);
      });
    });

    group('roundtrip toMap/fromMap', () {
      test('fade roundtrip preserves data', () {
        const original = LayerAnimation(
          type: LayerAnimationType.fade,
          phase: AnimationPhase.animateIn,
          duration: Duration(milliseconds: 500),
          curve: AnimationCurve.easeIn,
        );
        final restored = LayerAnimation.fromMap(original.toMap());
        expect(restored, original);
      });

      test('slide roundtrip preserves data', () {
        const original = LayerAnimation(
          type: LayerAnimationType.slide,
          phase: AnimationPhase.animateOut,
          duration: Duration(milliseconds: 300),
          curve: AnimationCurve.easeOut,
          slideDirection: SlideDirection.top,
        );
        final restored = LayerAnimation.fromMap(original.toMap());
        expect(restored, original);
      });

      test('scale roundtrip preserves data', () {
        const original = LayerAnimation(
          type: LayerAnimationType.scale,
          phase: AnimationPhase.animateInOut,
          duration: Duration(milliseconds: 250),
          scaleFrom: 0.2,
        );
        final restored = LayerAnimation.fromMap(original.toMap());
        expect(restored, original);
      });
    });

    group('copyWith', () {
      test('returns an equal copy when no fields are provided', () {
        const original = LayerAnimation(
          type: LayerAnimationType.slide,
          phase: AnimationPhase.animateIn,
          duration: Duration(milliseconds: 400),
          curve: AnimationCurve.easeOut,
          slideDirection: SlideDirection.left,
        );

        expect(original.copyWith(), original);
      });

      test('overrides only the provided fields', () {
        const original = LayerAnimation(
          type: LayerAnimationType.fade,
          phase: AnimationPhase.animateIn,
          duration: Duration(milliseconds: 500),
        );

        final updated = original.copyWith(
          phase: AnimationPhase.animateOut,
          duration: const Duration(milliseconds: 300),
          curve: AnimationCurve.easeInOut,
        );

        expect(updated.type, LayerAnimationType.fade);
        expect(updated.phase, AnimationPhase.animateOut);
        expect(updated.duration, const Duration(milliseconds: 300));
        expect(updated.curve, AnimationCurve.easeInOut);
      });
    });

    group('equality', () {
      test('identical animations are equal', () {
        const a = LayerAnimation(
          type: LayerAnimationType.fade,
          phase: AnimationPhase.animateIn,
          duration: Duration(milliseconds: 500),
        );
        const b = LayerAnimation(
          type: LayerAnimationType.fade,
          phase: AnimationPhase.animateIn,
          duration: Duration(milliseconds: 500),
        );
        expect(a, b);
        expect(a.hashCode, b.hashCode);
      });

      test('different type makes unequal', () {
        const a = LayerAnimation(
          type: LayerAnimationType.fade,
          phase: AnimationPhase.animateIn,
          duration: Duration(milliseconds: 500),
        );
        const b = LayerAnimation(
          type: LayerAnimationType.scale,
          phase: AnimationPhase.animateIn,
          duration: Duration(milliseconds: 500),
        );
        expect(a, isNot(b));
      });

      test('different slideDirection makes unequal', () {
        const a = LayerAnimation(
          type: LayerAnimationType.slide,
          phase: AnimationPhase.animateIn,
          duration: Duration(milliseconds: 500),
          slideDirection: SlideDirection.left,
        );
        const b = LayerAnimation(
          type: LayerAnimationType.slide,
          phase: AnimationPhase.animateIn,
          duration: Duration(milliseconds: 500),
          slideDirection: SlideDirection.right,
        );
        expect(a, isNot(b));
      });

      test('different scaleFrom makes unequal', () {
        const a = LayerAnimation(
          type: LayerAnimationType.scale,
          phase: AnimationPhase.animateIn,
          duration: Duration(milliseconds: 500),
          scaleFrom: 0.0,
        );
        const b = LayerAnimation(
          type: LayerAnimationType.scale,
          phase: AnimationPhase.animateIn,
          duration: Duration(milliseconds: 500),
          scaleFrom: 0.5,
        );
        expect(a, isNot(b));
      });
    });

    group('toString', () {
      test('contains class name and fields', () {
        const anim = LayerAnimation(
          type: LayerAnimationType.fade,
          phase: AnimationPhase.animateIn,
          duration: Duration(milliseconds: 500),
        );
        final str = anim.toString();

        expect(str, contains('LayerAnimation'));
        expect(str, contains('fade'));
        expect(str, contains('animateIn'));
      });

      test('includes slideDirection when present', () {
        const anim = LayerAnimation(
          type: LayerAnimationType.slide,
          phase: AnimationPhase.animateIn,
          duration: Duration(milliseconds: 500),
          slideDirection: SlideDirection.left,
        );
        expect(anim.toString(), contains('slideDirection'));
      });

      test('excludes scaleFrom when null', () {
        const anim = LayerAnimation(
          type: LayerAnimationType.fade,
          phase: AnimationPhase.animateIn,
          duration: Duration(milliseconds: 500),
        );
        expect(anim.toString(), isNot(contains('scaleFrom')));
      });
    });
  });

  group('Enum values', () {
    test('LayerAnimationType has expected values', () {
      expect(LayerAnimationType.values, [
        LayerAnimationType.fade,
        LayerAnimationType.slide,
        LayerAnimationType.scale,
      ]);
    });

    test('SlideDirection has expected values', () {
      expect(SlideDirection.values, [
        SlideDirection.left,
        SlideDirection.right,
        SlideDirection.top,
        SlideDirection.bottom,
      ]);
    });

    test('AnimationCurve has expected values', () {
      expect(AnimationCurve.values, [
        AnimationCurve.linear,
        AnimationCurve.easeIn,
        AnimationCurve.easeOut,
        AnimationCurve.easeInOut,
        AnimationCurve.easeInCubic,
        AnimationCurve.easeOutCubic,
        AnimationCurve.easeInOutCubic,
        AnimationCurve.bounceIn,
        AnimationCurve.bounceOut,
        AnimationCurve.bounceInOut,
        AnimationCurve.elasticIn,
        AnimationCurve.elasticOut,
        AnimationCurve.elasticInOut,
      ]);
    });

    test('AnimationPhase has expected values', () {
      expect(AnimationPhase.values, [
        AnimationPhase.animateIn,
        AnimationPhase.animateOut,
        AnimationPhase.animateInOut,
      ]);
    });
  });
}
