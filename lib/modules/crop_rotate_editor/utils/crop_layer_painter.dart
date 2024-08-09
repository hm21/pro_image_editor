// Flutter imports:
import 'package:flutter/material.dart';

/// A custom painter for drawing the crop layer background and overlay.
///
/// This class extends [CustomPainter] and is used to draw the crop layer's
/// background and overlay for a crop and rotate editor. It supports both
/// rectangular and round crop shapes and handles image rotation effects.
class CropLayerPainter extends CustomPainter {
  /// Creates an instance of [CropLayerPainter].
  ///
  /// The constructor initializes various parameters needed to draw the crop
  /// layer's background and overlay, such as the image ratio, rotation
  /// settings, and visual appearance.
  ///
  /// Example:
  /// ```
  /// CropLayerPainter(
  ///   imgRatio: 1.5,
  ///   isRoundCropper: false,
  ///   is90DegRotated: true,
  ///   backgroundColor: Colors.black.withOpacity(0.5),
  ///   opacity: 0.8,
  /// )
  /// ```
  CropLayerPainter({
    required this.imgRatio,
    required this.isRoundCropper,
    required this.is90DegRotated,
    required this.backgroundColor,
    required this.opacity,
  });

  /// The aspect ratio of the image.
  ///
  /// This double value represents the aspect ratio of the image being edited,
  /// affecting how the crop layer is drawn and scaled.
  final double imgRatio;

  /// Indicates whether the image is rotated by 90 degrees.
  ///
  /// This boolean flag determines whether the image is currently rotated by 90
  /// degrees, affecting the orientation of the crop layer.
  final bool is90DegRotated;

  /// The background color of the crop layer.
  ///
  /// This [Color] is used to fill the background of the crop layer, providing
  /// contrast and focus for the cropping area.
  final Color backgroundColor;

  /// Indicates whether the crop shape is round.
  ///
  /// This boolean flag determines whether the crop layer should be drawn with
  /// a round shape, affecting the visual appearance of the cropping area.
  final bool isRoundCropper;

  /// The opacity of the crop layer.
  ///
  /// This double value represents the opacity of the crop layer, allowing for
  /// adjustable transparency to enhance the visual experience.
  final double opacity;

  @override
  void paint(Canvas canvas, Size size) {
    if (opacity == 0 || imgRatio <= 0) return;
    _drawDarkenOutside(canvas: canvas, size: size);
  }

  void _drawDarkenOutside({
    required Canvas canvas,
    required Size size,
  }) {
    Path path = Path()
      // FillType "evenOdd" is important for the canvas web renderer
      ..fillType = PathFillType.evenOdd
      ..addRect(Rect.fromCenter(
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

      /// Subtract the area of the current rectangle from the path for the
      /// entire canvas
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

      /// Subtract the area of the current rectangle from the path for the
      /// entire canvas
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
