// Flutter imports:
import 'package:flutter/material.dart';

/// A custom widget representing a button with a specific aspect ratio.
class AspectRatioButton extends StatelessWidget {
  /// Creates an [AspectRatioButton] with the specified aspect ratio.
  const AspectRatioButton(
      {super.key, this.aspectRatio, this.isSelected = false});

  /// The numeric value of the aspect ratio (width / height).
  final double? aspectRatio;

  /// Indicates whether the button is selected or not.
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(100, 100),
      painter: AspectRatioPainter(
        aspectRatio: aspectRatio,
        isSelected: isSelected,
      ),
    );
  }
}

/// A custom painter for rendering an aspect ratio button.
class AspectRatioPainter extends CustomPainter {
  /// Creates an [AspectRatioPainter] with the specified properties.
  AspectRatioPainter({
    this.aspectRatio,
    this.isSelected = false,
  });

  /// The numeric value of the aspect ratio (width / height).
  final double? aspectRatio;

  /// Indicates whether the button is selected or not.
  final bool isSelected;

  @override
  void paint(Canvas canvas, Size size) {
    bool isFreestyleMode = aspectRatio == -1;

    final Color color = isSelected ? Colors.blue : Colors.grey;
    final Rect rect = Offset.zero & size;

    // Paint object for filling the rectangle with color and opacity
    final Paint fillPaint = Paint()
      ..color = color.withOpacity(0.5) // Set fill color opacity
      ..style = PaintingStyle.fill;

    // Paint object for the border
    final Paint borderPaint = Paint()
      ..color = color // Set the color for the border
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0; // Define border thickness

    final double aspectRatioResult =
        (aspectRatio != null && aspectRatio! > 0.0) ? aspectRatio! : 1.0;

    // Draw the filled rectangle with opacity
    canvas.drawRect(
      _getPaintRect(
        rect: const EdgeInsets.all(7.0).deflateRect(rect),
        inputSize: Size(aspectRatioResult * 100, 100.0),
      ),
      fillPaint,
    );

    // Draw the border around the rectangle
    if (!isFreestyleMode) {
      canvas.drawRect(
        _getPaintRect(
          rect: const EdgeInsets.all(7.0).deflateRect(rect),
          inputSize: Size(aspectRatioResult * 100, 100.0),
        ),
        borderPaint,
      );
    } else {
      // Calculate the rectangle to fit the aspect ratio
      final Rect paintRect = _getPaintRect(
        rect: const EdgeInsets.all(7.0).deflateRect(rect),
        inputSize: Size(aspectRatioResult * 100, 100.0),
      );
      // Draw the dashed border around the rectangle
      _drawDashedBorder(canvas, paintRect, borderPaint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return oldDelegate is AspectRatioPainter &&
        (oldDelegate.isSelected != isSelected ||
            oldDelegate.aspectRatio != aspectRatio);
  }

  void _drawDashedBorder(Canvas canvas, Rect rect, Paint paint) {
    const double dashWidth = 10.0;
    const double dashSpace = 5.0;
    final Path path = Path();

    // Top border
    _addDashedLine(path, Offset(rect.left, rect.top),
        Offset(rect.right, rect.top), dashWidth, dashSpace);

    // Right border
    _addDashedLine(path, Offset(rect.right, rect.top),
        Offset(rect.right, rect.bottom), dashWidth, dashSpace);

    // Bottom border
    _addDashedLine(path, Offset(rect.right, rect.bottom),
        Offset(rect.left, rect.bottom), dashWidth, dashSpace);

    // Left border
    _addDashedLine(path, Offset(rect.left, rect.bottom),
        Offset(rect.left, rect.top), dashWidth, dashSpace);

    canvas.drawPath(path, paint);
  }

// Helper method to add a dashed line to the path
  void _addDashedLine(
      Path path, Offset start, Offset end, double dashWidth, double dashSpace) {
    final double totalDistance = (end - start).distance;
    double currentDistance = 0.0;

    // Calculate the direction vector (unit vector) between start and end
    final Offset direction = Offset(
      (end.dx - start.dx) / totalDistance,
      (end.dy - start.dy) / totalDistance,
    );

    while (currentDistance < totalDistance) {
      final double dashEndDistance = currentDistance + dashWidth;
      final Offset dashEnd = Offset(
        start.dx + direction.dx * dashEndDistance,
        start.dy + direction.dy * dashEndDistance,
      );

      // Draw the dash line
      path.moveTo(start.dx + direction.dx * currentDistance,
          start.dy + direction.dy * currentDistance);
      if (dashEndDistance > totalDistance) {
        path.lineTo(end.dx, end.dy);
        break;
      } else {
        path.lineTo(dashEnd.dx, dashEnd.dy);
      }
      currentDistance += dashWidth + dashSpace;
    }
  }

  /// Calculate the painting rectangle within the given [rect] based on the
  /// [inputSize] and BoxFit.contain.
  Rect _getPaintRect({
    required Rect rect,
    required Size inputSize,
  }) {
    Size size = rect.size;

    final FittedSizes boxFitSize = applyBoxFit(BoxFit.contain, inputSize, size);
    Size newSize = boxFitSize.destination;

    final Offset newPosition = rect.topLeft.translate(
      (size.width - newSize.width) / 2.0,
      (size.height - newSize.height) / 2.0,
    );

    return newPosition & newSize;
  }
}
