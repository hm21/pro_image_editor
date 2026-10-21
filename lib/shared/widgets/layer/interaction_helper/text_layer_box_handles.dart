import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';

import '/core/models/layers/text_layer_box.dart';

/// Handles on the edges, and optionally the corners, of a text layer's
/// [TextLayerBox] that resize the box when dragged.
///
/// Place it over the layer in the selection overlay, in the layer's own
/// space (inside the transform that places the layer), filling the area
/// whose edges lie [boxInset] outside the box. A pressed handle calls
/// [onResizeDown]; the editor's own drag gesture then resizes the box, and
/// [onResizeUp] ends the resize. Wire them to
/// `LayerItemInteractions.textBoxResizeDown` and `textBoxResizeUp`.
///
/// A handle reaches [size] / 2 beyond the box edge, so [boxInset] should be
/// at least that, or the outer half of each handle cannot be hit.
class TextLayerBoxHandles extends StatelessWidget {
  /// Creates [TextLayerBoxHandles].
  const TextLayerBoxHandles({
    super.key,
    required this.onResizeDown,
    required this.onResizeUp,
    this.handles = TextLayerBoxHandle.values,
    this.boxInset = EdgeInsets.zero,
    this.size = 12,
    this.color = Colors.blue,
    this.fillColor = Colors.white,
    this.rotation = 0,
  });

  /// Called when a handle is pressed.
  final void Function(PointerDownEvent event, TextLayerBoxHandle handle)
  onResizeDown;

  /// Called when the pressed handle is let go, or the press is canceled.
  final void Function(PointerUpEvent event) onResizeUp;

  /// The handles to show.
  final List<TextLayerBoxHandle> handles;

  /// How far inside this widget the box edges lie.
  final EdgeInsets boxInset;

  /// The side of the square each handle can be grabbed in. Edge handles are
  /// drawn as a bar along the edge, corners as a square.
  final double size;

  /// The color of the handle outlines.
  final Color color;

  /// The color the handles are filled with.
  final Color fillColor;

  /// The rotation of the layer, which turns the resize cursors with it.
  final double rotation;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final box = boxInset.deflateRect(Offset.zero & constraints.biggest);
        return Stack(
          clipBehavior: Clip.none,
          children: [
            for (final handle in handles)
              Positioned(
                left: box.center.dx + handle.x * box.width / 2 - size / 2,
                top: box.center.dy + handle.y * box.height / 2 - size / 2,
                width: size,
                height: size,
                child: _buildHandle(handle),
              ),
          ],
        );
      },
    );
  }

  Widget _buildHandle(TextLayerBoxHandle handle) {
    final isCorner = handle.x != 0 && handle.y != 0;
    final thickness = size / 2;
    // Like the layer buttons, a handle hears the press but lets it through,
    // so the editor's own drag gesture still starts and does the resizing.
    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerDown: (event) => onResizeDown(event, handle),
      onPointerUp: onResizeUp,
      onPointerCancel: (event) => onResizeUp(
        PointerUpEvent(
          pointer: event.pointer,
          position: event.position,
          timeStamp: event.timeStamp,
        ),
      ),
      child: MouseRegion(
        cursor: _cursorFor(handle),
        hitTestBehavior: HitTestBehavior.translucent,
        child: IgnorePointer(
          child: Center(
            child: Container(
              width: isCorner || handle.x != 0 ? thickness : size,
              height: isCorner || handle.y != 0 ? thickness : size,
              decoration: BoxDecoration(
                color: fillColor,
                border: Border.all(color: color, width: size / 12),
                borderRadius: BorderRadius.circular(isCorner ? 1 : thickness),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// The resize cursor closest to the direction [handle] moves in on
  /// screen.
  MouseCursor _cursorFor(TextLayerBoxHandle handle) {
    final angle = math.atan2(handle.y.toDouble(), handle.x.toDouble());
    // Cursors repeat every half turn; split that into four directions.
    final turned = (angle + rotation) % math.pi;
    final step = ((turned < 0 ? turned + math.pi : turned) / (math.pi / 4))
        .round();
    return switch (step % 4) {
      0 => SystemMouseCursors.resizeLeftRight,
      1 => SystemMouseCursors.resizeUpLeftDownRight,
      2 => SystemMouseCursors.resizeUpDown,
      _ => SystemMouseCursors.resizeUpRightDownLeft,
    };
  }
}
