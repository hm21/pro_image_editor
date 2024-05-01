import 'dart:ui';

/// Draws a line with an arrowhead on top of it.
///
/// This function is used to draw a line from the specified [start] point to the
/// [end] point using the provided [painter], and it also adds an arrowhead at
/// the [end] point.
///
/// - `canvas`: The canvas on which to draw the arrow.
/// - `start`: The starting point of the line.
/// - `end`: The ending point of the line and the location of the arrowhead.
/// - `painter`: The paint object specifying the line's color, width, and style.
void drawArrow(Canvas canvas, Offset start, Offset end, Paint painter) {
  final arrowPainter = Paint()
    ..color = painter.color
    ..strokeWidth = painter.strokeWidth
    ..style = PaintingStyle.stroke;

  // Draw the line.
  canvas.drawLine(start, end, painter);

  // Calculate the path for the arrowhead.
  final pathOffset = painter.strokeWidth / 15;
  final path = Path()
    ..lineTo(-15 * pathOffset, 10 * pathOffset)
    ..lineTo(-15 * pathOffset, -10 * pathOffset)
    ..close();

  // Save the canvas state, translate it to the end point, rotate it to match
  // the direction of the line, and then draw the arrowhead.
  canvas.save();
  canvas.translate(end.dx, end.dy);
  canvas.rotate((end - start).direction);
  canvas.drawPath(path, arrowPainter);
  canvas.restore();
}
