import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:pro_image_editor/core/models/layers/exported_layer.dart';
import 'package:pro_image_editor/core/models/layers/layer.dart';
import 'package:pro_image_editor/features/paint_editor/paint_editor.dart';

void main() {
  group('ExportedLayer', () {
    test('stores all constructor parameters', () {
      final layer = TextLayer(text: 'Hello');
      final bytes = Uint8List.fromList([1, 2, 3]);
      const size = Size(100, 50);

      final exported = ExportedLayer(
        layer: layer,
        bytes: bytes,
        logicalSize: size,
      );

      expect(exported.layer, same(layer));
      expect(exported.bytes, same(bytes));
      expect(exported.logicalSize, size);
    });

    test('works with EmojiLayer', () {
      final layer = EmojiLayer(emoji: '😀');
      final bytes = Uint8List.fromList([0x89, 0x50, 0x4E, 0x47]);
      const size = Size(48, 48);

      final exported = ExportedLayer(
        layer: layer,
        bytes: bytes,
        logicalSize: size,
      );

      expect(exported.layer, isA<EmojiLayer>());
      expect((exported.layer as EmojiLayer).emoji, '😀');
      expect(exported.bytes.length, 4);
      expect(exported.logicalSize.width, 48);
      expect(exported.logicalSize.height, 48);
    });

    test('works with PaintLayer', () {
      final item = PaintedModel(
        mode: PaintMode.freeStyle,
        offsets: [Offset.zero],
        erasedOffsets: [],
        color: const Color(0xFF000000),
        strokeWidth: 5,
        opacity: 1,
        fill: false,
      );
      final layer = PaintLayer(
        item: item,
        rawSize: const Size(200, 200),
        opacity: 1.0,
      );
      final bytes = Uint8List.fromList(List.filled(100, 0));
      const size = Size(200, 200);

      final exported = ExportedLayer(
        layer: layer,
        bytes: bytes,
        logicalSize: size,
      );

      expect(exported.layer, isA<PaintLayer>());
      expect(exported.bytes.length, 100);
      expect(exported.logicalSize, const Size(200, 200));
    });

    test('preserves Size.zero for unmounted layers', () {
      final layer = Layer();
      final bytes = Uint8List.fromList([0]);

      final exported = ExportedLayer(
        layer: layer,
        bytes: bytes,
        logicalSize: Size.zero,
      );

      expect(exported.logicalSize, Size.zero);
    });

    group('frames', () {
      final base = Uint8List.fromList([0]);
      final first = Uint8List.fromList([1]);
      final second = Uint8List.fromList([2]);

      Duration ms(int value) => Duration(milliseconds: value);

      TextHighlight highlight(int start, int end, int from, int to) =>
          TextHighlight(
            start: start,
            end: end,
            startTime: ms(from),
            endTime: ms(to),
          );

      /// Each frame as (the one byte identifying its image, start, end).
      List<(int, Duration?, Duration?)> describe(
        List<ExportedLayerFrame> frames,
      ) => [
        for (final frame in frames)
          (frame.bytes.single, frame.startTime, frame.endTime),
      ];

      test('is one frame of the base image for a layer without highlights', () {
        final exported = ExportedLayer(
          layer: EmojiLayer(emoji: '😀', startTime: ms(100), endTime: ms(500)),
          bytes: base,
          logicalSize: const Size(10, 10),
        );

        expect(describe(exported.frames), [(0, ms(100), ms(500))]);
      });

      test('shows each highlight in its window and the base in between', () {
        final exported = ExportedLayer(
          layer: TextLayer(
            text: 'Hello world',
            startTime: ms(1000),
            endTime: ms(3000),
            highlights: [
              highlight(0, 5, 200, 600),
              highlight(6, 11, 800, 1500),
            ],
          ),
          bytes: base,
          logicalSize: const Size(10, 10),
          highlightBytes: {0: first, 1: second},
        );

        expect(describe(exported.frames), [
          (0, ms(1000), ms(1200)),
          (1, ms(1200), ms(1600)),
          (0, ms(1600), ms(1800)),
          (2, ms(1800), ms(2500)),
          (0, ms(2500), ms(3000)),
        ]);
      });

      test('joins back-to-back highlights without a gap frame', () {
        final exported = ExportedLayer(
          layer: TextLayer(
            text: 'Hello world',
            startTime: ms(0),
            endTime: ms(1000),
            highlights: [highlight(0, 5, 0, 500), highlight(6, 11, 500, 1000)],
          ),
          bytes: base,
          logicalSize: const Size(10, 10),
          highlightBytes: {0: first, 1: second},
        );

        expect(describe(exported.frames), [
          (1, ms(0), ms(500)),
          (2, ms(500), ms(1000)),
        ]);
      });

      test('clips highlights to the layer range', () {
        final exported = ExportedLayer(
          layer: TextLayer(
            text: 'Hello world',
            startTime: ms(100),
            endTime: ms(600),
            highlights: [highlight(6, 11, 300, 900)],
          ),
          bytes: base,
          logicalSize: const Size(10, 10),
          highlightBytes: {0: first},
        );

        expect(describe(exported.frames), [
          (0, ms(100), ms(400)),
          (1, ms(400), ms(600)),
        ]);
      });

      test('keeps open ends when the layer has no time range', () {
        final exported = ExportedLayer(
          layer: TextLayer(
            text: 'Hello world',
            highlights: [highlight(0, 5, 200, 400)],
          ),
          bytes: base,
          logicalSize: const Size(10, 10),
          highlightBytes: {0: first},
        );

        expect(describe(exported.frames), [
          (0, null, ms(200)),
          (1, ms(200), ms(400)),
          (0, ms(400), null),
        ]);
      });

      test('starts with a highlight that starts with an open-ended layer', () {
        final exported = ExportedLayer(
          layer: TextLayer(
            text: 'Hello world',
            highlights: [highlight(0, 5, 0, 400)],
          ),
          bytes: base,
          logicalSize: const Size(10, 10),
          highlightBytes: {0: first},
        );

        expect(describe(exported.frames), [
          (1, null, ms(400)),
          (0, ms(400), null),
        ]);
      });

      test('falls back to the base image for an uncaptured highlight', () {
        final exported = ExportedLayer(
          layer: TextLayer(
            text: 'Hello world',
            startTime: ms(0),
            endTime: ms(1000),
            highlights: [highlight(0, 5, 0, 400), highlight(6, 11, 400, 800)],
          ),
          bytes: base,
          logicalSize: const Size(10, 10),
          highlightBytes: {0: first},
        );

        expect(describe(exported.frames), [
          (1, ms(0), ms(400)),
          (0, ms(400), ms(1000)),
        ]);
      });

      group('with a text reveal', () {
        final none = Uint8List.fromList([10]);
        final one = Uint8List.fromList([11]);
        final two = Uint8List.fromList([12]);

        TextLayer revealing(AnimationPhase phase, {Duration? end}) => TextLayer(
          text: 'Hi you',
          startTime: ms(1000),
          endTime: end ?? ms(3000),
          animations: [
            LayerAnimation(
              type: LayerAnimationType.wordByWord,
              phase: phase,
              duration: ms(1000),
            ),
          ],
        );

        test('steps through the words, then shows the base', () {
          final exported = ExportedLayer(
            layer: revealing(AnimationPhase.animateIn),
            bytes: base,
            logicalSize: const Size(10, 10),
            revealBytes: {
              const ExportedTextState(revealedLength: 0): none,
              const ExportedTextState(revealedLength: 2): one,
            },
          );

          expect(describe(exported.frames), [
            (10, ms(1000), ms(1001)),
            (11, ms(1001), ms(1501)),
            (0, ms(1501), ms(3000)),
          ]);
        });

        test('takes the words away at the end', () {
          final exported = ExportedLayer(
            layer: revealing(AnimationPhase.animateOut),
            bytes: base,
            logicalSize: const Size(10, 10),
            revealBytes: {
              const ExportedTextState(revealedLength: 0): none,
              const ExportedTextState(revealedLength: 2): one,
            },
          );

          expect(describe(exported.frames), [
            (0, ms(1000), ms(2500)),
            (11, ms(2500), ms(3000)),
          ]);
        });

        test('repeats a looping reveal for as long as the layer lasts', () {
          final exported = ExportedLayer(
            layer: revealing(AnimationPhase.loop, end: ms(3000)),
            bytes: base,
            logicalSize: const Size(10, 10),
            revealBytes: {
              const ExportedTextState(revealedLength: 0): none,
              const ExportedTextState(revealedLength: 2): one,
            },
          );

          // Each 1 s cycle: whole, then one word, none, one word, whole.
          final frames = describe(exported.frames);
          expect(frames.map((f) => f.$1), [
            0, 11, 10, 11, //
            0, 11, 10, 11, //
            0,
          ]);
          expect(frames.first.$2, ms(1000));
          expect(frames.last.$3, ms(3000));
        });

        test('combines the reveal with an active highlight', () {
          final exported = ExportedLayer(
            layer: revealing(AnimationPhase.animateIn)
              ..highlights = [highlight(0, 2, 0, 2000)],
            bytes: base,
            logicalSize: const Size(10, 10),
            highlightBytes: {0: first},
            revealBytes: {
              const ExportedTextState(revealedLength: 0, highlightIndex: 0):
                  none,
              const ExportedTextState(revealedLength: 2, highlightIndex: 0):
                  two,
            },
          );

          expect(describe(exported.frames), [
            (10, ms(1000), ms(1001)),
            (12, ms(1001), ms(1501)),
            (1, ms(1501), ms(3000)),
          ]);
        });

        test('shows the base for a looping reveal without an end', () {
          final exported = ExportedLayer(
            layer: TextLayer(
              text: 'Hi you',
              animations: [
                LayerAnimation(
                  type: LayerAnimationType.typewriter,
                  phase: AnimationPhase.loop,
                  duration: ms(1000),
                ),
              ],
            ),
            bytes: base,
            logicalSize: const Size(10, 10),
            revealBytes: {const ExportedTextState(revealedLength: 0): none},
          );

          expect(describe(exported.frames), [(0, null, null)]);
        });
      });
    });

    group('ExportedTextState', () {
      test('compares by value', () {
        expect(
          const ExportedTextState(revealedLength: 2, highlightIndex: 1),
          const ExportedTextState(revealedLength: 2, highlightIndex: 1),
        );
        expect(
          const ExportedTextState(revealedLength: 2),
          isNot(const ExportedTextState(revealedLength: 2, highlightIndex: 0)),
        );
      });
    });
  });
}
