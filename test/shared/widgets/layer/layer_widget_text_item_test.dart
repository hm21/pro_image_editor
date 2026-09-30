import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:pro_image_editor/core/models/editor_configs/text_editor_configs.dart';
import 'package:pro_image_editor/core/models/layers/text_layer.dart';
import 'package:pro_image_editor/features/text_editor/widgets/rounded_background_text/rounded_background_text.dart';
import 'package:pro_image_editor/shared/widgets/layer/widgets/layer_widget_text_item.dart';

void main() {
  group(LayerWidgetTextItem, () {
    Future<RoundedBackgroundText> pumpLayer(
      WidgetTester tester,
      TextLayer layer,
    ) async {
      final showMoveCursor = ValueNotifier(false);
      addTearDown(showMoveCursor.dispose);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: LayerWidgetTextItem(
                layer: layer,
                textEditorConfigs: const TextEditorConfigs(),
                showMoveCursor: showMoveCursor,
                onHitChanged: (_) {},
              ),
            ),
          ),
        ),
      );
      return tester.widget<RoundedBackgroundText>(
        find.byType(RoundedBackgroundText),
      );
    }

    testWidgets('grows the outline and shadows with the rendered font size', (
      tester,
    ) async {
      const shadow = Shadow(
        color: Color(0x80000000),
        blurRadius: 4,
        offset: Offset(1, 2),
      );

      final text = await pumpLayer(
        tester,
        TextLayer(
          text: 'Hello',
          scale: 2,
          fontScale: 1.5,
          textStyle: const TextStyle(shadows: [shadow]),
          outlineWidth: 2,
          outlineColor: const Color(0xFFFF0000),
        ),
      );

      expect(text.outlineWidth, 6);
      expect(text.outlineColor, const Color(0xFFFF0000));
      expect(text.text.style?.shadows, [shadow.scale(3)]);
      expect(text.reserveEffectSpace, isTrue);
    });

    testWidgets('draws no outline for a layer without one', (tester) async {
      final text = await pumpLayer(tester, TextLayer(text: 'Hello', scale: 2));

      expect(text.outlineWidth, 0);
      expect(text.text.style?.shadows, isNull);
    });
  });
}
