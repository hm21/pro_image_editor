import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pro_image_editor/core/models/editor_configs/video/layer_timeline_configs.dart';
import 'package:pro_image_editor/core/models/layers/layer.dart';
import 'package:pro_image_editor/shared/widgets/layer/layer_timeline_visibility.dart';

void main() {
  const childKey = Key('layer-child');

  Future<ValueNotifier<Duration>> pumpVisibility(
    WidgetTester tester,
    Layer layer,
  ) async {
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

    testWidgets('slides in fully offset at the enter window start', (
      tester,
    ) async {
      final notifier = await pumpVisibility(tester, layer);
      await seek(tester, notifier, const Duration(seconds: 1));

      final translation = tester
          .widget<FractionalTranslation>(find.byType(FractionalTranslation))
          .translation;
      expect(translation, const Offset(-1, 0));
      // No fade-out yet, so no Opacity wrapper.
      expect(find.byType(Opacity), findsNothing);
    });

    testWidgets('slides partway through the enter window', (tester) async {
      final notifier = await pumpVisibility(tester, layer);
      await seek(tester, notifier, const Duration(milliseconds: 1200));

      final translation = tester
          .widget<FractionalTranslation>(find.byType(FractionalTranslation))
          .translation;
      expect(translation.dx, greaterThan(-1));
      expect(translation.dx, lessThan(0));
      expect(translation.dy, 0);
    });

    testWidgets('settles with no transform once entered', (tester) async {
      final notifier = await pumpVisibility(tester, layer);
      await seek(tester, notifier, const Duration(seconds: 5));

      expect(find.byType(FractionalTranslation), findsNothing);
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
    });

    testWidgets('hides before start and after end', (tester) async {
      final notifier = await pumpVisibility(tester, layer);

      await seek(tester, notifier, const Duration(milliseconds: 500));
      expect(find.byType(IgnorePointer), findsOneWidget);

      await seek(tester, notifier, const Duration(seconds: 11));
      expect(find.byType(IgnorePointer), findsOneWidget);
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
