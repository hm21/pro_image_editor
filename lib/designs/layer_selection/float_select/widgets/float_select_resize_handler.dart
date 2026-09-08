import 'package:material_ui/material_ui.dart';

import '/core/models/custom_widgets/layer_interaction_widgets.dart';
import '../utils/float_select_transparent_hit_test.dart';

/// A resize/rotate corner handler for FloatSelect items
class FloatSelectResizeRotateHandler extends StatelessWidget {
  /// Creates a handler with style and interaction config
  const FloatSelectResizeRotateHandler({
    super.key,
    required this.strokeWidth,
    required this.handlerLength,
    required this.rotationCount,
    required this.strokeColor,
    required this.interactions,
  });

  /// Stroke width of the handler arms
  final double strokeWidth;

  /// Total length of each handler arm
  final double handlerLength;

  /// Number of 90° rotations applied to the handler
  final int rotationCount;

  /// Color of the handler
  final Color strokeColor;

  /// Callbacks for scale and rotate interactions
  final LayerItemInteractions interactions;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      hitTestBehavior: HitTestBehavior.translucent,
      cursor: rotationCount.isEven
          ? SystemMouseCursors.resizeUpRightDownLeft
          : SystemMouseCursors.resizeUpLeftDownRight,
      child: Listener(
        behavior: HitTestBehavior.translucent,
        onPointerDown: interactions.scaleRotateDown,
        onPointerUp: interactions.scaleRotateUp,
        child: HitTestTransparent(
          child: RotatedBox(
            quarterTurns: rotationCount,
            child: Stack(
              alignment: Alignment.bottomLeft,
              children: [
                Container(
                  width: strokeWidth,
                  height: handlerLength,
                  color: strokeColor,
                ),
                Container(
                  width: handlerLength,
                  height: strokeWidth,
                  color: strokeColor,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
