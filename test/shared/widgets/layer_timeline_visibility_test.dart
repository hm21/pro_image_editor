import 'dart:math' as math;

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pro_image_editor/core/models/editor_configs/video/layer_timeline_configs.dart';
import 'package:pro_image_editor/core/models/layers/layer.dart';
import 'package:pro_image_editor/shared/widgets/layer/layer_timeline_visibility.dart';

void main() {
  const childKey = Key('layer-child');
  const canvasSize = Size(100, 100);
  const layerCenter = Offset(50, 50);

  Future<ValueNotifier<Duration>> pumpVisibility(
    WidgetTester tester,
    Layer layer, {
    Size canvas = canvasSize,
    Offset center = layerCenter,
    Offset fractionalOffset = const Offset(-0.5, -0.5),
    ValueNotifier<Duration>? reuse,
  }) async {
    // Start before any layer's time range so the first seek registers as a
    // real change on the [ValueNotifier]. Pass [reuse] to re-pump with a
    // changed geometry while the video position stays put.
    final notifier =
        reuse ?? ValueNotifier<Duration>(const Duration(milliseconds: -1));
    if (reuse == null) addTearDown(notifier.dispose);

    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: Center(
          child: LayerTimelineVisibility(
            layer: layer,
            playTimeNotifier: notifier,
            configs: const LayerTimelineConfigs(),
            canvasSize: canvas,
            layerCenter: center,
            layerFractionalOffset: fractionalOffset,
            child: const SizedBox(key: childKey, width: 100, height: 50),
          ),
        ),
      ),
    );
    return notifier;
  }

  Future<void> seek(
    WidgetTester tester,
    ValueNotifier<Duration> notifier,
    Duration time,
  ) async {
    notifier.value = time;
    await tester.pump();
  }

  // The absolute (canvas-pixel) slide component, read from the
  // [Transform.translate] matrix translation.
  Offset slideAbsolute(WidgetTester tester) {
    final matrix = tester.widget<Transform>(find.byType(Transform)).transform;
    return Offset(matrix.storage[12], matrix.storage[13]);
  }

  // The fractional slide component, read from the [FractionalTranslation].
  Offset slideFractional(WidgetTester tester) {
    return tester
        .widget<FractionalTranslation>(find.byType(FractionalTranslation))
        .translation;
  }

  group('LayerTimelineVisibility phase-aware preview', () {
    final layer = Layer(
      startTime: const Duration(seconds: 1),
      endTime: const Duration(seconds: 10),
      animations: const [
        LayerAnimation(
          type: LayerAnimationType.slide,
          phase: AnimationPhase.animateIn,
          duration: Duration(milliseconds: 400),
          slideDirection: SlideDirection.left,
          curve: AnimationCurve.easeOut,
        ),
        LayerAnimation(
          type: LayerAnimationType.fade,
          phase: AnimationPhase.animateOut,
          duration: Duration(milliseconds: 300),
        ),
      ],
    );

    testWidgets('slides in fully off-canvas at the enter window start', (
      tester,
    ) async {
      final notifier = await pumpVisibility(tester, layer);
      await seek(tester, notifier, const Duration(seconds: 1));

      // invP = 1: the layer sits fully outside the left edge. Absolute pushes
      // the center to x=0, fractional pushes by another half layer width, so
      // the layer's right edge lands exactly on x=0.
      expect(slideAbsolute(tester), const Offset(-50, 0));
      expect(slideFractional(tester), const Offset(-0.5, 0));
      // No fade-out yet, so no Opacity wrapper.
      expect(find.byType(Opacity), findsNothing);
    });

    testWidgets('slides partway through the enter window', (tester) async {
      final notifier = await pumpVisibility(tester, layer);
      await seek(tester, notifier, const Duration(milliseconds: 1200));

      final absolute = slideAbsolute(tester);
      expect(absolute.dx, greaterThan(-50));
      expect(absolute.dx, lessThan(0));
      expect(absolute.dy, 0);

      final fractional = slideFractional(tester);
      expect(fractional.dx, greaterThan(-0.5));
      expect(fractional.dx, lessThan(0));
      expect(fractional.dy, 0);
    });

    testWidgets('settles with no transform once entered', (tester) async {
      final notifier = await pumpVisibility(tester, layer);
      await seek(tester, notifier, const Duration(seconds: 5));

      expect(find.byType(FractionalTranslation), findsNothing);
      expect(find.byType(Transform), findsNothing);
      expect(find.byType(Opacity), findsNothing);
      expect(find.byKey(childKey), findsOneWidget);
    });

    testWidgets('fades out during the exit window', (tester) async {
      final notifier = await pumpVisibility(tester, layer);
      await seek(tester, notifier, const Duration(milliseconds: 9850));

      final opacity = tester.widget<Opacity>(find.byType(Opacity)).opacity;
      expect(opacity, closeTo(0.5, 1e-6));
      // The slide animation only plays on enter, so no translation here.
      expect(find.byType(FractionalTranslation), findsNothing);
      expect(find.byType(Transform), findsNothing);
    });

    testWidgets('hides before start and after end', (tester) async {
      final notifier = await pumpVisibility(tester, layer);

      await seek(tester, notifier, const Duration(milliseconds: 500));
      expect(find.byType(IgnorePointer), findsOneWidget);

      await seek(tester, notifier, const Duration(seconds: 11));
      expect(find.byType(IgnorePointer), findsOneWidget);
    });
  });

  group('LayerTimelineVisibility edge-aware slide', () {
    Layer slideOutLayer(SlideDirection direction) => Layer(
      startTime: Duration.zero,
      endTime: const Duration(seconds: 10),
      animations: [
        LayerAnimation(
          type: LayerAnimationType.slide,
          phase: AnimationPhase.animateOut,
          duration: const Duration(milliseconds: 400),
          slideDirection: direction,
          curve: AnimationCurve.linear,
        ),
      ],
    );

    // At the end of the window invP = 1, so each direction must move the
    // layer's nearest edge exactly onto the matching canvas border. With a
    // centered layer (50,50) on a 100×100 canvas the absolute component is the
    // distance from the center to that border and the fractional component is
    // a half layer size in the slide direction.
    const expected = <SlideDirection, ({Offset absolute, Offset fractional})>{
      SlideDirection.left: (
        absolute: Offset(-50, 0),
        fractional: Offset(-0.5, 0),
      ),
      SlideDirection.right: (
        absolute: Offset(50, 0),
        fractional: Offset(0.5, 0),
      ),
      SlideDirection.top: (
        absolute: Offset(0, -50),
        fractional: Offset(0, -0.5),
      ),
      SlideDirection.bottom: (
        absolute: Offset(0, 50),
        fractional: Offset(0, 0.5),
      ),
    };

    for (final entry in expected.entries) {
      testWidgets('slides ${entry.key.name} fully off-canvas at window end', (
        tester,
      ) async {
        final notifier = await pumpVisibility(tester, slideOutLayer(entry.key));
        await seek(tester, notifier, const Duration(seconds: 10));

        expect(slideAbsolute(tester), entry.value.absolute);
        expect(slideFractional(tester), entry.value.fractional);
      });
    }

    testWidgets('pushes an off-center layer past its nearest edge', (
      tester,
    ) async {
      // A layer centered at (20, 80) sliding left: the absolute component is
      // its own center distance from the left edge (-20) and the fractional
      // component still removes the remaining half layer width.
      final notifier = await pumpVisibility(
        tester,
        slideOutLayer(SlideDirection.left),
        center: const Offset(20, 80),
      );
      await seek(tester, notifier, const Duration(seconds: 10));

      expect(slideAbsolute(tester), const Offset(-20, 0));
      expect(slideFractional(tester), const Offset(-0.5, 0));
    });
  });

  group('LayerTimelineVisibility slide from a custom point', () {
    // A layer resting 10px right and 20px below the canvas center, entering
    // from a point 150px left and 60px above that center. Both are measured
    // like [Layer.offset], so the layer travels (-160, -80).
    const restingOffset = Offset(10, 20);
    const startPoint = Offset(-150, -60);
    const travel = Offset(-160, -80);

    Layer slideFromLayer({SlideDirection? direction}) => Layer(
      offset: restingOffset,
      startTime: const Duration(seconds: 1),
      endTime: const Duration(seconds: 10),
      animations: [
        LayerAnimation(
          type: LayerAnimationType.slide,
          phase: AnimationPhase.animateIn,
          duration: const Duration(milliseconds: 400),
          slideFrom: startPoint,
          slideDirection: direction,
          curve: AnimationCurve.linear,
        ),
      ],
    );

    testWidgets('starts on the point at the enter window start', (
      tester,
    ) async {
      final notifier = await pumpVisibility(
        tester,
        slideFromLayer(),
        center: const Offset(60, 70),
      );
      await seek(tester, notifier, const Duration(seconds: 1));

      // invP = 1: the layer sits exactly on the start point. The distance is
      // measured between two anchor points, so the layer's own size plays no
      // part and there is no fractional component.
      expect(slideAbsolute(tester), travel);
      expect(find.byType(FractionalTranslation), findsNothing);
    });

    testWidgets('travels a linear fraction partway through the window', (
      tester,
    ) async {
      final notifier = await pumpVisibility(tester, slideFromLayer());
      // 100ms into a 400ms linear window: invP = 0.75.
      await seek(tester, notifier, const Duration(milliseconds: 1100));

      expect(slideAbsolute(tester), travel * 0.75);
    });

    testWidgets('settles on the resting place once entered', (tester) async {
      final notifier = await pumpVisibility(tester, slideFromLayer());
      await seek(tester, notifier, const Duration(seconds: 5));

      expect(find.byType(Transform), findsNothing);
      expect(find.byType(FractionalTranslation), findsNothing);
    });

    testWidgets('overrides slideDirection when both are set', (tester) async {
      final notifier = await pumpVisibility(
        tester,
        slideFromLayer(direction: SlideDirection.right),
      );
      await seek(tester, notifier, const Duration(seconds: 1));

      // The right edge would push the layer the other way and add a
      // fractional half-width; the point wins outright.
      expect(slideAbsolute(tester), travel);
      expect(find.byType(FractionalTranslation), findsNothing);
    });

    testWidgets('leaves back towards the point on the way out', (tester) async {
      final layer = Layer(
        offset: restingOffset,
        startTime: Duration.zero,
        endTime: const Duration(seconds: 10),
        animations: const [
          LayerAnimation(
            type: LayerAnimationType.slide,
            phase: AnimationPhase.animateOut,
            duration: Duration(milliseconds: 400),
            slideFrom: startPoint,
            curve: AnimationCurve.linear,
          ),
        ],
      );
      final notifier = await pumpVisibility(tester, layer);
      await seek(tester, notifier, const Duration(seconds: 10));

      expect(slideAbsolute(tester), travel);
    });
  });

  group('LayerTimelineVisibility geometry updates', () {
    // [Layer] is mutable and is mutated in place while it is dragged, so the
    // cached frame has to be invalidated by the geometry it read, not by
    // comparing the old and new widget's layer.
    testWidgets('recomputes a point slide when the layer moves', (
      tester,
    ) async {
      final layer = Layer(
        offset: const Offset(10, 20),
        startTime: const Duration(seconds: 1),
        endTime: const Duration(seconds: 10),
        animations: const [
          LayerAnimation(
            type: LayerAnimationType.slide,
            phase: AnimationPhase.animateIn,
            duration: Duration(milliseconds: 400),
            slideFrom: Offset(-150, -60),
            curve: AnimationCurve.linear,
          ),
        ],
      );
      final notifier = await pumpVisibility(tester, layer);
      await seek(tester, notifier, const Duration(seconds: 1));

      expect(slideAbsolute(tester), const Offset(-160, -80));

      // Drag the layer without touching the video position.
      layer.offset = const Offset(50, 50);
      await pumpVisibility(
        tester,
        layer,
        center: const Offset(90, 100),
        reuse: notifier,
      );

      expect(slideAbsolute(tester), const Offset(-200, -110));
    });

    testWidgets('recomputes an edge slide when the canvas resizes', (
      tester,
    ) async {
      final layer = Layer(
        startTime: const Duration(seconds: 1),
        endTime: const Duration(seconds: 10),
        animations: const [
          LayerAnimation(
            type: LayerAnimationType.slide,
            phase: AnimationPhase.animateIn,
            duration: Duration(milliseconds: 400),
            slideDirection: SlideDirection.right,
            curve: AnimationCurve.linear,
          ),
        ],
      );
      final notifier = await pumpVisibility(tester, layer);
      await seek(tester, notifier, const Duration(seconds: 1));

      // invP = 1: pushed to the right edge, (canvas.width - center.dx).
      expect(slideAbsolute(tester), const Offset(50, 0));

      await pumpVisibility(
        tester,
        layer,
        canvas: const Size(300, 100),
        reuse: notifier,
      );

      expect(slideAbsolute(tester), const Offset(250, 0));
    });
  });

  group('LayerTimelineVisibility scale animation', () {
    final layer = Layer(
      startTime: Duration.zero,
      endTime: const Duration(seconds: 10),
      animations: const [
        LayerAnimation(
          type: LayerAnimationType.scale,
          phase: AnimationPhase.animateIn,
          duration: Duration(milliseconds: 400),
          scaleFrom: 0.5,
        ),
      ],
    );

    double currentScale(WidgetTester tester) {
      // storage[0] is the x-scale entry of the Transform.scale matrix.
      final transform = tester
          .widget<Transform>(find.byType(Transform))
          .transform;
      return transform.storage[0];
    }

    AlignmentGeometry? scaleAlignment(WidgetTester tester) {
      return tester.widget<Transform>(find.byType(Transform)).alignment;
    }

    testWidgets('scales from scaleFrom up to 1', (tester) async {
      final notifier = await pumpVisibility(tester, layer);

      await seek(tester, notifier, Duration.zero);
      expect(currentScale(tester), closeTo(0.5, 1e-6));

      await seek(tester, notifier, const Duration(milliseconds: 200));
      expect(currentScale(tester), closeTo(0.75, 1e-6));

      await seek(tester, notifier, const Duration(seconds: 5));
      expect(find.byType(Transform), findsNothing);
    });

    testWidgets('anchors scale on the layer visual center, not the box '
        'center', (tester) async {
      // Default fractional offset (-0.5, -0.5) paints the layer's visual
      // center at the box top-left, so scaling must anchor there. Otherwise a
      // combined slide + scale drifts diagonally instead of entering straight.
      final notifier = await pumpVisibility(tester, layer);
      await seek(tester, notifier, Duration.zero);
      expect(scaleAlignment(tester), Alignment.topLeft);
    });

    testWidgets('anchors scale on the box center for a centered offset', (
      tester,
    ) async {
      // A fractional offset of (0, 0) leaves the visual center at the box
      // center, so scaling anchors there.
      final notifier = await pumpVisibility(
        tester,
        layer,
        fractionalOffset: Offset.zero,
      );
      await seek(tester, notifier, Duration.zero);
      expect(scaleAlignment(tester), Alignment.center);
    });
  });

  group('LayerTimelineVisibility wiggle, bounce and loop', () {
    // The tilt of the [Transform.rotate] a wiggle adds, clockwise.
    double tilt(WidgetTester tester) {
      final matrix = tester.widget<Transform>(find.byType(Transform)).transform;
      return math.atan2(matrix.storage[1], matrix.storage[0]);
    }

    Layer layerWith(LayerAnimation animation, {double rotation = 0}) => Layer(
      startTime: Duration.zero,
      endTime: const Duration(seconds: 10),
      rotation: rotation,
      animations: [animation],
    );

    testWidgets('wiggles to one side and then the other in a loop', (
      tester,
    ) async {
      final layer = layerWith(
        const LayerAnimation(
          type: LayerAnimationType.wiggle,
          phase: AnimationPhase.loop,
          duration: Duration(seconds: 1),
          wiggleAngle: 0.3,
        ),
      );
      final notifier = await pumpVisibility(tester, layer);

      await seek(tester, notifier, const Duration(milliseconds: 250));
      expect(tilt(tester), closeTo(0.3, 1e-9));

      await seek(tester, notifier, const Duration(milliseconds: 750));
      expect(tilt(tester), closeTo(-0.3, 1e-9));

      // Upright between the swings: no transform at all.
      await seek(tester, notifier, const Duration(milliseconds: 1000));
      expect(find.byType(Transform), findsNothing);
    });

    testWidgets('tilts around the visual center the scale is anchored on', (
      tester,
    ) async {
      final layer = layerWith(
        const LayerAnimation(
          type: LayerAnimationType.wiggle,
          phase: AnimationPhase.animateIn,
          duration: Duration(seconds: 1),
        ),
      );
      final notifier = await pumpVisibility(tester, layer);
      await seek(tester, notifier, Duration.zero);

      expect(
        tester.widget<Transform>(find.byType(Transform)).alignment,
        Alignment.topLeft,
      );
      expect(tilt(tester), closeTo(LayerAnimation.defaultWiggleAngle, 1e-9));
    });

    testWidgets('drops in from a multiple of the layer height', (tester) async {
      final layer = layerWith(
        const LayerAnimation(
          type: LayerAnimationType.bounce,
          phase: AnimationPhase.animateIn,
          duration: Duration(seconds: 1),
          bounceHeight: 2,
        ),
      );
      final notifier = await pumpVisibility(tester, layer);
      await seek(tester, notifier, const Duration(seconds: 2));
      final rest = tester.getTopLeft(find.byKey(childKey));

      // The child is 50 tall: half way in, it is lifted by 2 × 50 / 2.
      await seek(tester, notifier, const Duration(milliseconds: 500));
      expect(
        tester.getTopLeft(find.byKey(childKey)),
        rest - const Offset(0, 50),
      );
    });

    testWidgets('measures the lift on the box around a rotated layer', (
      tester,
    ) async {
      // Turned a quarter, the 100 × 50 child is drawn 100 tall.
      final layer = layerWith(
        const LayerAnimation(
          type: LayerAnimationType.bounce,
          phase: AnimationPhase.animateIn,
          duration: Duration(seconds: 1),
          bounceHeight: 1,
        ),
        rotation: math.pi / 2,
      );
      final notifier = await pumpVisibility(tester, layer);
      await seek(tester, notifier, const Duration(seconds: 2));
      final rest = tester.getTopLeft(find.byKey(childKey));

      await seek(tester, notifier, Duration.zero);
      final lifted = tester.getTopLeft(find.byKey(childKey));
      expect(lifted.dx, closeTo(rest.dx, 1e-9));
      expect(lifted.dy, closeTo(rest.dy - 100, 1e-9));
    });

    testWidgets('pulses in a scale loop', (tester) async {
      final layer = layerWith(
        const LayerAnimation(
          type: LayerAnimationType.scale,
          phase: AnimationPhase.loop,
          duration: Duration(seconds: 1),
          scaleFrom: 0.8,
        ),
      );
      final notifier = await pumpVisibility(tester, layer);

      await seek(tester, notifier, const Duration(milliseconds: 500));
      final matrix = tester.widget<Transform>(find.byType(Transform)).transform;
      expect(matrix.storage[0], closeTo(0.8, 1e-9));
    });

    testWidgets('leaves a text reveal to the text layer', (tester) async {
      final layer = layerWith(
        const LayerAnimation(
          type: LayerAnimationType.typewriter,
          phase: AnimationPhase.animateIn,
          duration: Duration(seconds: 1),
        ),
      );
      final notifier = await pumpVisibility(tester, layer);
      await seek(tester, notifier, const Duration(milliseconds: 500));

      expect(find.byType(Transform), findsNothing);
      expect(find.byType(Opacity), findsNothing);
    });
  });

  group('LayerTimelineVisibility legacy fade path', () {
    testWidgets('uses the transitionBuilder when animations is empty', (
      tester,
    ) async {
      final layer = Layer(
        startTime: Duration.zero,
        endTime: const Duration(seconds: 10),
        enterDuration: const Duration(milliseconds: 400),
      );
      final notifier = await pumpVisibility(tester, layer);

      // Halfway through the fade-in window.
      await seek(tester, notifier, const Duration(milliseconds: 200));
      expect(find.byType(FadeTransition), findsOneWidget);
    });
  });

  group('LayerTimelineVisibility keyframes', () {
    // Anchor the transforms on the child's own center: the test child is not
    // shifted by a fractional translation the way a real layer is.
    const centered = Offset.zero;

    Layer keyframedLayer({
      bool flipX = false,
      List<LayerAnimation>? animations,
      Duration? enterDuration,
    }) => Layer(
      startTime: Duration.zero,
      endTime: const Duration(seconds: 10),
      flipX: flipX,
      animations: animations,
      enterDuration: enterDuration,
      keyframes: const [
        LayerKeyframe(time: Duration.zero, offset: Offset.zero),
        LayerKeyframe(
          time: Duration(seconds: 1),
          offset: Offset(40, 20),
          scale: 2,
          rotation: math.pi / 2,
          opacity: 0.5,
        ),
      ],
    );

    Offset topLeft(WidgetTester tester) =>
        tester.getTopLeft(find.byKey(childKey));

    testWidgets('moves, scales and turns the layer to its keyframed '
        'placement', (tester) async {
      final notifier = await pumpVisibility(
        tester,
        keyframedLayer(),
        fractionalOffset: centered,
      );
      await seek(tester, notifier, Duration.zero);
      final restCenter = tester.getCenter(find.byKey(childKey));
      expect(find.byType(Opacity), findsNothing);

      await seek(tester, notifier, const Duration(seconds: 1));

      // The 100 × 50 child's top-left corner, (-50, -25) from its center,
      // turned a quarter clockwise and doubled.
      final corner = topLeft(tester) - restCenter - const Offset(40, 20);
      expect(corner.dx, closeTo(50, 1e-6));
      expect(corner.dy, closeTo(-100, 1e-6));
      expect(tester.widget<Opacity>(find.byType(Opacity)).opacity, equals(0.5));
    });

    testWidgets('turns a layer flipped on one axis the other way, as it is '
        'drawn mirrored', (tester) async {
      final notifier = await pumpVisibility(
        tester,
        keyframedLayer(flipX: true),
        fractionalOffset: centered,
      );
      await seek(tester, notifier, Duration.zero);
      final restCenter = tester.getCenter(find.byKey(childKey));

      await seek(tester, notifier, const Duration(seconds: 1));

      final corner = topLeft(tester) - restCenter - const Offset(40, 20);
      expect(corner.dx, closeTo(-50, 1e-6));
      expect(corner.dy, closeTo(100, 1e-6));
    });

    testWidgets('turns the other way once the same layer is flipped in '
        'place', (tester) async {
      final layer = keyframedLayer();
      final notifier = await pumpVisibility(
        tester,
        layer,
        fractionalOffset: centered,
      );
      await seek(tester, notifier, Duration.zero);
      final restCenter = tester.getCenter(find.byKey(childKey));
      await seek(tester, notifier, const Duration(seconds: 1));

      // A host flips the layer it already shows, at the same position.
      layer.flipX = true;
      await pumpVisibility(
        tester,
        layer,
        fractionalOffset: centered,
        reuse: notifier,
      );

      final corner = topLeft(tester) - restCenter - const Offset(40, 20);
      expect(corner.dx, closeTo(-50, 1e-6));
      expect(corner.dy, closeTo(100, 1e-6));
    });

    testWidgets('measures the difference to the placement the layer is laid '
        'out with', (tester) async {
      final layer = keyframedLayer()
        ..offset = const Offset(40, 20)
        ..scale = 2
        ..rotation = math.pi / 2;
      final notifier = await pumpVisibility(
        tester,
        layer,
        fractionalOffset: centered,
      );

      // At the keyframe that matches the layout there is nothing to move.
      await seek(tester, notifier, const Duration(seconds: 1));
      expect(find.byType(Transform), findsNothing);
    });

    testWidgets('plays a keyframe effect between its two keyframes only', (
      tester,
    ) async {
      final layer = Layer(
        startTime: Duration.zero,
        endTime: const Duration(seconds: 10),
        keyframes: const [
          LayerKeyframe(
            time: Duration.zero,
            offset: Offset.zero,
            // Two hops of 500 ms between the keyframes.
            effects: [
              LayerAnimation(
                type: LayerAnimationType.bounce,
                phase: AnimationPhase.loop,
                duration: Duration(milliseconds: 500),
              ),
            ],
          ),
          LayerKeyframe(time: Duration(seconds: 1), offset: Offset.zero),
        ],
      );
      final notifier = await pumpVisibility(
        tester,
        layer,
        fractionalOffset: centered,
      );
      await seek(tester, notifier, Duration.zero);
      final rest = tester.getCenter(find.byKey(childKey));

      // At the top of the first hop: half the 50 px child's height up.
      await seek(tester, notifier, const Duration(milliseconds: 250));
      expect(
        tester.getCenter(find.byKey(childKey)) - rest,
        const Offset(0, -25),
      );

      // Back down on the second keyframe, and still after it.
      await seek(tester, notifier, const Duration(seconds: 1));
      expect(tester.getCenter(find.byKey(childKey)), rest);
      await seek(tester, notifier, const Duration(milliseconds: 1250));
      expect(tester.getCenter(find.byKey(childKey)), rest);
    });

    testWidgets('keeps the legacy fade and places the faded layer', (
      tester,
    ) async {
      final notifier = await pumpVisibility(
        tester,
        keyframedLayer(enterDuration: const Duration(seconds: 2)),
        fractionalOffset: centered,
      );
      await seek(tester, notifier, Duration.zero);
      final restCenter = tester.getCenter(find.byKey(childKey));

      await seek(tester, notifier, const Duration(seconds: 1));

      expect(find.byType(FadeTransition), findsOneWidget);
      expect(
        tester.getCenter(find.byKey(childKey)) - restCenter,
        equals(const Offset(40, 20)),
      );
    });

    testWidgets('slides in from the edge nearest the keyframed place', (
      tester,
    ) async {
      final layer = keyframedLayer(
        animations: const [
          LayerAnimation(
            type: LayerAnimationType.slide,
            phase: AnimationPhase.animateIn,
            duration: Duration(seconds: 2),
            slideDirection: SlideDirection.left,
          ),
        ],
      );
      final notifier = await pumpVisibility(
        tester,
        layer,
        fractionalOffset: centered,
      );

      // Half way into the slide, at the keyframe: the layer's center (50 +
      // 40) has covered half its way to the left edge, and the fractional
      // part half of the doubled layer's half width.
      await seek(tester, notifier, const Duration(seconds: 1));
      // The outermost transform is the translation.
      final translate = tester
          .widgetList<Transform>(find.byType(Transform))
          .first
          .transform;
      expect(translate.storage[12], closeTo(40 - 90 * 0.5, 1e-9));
      expect(slideFractional(tester), equals(const Offset(-0.5, 0)));
    });
  });
}
