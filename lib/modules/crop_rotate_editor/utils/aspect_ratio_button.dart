import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';

/// A custom widget representing a button with a specific aspect ratio.
class AspectRatioButton extends StatelessWidget {
  /// Creates an [AspectRatioButton] with the specified aspect ratio.
  const AspectRatioButton(
      {super.key,
      this.aspectRatioS,
      this.aspectRatio,
      this.isSelected = false});

  /// A string representation of the aspect ratio (e.g., "16:9").
  final String? aspectRatioS;

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
        aspectRatioS: aspectRatioS,
        isSelected: isSelected,
      ),
    );
  }
}

/// A custom painter for rendering an aspect ratio button.
class AspectRatioPainter extends CustomPainter {
  /// Creates an [AspectRatioPainter] with the specified properties.
  AspectRatioPainter(
      {this.aspectRatioS, this.aspectRatio, this.isSelected = false});

  /// A string representation of the aspect ratio (e.g., "16:9").
  final String? aspectRatioS;

  /// The numeric value of the aspect ratio (width / height).
  final double? aspectRatio;

  /// Indicates whether the button is selected or not.
  final bool isSelected;

  @override
  void paint(Canvas canvas, Size size) {
    final Color color = isSelected ? Colors.blue : Colors.grey;
    final Rect rect = Offset.zero & size;
    final Paint paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    final double aspectRatioResult =
        (aspectRatio != null && aspectRatio! > 0.0) ? aspectRatio! : 1.0;

    canvas.drawRect(
        getDestinationRect(
          rect: const EdgeInsets.all(10.0).deflateRect(rect),
          inputSize: Size(aspectRatioResult * 100, 100.0),
          fit: BoxFit.contain,
        ),
        paint);

    final TextPainter textPainter = TextPainter(
        text: TextSpan(
            text: aspectRatioS,
            style: TextStyle(
              color:
                  color.computeLuminance() < 0.5 ? Colors.white : Colors.black,
              fontSize: 16.0,
            )),
        textDirection: TextDirection.ltr,
        maxLines: 1);
    textPainter.layout(maxWidth: rect.width);

    textPainter.paint(
        canvas,
        rect.center -
            Offset(textPainter.width / 2.0, textPainter.height / 2.0));
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return oldDelegate is AspectRatioPainter &&
        (oldDelegate.isSelected != isSelected ||
            oldDelegate.aspectRatioS != aspectRatioS ||
            oldDelegate.aspectRatio != aspectRatio);
  }
}
