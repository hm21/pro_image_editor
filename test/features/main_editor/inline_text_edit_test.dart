import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:pro_image_editor/features/text_editor/widgets/rounded_background_text/rounded_background_text_field.dart';
import 'package:pro_image_editor/pro_image_editor.dart';
import 'package:pro_image_editor/shared/widgets/adaptive_dialog.dart';

import '../../mock/mock_image.dart';

void main() {
  const inlineConfigs = ProImageEditorConfigs(
    progressIndicatorConfigs: ProgressIndicatorConfigs(
      widgets: ProgressIndicatorWidgets(
        circularProgressIndicator: SizedBox.shrink(),
      ),
    ),
    imageGeneration: ImageGenerationConfigs(
      enableIsolateGeneration: false,
      enableBackgroundGeneration: false,
    ),
    textEditor: TextEditorConfigs(enableInlineEditing: true),
  );

  Future<ProImageEditorState> pumpEditor(
    WidgetTester tester, {
    ProImageEditorConfigs configs = inlineConfigs,
  }) async {
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

  test('inline editing stays off unless a host turns it on', () {
    expect(const TextEditorConfigs().enableInlineEditing, isFalse);
  });

  testWidgets('typing on the layer replaces its text once', (tester) async {
    final state = await pumpEditor(tester);
    final layer = TextLayer(text: 'Name', scale: 1);
    state.addLayer(
      layer,
      autoCorrectZoomOffset: false,
      autoCorrectZoomScale: false,
    );
    await tester.pump();

    state.beginInlineTextEdit(layer, selectAll: true);
    await tester.pump();

    expect(find.byType(TextEditor), findsNothing);
    expect(find.byType(EditableText), findsOneWidget);
    expect(state.activeLayers.whereType<TextLayer>().single.text, 'Name');

    await tester.enterText(find.byType(EditableText), 'Hello');
    state.inlineTextEdit!.done();
    await tester.pump();

    final written = state.activeLayers.whereType<TextLayer>().single;
    expect(written.text, 'Hello');
    expect(written.id, layer.id);
    expect(state.inlineTextEdit, isNull);
    expect(find.byType(EditableText), findsNothing);
  });

  testWidgets('clearing the text removes the layer', (tester) async {
    final state = await pumpEditor(tester);
    final layer = TextLayer(text: 'Name');
    state.addLayer(
      layer,
      autoCorrectZoomOffset: false,
      autoCorrectZoomScale: false,
    );
    await tester.pump();
    state.beginInlineTextEdit(layer);
    await tester.pump();

    state.inlineTextEdit!.textCtrl.text = '   ';
    state.inlineTextEdit!.done();
    await tester.pump();

    expect(state.activeLayers.whereType<TextLayer>(), isEmpty);
  });

  testWidgets('a text box keeps its size while it is edited', (tester) async {
    final state = await pumpEditor(tester);
    final layer = TextLayer(
      text: 'Name',
      scale: 2,
      box: const TextLayerBox(size: Size(120, 40)),
    );
    state.addLayer(
      layer,
      autoCorrectZoomOffset: false,
      autoCorrectZoomScale: false,
    );
    await tester.pump();
    state.beginInlineTextEdit(layer);
    await tester.pump();

    expect(
      tester.getSize(find.byType(RoundedBackgroundTextField)),
      const Size(240, 80),
    );

    state.inlineTextEdit!.textCtrl.text = 'Longer name';
    state.inlineTextEdit!.done();
    await tester.pump();

    final written = state.activeLayers.whereType<TextLayer>().single;
    expect(written.text, 'Longer name');
    expect(written.box!.size, const Size(120, 40));
    expect(written.scale, 2);
  });

  testWidgets('editor shortcuts do not move or undo a layer being typed', (
    tester,
  ) async {
    final state = await pumpEditor(tester);
    final layer = TextLayer(
      text: 'Name',
      offset: const Offset(12, 24),
      scale: 1.5,
      rotation: 0.2,
    );
    state.addLayer(
      layer,
      autoCorrectZoomOffset: false,
      autoCorrectZoomScale: false,
    );
    await tester.pump();
    state.beginInlineTextEdit(layer);
    await tester.pump();
    // The field records its current text, then a later edit can be undone.
    await tester.pump(const Duration(milliseconds: 500));

    final live = state.activeLayers.whereType<TextLayer>().single;
    final history = state.stateManager.historyPointer;
    await tester.enterText(find.byType(EditableText), 'NameX');
    await tester.pump(const Duration(milliseconds: 500));

    await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp);
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
    await tester.pump();

    final placed = state.activeLayers.whereType<TextLayer>().single;
    expect(placed.offset, live.offset);
    expect(placed.scale, live.scale);
    expect(placed.rotation, live.rotation);
    expect(state.stateManager.historyPointer, history);

    final undoModifier =
        defaultTargetPlatform == TargetPlatform.macOS ||
            defaultTargetPlatform == TargetPlatform.iOS
        ? LogicalKeyboardKey.metaLeft
        : LogicalKeyboardKey.controlLeft;
    await tester.sendKeyDownEvent(undoModifier);
    await tester.sendKeyEvent(LogicalKeyboardKey.keyZ);
    await tester.sendKeyUpEvent(undoModifier);
    await tester.pump();

    expect(state.inlineTextEdit, isNotNull);
    expect(state.inlineTextEdit!.textCtrl.text, 'Name');
    expect(state.stateManager.historyPointer, history);
    expect(state.activeLayers.whereType<TextLayer>().single.rotation, 0.2);

    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pump();

    expect(state.mounted, isTrue);
    expect(find.byType(ProImageEditor), findsOneWidget);
    expect(find.byType(AdaptiveDialog), findsNothing);
    expect(state.inlineTextEdit, isNull);
    expect(state.activeLayers.whereType<TextLayer>().single.text, 'Name');
  });

  testWidgets('capture writes the typed text before the field is recorded', (
    tester,
  ) async {
    final state = await pumpEditor(tester);
    final layer = TextLayer(text: 'Name');
    state.addLayer(
      layer,
      autoCorrectZoomOffset: false,
      autoCorrectZoomScale: false,
    );
    await tester.pump();
    state.beginInlineTextEdit(layer);
    await tester.pump();
    await tester.enterText(find.byType(EditableText), 'Hello');

    final capturing = state.captureEditorImage();
    var captured = false;
    unawaited(
      capturing.then((_) => captured = true, onError: (_) => captured = true),
    );
    await tester.pump();
    // The field is gone, and the image future has not returned yet.
    expect(captured, isFalse);
    expect(find.byType(EditableText), findsNothing);
    expect(state.activeLayers.whereType<TextLayer>().single.text, 'Hello');
    expect(state.inlineTextEdit, isNull);
  });

  testWidgets('export writes the typed text without closing the field first', (
    tester,
  ) async {
    final state = await pumpEditor(tester);
    final layer = TextLayer(text: 'Name');
    state.addLayer(
      layer,
      autoCorrectZoomOffset: false,
      autoCorrectZoomScale: false,
    );
    await tester.pump();
    state.beginInlineTextEdit(layer);
    await tester.pump();
    await tester.enterText(find.byType(EditableText), 'Hello');

    unawaited(state.exportStateHistory().then((_) {}, onError: (_) {}));
    await tester.pump();
    expect(find.byType(EditableText), findsNothing);
    expect(state.activeLayers.whereType<TextLayer>().single.text, 'Hello');
    expect(state.inlineTextEdit, isNull);
  });

  testWidgets('the full-screen editor still opens when inline editing is off', (
    tester,
  ) async {
    final state = await pumpEditor(
      tester,
      configs: const ProImageEditorConfigs(
        progressIndicatorConfigs: ProgressIndicatorConfigs(
          widgets: ProgressIndicatorWidgets(
            circularProgressIndicator: SizedBox.shrink(),
          ),
        ),
        imageGeneration: ImageGenerationConfigs(
          enableIsolateGeneration: false,
          enableBackgroundGeneration: false,
        ),
      ),
    );
    final layer = TextLayer(text: 'Name');
    state.addLayer(
      layer,
      autoCorrectZoomOffset: false,
      autoCorrectZoomScale: false,
    );
    await tester.pump();

    state.editTextLayer(layer);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.byType(TextEditor), findsOneWidget);
    expect(state.inlineTextEdit, isNull);
  });
}
