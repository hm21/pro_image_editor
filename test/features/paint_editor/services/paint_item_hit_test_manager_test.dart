// Flutter imports:
import 'dart:ui';

// Package imports:
import 'package:flutter_test/flutter_test.dart';
import 'package:pro_image_editor/core/models/editor_configs/paint_editor/paint_editor_configs.dart';
import 'package:pro_image_editor/features/paint_editor/enums/paint_editor_enum.dart';
import 'package:pro_image_editor/features/paint_editor/services/paint_item_hit_test_manager.dart';

void main() {
  const configs = PaintEditorConfigs();
  final manager = PaintItemHitTestManager();

  PaintedModel buildFreestyle({
    required List<Offset?> offsets,
    double strokeWidth = 10,
    PaintMode mode = PaintMode.freeStyle,
  }) {
    return PaintedModel(
      mode: mode,
      offsets: offsets,
      erasedOffsets: [],
      color: const Color(0xFF000000),
      strokeWidth: strokeWidth,
      opacity: 1,
    );
  }

  bool hitTest(PaintedModel item, Offset position, {double scale = 1}) {
    return manager.hitTest(
      item: item,
      position: position,
      scaleFactor: scale,
      paintEditorConfigs: configs,
    );
  }

  group('PaintedModel.bounds', () {
    test('encloses the points plus half the stroke width', () {
      final item = buildFreestyle(
        offsets: const [Offset(20, 30), Offset(60, 90)],
      );

      expect(item.bounds, const Rect.fromLTRB(15, 25, 65, 95));
    });

    test('is recomputed when the points are replaced', () {
      final item = buildFreestyle(
        offsets: const [Offset(20, 30), Offset(60, 90)],
      );
      expect(item.bounds, const Rect.fromLTRB(15, 25, 65, 95));

      item.offsets = const [Offset(0, 0), Offset(10, 10)];
      expect(item.bounds, const Rect.fromLTRB(-5, -5, 15, 15));
    });

    test('is recomputed when the stroke width changes', () {
      final item = buildFreestyle(
        offsets: const [Offset(20, 30), Offset(60, 90)],
      );
      expect(item.bounds, const Rect.fromLTRB(15, 25, 65, 95));

      item.strokeWidth = 20;
      expect(item.bounds, const Rect.fromLTRB(10, 20, 70, 100));
    });

    test('reserves room for the whole arrow head', () {
      final item = buildFreestyle(
        offsets: const [Offset(20, 20), Offset(60, 20)],
        mode: PaintMode.freeStyleArrowEnd,
      );

      expect(item.bounds.left, lessThan(15));
      expect(item.bounds.right, greaterThan(65));

      // The barbs run out to `(-4, +/-4)` units of `strokeWidth / 2` from the
      // anchor at (60, 20), so their tips sit at (40, 0) and (40, 40) with
      // another half stroke of rendered width around them. A box padded by
      // only `4 * strokeWidth / 2` would cut those corners off.
      expect(item.bounds.contains(const Offset(40, 44.9)), isTrue);
      expect(item.bounds.contains(const Offset(40, -4.9)), isTrue);
    });

    test('is Rect.zero when there is no point at all', () {
      expect(buildFreestyle(offsets: const [null]).bounds, Rect.zero);
    });
  });

  group('freestyle hit test', () {
    final item = buildFreestyle(
      offsets: const [Offset(10, 10), Offset(110, 10), Offset(110, 110)],
    );

    test('hits directly on the stroke', () {
      expect(hitTest(item, const Offset(60, 10)), isTrue);
      expect(hitTest(item, const Offset(110, 60)), isTrue);
    });

    test('hits within half the stroke width', () {
      expect(hitTest(item, const Offset(60, 14)), isTrue);
      expect(hitTest(item, const Offset(60, 6)), isTrue);
    });

    test('misses just outside the stroke', () {
      expect(hitTest(item, const Offset(60, 17)), isFalse);
      expect(hitTest(item, const Offset(60, 3)), isFalse);
    });

    test('misses inside the bounding box but away from the stroke', () {
      // The corner the L-shape does not cover.
      expect(hitTest(item, const Offset(20, 100)), isFalse);
    });

    test('misses far outside the bounding box', () {
      expect(hitTest(item, const Offset(900, 900)), isFalse);
    });

    test('respects the scale factor', () {
      // At scale 2 the stroke runs from (20, 20) to (220, 20) and back down,
      // with a 10px hit radius.
      expect(hitTest(item, const Offset(120, 20), scale: 2), isTrue);
      expect(hitTest(item, const Offset(120, 28)), isFalse);
      expect(hitTest(item, const Offset(120, 28), scale: 2), isTrue);
    });

    test('hits an isolated dot', () {
      final dotted = buildFreestyle(
        offsets: const [Offset(10, 10), null, Offset(200, 200)],
      );

      expect(hitTest(dotted, const Offset(200, 200)), isTrue);
      expect(hitTest(dotted, const Offset(10, 10)), isTrue);
      // The gap between both dots must not connect them.
      expect(hitTest(dotted, const Offset(105, 105)), isFalse);
    });

    test('hits the arrow head beyond the last point', () {
      final arrow = buildFreestyle(
        offsets: const [Offset(10, 10), Offset(110, 10)],
        mode: PaintMode.freeStyleArrowEnd,
      );

      expect(hitTest(arrow, const Offset(118, 10)), isTrue);
      expect(hitTest(arrow, const Offset(118, 10), scale: 1), isTrue);
      // Still bounded - far past the head stays a miss.
      expect(hitTest(arrow, const Offset(400, 10)), isFalse);
    });

    test('hits the outer tip of the arrow head', () {
      final arrow = buildFreestyle(
        offsets: const [Offset(10, 10), Offset(110, 10)],
        mode: PaintMode.freeStyleArrowEnd,
      );

      // The barb runs from the anchor at (110, 10) out to (90, 30), so its far
      // end is 28.3px from the anchor - past the `4 * strokeWidth / 2` that a
      // straight reading of the head geometry suggests.
      expect(hitTest(arrow, const Offset(90, 33)), isTrue);
      // Clear of the barb, so still a miss.
      expect(hitTest(arrow, const Offset(90, 40)), isFalse);
    });

    test('writes the result back onto the item', () {
      expect(hitTest(item, const Offset(60, 10)), isTrue);
      expect(item.hit, isTrue);

      expect(hitTest(item, const Offset(900, 900)), isFalse);
      expect(item.hit, isFalse);
    });
  });

  group('other modes still hit', () {
    test('line', () {
      final line = buildFreestyle(
        offsets: const [Offset(10, 10), Offset(110, 110)],
        mode: PaintMode.line,
      );

      expect(hitTest(line, const Offset(60, 60)), isTrue);
      expect(hitTest(line, const Offset(10, 110)), isFalse);
      expect(hitTest(line, const Offset(900, 900)), isFalse);
    });

    test('rect', () {
      final rect = PaintedModel(
        mode: PaintMode.rect,
        offsets: const [Offset(10, 10), Offset(110, 110)],
        erasedOffsets: [],
        color: const Color(0xFF000000),
        strokeWidth: 10,
        opacity: 1,
        fill: true,
      );

      expect(hitTest(rect, const Offset(60, 60)), isTrue);
      expect(hitTest(rect, const Offset(900, 900)), isFalse);
    });
  });
}
