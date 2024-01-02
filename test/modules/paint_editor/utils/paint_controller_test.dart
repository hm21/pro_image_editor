import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pro_image_editor/models/paint_editor/painted_model.dart';
import 'package:pro_image_editor/modules/paint_editor/utils/paint_controller.dart';
import 'package:pro_image_editor/modules/paint_editor/utils/paint_editor_enum.dart';

void main() {
  test('PaintingController initializes with correct values', () {
    final controller = PaintingController(
      strokeWidth: 2.0,
      color: Colors.red,
      mode: PaintModeE.line,
      fill: false,
      strokeMultiplier: 1,
    );

    expect(controller.strokeWidth, 2.0);
    expect(controller.color, Colors.red);
    expect(controller.mode, PaintModeE.line);
    expect(controller.fill, false);
  });

  test('Add and retrieve painted models in painting history', () {
    final controller = PaintingController(
      strokeWidth: 2.0,
      color: Colors.red,
      mode: PaintModeE.line,
      fill: false,
      strokeMultiplier: 1,
    );

    final paintedModel = PaintedModel(
      color: Colors.blue,
      mode: PaintModeE.rect,
      offsets: [const Offset(0, 0), const Offset(50, 50)],
      strokeWidth: 3.0,
    );

    controller.addPaintInfo(paintedModel);

    expect(controller.paintHistory, [paintedModel]);
  });

  test('Undo and redo painting actions', () {
    final controller = PaintingController(
      strokeWidth: 2.0,
      color: Colors.red,
      mode: PaintModeE.line,
      fill: false,
      strokeMultiplier: 1,
    );

    final paintedModel1 = PaintedModel(
      color: Colors.blue,
      mode: PaintModeE.rect,
      offsets: [const Offset(0, 0), const Offset(50, 50)],
      strokeWidth: 3.0,
    );

    final paintedModel2 = PaintedModel(
      color: Colors.green,
      mode: PaintModeE.circle,
      offsets: [const Offset(20, 20), const Offset(70, 70)],
      strokeWidth: 2.5,
    );

    controller.addPaintInfo(paintedModel1);
    controller.addPaintInfo(paintedModel2);

    controller.undo();
    expect(controller.paintHistory, [paintedModel1]);
    expect(controller.paintRedoHistory, [paintedModel2]);

    controller.redo();
    expect(controller.paintHistory, [paintedModel1, paintedModel2]);
    expect(controller.paintRedoHistory, []);
  });

  test('Clear painting history', () {
    final controller = PaintingController(
      strokeWidth: 2.0,
      color: Colors.red,
      mode: PaintModeE.line,
      fill: false,
      strokeMultiplier: 1,
    );

    final paintedModel = PaintedModel(
      color: Colors.blue,
      mode: PaintModeE.rect,
      offsets: [const Offset(0, 0), const Offset(50, 50)],
      strokeWidth: 3.0,
    );

    controller.addPaintInfo(paintedModel);
    controller.clear();

    expect(controller.paintHistory, []);
  });
}
