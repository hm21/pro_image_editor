import 'dart:math';

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

    group('layerBounds', () {
      const bodySize = Size(300, 500);
      const text = 'The quick brown fox jumps over the lazy dog';

      Rect fullBody(Size editorBodySize) => Offset.zero & editorBodySize;

      Future<Size> pumpSized(
        WidgetTester tester,
        TextLayer layer, {
        Size editorBodySize = bodySize,
        Rect Function(Size editorBodySize)? layerBounds,
      }) async {
        final showMoveCursor = ValueNotifier(false);
        addTearDown(showMoveCursor.dispose);

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: OverflowBox(
                maxWidth: double.infinity,
                maxHeight: double.infinity,
                child: Center(
                  child: LayerWidgetTextItem(
                    layer: layer,
                    textEditorConfigs: TextEditorConfigs(
                      layerBounds: layerBounds,
                    ),
                    editorBodySize: editorBodySize,
                    showMoveCursor: showMoveCursor,
                    onHitChanged: (_) {},
                  ),
                ),
              ),
            ),
          ),
        );
        return tester.getSize(find.byType(RoundedBackgroundText));
      }

      testWidgets('wraps a scaled-up layer to stay within the bounds', (
        tester,
      ) async {
        final oneLine = await pumpSized(
          tester,
          TextLayer(text: text, scale: 3),
        );
        final wrapped = await pumpSized(
          tester,
          TextLayer(text: text, scale: 3),
          layerBounds: fullBody,
        );

        expect(oneLine.width, greaterThan(bodySize.width));
        expect(wrapped.width, lessThanOrEqualTo(bodySize.width));
        expect(wrapped.height, greaterThan(oneLine.height * 2));
      });

      testWidgets('unwraps the layer again when it is scaled back down', (
        tester,
      ) async {
        final layer = TextLayer(text: 'Hello world', scale: 3);
        final wrapped = await pumpSized(tester, layer, layerBounds: fullBody);

        layer.scale = 0.5;
        final scaledDown = await pumpSized(
          tester,
          layer,
          layerBounds: fullBody,
        );
        final unconstrained = await pumpSized(tester, layer);

        expect(wrapped.width, lessThanOrEqualTo(bodySize.width));
        expect(scaledDown, unconstrained);
      });

      testWidgets('wraps a layer moved towards an edge and unwraps it when '
          'moved back', (tester) async {
        final layer = TextLayer(text: 'ab cd ef');
        final centered = await pumpSized(tester, layer, layerBounds: fullBody);

        // 50 px from the right edge leaves room for a 100 px wide layer.
        layer.offset = const Offset(100, 0);
        final atEdge = await pumpSized(tester, layer, layerBounds: fullBody);

        layer.offset = Offset.zero;
        final movedBack = await pumpSized(tester, layer, layerBounds: fullBody);

        expect(centered.width, greaterThan(100));
        expect(atEdge.width, lessThanOrEqualTo(100));
        expect(atEdge.height, greaterThan(centered.height * 2));
        expect(movedBack, centered);
      });

      testWidgets('keeps its longest word whole at an edge', (tester) async {
        final word = await pumpSized(tester, TextLayer(text: 'Hello'));
        final atEdge = await pumpSized(
          tester,
          TextLayer(text: 'Hello world', offset: const Offset(140, 0)),
          layerBounds: fullBody,
        );

        expect(atEdge.width, word.width);
        expect(atEdge.height, greaterThan(word.height * 1.5));
      });

      testWidgets('breaks a word wider than the bounds', (tester) async {
        final size = await pumpSized(
          tester,
          TextLayer(text: 'Supercalifragilistic'),
          layerBounds: fullBody,
        );

        expect(size.width, lessThanOrEqualTo(bodySize.width));
      });

      testWidgets('measures a rotated layer along its text', (tester) async {
        final size = await pumpSized(
          tester,
          TextLayer(text: text, scale: 3, rotation: pi / 2),
          layerBounds: fullBody,
        );

        // Turned upright, the text runs along the taller side of the bounds.
        expect(size.width, greaterThan(bodySize.width));
        expect(size.width, lessThanOrEqualTo(bodySize.height));
      });

      testWidgets('derives the bounds from the editor body size', (
        tester,
      ) async {
        final sizes = <Size>[];
        final size = await pumpSized(
          tester,
          TextLayer(text: text, scale: 3),
          layerBounds: (editorBodySize) {
            sizes.add(editorBodySize);
            return Rect.fromCenter(
              center: editorBodySize.center(Offset.zero),
              width: editorBodySize.width / 2,
              height: editorBodySize.height,
            );
          },
        );

        expect(sizes, everyElement(bodySize));
        expect(size.width, lessThanOrEqualTo(bodySize.width / 2));
      });

      testWidgets('sets no limit before the editor body has a size', (
        tester,
      ) async {
        var calls = 0;
        final size = await pumpSized(
          tester,
          TextLayer(text: text, scale: 3),
          editorBodySize: Size.zero,
          layerBounds: (editorBodySize) {
            calls++;
            return fullBody(editorBodySize);
          },
        );

        expect(calls, 0);
        expect(size.width, greaterThan(bodySize.width));
      });

      testWidgets('keeps a narrower maxTextWidth of the layer', (tester) async {
        final size = await pumpSized(
          tester,
          TextLayer(text: text, maxTextWidth: 50),
          layerBounds: fullBody,
        );

        expect(size.width, lessThan(bodySize.width / 2));
      });
    });
  });
}
