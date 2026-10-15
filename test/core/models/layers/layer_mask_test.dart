import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

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
        final read = LayerMask.fromMap({...mask.toMap(), 'shape': 'star'});

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
}
