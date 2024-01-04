import 'package:flutter/material.dart';

import '../paint_controller.dart';
import 'drawers/draw_element.dart';

/// Handles all the ongoing painting on the canvas.
class DrawImage extends CustomPainter {
  /// The controller that manages and provides paint details.
  late PaintingController _paintCtrl;

  /// Constructor for the canvas.
  ///
  /// - [paintCtrl]: The `PaintingController` responsible for managing paint details.
  DrawImage({
    required PaintingController paintCtrl,
  }) : super(repaint: paintCtrl) {
    _paintCtrl = paintCtrl;
  }

  @override
  void paint(Canvas canvas, Size size) {
    // Paints all the previously recorded paintInfo history on [PaintHistory].
    for (final item in _paintCtrl.paintHistory) {
      drawElement(
        canvas: canvas,
        size: size,
        mode: item.mode,
        painter: item.paint,
        offsets: item.offsets,
        start: item.offsets[0],
        end: item.offsets[1],
        freeStyleHighPerformanceScaling: false,
        freeStyleHighPerformanceMoving: false,
      );
    }

    // Draws ongoing action on the canvas while in drag.
    if (_paintCtrl.busy) {
      drawElement(
        canvas: canvas,
        size: size,
        mode: _paintCtrl.mode,
        painter: _paintCtrl.brush,
        offsets: _paintCtrl.offsets,
        start: _paintCtrl.start,
        end: _paintCtrl.end,
        freeStyleHighPerformanceScaling: false,
        freeStyleHighPerformanceMoving: false,
      );
    }
  }

  @override
  bool shouldRepaint(DrawImage oldDelegate) =>
      oldDelegate._paintCtrl != _paintCtrl;
}
