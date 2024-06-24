// Flutter imports:
import 'package:flutter/material.dart';

class CropLayerPainter extends CustomPainter {
  final double imgRatio;
  final bool is90DegRotated;
  final Color backgroundColor;
  final bool isRoundCropper;
  final double opacity;

  CropLayerPainter({
    required this.imgRatio,
    required this.isRoundCropper,
    required this.is90DegRotated,
    required this.backgroundColor,
    required this.opacity,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (opacity == 0 || imgRatio <= 0) return;
    _drawDarkenOutside(canvas: canvas, size: size);
  }

  void _drawDarkenOutside({
    required Canvas canvas,
    required Size size,
  }) {
    Path path = Path();

    /// Filltype "evenOdd" is important for the canvas web renderer
    path.fillType = PathFillType.evenOdd;
    path.addRect(Rect.fromCenter(
      center: Offset(
        size.width / 2,
        size.height / 2,
      ),
      width: size.width,
      height: size.height,
    ));

    double ratio = is90DegRotated ? 1 / imgRatio : imgRatio;

    double w = 0;
    double h = 0;

    size = Size(
      size.width,
      size.height,
    );

    if (size.aspectRatio > ratio) {
      h = size.height;
      w = size.height * ratio;
    } else {
      w = size.width;
      h = size.width / ratio;
    }

    if (isRoundCropper) {
      Path rectPath = Path()
        ..addOval(
          Rect.fromCenter(
            center: Offset(size.width / 2, size.height / 2),
            width: w,
            height: h,
          ),
        );

      /// Subtract the area of the current rectangle from the path for the entire canvas
      path = Path.combine(PathOperation.difference, path, rectPath);
    } else {
      Path rectPath = Path()
        ..addRect(
          Rect.fromCenter(
            center: Offset(size.width / 2, size.height / 2),
            width: w,
            height: h,
          ),
        );

      /// Subtract the area of the current rectangle from the path for the entire canvas
      path = Path.combine(PathOperation.difference, path, rectPath);
    }

    /// Draw the darkened area
    canvas.drawPath(
      path,
      Paint()
        ..color = backgroundColor.withOpacity(opacity)
        ..style = PaintingStyle.fill,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return oldDelegate is! CropLayerPainter ||
        oldDelegate.imgRatio != imgRatio ||
        oldDelegate.is90DegRotated != is90DegRotated ||
        oldDelegate.backgroundColor != backgroundColor ||
        oldDelegate.opacity != opacity ||
        oldDelegate.is90DegRotated != is90DegRotated;
  }
}
