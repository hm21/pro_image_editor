import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:pro_image_editor/features/text_editor/utils/rounded_background_painter.dart';
import 'package:pro_image_editor/features/text_editor/widgets/rounded_background_text/rounded_background_text.dart';
import 'package:pro_image_editor/pro_image_editor.dart';
import 'package:pro_image_editor/shared/widgets/layer/layer_widget.dart';

void main() {
  group('Text layer reveal', () {
    late ValueNotifier<Duration> playTime;

    setUp(() => playTime = ValueNotifier(Duration.zero));
    tearDown(() => playTime.dispose());

    /// "ab cd" typing itself out over the first second of a 1 – 3 s layer:
    /// four letters, a quarter second each.
    TextLayer buildLayer({
      double outlineWidth = 0,
      Color background = const Color(0x00000000),
    }) => TextLayer(
      text: 'ab cd',
      color: const Color(0xFFFFFFFF),
      background: background,
      colorMode: background.a == 0
          ? LayerBackgroundMode.onlyColor
          : LayerBackgroundMode.backgroundAndColor,
      outlineWidth: outlineWidth,
      outlineColor: const Color(0xFFFF0000),
      startTime: const Duration(seconds: 1),
      endTime: const Duration(seconds: 3),
      animations: const [
        LayerAnimation(
          type: LayerAnimationType.typewriter,
          phase: AnimationPhase.animateIn,
          duration: Duration(seconds: 1),
        ),
      ],
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

    RoundedBackgroundTextPainter painter(WidgetTester tester) {
      final customPaint = tester.widget<CustomPaint>(
        find.byWidgetPredicate(
          (widget) =>
              widget is CustomPaint &&
              widget.painter is RoundedBackgroundTextPainter,
        ),
      );
      return customPaint.painter! as RoundedBackgroundTextPainter;
    }

    /// The part of [span] that paints with a visible foreground or color.
    String visibleText(InlineSpan span) {
      final visible = StringBuffer();
      void visit(InlineSpan span, TextStyle? inherited) {
        if (span is! TextSpan) return;
        final style = inherited?.merge(span.style) ?? span.style;
        final hidden = style?.foreground?.color.a == 0;
        if (!hidden) visible.write(span.text ?? '');
        for (final child in span.children ?? const <InlineSpan>[]) {
          visit(child, style);
        }
      }

      visit(span, null);
      return visible.toString();
    }

    group('preview', () {
      testWidgets('shows the letters the playback position has reached', (
        tester,
      ) async {
        await pumpLayer(tester, buildLayer(), playTimeNotifier: playTime);

        playTime.value = const Duration(milliseconds: 1100);
        await tester.pump();
        expect(visibleText(painter(tester).painter.text!), 'a');

        playTime.value = const Duration(milliseconds: 1600);
        await tester.pump();
        expect(visibleText(painter(tester).painter.text!), 'ab c');

        playTime.value = const Duration(milliseconds: 2500);
        await tester.pump();
        expect(visibleText(painter(tester).painter.text!), 'ab cd');
      });

      testWidgets('keeps the size of the whole text while typing', (
        tester,
      ) async {
        await pumpLayer(tester, buildLayer(), playTimeNotifier: playTime);
        playTime.value = const Duration(milliseconds: 2500);
        await tester.pump();
        final whole = tester.getSize(find.byType(RoundedBackgroundText));

        playTime.value = const Duration(milliseconds: 1100);
        await tester.pump();
        expect(tester.getSize(find.byType(RoundedBackgroundText)), whole);
      });

      testWidgets('hides the outline of letters not typed yet', (tester) async {
        await pumpLayer(
          tester,
          buildLayer(outlineWidth: 2),
          playTimeNotifier: playTime,
        );
        playTime.value = const Duration(milliseconds: 1100);
        await tester.pump();

        expect(visibleText(painter(tester).outlinePainter!.text!), 'a');
      });

      testWidgets('can be picked before any of its text has appeared', (
        tester,
      ) async {
        await pumpLayer(
          tester,
          buildLayer(background: const Color(0xFF0000FF)),
          playTimeNotifier: playTime,
        );
        playTime.value = const Duration(milliseconds: 1100);
        await tester.pump();

        final size = tester.getSize(find.byType(RoundedBackgroundText));
        expect(painter(tester).hitTest(size.center(Offset.zero)), isTrue);
      });

      testWidgets('shows the whole text without a playback position', (
        tester,
      ) async {
        await pumpLayer(tester, buildLayer());

        expect(visibleText(painter(tester).painter.text!), 'ab cd');
      });
    });

    group('captureAllLayers', () {
      /// The image size and how many of its pixels are not transparent.
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

      testWidgets('captures the whole text as the base and one image a step', (
        tester,
      ) async {
        final layer = buildLayer(outlineWidth: 2);
        await pumpLayer(tester, layer, playTimeNotifier: playTime);
        // The screen shows "a"; the base capture must show everything.
        playTime.value = const Duration(milliseconds: 1100);
        await tester.pump();

        await tester.runAsync(() async {
          final exported = await Layer.captureAllLayers(
            layers: [layer],
            pixelRatio: 1,
            applyTransforms: false,
          );
          final result = exported.single;

          expect(result.revealBytes.keys.map((s) => s.revealedLength), [
            0,
            1,
            2,
            4,
          ]);
          final base = await inspect(result.bytes);
          var previous = -1;
          for (final length in [0, 1, 2, 4]) {
            final step = await inspect(
              result.revealBytes[ExportedTextState(revealedLength: length)]!,
            );
            expect(step.size, base.size);
            expect(step.opaque, greaterThan(previous));
            expect(step.opaque, lessThan(base.opaque));
            previous = step.opaque;
          }
          // Nothing typed yet: not even the outline shows.
          expect(
            (await inspect(
              result.revealBytes[const ExportedTextState(revealedLength: 0)]!,
            )).opaque,
            0,
          );

          expect(
            [
              for (final frame in result.frames)
                (frame.startTime, frame.endTime),
            ],
            [
              (const Duration(seconds: 1), const Duration(milliseconds: 1001)),
              (
                const Duration(milliseconds: 1001),
                const Duration(milliseconds: 1251),
              ),
              (
                const Duration(milliseconds: 1251),
                const Duration(milliseconds: 1501),
              ),
              (
                const Duration(milliseconds: 1501),
                const Duration(milliseconds: 1751),
              ),
              (const Duration(milliseconds: 1751), const Duration(seconds: 3)),
            ],
          );
          expect(identical(result.frames.last.bytes, result.bytes), isTrue);
        });
      });

      testWidgets('grows the background with the revealed text', (
        tester,
      ) async {
        final layer = buildLayer(background: const Color(0xFF0000FF));
        await pumpLayer(tester, layer, playTimeNotifier: playTime);

        await tester.runAsync(() async {
          final result = (await Layer.captureAllLayers(
            layers: [layer],
            pixelRatio: 1,
            applyTransforms: false,
          )).single;

          final base = await inspect(result.bytes);
          final none = await inspect(
            result.revealBytes[const ExportedTextState(revealedLength: 0)]!,
          );
          final two = await inspect(
            result.revealBytes[const ExportedTextState(revealedLength: 2)]!,
          );
          // Nothing typed: no background either. Two letters: a background
          // behind those, narrower than behind the whole text.
          expect(none.opaque, 0);
          expect(two.opaque, greaterThan(0));
          expect(two.opaque, lessThan(base.opaque));
          expect(two.size, base.size);
        });
      });

      testWidgets('captures no reveal images for text without a reveal', (
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

          expect(exported.single.revealBytes, isEmpty);
        });
      });
    });
  });
}
