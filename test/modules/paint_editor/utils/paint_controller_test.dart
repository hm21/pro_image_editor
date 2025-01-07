// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_test/flutter_test.dart';
import 'package:pro_image_editor/core/models/paint_editor/painted_model.dart';
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

  test('Add and retrieve painted models in paint history', () {
    final controller = PaintController(
      strokeWidth: 2.0,
      color: Colors.red,
      mode: PaintMode.line,
      fill: false,
      strokeMultiplier: 1,
      opacity: 1,
    );

    final paintedModel = PaintedModel(
      color: Colors.blue,
      mode: PaintMode.rect,
      offsets: [const Offset(0, 0), const Offset(50, 50)],
      strokeWidth: 3.0,
      opacity: 1,
    );

    controller.addPaintInfo(paintedModel);

    expect(controller.activePaintItemList, [paintedModel]);
  });

  test('Undo and redo paint actions', () {
    final controller = PaintController(
      strokeWidth: 2.0,
      color: Colors.red,
      mode: PaintMode.line,
      fill: false,
      strokeMultiplier: 1,
      opacity: 1,
    );

    final paintedModel1 = PaintedModel(
      color: Colors.blue,
      mode: PaintMode.rect,
      offsets: [const Offset(0, 0), const Offset(50, 50)],
      strokeWidth: 3.0,
      opacity: 1.0,
    );

    final paintedModel2 = PaintedModel(
      color: Colors.green,
      mode: PaintMode.circle,
      offsets: [const Offset(20, 20), const Offset(70, 70)],
      strokeWidth: 2.5,
      opacity: 1.0,
    );

    controller
      ..addPaintInfo(paintedModel1)
      ..addPaintInfo(paintedModel2)
      ..undo();
    expect(controller.activePaintItemList, [paintedModel1]);
    expect(controller.historyPosition, 1);

    controller.redo();
    expect(controller.activePaintItemList, [paintedModel1, paintedModel2]);
    expect(controller.historyPosition, 2);
  });
}
