import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
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
}
