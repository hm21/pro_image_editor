// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
// Package imports:
import 'package:flutter_test/flutter_test.dart';
import 'package:pro_image_editor/features/paint_editor/enums/paint_editor_enum.dart';
import 'package:pro_image_editor/features/paint_editor/models/painted_model.dart';
import 'package:pro_image_editor/features/paint_editor/widgets/draw_paint_item.dart';

void main() {
  testWidgets('DrawCanvas should handle hit testing for different modes',
      (WidgetTester tester) async {
    // Define a list of modes to test
    final paintModes = [
      PaintMode.line,
      PaintMode.dashLine,
      PaintMode.dashDotLine,
      PaintMode.arrow,
      PaintMode.freeStyle,
      PaintMode.rect,
      PaintMode.circle,
    ];

    for (final mode in paintModes) {
      // Create a PaintedModel with the current mode
      final paintedModel = PaintedModel(
        color: const Color(0xFFFF0000),
        mode: mode,
        offsets: [const Offset(0, 0), const Offset(50, 50)],
        erasedOffsets: [],
        strokeWidth: 5.0,
        fill: true,
        opacity: 1,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomPaint(
              painter: DrawPaintItem(
                item: paintedModel,
                scale: 1.0,
                enabledHitDetection: true,
              ),
            ),
          ),
        ),
      );

      final customPaintFinder = find.byType(CustomPaint).first;

      final isHit = tester.renderObject<RenderBox>(customPaintFinder).hitTest(
            BoxHitTestResult(),
            position: tester.getCenter(customPaintFinder),
          );

      expect(isHit, true);
    }
  });
}
