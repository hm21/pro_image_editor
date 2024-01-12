import 'package:flutter/material.dart';

import '../../../models/theme/theme.dart';

class CropCornerPainter extends CustomPainter {
  final Rect cropRect;
  final Rect viewRect;
  final Size screenSize;
  final ImageEditorTheme imageEditorTheme;
  final bool interactionActive;

  double cornerLength = 50;
  double cornerWidth = 7;
  final double scaleFactor;

  CropCornerPainter({
    required this.cropRect,
    required this.viewRect,
    required this.screenSize,
    required this.scaleFactor,
    required this.imageEditorTheme,
    required this.interactionActive,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Calculate the middle point of the canvas
    double centerX = size.width / 2;
    double centerY = size.height / 2;

    // Calculate the dimensions of your cropRect relative to the center point
    double cropRectWidth = cropRect.width;
    double cropRectHeight = cropRect.height;

    // Calculate the top-left position of cropRect relative to the center point
    double cropRectLeft = centerX - (cropRectWidth / 2);
    double cropRectTop = centerY - (cropRectHeight / 2);

    // Optionally, draw draggable handles at the corners using the same relative calculations
    final cornerPaint = Paint()
      ..color = imageEditorTheme.cropRotateEditor.cropCornerColor
      ..style = PaintingStyle.fill;

    /// Draw outline darken layers
    Path darkenPath = Path();

    /// Draw top
    double heightVertical = (size.height * scaleFactor - size.height) / 2;
    double widthVertical = (size.width * scaleFactor - size.width) / 2;
    darkenPath.addRect(
      Rect.fromCenter(
        center: Offset(size.width / 2, -heightVertical / 2),
        width: screenSize.width,
        height: heightVertical,
      ),
    );

    /// Draw right
    darkenPath.addRect(
      Rect.fromCenter(
        center: Offset(size.width + widthVertical / 2, size.height / 2),
        width: widthVertical,
        height: size.height,
      ),
    );

    /// Draw left
    darkenPath.addRect(
      Rect.fromCenter(
        center: Offset(-widthVertical / 2, size.height / 2),
        width: widthVertical,
        height: size.height,
      ),
    );

    /// Draw bottom
    darkenPath.addRect(
      Rect.fromCenter(
        center: Offset(size.width / 2, size.height + heightVertical / 2),
        width: screenSize.width,
        height: heightVertical,
      ),
    );

    canvas.drawPath(
        darkenPath,
        Paint()
          ..color = interactionActive ? Colors.black38 : Colors.black54
          ..style = PaintingStyle.fill);

    /// Draw corners
    Path cornerPath = Path();

    /// Top-Left
    cornerPath.addRect(Rect.fromLTWH(0, 0, cornerLength, cornerWidth));
    cornerPath.addRect(Rect.fromLTWH(0, 0, cornerWidth, cornerLength));

    /// Top-Right
    cornerPath.addRect(Rect.fromLTWH(size.width - cornerLength, 0, cornerLength, cornerWidth));
    cornerPath.addRect(Rect.fromLTWH(size.width - cornerWidth, 0, cornerWidth, cornerLength));

    /// Bottom-Left
    cornerPath.addRect(Rect.fromLTWH(0, size.height - cornerWidth, cornerLength, cornerWidth));
    cornerPath.addRect(Rect.fromLTWH(0, size.height - cornerLength, cornerWidth, cornerLength));

    /// Bottom-Right
    cornerPath.addRect(Rect.fromLTWH(size.width - cornerLength, size.height - cornerWidth, cornerLength, cornerWidth));
    cornerPath.addRect(Rect.fromLTWH(size.width - cornerWidth, size.height - cornerLength, cornerWidth, cornerLength));

    canvas.drawPath(cornerPath, cornerPaint);
  }

  void _drawCorners() {}

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return oldDelegate is! CropCornerPainter || oldDelegate.cropRect != cropRect || oldDelegate.viewRect != viewRect;
  }
}
