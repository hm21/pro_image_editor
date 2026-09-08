// Flutter imports:
// Package imports:
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:pro_image_editor/features/paint_editor/controllers/paint_controller.dart';
import 'package:pro_image_editor/features/paint_editor/enums/paint_editor_enum.dart';

void main() {
  test('PaintController initializes with correct values', () {
    final controller = PaintController(
      strokeWidth: 2.0,
      color: Colors.red,
      mode: PaintMode.line,
      fill: false,
      strokeMultiplier: 1,
      opacity: 1,
    );

    expect(controller.strokeWidth, 2.0);
    expect(controller.color, Colors.red);
    expect(controller.mode, PaintMode.line);
    expect(controller.fill, false);
  });
}
