import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:pro_image_editor/core/models/layers/layer.dart';
import 'package:pro_image_editor/shared/widgets/layer/interaction_helper/text_layer_box_handles.dart';

void main() {
  group(TextLayerBoxHandles, () {
    testWidgets('reports the pressed handle and lets the drag through', (
      tester,
    ) async {
      final pressed = <TextLayerBoxHandle>[];
      var released = 0;
      var dragged = Offset.zero;

      await tester.pumpWidget(
        MaterialApp(
          home: Stack(
            children: [
              // Stands in for the editor's own drag gesture, which does the
              // resizing.
              Positioned.fill(
                child: GestureDetector(
                  onPanUpdate: (details) => dragged += details.delta,
                ),
              ),
              Positioned(
                left: 100,
                top: 100,
                width: 216,
                height: 116,
                child: TextLayerBoxHandles(
                  boxInset: const EdgeInsets.all(8),
                  onResizeDown: (_, handle) => pressed.add(handle),
                  onResizeUp: (_) => released++,
                ),
              ),
            ],
          ),
        ),
      );

      // The right edge of the 200×100 box, halfway down.
      final gesture = await tester.startGesture(const Offset(308, 158));
      await gesture.moveBy(const Offset(40, 0));
      await gesture.moveBy(const Offset(10, 0));
      await gesture.up();

      expect(pressed, [TextLayerBoxHandle.right]);
      expect(released, 1);
      expect(dragged.dx, greaterThan(0));
    });
  });
}
