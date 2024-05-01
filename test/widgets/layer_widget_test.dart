import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pro_image_editor/models/layer.dart';
import 'package:pro_image_editor/pro_image_editor.dart';
import 'package:pro_image_editor/widgets/layer_widget.dart';

void main() {
  testWidgets('LayerWidget test', (WidgetTester tester) async {
    // Create a mock layer for testing.
    final layer = TextLayerData(
      text: 'Test Text',
      color: Colors.white,
      background: Colors.blue,
      offset: const Offset(10, 10),
      align: TextAlign.center,
      flipX: false,
      flipY: false,
      rotation: 0.0,
      scale: 1.0,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Stack(
            children: [
              LayerWidget(
                layerData: layer,
                padding: EdgeInsets.zero,
                onTapDown: () {},
                onTapUp: () {},
                onTap: (Layer layer) {
                  expect(layer, equals(layer));
                },
                configs: const ProImageEditorConfigs(),
                onEditTap: () {},
                onRemoveTap: () {},
                enableHitDetection: true,
                freeStyleHighPerformanceScaling: true,
                freeStyleHighPerformanceMoving: true,
              ),
            ],
          ),
        ),
      ),
    );

    expect(find.byType(LayerWidget), findsOneWidget);

    await tester.tapAt(const Offset(11, 11));
  });
}
