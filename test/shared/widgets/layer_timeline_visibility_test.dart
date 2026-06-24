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
  }) async {
    // Start before any layer's time range so the first seek registers as a
    // real change on the [ValueNotifier].
    final notifier = ValueNotifier<Duration>(const Duration(milliseconds: -1));
    addTearDown(notifier.dispose);

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

    testWidgets('scales from scaleFrom up to 1', (tester) async {
      final notifier = await pumpVisibility(tester, layer);

      await seek(tester, notifier, Duration.zero);
      expect(currentScale(tester), closeTo(0.5, 1e-6));

      await seek(tester, notifier, const Duration(milliseconds: 200));
      expect(currentScale(tester), closeTo(0.75, 1e-6));

      await seek(tester, notifier, const Duration(seconds: 5));
      expect(find.byType(Transform), findsNothing);
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
}
