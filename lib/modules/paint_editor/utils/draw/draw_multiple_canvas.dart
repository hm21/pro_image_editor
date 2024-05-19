// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:pro_image_editor/models/paint_editor/painted_model.dart';
import 'package:pro_image_editor/modules/paint_editor/utils/paint_editor_enum.dart';
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
        item: item,
      );
    }

    // Draws ongoing action on the canvas while in drag.
    if (_paintCtrl.busy) {
      drawElement(
        canvas: canvas,
        size: size,
        item: PaintedModel(
          mode: _paintCtrl.mode,
          offsets: _paintCtrl.mode == PaintModeE.freeStyle
              ? _paintCtrl.offsets
              : [_paintCtrl.start, _paintCtrl.end],
          color: _paintCtrl.color,
          strokeWidth: _paintCtrl.strokeWidth,
          fill: _paintCtrl.fill,
        ),
      );
    }
  }

  @override
  bool shouldRepaint(DrawImage oldDelegate) =>
      oldDelegate._paintCtrl != _paintCtrl;
}
