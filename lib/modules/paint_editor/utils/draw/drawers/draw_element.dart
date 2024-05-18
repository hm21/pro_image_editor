import 'package:flutter/material.dart';

import '../../../../../models/paint_editor/painted_model.dart';
import '../../paint_editor_enum.dart';
import 'draw_arrow.dart';
import 'draw_dash_line.dart';
import 'draw_free_style.dart';

/// Draws an element on a canvas based on the specified mode and parameters.
///
/// This function is used to draw various elements such as freehand lines, straight
/// lines, arrows, dashed lines, rectangles, and circles on a canvas. The appearance
/// of the element is determined by the provided [mode] and additional parameters
/// such as [offsets], [painter], [scale], [start], and [end].
///
/// - `canvas`: The canvas on which to draw the element.
/// - `size`: The size of the canvas.
/// - `scale`: The scaling factor applied to the coordinates of the element.
/// - `freeStyleHighPerformance`: Controls high-performance for free-style drawing.
/// - `item` Represents a unit of shape or drawing information used in painting.
void drawElement({
  required Canvas canvas,
  required Size size,
  required PaintedModel item,
  bool freeStyleHighPerformance = false,
  double scale = 1,
}) {
  var painter = Paint()
    ..color = item.paint.color
    ..style = item.paint.style
    ..strokeWidth = item.paint.strokeWidth * scale;

  PaintModeE mode = item.mode;
  List<Offset?> offsets = item.offsets;
  Offset? start = item.offsets[0];
  Offset? end = item.offsets[1];

  switch (mode) {
    case PaintModeE.freeStyle:
      drawFreeStyle(
        offsets: offsets,
        canvas: canvas,
        painter: painter,
        scale: scale,
        freeStyleHighPerformance: freeStyleHighPerformance,
      );
      break;
    case PaintModeE.line:
      canvas.drawLine(start! * scale, end! * scale, painter);
      break;
    case PaintModeE.arrow:
      drawArrow(canvas, start! * scale, end! * scale, painter);
      break;
    case PaintModeE.dashLine:
      final path = Path()
        ..moveTo(start!.dx * scale, start.dy * scale)
        ..lineTo(end!.dx * scale, end.dy * scale);
      canvas.drawPath(drawDashLine(path, painter.strokeWidth), painter);
      break;
    case PaintModeE.rect:
      canvas.drawRect(Rect.fromPoints(start! * scale, end! * scale), painter);
      break;
    case PaintModeE.circle:
      final path = Path();
      var ovalRect = Rect.fromPoints(start! * scale, end! * scale);
      path.addOval(ovalRect);
      canvas.drawPath(path, painter);
      break;
    default:
      throw ErrorHint('$mode is not a valid PaintModeE');
  }
}
