import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:pro_image_editor/pro_image_editor.dart';
import 'package:pro_image_editor/shared/widgets/layer/layer_widget.dart';

void main() {
  group('Paint layer draw-on', () {
    late ValueNotifier<Duration> playTime;

    setUp(() => playTime = ValueNotifier(Duration.zero));
    tearDown(() => playTime.dispose());

    /// Two horizontal strokes, 100 and 300 long, drawing themselves over the
    /// first 400 ms of a 1 – 3 s layer: the pen covers one unit a
    /// millisecond.
    PaintLayer buildLayer() => PaintLayer(
      items: [
        PaintedModel(
          mode: PaintMode.freeStyle,
          offsets: const [Offset(10, 10), Offset(110, 10)],
          erasedOffsets: const [],
          color: const Color(0xFFFF0000),
          strokeWidth: 8,
          opacity: 1,
        ),
        PaintedModel(
          mode: PaintMode.freeStyle,
          offsets: const [Offset(10, 40), Offset(310, 40)],
          erasedOffsets: const [],
          color: const Color(0xFF0000FF),
          strokeWidth: 8,
          opacity: 1,
        ),
      ],
      rawSize: const Size(320, 50),
      opacity: 1,
      startTime: const Duration(seconds: 1),
      endTime: const Duration(seconds: 3),
      animations: const [
        LayerAnimation(
          type: LayerAnimationType.drawOn,
          phase: AnimationPhase.animateIn,
          duration: Duration(milliseconds: 400),
        ),
      ],
    );

    Future<void> pumpLayer(
      WidgetTester tester,
      PaintLayer layer, {
      ValueNotifier<Duration>? playTimeNotifier,
    }) {
      return tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Stack(
              children: [
                LayerWidget(
                  editorBodySize: const Size(400, 400),
                  layer: layer,
                  configs: const ProImageEditorConfigs(),
                  playTimeNotifier: playTimeNotifier,
                ),
              ],
            ),
          ),
        ),
      );
    }

    List<DrawPaintItem> painters(WidgetTester tester) => [
      for (final paint in tester.widgetList<CustomPaint>(
        find.byWidgetPredicate(
          (widget) => widget is CustomPaint && widget.painter is DrawPaintItem,
        ),
      ))
        paint.painter! as DrawPaintItem,
    ];

    group('preview', () {
      testWidgets('draws as far as the playback position has reached', (
        tester,
      ) async {
        await pumpLayer(tester, buildLayer(), playTimeNotifier: playTime);

        playTime.value = const Duration(milliseconds: 1050);
        await tester.pump();
        var [first, second] = painters(tester);
        expect(first.skipPaint, isFalse);
        expect(first.paintedItem!.offsets.last, const Offset(60, 10));
        expect(second.skipPaint, isTrue);

        playTime.value = const Duration(milliseconds: 1200);
        await tester.pump();
        [first, second] = painters(tester);
        expect(first.paintedItem, isNull);
        expect(second.paintedItem!.offsets.last, const Offset(110, 40));

        playTime.value = const Duration(milliseconds: 2000);
        await tester.pump();
        [first, second] = painters(tester);
        expect(first.paintedItem, isNull);
        expect(second.paintedItem, isNull);
        expect(second.skipPaint, isFalse);
      });

      testWidgets('hit-tests every stroke before it is drawn', (tester) async {
        await pumpLayer(tester, buildLayer(), playTimeNotifier: playTime);
        playTime.value = const Duration(milliseconds: 1050);
        await tester.pump();

        final second = painters(tester).last;
        expect(second.item.offsets.last, const Offset(310, 40));
      });

      testWidgets('shows the whole drawing without a playback position', (
        tester,
      ) async {
        await pumpLayer(tester, buildLayer());

        expect(painters(tester).map((painter) => painter.skipPaint), [
          false,
          false,
        ]);
        expect(painters(tester).map((painter) => painter.paintedItem), [
          null,
          null,
        ]);
      });
    });

    group('captureAllLayers', () {
      /// How many pixels of [bytes] are not transparent, and the image size.
      Future<({Size size, int opaque})> inspect(Uint8List bytes) async {
        final codec = await ui.instantiateImageCodec(bytes);
        final image = (await codec.getNextFrame()).image;
        final data = (await image.toByteData())!;
        var opaque = 0;
        for (var i = 3; i < data.lengthInBytes; i += 4) {
          if (data.getUint8(i) > 0) opaque++;
        }
        final size = Size(image.width.toDouble(), image.height.toDouble());
        image.dispose();
        codec.dispose();
        return (size: size, opaque: opaque);
      }

      testWidgets('captures the whole drawing and one image a frame', (
        tester,
      ) async {
        final layer = buildLayer();
        await pumpLayer(tester, layer, playTimeNotifier: playTime);
        // The screen shows part of the first stroke; the base capture must
        // show the whole drawing.
        playTime.value = const Duration(milliseconds: 1050);
        await tester.pump();

        await tester.runAsync(() async {
          final result = (await Layer.captureAllLayers(
            layers: [layer],
            pixelRatio: 1,
            applyTransforms: false,
            drawOnFrameRate: 10,
          )).single;

          expect(result.drawOnFrameRate, 10);
          expect(result.drawOnBytes.keys, [0.0, 0.25, 0.5, 0.75]);
          final base = await inspect(result.bytes);
          var previous = -1;
          for (final step in result.drawOnBytes.values) {
            final image = await inspect(step);
            expect(image.size, base.size);
            expect(image.opaque, greaterThan(previous));
            expect(image.opaque, lessThan(base.opaque));
            previous = image.opaque;
          }
          expect((await inspect(result.drawOnBytes[0]!)).opaque, 0);

          expect(
            [for (final frame in result.frames) frame.startTime],
            [
              const Duration(seconds: 1),
              const Duration(milliseconds: 1100),
              const Duration(milliseconds: 1200),
              const Duration(milliseconds: 1300),
              const Duration(milliseconds: 1400),
            ],
          );
          expect(identical(result.frames.last.bytes, result.bytes), isTrue);
        });
      });

      testWidgets('captures no steps for a drawing that does not draw itself', (
        tester,
      ) async {
        final layer = buildLayer()..animations = const [];
        await pumpLayer(tester, layer, playTimeNotifier: playTime);

        await tester.runAsync(() async {
          final result = (await Layer.captureAllLayers(
            layers: [layer],
            pixelRatio: 1,
            applyTransforms: false,
          )).single;

          expect(result.drawOnBytes, isEmpty);
          expect(result.frames, hasLength(1));
        });
      });
    });
  });
}
