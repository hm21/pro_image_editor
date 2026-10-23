import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:pro_image_editor/pro_image_editor.dart';

import '../../mock/mock_image.dart';

void main() {
  const text = 'The quick brown fox jumps over the lazy dog';

  Future<ProImageEditorState> pumpEditor(WidgetTester tester) async {
    final key = GlobalKey<ProImageEditorState>();
    await tester.pumpWidget(
      MaterialApp(
        home: ProImageEditor.memory(
          mockMemoryImage,
          key: key,
          configs: ProImageEditorConfigs(
            progressIndicatorConfigs: const ProgressIndicatorConfigs(
              widgets: ProgressIndicatorWidgets(
                circularProgressIndicator: SizedBox.shrink(),
              ),
            ),
            imageGeneration: const ImageGenerationConfigs(
              enableIsolateGeneration: false,
              enableBackgroundGeneration: false,
            ),
            textEditor: TextEditorConfigs(
              layerBounds: (editorBodySize) => Offset.zero & editorBodySize,
            ),
          ),
          callbacks: ProImageEditorCallbacks(
            onImageEditingComplete: (Uint8List bytes) async {},
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    return key.currentState!;
  }

  group('ProImageEditorState.textLayerWrapsAtBounds', () {
    testWidgets('reports a layer the bounds wrap', (tester) async {
      final state = await pumpEditor(tester);

      expect(
        state.textLayerWrapsAtBounds(TextLayer(text: text, scale: 6)),
        isTrue,
      );
    });

    testWidgets('ignores a layer that fits inside the bounds', (tester) async {
      final state = await pumpEditor(tester);

      expect(
        state.textLayerWrapsAtBounds(TextLayer(text: 'Hi', scale: 1)),
        isFalse,
      );
    });

    testWidgets('ignores a layer that does not wrap at the bounds', (
      tester,
    ) async {
      final state = await pumpEditor(tester);

      expect(
        state.textLayerWrapsAtBounds(
          TextLayer(text: text, scale: 6, wrapAtLayerBounds: false),
        ),
        isFalse,
      );
    });
  });
}
