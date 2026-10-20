import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:pro_image_editor/features/paint_editor/models/eraser_model.dart';
import 'package:pro_image_editor/pro_image_editor.dart';

void main() {
  group('PaintedModel.drawsSameAs', () {
    PaintedModel stroke({Color color = Colors.red}) => PaintedModel(
      mode: PaintMode.freeStyle,
      offsets: const [Offset(1, 2), Offset(3, 4)],
      erasedOffsets: const [],
      color: color,
      strokeWidth: 4,
      opacity: 1,
    );

    test('matches a copy, which has its own id', () {
      final original = stroke();
      final copy = original.copy();

      expect(copy.id, isNot(original.id));
      expect(copy, isNot(original));
      expect(copy.drawsSameAs(original), isTrue);
    });

    test('tells apart strokes that look different', () {
      expect(stroke().drawsSameAs(stroke(color: Colors.blue)), isFalse);
    });
  });

  group('PaintedModel.copy', () {
    PaintedModel stroke() => PaintedModel(
      mode: PaintMode.freeStyle,
      offsets: [const Offset(1, 2), const Offset(3, 4)],
      erasedOffsets: [],
      color: Colors.red,
      strokeWidth: 4,
      opacity: 1,
    );

    test('shares the points instead of copying them', () {
      final original = stroke();

      expect(identical(original.copy().offsets, original.offsets), isTrue);
    });

    test('keeps the erased areas apart, which the eraser adds to in place', () {
      final original = stroke();
      original.copy().erasedOffsets.add(
        const ErasedOffset(offset: Offset(1, 2), radius: 3),
      );

      expect(original.erasedOffsets, isEmpty);
    });
  });
}
