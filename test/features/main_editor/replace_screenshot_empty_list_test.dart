// Flutter imports:
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
// Package imports:
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
// Project imports:
import 'package:pro_image_editor/pro_image_editor.dart';

import '../../mock/mock_image.dart';

// Scale-end replaces the screenshot reserved at scale-start. A canvas pan
// while a layer stays selected never reserved one, and background generation
// never appends, so removeLast used to throw on an empty list.
void main() {
  const configs = ProImageEditorConfigs(
    progressIndicatorConfigs: ProgressIndicatorConfigs(
      widgets: ProgressIndicatorWidgets(
        circularProgressIndicator: SizedBox.shrink(),
      ),
    ),
    mainEditor: MainEditorConfigs(enableZoom: true),
    imageGeneration: ImageGenerationConfigs(
      enableIsolateGeneration: false,
      enableBackgroundGeneration: false,
    ),
  );

  Future<ProImageEditorState> pumpEditor(WidgetTester tester) async {
    final key = GlobalKey<ProImageEditorState>();
    await tester.pumpWidget(
      MaterialApp(
        home: ProImageEditor.memory(
          mockMemoryImage,
          key: key,
          configs: configs,
          callbacks: ProImageEditorCallbacks(
            onImageEditingComplete: (Uint8List bytes) async {},
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    return key.currentState!;
  }

  testWidgets(
    'panning with a selected layer does not throw when screenshots are empty',
    (tester) async {
      final state = await pumpEditor(tester);

      final layer = EmojiLayer(
        emoji: '😀',
        offset: Offset.zero,
        scale: 1,
        rotation: 0,
      );
      state.addLayer(
        layer,
        autoCorrectZoomOffset: false,
        autoCorrectZoomScale: false,
      );
      await tester.pump();

      state.layerInteractionManager
        ..clearSelectedLayers()
        ..addSelectedLayer(layer.id);
      await tester.pump();

      expect(state.stateManager.screenshots, isEmpty);

      final Offset center = tester.getCenter(find.byType(ProImageEditor));
      final TestGesture gesture = await tester.startGesture(
        center,
        kind: PointerDeviceKind.mouse,
        buttons: kMiddleMouseButton,
      );
      await tester.pump();
      await gesture.moveBy(const Offset(40, 20));
      await tester.pump();
      await gesture.up();
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    },
  );
}
