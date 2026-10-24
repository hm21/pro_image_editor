import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:pro_image_editor/features/text_editor/widgets/rounded_background_text/rounded_background_text.dart';
import 'package:pro_image_editor/pro_image_editor.dart';

import '../../mock/mock_image.dart';

/// Hovering a text layer must leave its painted text alone, or the text
/// shifts by a fraction of a pixel on screen.
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
    layerInteraction: LayerInteractionConfigs(
      selectable: LayerInteractionSelectable.enabled,
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

  RenderCustomPaint textPaint(WidgetTester tester) {
    return tester.renderObject<RenderCustomPaint>(
      find.descendant(
        of: find.byType(RoundedBackgroundText),
        matching: find.byType(CustomPaint),
      ),
    );
  }

  for (final selected in [false, true]) {
    testWidgets(
      'hovering in and out does not repaint the text (selected: $selected)',
      (tester) async {
        final state = await pumpEditor(tester);
        state.addLayer(
          TextLayer(text: 'Name', background: const Color(0xFFFF0000)),
          autoCorrectZoomOffset: false,
          autoCorrectZoomScale: false,
        );
        if (!selected) state.unselectAllLayers();
        await tester.pumpAndSettle();

        final rect = tester.getRect(find.byType(RoundedBackgroundText));
        final outside = rect.topLeft - const Offset(40, 40);
        final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
        await mouse.addPointer(location: outside);
        addTearDown(mouse.removePointer);
        await tester.pump();

        final layer = state.activeLayers.single as TextLayer;
        final painted = <RenderObject>[];
        debugProfilePaintsEnabled = true;
        debugOnProfilePaint = painted.add;
        try {
          for (final (position, hit) in [
            (rect.center, true),
            (outside, false),
            (rect.center, true),
            (outside, false),
          ]) {
            await mouse.moveTo(position);
            await tester.pump();
            expect(layer.hit, hit);
            expect(painted, isNot(contains(textPaint(tester))));
          }
        } finally {
          // The binding checks these before tear-downs run.
          debugOnProfilePaint = null;
          debugProfilePaintsEnabled = false;
        }
      },
      variant: TargetPlatformVariant.only(TargetPlatform.linux),
    );
  }

  testWidgets('the text is never raster cached', (tester) async {
    final state = await pumpEditor(tester);
    state.addLayer(TextLayer(text: 'Name'));
    await tester.pumpAndSettle();

    // A cached picture is drawn at whole pixels, the live one is not.
    expect(textPaint(tester).willChange, isTrue);
    expect(textPaint(tester).isComplex, isFalse);
  });
}
