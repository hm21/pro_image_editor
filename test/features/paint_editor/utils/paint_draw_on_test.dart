import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:pro_image_editor/core/models/editor_configs/paint_editor/paint_editor_configs.dart';
import 'package:pro_image_editor/features/paint_editor/enums/paint_editor_enum.dart';
import 'package:pro_image_editor/features/paint_editor/models/eraser_model.dart';
import 'package:pro_image_editor/features/paint_editor/utils/paint_draw_on.dart';

void main() {
  PaintedModel stroke(
    PaintMode mode,
    List<Offset?> offsets, {
    bool fill = false,
    List<ErasedOffset> erased = const [],
  }) => PaintedModel(
    mode: mode,
    offsets: offsets,
    erasedOffsets: erased,
    color: const Color(0xFFFF0000),
    strokeWidth: 4,
    opacity: 0.5,
    fill: fill,
  );

  group('paintStrokeLength', () {
    test('adds up the segments of a freehand stroke', () {
      final item = stroke(PaintMode.freeStyle, const [
        Offset(0, 0),
        Offset(30, 40),
        null,
        Offset(100, 0),
        Offset(100, 10),
      ]);

      expect(paintStrokeLength(item), 60);
    });

    test('measures a line between its ends', () {
      final item = stroke(PaintMode.arrow, const [Offset(0, 0), Offset(0, 25)]);

      expect(paintStrokeLength(item), 25);
    });

    test('measures the outline of a shape', () {
      final item = stroke(PaintMode.rect, const [Offset(0, 0), Offset(10, 20)]);

      expect(paintStrokeLength(item), closeTo(60, 1e-6));
    });

    test('measures again once the points are replaced', () {
      final item = stroke(PaintMode.freeStyle, const [
        Offset(0, 0),
        Offset(10, 0),
      ]);
      expect(paintStrokeLength(item), 10);

      item.offsets = const [Offset(0, 0), Offset(20, 0)];

      expect(paintStrokeLength(item), 20);
    });
  });

  group('drawnPaintStrokes', () {
    final first = stroke(PaintMode.freeStyle, const [
      Offset(0, 0),
      Offset(100, 0),
    ]);
    final second = stroke(PaintMode.freeStyle, const [
      Offset(0, 10),
      Offset(300, 10),
    ]);

    test('draws nothing at the start and everything at the end', () {
      expect(drawnPaintStrokes([first, second], 0), [null, null]);
      expect(drawnPaintStrokes([first, second], 1), [first, second]);
    });

    test('gives each stroke a share of the time that follows its length', () {
      // 100 of 400 drawn: exactly the first stroke.
      final quarter = drawnPaintStrokes([first, second], 0.25);
      expect(identical(quarter[0], first), isTrue);
      expect(quarter[1], isNull);

      // 200 of 400 drawn: the first stroke and a third of the second.
      final half = drawnPaintStrokes([first, second], 0.5);
      expect(identical(half[0], first), isTrue);
      expect(half[1]!.offsets, const [Offset(0, 10), Offset(100, 10)]);
    });

    test('cuts a freehand stroke where the pen is, in drawing order', () {
      final item = stroke(PaintMode.freeStyle, const [
        Offset(0, 0),
        Offset(10, 0),
        Offset(10, 10),
        null,
        Offset(50, 50),
        Offset(60, 50),
      ]);

      // 15 of 30: across the first segment and halfway down the second.
      expect(drawnPaintStrokes([item], 0.5).single!.offsets, const [
        Offset(0, 0),
        Offset(10, 0),
        Offset(10, 5),
      ]);
      // 20 of 30: the first part ends exactly; the second has not started,
      // so its first point does not show as a dot.
      expect(drawnPaintStrokes([item], 2 / 3).single!.offsets, const [
        Offset(0, 0),
        Offset(10, 0),
        Offset(10, 10),
      ]);
    });

    test('keeps the look and the erased spots of a cut stroke', () {
      final erased = [const ErasedOffset(offset: Offset(5, 0), radius: 2)];
      final item = stroke(PaintMode.freeStyleArrowEnd, const [
        Offset(0, 0),
        Offset(10, 0),
      ], erased: erased);

      final part = drawnPaintStrokes([item], 0.5).single!;

      expect(part.mode, PaintMode.freeStyleArrowEnd);
      expect(part.color, item.color);
      expect(part.strokeWidth, item.strokeWidth);
      expect(part.opacity, item.opacity);
      expect(part.erasedOffsets, erased);
    });

    test('grows a line from its start towards its end', () {
      final item = stroke(PaintMode.dashLine, const [
        Offset(0, 0),
        Offset(40, 0),
      ]);

      expect(drawnPaintStrokes([item], 0.25).single!.offsets, const [
        Offset(0, 0),
        Offset(10, 0),
      ]);
    });

    test('outlines a filled shape and fills it once the outline is done', () {
      final item = stroke(PaintMode.rect, const [
        Offset(0, 0),
        Offset(10, 10),
      ], fill: true);

      final part = drawnPaintStrokes([item], 0.5).single!;

      expect(part.mode, PaintMode.freeStyle);
      expect(part.fill, isFalse);
      // Half of the 40 long outline: along two sides of the square.
      expect(part.offsets.first, const Offset(0, 0));
      expect(part.offsets.last, const Offset(10, 10));
      expect(identical(drawnPaintStrokes([item], 1).single, item), isTrue);
    });

    test('shows a dot once the pen has passed it', () {
      final dot = stroke(PaintMode.freeStyle, const [Offset(5, 5)]);

      // The pen is exactly at the end of the first stroke.
      expect(drawnPaintStrokes([first, dot, second], 0.25)[1], isNull);

      final drawn = drawnPaintStrokes([first, dot, second], 0.26);
      expect(identical(drawn[1], dot), isTrue);
      expect(drawn[2]!.offsets.last, const Offset(4, 10));
    });

    test('gives every dot the same share in a drawing of dots only', () {
      final dots = [
        for (var i = 0; i < 4; i++)
          stroke(PaintMode.freeStyle, [Offset(i * 10.0, 0)]),
      ];

      expect(drawnPaintStrokes(dots, 0.3).nonNulls, hasLength(2));
      expect(drawnPaintStrokes(dots, 0.5).nonNulls, hasLength(2));
      expect(drawnPaintStrokes(dots, 0.51).nonNulls, hasLength(3));
    });

    test('draws a custom freehand mode along its points', () {
      const configs = PaintEditorConfigs(
        freeStyleCustomModes: {PaintMode.custom1},
      );
      final item = stroke(PaintMode.custom1, const [
        Offset(0, 0),
        Offset(20, 0),
      ]);

      final part = drawnPaintStrokes(
        [item],
        0.5,
        paintEditorConfigs: configs,
      ).single!;

      expect(part.mode, PaintMode.custom1);
      expect(part.offsets, const [Offset(0, 0), Offset(10, 0)]);
    });
  });
}
