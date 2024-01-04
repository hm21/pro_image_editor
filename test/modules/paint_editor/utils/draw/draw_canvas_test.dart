import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pro_image_editor/models/paint_editor/painted_model.dart';
import 'package:pro_image_editor/modules/paint_editor/utils/draw/draw_canvas.dart';
import 'package:pro_image_editor/modules/paint_editor/utils/paint_editor_enum.dart';

void main() {
  testWidgets('DrawCanvas should handle hit testing for different modes',
      (WidgetTester tester) async {
    // Define a list of modes to test
    final paintModes = [
      PaintModeE.line,
      PaintModeE.dashLine,
      PaintModeE.arrow,
      PaintModeE.freeStyle,
      PaintModeE.rect,
      PaintModeE.circle,
    ];

    for (final mode in paintModes) {
      // Create a PaintedModel with the current mode
      final paintedModel = PaintedModel(
        color: const Color(0xFFFF0000),
        mode: mode,
        offsets: [const Offset(0, 0), const Offset(50, 50)],
        strokeWidth: 5.0,
        fill: true,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomPaint(
              painter: DrawCanvas(
                item: paintedModel,
                scale: 1.0,
                enabledHitDetection: true,
                freeStyleHighPerformanceScaling: true,
                freeStyleHighPerformanceMoving: true,
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
