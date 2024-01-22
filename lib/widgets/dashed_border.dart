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
    /*  TODO: Write code for desktop devices */
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Padding(
          padding: const EdgeInsets.all(10.0),
          child: CustomPaint(
            painter: DashedBorderPainter(color: widget.color),
            child: Padding(
              padding: const EdgeInsets.all(4.0),
              child: ConstrainedBox(
                constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
                child: Center(child: widget.child),
              ),
            ),
          ),
        ),
        Positioned(
          top: 0,
          left: 0,
          child: DraggablePoint(
            icon: Icons.pinch_outlined,
            cursor: SystemMouseCursors.click,
            onDrag: (Offset offset) {
              setState(() {
                /* width += offset.dx;
                height += offset.dy; */
              });
            },
          ),
        ),
        Positioned(
          top: 0,
          right: 0,
          child: DraggablePoint(
            icon: Icons.swipe_outlined,
            cursor: SystemMouseCursors.click,
            onDrag: (Offset offset) {
              setState(() {
                /*  width -= offset.dx;
                height += offset.dy; */
              });
            },
          ),
        ),
        Positioned(
          bottom: 0,
          left: 0,
          child: DraggablePoint(
            icon: Icons.delete_outline,
            cursor: SystemMouseCursors.click,
            onDrag: (Offset offset) {
              setState(() {
                /*  width += offset.dx;
                height -= offset.dy; */
              });
            },
          ),
        ),
        Positioned(
          bottom: 0,
          right: 0,
          child: DraggablePoint(
            icon: Icons.close,
            cursor: SystemMouseCursors.click,
            onDrag: (Offset offset) {
              setState(() {
                widget.layerData.scale -= offset.dx;
                /* width -= offset.dx;
                height -= offset.dy; */
              });
            },
          ),
        ),
      ],
    );
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
  final IconData icon;
  final MouseCursor cursor;

  const DraggablePoint({
    super.key,
    required this.onDrag,
    required this.icon,
    required this.cursor,
  });

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: cursor,
      child: Container(
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          border: Border.all(width: 0.2),
          borderRadius: BorderRadius.circular(100),
          color: Colors.white,
        ),
        child: Icon(
          icon,
          color: const Color(0xFF000000),
          size: 20,
        ),
      ),
    );
  }
}
