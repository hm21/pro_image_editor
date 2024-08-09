// Dart imports:
import 'dart:math';

// Flutter imports:
import 'package:flutter/widgets.dart';

// Project imports:
import 'package:pro_image_editor/models/theme/theme_layer_interaction.dart';

/// A custom painter for rendering the border of a layer interaction area.
///
/// This painter draws borders around interactive layers in an image editing
/// application, applying styles and themes to enhance the visual appearance
/// of the interaction area.
class LayerInteractionBorderPainter extends CustomPainter {
  /// Creates a [LayerInteractionBorderPainter].
  ///
  /// The painter uses the provided [theme] and [borderStyle] to determine the
  /// appearance of the layer's border, such as color, stroke width, and style.
  ///
  /// Example:
  /// ```
  /// LayerInteractionBorderPainter(
  ///   theme: myThemeLayerInteraction,
  ///   borderStyle: LayerInteractionBorderStyle.solid,
  /// )
  /// ```
  LayerInteractionBorderPainter({
    required this.theme,
    required this.borderStyle,
  });

  /// The theme settings for the layer interaction.
  ///
  /// This theme provides color, opacity, and other styling options for the
  /// layer border, ensuring it matches the overall design of the application.
  final ThemeLayerInteraction theme;

  /// The style of the layer interaction border.
  ///
  /// This style determines how the border is drawn, such as whether it is
  /// solid, dashed, or dotted, and influences the border's appearance.
  final LayerInteractionBorderStyle borderStyle;

  @override
  void paint(Canvas canvas, Size size) {
    switch (borderStyle) {
      case LayerInteractionBorderStyle.solid:
        _drawSolidBorder(canvas, size);
        break;
      case LayerInteractionBorderStyle.dashed:
        _drawDashedBorder(canvas, size);
        break;
      case LayerInteractionBorderStyle.dotted:
        _drawDottedBorder(canvas, size);
        break;
      default:
    }
  }

  void _drawDashedBorder(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = theme.borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = theme.strokeWidth;

    const startVal = 3.0;
    final dashWidth = theme.borderElementWidth;
    final dashSpace = theme.borderElementSpace;
    // Draw top border
    var currentX = startVal;
    while (currentX < size.width) {
      canvas.drawLine(
        Offset(currentX, 0),
        Offset(min(currentX + dashWidth, size.width), 0),
        paint,
      );
      currentX += dashWidth + dashSpace;
    }

    // Draw right border
    var currentY = startVal;
    while (currentY < size.height) {
      canvas.drawLine(
        Offset(size.width, currentY),
        Offset(size.width, min(currentY + dashWidth, size.height)),
        paint,
      );
      currentY += dashWidth + dashSpace;
    }

    // Draw bottom border
    currentX = startVal;
    while (currentX < size.width) {
      canvas.drawLine(
        Offset(currentX, size.height),
        Offset(min(currentX + dashWidth, size.width), size.height),
        paint,
      );
      currentX += dashWidth + dashSpace;
    }

    // Draw left border
    currentY = startVal;
    while (currentY < size.height) {
      canvas.drawLine(
        Offset(0, currentY),
        Offset(0, min(currentY + dashWidth, size.height)),
        paint,
      );
      currentY += dashWidth + dashSpace;
    }
  }

// Method to draw a solid border
  void _drawSolidBorder(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = theme.borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = theme.strokeWidth;

    // Draw top border
    canvas
      ..drawLine(
        const Offset(0, 0),
        Offset(size.width, 0),
        paint,
      )

      // Draw right border
      ..drawLine(
        Offset(size.width, 0),
        Offset(size.width, size.height),
        paint,
      )

      // Draw bottom border
      ..drawLine(
        Offset(0, size.height),
        Offset(size.width, size.height),
        paint,
      )

      // Draw left border
      ..drawLine(
        const Offset(0, 0),
        Offset(0, size.height),
        paint,
      );
  }

// Method to draw a rounded dotted border
  void _drawDottedBorder(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = theme.borderColor
      ..style = PaintingStyle.fill
      ..strokeWidth = theme.strokeWidth;

    final width = theme.borderElementWidth;
    final space = theme.borderElementSpace;
    final startVal = width * 2;

    // Draw top border
    var currentX = startVal;
    while (currentX < size.width) {
      canvas.drawCircle(
        Offset(currentX, 0),
        width,
        paint,
      );
      currentX += width + space;
    }

    // Draw right border
    var currentY = startVal;
    while (currentY < size.height) {
      canvas.drawCircle(
        Offset(size.width, currentY),
        width,
        paint,
      );
      currentY += width + space;
    }

    // Draw bottom border
    currentX = startVal;
    while (currentX < size.width) {
      canvas.drawCircle(
        Offset(currentX, size.height),
        width,
        paint,
      );
      currentX += width + space;
    }

    // Draw left border
    currentY = startVal;
    while (currentY < size.height) {
      canvas.drawCircle(
        Offset(0, currentY),
        width,
        paint,
      );
      currentY += width + space;
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}
