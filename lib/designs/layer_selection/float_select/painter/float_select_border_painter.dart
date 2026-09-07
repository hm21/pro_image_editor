import 'package:material_ui/material_ui.dart';

/// Paints a custom rectangular border for FloatSelect
class FloatSelectBorderPainter extends CustomPainter {
  /// Creates a border painter with custom settings
  const FloatSelectBorderPainter({
    required this.borderColor,
    required this.strokeWidth,
    required this.spacer,
    required this.outsideSpace,
  });

  /// Color of the border
  final Color borderColor;

  /// Width of the border stroke
  final double strokeWidth;

  /// Inner spacing from content edges
  final double spacer;

  /// Outer spacing around the border
  final double outsideSpace;

  @override
  void paint(Canvas canvas, Size size) {
    _drawSolidBorder(canvas, size);
  }

  /// Draws a rectangular border around the content
  void _drawSolidBorder(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    final offset = strokeWidth / 2;

    canvas
      // Top
      ..drawLine(
        Offset(spacer, outsideSpace + offset),
        Offset(size.width - spacer, outsideSpace + offset),
        paint,
      )
      // Right
      ..drawLine(
        Offset(size.width - outsideSpace - offset, spacer),
        Offset(size.width - outsideSpace - offset, size.height - spacer),
        paint,
      )
      // Bottom
      ..drawLine(
        Offset(spacer, size.height - outsideSpace - offset),
        Offset(size.width - spacer, size.height - outsideSpace - offset),
        paint,
      )
      // Left
      ..drawLine(
        Offset(outsideSpace + offset, spacer),
        Offset(outsideSpace + offset, size.height - spacer),
        paint,
      );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
