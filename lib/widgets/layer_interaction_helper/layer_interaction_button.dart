import 'package:flutter/material.dart';

class LayerInteractionButton extends StatelessWidget {
  final Function(PointerDownEvent)? onScaleRotateDown;
  final Function(PointerUpEvent)? onScaleRotateUp;
  final Function(bool) toogleTooltipVisibility;
  final Function()? onTap;
  final IconData icon;
  final MouseCursor cursor;
  final double buttonRadius;
  final double rotation;
  final String tooltip;

  const LayerInteractionButton({
    super.key,
    this.onScaleRotateDown,
    this.onScaleRotateUp,
    this.onTap,
    required this.toogleTooltipVisibility,
    required this.icon,
    required this.cursor,
    required this.buttonRadius,
    required this.rotation,
    required this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: rotation,
      child: MouseRegion(
        cursor: cursor,
        child: Listener(
          onPointerDown: onScaleRotateDown,
          onPointerUp: onScaleRotateUp,
          child: GestureDetector(
            onTap: onTap,
            child: Tooltip(
              message: tooltip,
              child: Container(
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(100),
                  color: Colors.white,
                ),
                child: Icon(
                  icon,
                  color: const Color(0xFF000000),
                  size: buttonRadius * 2,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
