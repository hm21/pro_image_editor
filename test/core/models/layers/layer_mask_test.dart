import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart' show ValueListenable;
import 'package:flutter/rendering.dart' show RenderRepaintBoundary;
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:pro_image_editor/pro_image_editor.dart';

void main() {
  group(LayerMask, () {
    const mask = LayerMask(
      shape: LayerMaskShape.rectangle,
      center: Offset(0.25, 0.75),
      size: Size(0.4, 0.2),
      rotation: 0.5,
      feather: 0.1,
      cornerRadius: 0.3,
      invert: true,
    );

    group('fromMap', () {
      test('reads what toMap writes', () {
        expect(LayerMask.fromMap(mask.toMap()), mask);
      });

      test('falls back to an ellipse for a shape it does not know', () {
        final read = LayerMask.fromMap({...mask.toMap(), 'shape': 'spiral'});

        expect(read.shape, LayerMaskShape.ellipse);
        expect(read.center, mask.center);
      });
    });

    test('copyWith replaces only the fields given', () {
      final copy = mask.copyWith(shape: LayerMaskShape.heart, invert: false);

      expect(copy.shape, LayerMaskShape.heart);
      expect(copy.invert, isFalse);
      expect(copy.copyWith(shape: mask.shape, invert: true), mask);
    });

    group('outline', () {
      test('bounds an unturned shape by its box', () {
        const ellipse = LayerMask(
          shape: LayerMaskShape.ellipse,
          center: Offset(0.5, 0.25),
          size: Size(0.5, 0.25),
        );

        final bounds = ellipse.outline(const Size(200, 400)).getBounds();

        expect(bounds.left, closeTo(50, 0.01));
        expect(bounds.top, closeTo(50, 0.01));
        expect(bounds.width, closeTo(100, 0.01));
        expect(bounds.height, closeTo(100, 0.01));
      });

      test('fills the box of every unturned shape', () {
        const layerSize = Size(200, 400);
        for (final shape in LayerMaskShape.values) {
          if (shape == LayerMaskShape.linear) continue;
          final mask = LayerMask(
            shape: shape,
            center: const Offset(0.4, 0.6),
            size: const Size(0.5, 0.3),
          );

          final bounds = mask.outline(layerSize).getBounds();
          final box = mask.shapeRect(layerSize);

          expect(bounds.left, closeTo(box.left, 0.01), reason: shape.name);
          expect(bounds.top, closeTo(box.top, 0.01), reason: shape.name);
          expect(bounds.right, closeTo(box.right, 0.01), reason: shape.name);
          expect(bounds.bottom, closeTo(box.bottom, 0.01), reason: shape.name);
        }
      });

      test('turns a linear edge around the centre', () {
        const linear = LayerMask(
          shape: LayerMaskShape.linear,
          rotation: math.pi / 2,
        );

        final bounds = linear.outline(const Size(100, 100)).getBounds();

        expect(bounds.width, closeTo(0, 0.01));
        expect(bounds.center.dx, closeTo(50, 0.01));
      });
    });

    group('paint', () {
      const side = 100.0;

      /// Renders [mask] over a square layer and returns the alpha at each
      /// fraction of the layer in [points].
      Future<List<int>> alphasAt(
        WidgetTester tester,
        LayerMask mask,
        List<Offset> points,
      ) async {
        final bytes = (await tester.runAsync(() async {
          final image = await mask.toImage(const Size(side, side));
          final data = await image.toByteData();
          image.dispose();
          return data!.buffer.asUint8List();
        }))!;
        return [
          for (final point in points)
            bytes[(((point.dy * (side - 1)).round() * side.toInt()) +
                        (point.dx * (side - 1)).round()) *
                    4 +
                3],
        ];
      }

      const center = Offset(0.5, 0.5);
      const corner = Offset(0.02, 0.02);

      testWidgets('shows the layer inside an ellipse only', (tester) async {
        final alphas = await alphasAt(
          tester,
          const LayerMask(shape: LayerMaskShape.ellipse, size: Size(1, 1)),
          [center, corner],
        );

        expect(alphas, [255, 0]);
      });

      testWidgets('shows the layer outside an inverted ellipse', (
        tester,
      ) async {
        final alphas = await alphasAt(
          tester,
          const LayerMask(
            shape: LayerMaskShape.ellipse,
            size: Size(1, 1),
            invert: true,
          ),
          [center, corner],
        );

        expect(alphas, [0, 255]);
      });

      testWidgets('rounds the corners of a rectangle', (tester) async {
        Future<int> cornerAlpha(double cornerRadius) async => (await alphasAt(
          tester,
          LayerMask(
            shape: LayerMaskShape.rectangle,
            size: const Size(1, 1),
            cornerRadius: cornerRadius,
          ),
          [corner],
        )).single;

        expect(await cornerAlpha(0), 255);
        expect(await cornerAlpha(1), 0);
      });

      testWidgets('cuts a heart with its dip at the top', (tester) async {
        final alphas = await alphasAt(
          tester,
          const LayerMask(shape: LayerMaskShape.heart, size: Size(1, 1)),
          [
            const Offset(0.5, 0.55),
            const Offset(0.5, 0.03),
            const Offset(0.25, 0.1),
            const Offset(0.05, 0.95),
          ],
        );

        expect(alphas, [255, 0, 255, 0]);
      });

      for (final (shape, shown, hidden) in [
        (
          LayerMaskShape.star,
          const [Offset(0.5, 0.5), Offset(0.5, 0.06), Offset(0.95, 0.39)],
          const [Offset(0.5, 0.97), Offset(0.85, 0.15), Offset(0.02, 0.8)],
        ),
        (
          LayerMaskShape.triangle,
          const [Offset(0.5, 0.1), Offset(0.05, 0.97), Offset(0.95, 0.97)],
          const [Offset(0.15, 0.15), Offset(0.85, 0.15)],
        ),
        (
          LayerMaskShape.diamond,
          const [Offset(0.5, 0.05), Offset(0.95, 0.5), Offset(0.5, 0.5)],
          const [Offset(0.2, 0.2), Offset(0.8, 0.8), corner],
        ),
        (
          LayerMaskShape.hexagon,
          const [Offset(0.5, 0.05), Offset(0.03, 0.5), Offset(0.97, 0.5)],
          const [Offset(0.1, 0.1), Offset(0.9, 0.9), corner],
        ),
        (
          LayerMaskShape.speechBubble,
          const [Offset(0.5, 0.4), Offset(0.03, 0.4), Offset(0.2, 0.9)],
          const [Offset(0.8, 0.9), Offset(0.05, 0.9), corner],
        ),
      ]) {
        testWidgets('cuts a ${shape.name} filling its box', (tester) async {
          final alphas = await alphasAt(
            tester,
            LayerMask(shape: shape, size: const Size(1, 1)),
            [...shown, ...hidden],
          );

          expect(alphas, [
            for (final _ in shown) 255,
            for (final _ in hidden) 0,
          ]);
        });
      }

      for (final (size, shown, hidden) in [
        (
          const Size(-1, 1),
          const [Offset(0.5, 0.4), Offset(0.97, 0.4), Offset(0.8, 0.9)],
          const [Offset(0.2, 0.9), corner, Offset(0.98, 0.02)],
        ),
        (
          const Size(1, -1),
          const [Offset(0.5, 0.6), Offset(0.03, 0.6), Offset(0.2, 0.1)],
          const [Offset(0.8, 0.1), Offset(0.02, 0.98), Offset(0.98, 0.98)],
        ),
      ]) {
        testWidgets('mirrors a speech bubble in a box of size $size', (
          tester,
        ) async {
          final alphas = await alphasAt(
            tester,
            LayerMask(shape: LayerMaskShape.speechBubble, size: size),
            [...shown, ...hidden],
          );

          expect(alphas, [
            for (final _ in shown) 255,
            for (final _ in hidden) 0,
          ]);
        });
      }

      testWidgets('shows the layer above an unturned linear edge', (
        tester,
      ) async {
        final alphas = await alphasAt(
          tester,
          const LayerMask(shape: LayerMaskShape.linear),
          [const Offset(0.5, 0.2), const Offset(0.5, 0.8)],
        );

        expect(alphas, [255, 0]);
      });

      testWidgets('turns a linear edge with the rotation', (tester) async {
        final alphas = await alphasAt(
          tester,
          const LayerMask(shape: LayerMaskShape.linear, rotation: math.pi),
          [const Offset(0.5, 0.2), const Offset(0.5, 0.8)],
        );

        expect(alphas, [0, 255]);
      });

      testWidgets('fades a feathered linear edge over its width', (
        tester,
      ) async {
        final alphas = await alphasAt(
          tester,
          const LayerMask(shape: LayerMaskShape.linear, feather: 0.5),
          [
            const Offset(0.5, 0.2),
            const Offset(0.5, 0.4),
            const Offset(0.5, 0.6),
            const Offset(0.5, 0.8),
          ],
        );

        expect(alphas.first, 255);
        expect(alphas[1], allOf(greaterThan(128), lessThan(255)));
        expect(alphas[2], allOf(greaterThan(0), lessThan(128)));
        expect(alphas.last, 0);
      });

      testWidgets('softens the edge of a feathered shape', (tester) async {
        const edge = Offset(0.5, 0.25);
        Future<int> edgeAlpha(double feather) async => (await alphasAt(
          tester,
          LayerMask(shape: LayerMaskShape.ellipse, feather: feather),
          [edge],
        )).single;

        expect(await edgeAlpha(0.2), allOf(greaterThan(20), lessThan(235)));
      });

      testWidgets('turns a shape around its centre', (tester) async {
        // A wide bar covers the point left of the centre until it is turned
        // upright.
        const bar = LayerMask(
          shape: LayerMaskShape.rectangle,
          size: Size(0.9, 0.2),
        );
        const left = Offset(0.15, 0.5);

        expect(await alphasAt(tester, bar, [left]), [255]);
        expect(
          await alphasAt(tester, bar.copyWith(rotation: math.pi / 2), [left]),
          [0],
        );
      });
    });

    for (final feather in [0.0, 0.5]) {
      testWidgets('crosses the whole layer with a '
          '${feather > 0 ? 'feathered' : 'hard'} linear edge centred outside '
          'it', (tester) async {
        // A wide, short layer with the edge's centre far to its right: an
        // edge that reached only as far as the layer is wide and high would
        // stop short of its left end.
        const layerSize = Size(200, 20);
        final bytes = (await tester.runAsync(() async {
          final image = await LayerMask(
            shape: LayerMaskShape.linear,
            center: const Offset(2, 0.5),
            feather: feather,
          ).toImage(layerSize);
          final data = await image.toByteData();
          image.dispose();
          return data!.buffer.asUint8List();
        }))!;

        int alphaAt(int x, int y) => bytes[(y * 200 + x) * 4 + 3];
        expect(alphaAt(5, 1), 255);
        expect(alphaAt(195, 1), 255);
        expect(alphaAt(5, 18), 0);
      });
    }

    testWidgets('fills the last row and column of an image rounded up to '
        'whole pixels', (tester) async {
      // 10.5 logical pixels become an 11-pixel image. An inverted mask hides
      // its corner fully; a half-covered last pixel would show the layer
      // through as a thin line along the edge.
      final bytes = (await tester.runAsync(() async {
        final image = await const LayerMask(
          shape: LayerMaskShape.ellipse,
          size: Size(0.2, 0.2),
          invert: true,
        ).toImage(const Size(10.5, 10.5));
        final data = await image.toByteData();
        expect(image.width, 11);
        image.dispose();
        return data!.buffer.asUint8List();
      }))!;

      expect(bytes[(10 * 11 + 10) * 4 + 3], 255);
      expect(bytes[(10 * 11 + 5) * 4 + 3], 255);
    });

    testWidgets('applyTo keeps the image only inside the shape', (
      tester,
    ) async {
      final bytes = (await tester.runAsync(() async {
        final recorder = ui.PictureRecorder();
        Canvas(recorder).drawColor(const Color(0xFFFF0000), BlendMode.src);
        final picture = recorder.endRecording();
        final solid = await picture.toImage(40, 40);
        picture.dispose();

        final masked = await const LayerMask(
          shape: LayerMaskShape.ellipse,
          size: Size(1, 1),
        ).applyTo(solid);
        solid.dispose();
        final data = await masked.toByteData();
        masked.dispose();
        return data!.buffer.asUint8List();
      }))!;

      Uint8List pixel(int x, int y) =>
          bytes.sublist((y * 40 + x) * 4, (y * 40 + x) * 4 + 4);
      expect(pixel(20, 20), [255, 0, 0, 255]);
      expect(pixel(1, 1)[3], 0);
    });
  });

  group(LayerMaskBox, () {
    const boundaryKey = ValueKey('mask-box-boundary');
    const side = 20.0;

    /// Paints a red square of [side] logical pixels through [mask] on a
    /// screen of pixel ratio 1.
    Future<void> pumpMasked(WidgetTester tester, LayerMask? mask) {
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetDevicePixelRatio);
      return tester.pumpWidget(
        Center(
          child: RepaintBoundary(
            key: boundaryKey,
            child: LayerMaskBox(
              mask: mask,
              child: const ColoredBox(
                color: Color(0xFFFF0000),
                child: SizedBox.square(dimension: side),
              ),
            ),
          ),
        ),
      );
    }

    /// Captures the masked square at [pixelRatio] and returns the alpha at
    /// each logical point in [points].
    Future<List<int>> alphasAt(
      WidgetTester tester,
      List<Offset> points, {
      double pixelRatio = 1,
    }) async {
      final boundary = tester.renderObject<RenderRepaintBoundary>(
        find.byKey(boundaryKey),
      );
      final bytes = (await tester.runAsync(() async {
        final image = await boundary.toImage(pixelRatio: pixelRatio);
        final data = await image.toByteData();
        image.dispose();
        return data!.buffer.asUint8List();
      }))!;
      final width = (side * pixelRatio).round();
      return [
        for (final point in points)
          bytes[((point.dy * pixelRatio).floor() * width +
                      (point.dx * pixelRatio).floor()) *
                  4 +
              3],
      ];
    }

    const circle = LayerMask(shape: LayerMaskShape.ellipse, size: Size(1, 1));
    const center = Offset(side / 2, side / 2);
    const corner = Offset(0.5, 0.5);

    testWidgets('keeps a hard edge sharp in a capture sharper than the '
        'screen', (tester) async {
      await pumpMasked(tester, circle);

      // A fifth of a logical pixel inside the circle's top-left edge: a
      // mask rendered for the screen and stretched over the capture would
      // leave it partly transparent.
      final alphas = await alphasAt(tester, [
        const Offset(3.1, 3.1),
        center,
        corner,
      ], pixelRatio: 8);

      expect(alphas, [255, 255, 0]);
    });

    testWidgets('fades the child out across a feathered edge', (tester) async {
      await pumpMasked(tester, circle.copyWith(feather: 0.2));

      final alphas = await alphasAt(tester, [
        center,
        const Offset(1, side / 2),
        corner,
      ]);

      expect(alphas.first, 255);
      expect(alphas[1], allOf(greaterThan(0), lessThan(255)));
      expect(alphas.last, lessThan(alphas[1]));
    });

    testWidgets('switches between a hard edge, a soft one and none', (
      tester,
    ) async {
      final inverted = circle.copyWith(invert: true);
      for (final (mask, expected) in [
        (inverted, [0, 255]),
        (inverted.copyWith(feather: 0.05), [0, 255]),
        (circle, [255, 0]),
        (null, [255, 255]),
        (circle.copyWith(feather: 0.05), [255, 0]),
      ]) {
        await pumpMasked(tester, mask);

        expect(
          await alphasAt(tester, [center, corner]),
          expected,
          reason: '$mask',
        );
      }
    });
  });

  group('$LayerMaskBox with keyframes', () {
    const boundaryKey = ValueKey('timed-mask-box-boundary');
    const side = 20.0;

    /// A circle on the left half of the square at 0 that moves to its right
    /// half at 1 s.
    final moving =
        const LayerMask(
          shape: LayerMaskShape.ellipse,
          size: Size(0.5, 0.5),
        ).withKeyframes(const [
          LayerMaskKeyframe(
            time: Duration.zero,
            center: Offset(0.25, 0.5),
            size: Size(0.5, 0.5),
          ),
          LayerMaskKeyframe(
            time: Duration(seconds: 1),
            center: Offset(0.75, 0.5),
            size: Size(0.5, 0.5),
          ),
        ]);

    Future<void> pumpMasked(
      WidgetTester tester, {
      ValueListenable<Duration>? playTime,
      Duration keyframeOrigin = Duration.zero,
      double feather = 0,
    }) {
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetDevicePixelRatio);
      final mask = feather == 0
          ? moving
          : moving.withKeyframes([
              for (final keyframe in moving.keyframes)
                keyframe.copyWith(feather: feather),
            ]);
      return tester.pumpWidget(
        Center(
          child: RepaintBoundary(
            key: boundaryKey,
            child: LayerMaskBox(
              mask: mask,
              playTime: playTime,
              keyframeOrigin: keyframeOrigin,
              child: const ColoredBox(
                color: Color(0xFFFF0000),
                child: SizedBox.square(dimension: side),
              ),
            ),
          ),
        ),
      );
    }

    /// The alpha of the masked square at its left and right quarter points.
    Future<(int, int)> leftAndRightAlpha(WidgetTester tester) async {
      final boundary = tester.renderObject<RenderRepaintBoundary>(
        find.byKey(boundaryKey),
      );
      final bytes = (await tester.runAsync(() async {
        final image = await boundary.toImage();
        final data = await image.toByteData();
        image.dispose();
        return data!.buffer.asUint8List();
      }))!;
      int alphaAt(double x) =>
          bytes[((side ~/ 2) * side.toInt() + x.floor()) * 4 + 3];
      return (alphaAt(side / 4), alphaAt(side * 3 / 4));
    }

    testWidgets('moves the shape as the play time moves', (tester) async {
      final playTime = ValueNotifier(Duration.zero);
      addTearDown(playTime.dispose);
      await pumpMasked(tester, playTime: playTime);

      expect(await leftAndRightAlpha(tester), (255, 0));

      playTime.value = const Duration(seconds: 1);
      await tester.pump();

      expect(await leftAndRightAlpha(tester), (0, 255));
    });

    testWidgets('moves a soft shape as the play time moves', (tester) async {
      final playTime = ValueNotifier(Duration.zero);
      addTearDown(playTime.dispose);
      await pumpMasked(tester, playTime: playTime, feather: 0.05);

      final (startLeft, startRight) = await leftAndRightAlpha(tester);
      expect(startLeft, greaterThan(startRight));

      playTime.value = const Duration(seconds: 1);
      await tester.pump();

      final (endLeft, endRight) = await leftAndRightAlpha(tester);
      expect(endRight, greaterThan(endLeft));
    });

    testWidgets('reads the keyframes from the origin on', (tester) async {
      final playTime = ValueNotifier(const Duration(seconds: 1));
      addTearDown(playTime.dispose);
      await pumpMasked(
        tester,
        playTime: playTime,
        keyframeOrigin: const Duration(seconds: 1),
      );

      expect(await leftAndRightAlpha(tester), (255, 0));
    });

    testWidgets('shows the mask at its start without a play time', (
      tester,
    ) async {
      await pumpMasked(tester);

      expect(await leftAndRightAlpha(tester), (255, 0));
    });
  });

  group('Layer.mask', () {
    const mask = LayerMask(shape: LayerMaskShape.heart, feather: 0.05);

    test('is written by toMap and read by Layer.fromMap', () {
      final layer = TextLayer(text: 'masked', mask: mask);

      final read = Layer.fromMap(layer.toMap());

      expect(read, isA<TextLayer>());
      expect(read.mask, mask);
    });

    test('toMapFromReference writes a removed mask as null', () {
      final masked = EmojiLayer(emoji: '😀', mask: mask);
      final plain = masked.copyWith()..mask = null;

      expect(plain.toMapFromReference(masked), containsPair('mask', null));
      expect(masked.toMapFromReference(plain)['mask'], mask.toMap());
      expect(masked.toMapFromReference(masked), isNot(contains('mask')));
    });

    test('every layer type keeps it through copyWith', () {
      final layers = <Layer>[
        Layer(mask: mask),
        TextLayer(text: 'a', mask: mask),
        EmojiLayer(emoji: '😀', mask: mask),
        WidgetLayer(widget: const SizedBox(), mask: mask),
        PaintLayer(
          item: PaintedModel(
            mode: PaintMode.freeStyle,
            offsets: const [Offset.zero, Offset(10, 10)],
            erasedOffsets: const [],
            color: const Color(0xFF000000),
            strokeWidth: 2,
            opacity: 1,
          ),
          rawSize: const Size(10, 10),
          opacity: 1,
          mask: mask,
        ),
      ];

      for (final layer in layers) {
        expect(layer.copyWith().mask, mask, reason: '${layer.runtimeType}');
      }
    });
  });

  group('$LayerMask keyframes', () {
    const mask = LayerMask(
      shape: LayerMaskShape.rectangle,
      center: Offset(0.5, 0.5),
      size: Size(0.4, 0.4),
      cornerRadius: 0.3,
      invert: true,
    );
    const first = LayerMaskKeyframe(
      time: Duration(seconds: 1),
      center: Offset(0.2, 0.2),
      size: Size(0.2, 0.2),
      curve: AnimationCurve.easeOut,
    );
    const second = LayerMaskKeyframe(
      time: Duration(seconds: 3),
      center: Offset(0.8, 0.8),
      size: Size(0.6, 0.6),
      rotation: 1,
      feather: 0.2,
    );
    final keyframed = mask.withKeyframes(const [second, first]);

    test('withKeyframes sorts the keyframes', () {
      expect(keyframed.keyframes, [first, second]);
      expect(keyframed.hasKeyframes, isTrue);
      expect(mask.hasKeyframes, isFalse);
    });

    test('are written by toMap and read by fromMap, sorted', () {
      final map = keyframed.toMap();
      map['keyframes'] = (map['keyframes'] as List).reversed.toList();

      expect(LayerMask.fromMap(map), keyframed);
      expect(mask.toMap(), isNot(contains('keyframes')));
    });

    test('count for equality', () {
      expect(keyframed, isNot(mask));
      expect(keyframed, mask.withKeyframes(const [first, second]));
      expect(
        keyframed.hashCode,
        mask.withKeyframes(const [first, second]).hashCode,
      );
      expect(keyframed.still, mask);
    });

    test('copyWith keeps them unless given and sorts what it is given', () {
      expect(keyframed.copyWith(invert: false).keyframes, [first, second]);
      expect(mask.copyWith(keyframes: const [second, first]), keyframed);
    });

    test('at gives the still mask the keyframes make there', () {
      final atStart = keyframed.at(Duration.zero);
      expect(atStart.hasKeyframes, isFalse);
      expect(atStart.center, first.center);
      expect(atStart.size, first.size);
      expect(atStart.shape, mask.shape);
      expect(atStart.cornerRadius, mask.cornerRadius);
      expect(atStart.invert, isTrue);

      final atEnd = keyframed.at(const Duration(seconds: 5));
      expect(atEnd.center, second.center);
      expect(atEnd.rotation, second.rotation);
      expect(atEnd.feather, second.feather);

      expect(mask.at(const Duration(seconds: 2)), same(mask));
    });

    test('keyframeIndexAt finds the nearest keyframe within the tolerance', () {
      expect(keyframed.keyframeIndexAt(const Duration(milliseconds: 1005)), 0);
      expect(keyframed.keyframeIndexAt(const Duration(milliseconds: 1100)), -1);
      expect(
        keyframed.keyframeIndexAt(
          const Duration(milliseconds: 1100),
          tolerance: const Duration(milliseconds: 200),
        ),
        0,
      );
    });

    group('withKeyframeAt', () {
      const shown = LayerMask(
        shape: LayerMaskShape.rectangle,
        center: Offset(0.4, 0.6),
        size: Size(0.3, 0.5),
        rotation: 0.25,
        feather: 0.1,
        cornerRadius: 0.3,
        invert: true,
      );

      test('replaces the keyframe there, keeping its time and curve', () {
        final updated = keyframed.withKeyframeAt(
          const Duration(milliseconds: 1004),
          geometry: shown,
        );

        expect(updated.keyframes, [first.withGeometryOf(shown), second]);
      });

      test('adds one with the curve of the keyframe before it', () {
        final updated = keyframed.withKeyframeAt(
          const Duration(seconds: 2),
          geometry: shown,
        );

        expect(updated.keyframes, hasLength(3));
        expect(
          updated.keyframes[1],
          LayerMaskKeyframe.fromMask(
            shown,
            time: const Duration(seconds: 2),
            curve: first.curve,
          ),
        );
      });

      test('takes the curve it is given', () {
        final updated = keyframed.withKeyframeAt(
          const Duration(seconds: 1),
          curve: AnimationCurve.bounceIn,
        );

        expect(updated.keyframes.first.curve, AnimationCurve.bounceIn);
      });

      test('holds the mask itself when no geometry is given', () {
        final updated = mask.withKeyframeAt(Duration.zero);

        expect(updated.keyframes, [
          LayerMaskKeyframe.fromMask(mask, time: Duration.zero),
        ]);
        expect(updated.still, mask);
      });

      test('takes over the shape, corners and inversion of the geometry', () {
        final updated = keyframed.withKeyframeAt(
          const Duration(seconds: 1),
          geometry: shown.copyWith(shape: LayerMaskShape.heart, invert: false),
        );

        expect(updated.shape, LayerMaskShape.heart);
        expect(updated.invert, isFalse);
        expect(updated.keyframes, hasLength(2));
      });
    });

    group('withoutKeyframeAt', () {
      test('removes the keyframe there', () {
        expect(
          keyframed.withoutKeyframeAt(const Duration(seconds: 3)).keyframes,
          [first],
        );
      });

      test('returns the mask itself when there is none there', () {
        expect(
          keyframed.withoutKeyframeAt(const Duration(seconds: 2)),
          same(keyframed),
        );
      });

      test('leaves the mask as it showed when the last one goes', () {
        final single = mask.withKeyframes(const [second]);

        final removed = single.withoutKeyframeAt(const Duration(seconds: 3));

        expect(removed.hasKeyframes, isFalse);
        expect(removed.center, second.center);
        expect(removed.size, second.size);
        expect(removed.rotation, second.rotation);
        expect(removed.feather, second.feather);
        expect(removed.invert, isTrue);
      });
    });

    test('Layer.maskAt reads them from the layer\'s start on', () {
      final layer = Layer(
        startTime: const Duration(seconds: 2),
        mask: keyframed,
      );

      expect(
        layer.maskAt(const Duration(seconds: 3)),
        keyframed.at(const Duration(seconds: 1)),
      );
      expect(Layer().maskAt(Duration.zero), isNull);
    });

    test('a history step that drops them does not bring them back', () {
      final previous = EmojiLayer(emoji: '😀', mask: keyframed);
      final current = previous.copyWith()..mask = keyframed.still;

      // The import merges a step's diff over the layer of the step before.
      final merged = Layer.fromMap({
        ...previous.toMap(),
        ...current.toMapFromReference(previous),
      });

      expect(merged.mask, keyframed.still);
    });

    test('Layer.fromMap reads them back', () {
      final layer = TextLayer(text: 'masked', mask: keyframed);

      expect(Layer.fromMap(layer.toMap()).mask, keyframed);
    });
  });
}
