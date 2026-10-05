import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:pro_image_editor/features/text_editor/utils/rounded_background_painter.dart';
import 'package:pro_image_editor/features/text_editor/widgets/rounded_background_text/rounded_background_text.dart';
import 'package:pro_image_editor/pro_image_editor.dart';
import 'package:pro_image_editor/shared/widgets/layer/layer_widget.dart';

void main() {
  group('Text layer highlights', () {
    const highlightColor = Color(0xFFFFD60A);

    late ValueNotifier<Duration> playTime;

    setUp(() => playTime = ValueNotifier(Duration.zero));
    tearDown(() => playTime.dispose());

    TextLayer buildLayer() => TextLayer(
      text: 'Hello world',
      color: const Color(0xFFFFFFFF),
      background: const Color(0xFF0000FF),
      startTime: const Duration(seconds: 1),
      endTime: const Duration(seconds: 3),
      highlights: const [
        TextHighlight(
          start: 0,
          end: 5,
          startTime: Duration.zero,
          endTime: Duration(milliseconds: 500),
        ),
        TextHighlight(
          start: 6,
          end: 11,
          startTime: Duration(milliseconds: 500),
          endTime: Duration(seconds: 1),
        ),
      ],
      highlightColor: highlightColor,
    );

    Future<void> pumpLayer(
      WidgetTester tester,
      TextLayer layer, {
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

    /// The text painted in [highlightColor], or `null` when no part is.
    String? highlightedText(WidgetTester tester) {
      final customPaint = tester.widget<CustomPaint>(
        find.byWidgetPredicate(
          (widget) =>
              widget is CustomPaint &&
              widget.painter is RoundedBackgroundTextPainter,
        ),
      );
      final painter = customPaint.painter! as RoundedBackgroundTextPainter;
      String? highlighted;
      painter.painter.text!.visitChildren((span) {
        if (span is TextSpan && span.style?.color == highlightColor) {
          highlighted = span.text;
          return false;
        }
        return true;
      });
      return highlighted;
    }

    group('preview', () {
      testWidgets('highlights the word the playback position is on', (
        tester,
      ) async {
        await pumpLayer(tester, buildLayer(), playTimeNotifier: playTime);

        playTime.value = const Duration(milliseconds: 1200);
        await tester.pump();
        expect(highlightedText(tester), 'Hello');

        playTime.value = const Duration(milliseconds: 1700);
        await tester.pump();
        expect(highlightedText(tester), 'world');

        playTime.value = const Duration(milliseconds: 2500);
        await tester.pump();
        expect(highlightedText(tester), isNull);
      });

      testWidgets('highlights nothing without a playback position', (
        tester,
      ) async {
        await pumpLayer(tester, buildLayer());

        expect(highlightedText(tester), isNull);
      });
    });

    group('captureAllLayers', () {
      /// The image size and the mean x of the pixels in [highlightColor], or
      /// `null` for the mean when there are none.
      Future<({Size size, double? highlightCenterX})> inspect(
        Uint8List bytes,
      ) async {
        final codec = await ui.instantiateImageCodec(bytes);
        final image = (await codec.getNextFrame()).image;
        final data = (await image.toByteData())!;
        var count = 0;
        var sumX = 0;
        for (var i = 0; i < data.lengthInBytes; i += 4) {
          if (data.getUint8(i) == 0xFF &&
              data.getUint8(i + 1) == 0xD6 &&
              data.getUint8(i + 2) == 0x0A) {
            count++;
            sumX += (i ~/ 4) % image.width;
          }
        }
        final size = Size(image.width.toDouble(), image.height.toDouble());
        image.dispose();
        codec.dispose();
        return (size: size, highlightCenterX: count == 0 ? null : sumX / count);
      }

      testWidgets(
        'captures the base without a highlight and each word lit on its own',
        (tester) async {
          final layer = buildLayer();
          await pumpLayer(tester, layer, playTimeNotifier: playTime);
          // The screen shows "Hello" lit; the base capture must not.
          playTime.value = const Duration(milliseconds: 1200);
          await tester.pump();

          await tester.runAsync(() async {
            final exported = await Layer.captureAllLayers(
              layers: [layer],
              pixelRatio: 1,
              applyTransforms: false,
            );

            expect(exported, hasLength(1));
            final result = exported.single;
            expect(result.highlightBytes.keys, [0, 1]);

            final base = await inspect(result.bytes);
            final hello = await inspect(result.highlightBytes[0]!);
            final world = await inspect(result.highlightBytes[1]!);

            expect(base.highlightCenterX, isNull);
            expect(hello.size, base.size);
            expect(world.size, base.size);
            expect(hello.highlightCenterX, lessThan(base.size.width / 2));
            expect(world.highlightCenterX, greaterThan(base.size.width / 2));
          });
        },
      );

      testWidgets('renders the base exactly as the screen paints it', (
        tester,
      ) async {
        // Captured from the on-screen boundary, since it has no highlights.
        final plain = buildLayer()..highlights = [];
        // Captured through the model renderer.
        final highlighted = buildLayer();
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Stack(
                children: [
                  for (final layer in [plain, highlighted])
                    LayerWidget(
                      editorBodySize: const Size(400, 400),
                      layer: layer,
                      configs: const ProImageEditorConfigs(),
                    ),
                ],
              ),
            ),
          ),
        );

        await tester.runAsync(() async {
          final exported = await Layer.captureAllLayers(
            layers: [plain, highlighted],
            pixelRatio: 2,
            applyTransforms: false,
          );

          Future<Uint8List> pixels(Uint8List png) async {
            final codec = await ui.instantiateImageCodec(png);
            final image = (await codec.getNextFrame()).image;
            final data = await image.toByteData();
            image.dispose();
            codec.dispose();
            return data!.buffer.asUint8List();
          }

          expect(exported[1].highlightBytes, isNotEmpty);
          expect(
            await pixels(exported[1].bytes),
            await pixels(exported[0].bytes),
          );
        });
      });

      testWidgets('renders a wrapped base exactly as the screen paints it', (
        tester,
      ) async {
        // Fits on one line when centered, but sits near the right edge, so it
        // has to wrap to stay inside.
        TextLayer buildWrappedLayer() =>
            buildLayer()..offset = const Offset(120, 0);
        final plain = buildWrappedLayer()..highlights = [];
        final highlighted = buildWrappedLayer();
        final configs = ProImageEditorConfigs(
          textEditor: TextEditorConfigs(
            layerBounds: (editorBodySize) => Offset.zero & editorBodySize,
          ),
        );
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Stack(
                children: [
                  for (final layer in [plain, highlighted])
                    LayerWidget(
                      editorBodySize: const Size(400, 400),
                      layer: layer,
                      configs: configs,
                    ),
                ],
              ),
            ),
          ),
        );
        // 80 px from the right edge leaves room for 160 px.
        expect(
          tester.getSize(find.byType(RoundedBackgroundText).first).width,
          lessThanOrEqualTo(160),
        );

        await tester.runAsync(() async {
          final exported = await Layer.captureAllLayers(
            layers: [plain, highlighted],
            pixelRatio: 1,
            applyTransforms: false,
          );

          Future<Uint8List> pixels(Uint8List png) async {
            final codec = await ui.instantiateImageCodec(png);
            final image = (await codec.getNextFrame()).image;
            final data = await image.toByteData();
            image.dispose();
            codec.dispose();
            return data!.buffer.asUint8List();
          }

          expect(exported[1].highlightBytes, isNotEmpty);
          expect(
            await pixels(exported[1].bytes),
            await pixels(exported[0].bytes),
          );
        });
      });

      testWidgets('captures no highlight images for plain text', (
        tester,
      ) async {
        final layer = TextLayer(text: 'Hello world');
        await pumpLayer(tester, layer, playTimeNotifier: playTime);

        await tester.runAsync(() async {
          final exported = await Layer.captureAllLayers(
            layers: [layer],
            pixelRatio: 1,
            applyTransforms: false,
          );

          expect(exported.single.bytes, isNotEmpty);
          expect(exported.single.highlightBytes, isEmpty);
        });
      });
    });
  });
}
