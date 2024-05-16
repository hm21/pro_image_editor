import 'dart:ui';

/// Draws freehand lines on a canvas.
///
/// This function takes a list of [offsets] representing points and draws freehand
/// lines connecting those points on the specified [canvas] using the provided [painter].
/// The lines are scaled by the given [scale].
///
/// - [offsets]: A list of points representing the path of the freehand lines.
/// - [canvas]: The canvas on which to draw the freehand lines.
/// - [painter]: The paint object specifying the appearance of the lines (e.g., color,
///   stroke cap).
/// - [scale]: The scaling factor applied to the coordinates of the lines.
/// - [freeStyleHighPerformance]: Controls high-performance for freehand drawing.
void drawFreeStyle({
  required List<Offset?> offsets,
  required Canvas canvas,
  required Paint painter,
  required double scale,
  required bool freeStyleHighPerformance,
}) {
  painter.strokeCap = StrokeCap.round;
  if (!freeStyleHighPerformance) {
    final path = Path();

    for (int i = 0; i < offsets.length - 1; i++) {
      final currentOffset = offsets[i];
      final nextOffset = offsets[i + 1];

      if (currentOffset != null && nextOffset != null) {
        path.reset();
        path.moveTo(currentOffset.dx * scale, currentOffset.dy * scale);
        path.lineTo(nextOffset.dx * scale, nextOffset.dy * scale);
        canvas.drawPath(path, painter);
      } else if (currentOffset != null && nextOffset == null) {
        canvas.drawPoints(PointMode.points, [currentOffset], painter);
      }
    }
  } else {
    final path = Path();

    for (int i = 0; i < offsets.length - 1; i++) {
      if (offsets[i] != null && offsets[i + 1] != null) {
        final startPoint =
            Offset(offsets[i]!.dx * scale, offsets[i]!.dy * scale);
        final endPoint =
            Offset(offsets[i + 1]!.dx * scale, offsets[i + 1]!.dy * scale);

        if (i == 0) {
          path.moveTo(startPoint.dx, startPoint.dy);
        }

        path.lineTo(endPoint.dx, endPoint.dy);
      } else if (offsets[i] != null && offsets[i + 1] == null) {
        canvas.drawPoints(PointMode.points, [offsets[i]!], painter);
      }
    }

    canvas.drawPath(path, painter);
  }
}
