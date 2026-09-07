// Flutter imports:
// Package imports:
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
// Project imports:
import 'package:pro_image_editor/pro_image_editor.dart';
import 'package:pro_image_editor/shared/widgets/layer/layer_widget.dart';

void main() {
  testWidgets('LayerWidget test', (WidgetTester tester) async {
    // Create a mock layer for testing.
    final layer = TextLayer(
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
                editorBodySize: const Size(250, 250),
                layer: layer,
                configs: const ProImageEditorConfigs(),
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
