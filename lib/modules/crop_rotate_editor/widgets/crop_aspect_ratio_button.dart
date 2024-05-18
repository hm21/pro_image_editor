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
    final Color color = isSelected ? Colors.blue : Colors.grey;
    final Rect rect = Offset.zero & size;
    final Paint paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    final double aspectRatioResult =
        (aspectRatio != null && aspectRatio! > 0.0) ? aspectRatio! : 1.0;

    canvas.drawRect(
      _getPaintRect(
        rect: const EdgeInsets.all(7.0).deflateRect(rect),
        inputSize: Size(aspectRatioResult * 100, 100.0),
      ),
      paint,
    );

    final TextPainter textPainter = TextPainter(
        text: TextSpan(
            text: '',
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
            oldDelegate.aspectRatio != aspectRatio);
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
