import 'dart:math';

import 'package:flutter/material.dart';

import '../models/layer.dart';

class LayerDashedBorderHelper extends StatefulWidget {
  final Widget child;
  final Color color;

  /// Data for the layer.
  final Layer layerData;

  const LayerDashedBorderHelper({
    super.key,
    required this.layerData,
    required this.child,
    required this.color,
  });

  @override
  State<LayerDashedBorderHelper> createState() =>
      _LayerDashedBorderHelperState();
}

class _LayerDashedBorderHelperState extends State<LayerDashedBorderHelper> {
  @override
  Widget build(BuildContext context) {
    return widget.child;
    /* TODO: Write code for desktop devices
    return Stack(
      clipBehavior: Clip.none,
      children: [
        CustomPaint(
          painter: DashedBorderPainter(color: widget.color),
          child: widget.child,
        ),
        Positioned(
          top: -7,
          left: -7,
          child: DraggablePoint(
            onDrag: (Offset offset) {
              setState(() {
                /* width += offset.dx;
                height += offset.dy; */
              });
            },
          ),
        ),
        Positioned(
          top: -7,
          right: -7,
          child: DraggablePoint(
            onDrag: (Offset offset) {
              setState(() {
                /*  width -= offset.dx;
                height += offset.dy; */
              });
            },
          ),
        ),
        Positioned(
          bottom: -7,
          left: -7,
          child: DraggablePoint(
            onDrag: (Offset offset) {
              setState(() {
                /*  width += offset.dx;
                height -= offset.dy; */
              });
            },
          ),
        ),
        Positioned(
          bottom: -7,
          right: -7,
          child: DraggablePoint(
            onDrag: (Offset offset) {
              setState(() {
                widget.layerData.scale -= offset.dx;
                /* width -= offset.dx;
                height -= offset.dy; */
              });
            },
          ),
        ),
        Positioned.fill(
          child: widget.child,
        ),
      ],
    );
 */
  }
}

class DashedBorderPainter extends CustomPainter {
  final Color color;
  DashedBorderPainter({
    required this.color,
  });
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    const dashWidth = 6;
    const dashSpace = 5;
    const startVal = 3.0;

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

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}

class DraggablePoint extends StatelessWidget {
  final Function(Offset) onDrag;

  const DraggablePoint({
    super.key,
    required this.onDrag,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 14,
      height: 14,
      decoration: BoxDecoration(
        border: Border.all(
          width: 0.2,
        ),
        borderRadius: BorderRadius.circular(10),
        color: Colors.white,
      ),
    );
  }
}
