// Flutter imports:
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Package imports:
import 'package:flutter_test/flutter_test.dart';

// Project imports:
import 'package:pro_image_editor/pro_image_editor.dart';

import '../../mock/mock_image.dart';

/// Reproduction for issue #850:
/// "Editor freezes after a three-finger gesture while rotating an emoji layer".
///
/// Steps from the report:
///   1. Add an emoji layer.
///   2. Rotate it with two fingers (keep both fingers down).
///   3. Tap the screen with a third finger.
///
/// On iOS this throws `assert(_dependents.isEmpty)` from
/// `InheritedElement.debugDeactivated()` and freezes the editor.
void main() {
  const configs = ProImageEditorConfigs(
    progressIndicatorConfigs: ProgressIndicatorConfigs(
      widgets: ProgressIndicatorWidgets(
        circularProgressIndicator: SizedBox.shrink(),
      ),
    ),
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
    'adding a third finger while rotating an emoji layer does not throw',
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

      // Select the emoji so the two-finger gesture scales/rotates the layer.
      state.layerInteractionManager
        ..clearSelectedLayers()
        ..addSelectedLayer(layer.id);
      await tester.pump();

      final Offset center = tester.getCenter(find.byType(ProImageEditor));

      // --- Two fingers down: start a rotate/scale gesture on the layer. ---
      final TestGesture finger1 = await tester.startGesture(
        center + const Offset(-40, 0),
        pointer: 1,
      );
      final TestGesture finger2 = await tester.startGesture(
        center + const Offset(40, 0),
        pointer: 2,
      );
      await tester.pump();

      // Move both fingers to rotate the layer (rotate around the center).
      for (int i = 1; i <= 6; i++) {
        final double angle = (pi / 12) * i;
        await finger1.moveTo(
          center + Offset(-40 * cos(angle), -40 * sin(angle)),
        );
        await finger2.moveTo(center + Offset(40 * cos(angle), 40 * sin(angle)));
        await tester.pump(const Duration(milliseconds: 16));
      }

      // --- Third finger taps while the first two are still held down. ---
      final TestGesture finger3 = await tester.startGesture(
        center + const Offset(0, 120),
        pointer: 3,
      );
      await tester.pump(const Duration(milliseconds: 16));

      // A tap = quick lift of the third finger.
      await finger3.up();
      await tester.pump(const Duration(milliseconds: 16));

      // Continue moving the two remaining fingers a little.
      await finger1.moveBy(const Offset(-5, -5));
      await finger2.moveBy(const Offset(5, 5));
      await tester.pump(const Duration(milliseconds: 16));

      // Lift the remaining fingers.
      await finger1.up();
      await finger2.up();
      await tester.pumpAndSettle();

      expect(
        tester.takeException(),
        isNull,
        reason:
            'Adding a third finger mid-rotation must not throw '
            '(issue #850).',
      );
    },
  );
}
