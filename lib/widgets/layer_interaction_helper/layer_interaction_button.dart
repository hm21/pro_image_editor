// Flutter imports:
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
  final Color background;
  final Color color;

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
    required this.color,
    required this.background,
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
                  borderRadius: BorderRadius.circular(buttonRadius * 2),
                  color: background,
                ),
                child: Icon(
                  icon,
                  color: color,
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
