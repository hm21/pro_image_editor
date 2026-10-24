import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:pro_image_editor/pro_image_editor.dart';

import '../../../mock/mock_image.dart';

void main() {
  const overlayKey = ValueKey('selection-overlay');

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
            layerInteraction: LayerInteractionConfigs(
              selectable: LayerInteractionSelectable.enabled,
              widgets: LayerInteractionWidgets(
                overlayChildBuilder: (rebuildStream, _, _, _) => ReactiveWidget(
                  stream: rebuildStream,
                  builder: (_) =>
                      const SizedBox(key: overlayKey, width: 10, height: 10),
                ),
              ),
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

  testWidgets('a layer selected as it is added shows its overlay', (
    tester,
  ) async {
    final state = await pumpEditor(tester);
    final layer = TextLayer(text: 'Name');
    state
      ..addLayer(
        layer,
        autoCorrectZoomOffset: false,
        autoCorrectZoomScale: false,
      )
      ..selectLayerById(layer.id);
    await tester.pumpAndSettle();

    expect(find.byKey(overlayKey), findsOneWidget);
  });
}
