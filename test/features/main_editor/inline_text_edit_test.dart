import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:pro_image_editor/features/text_editor/widgets/rounded_background_text/rounded_background_text.dart';
import 'package:pro_image_editor/features/text_editor/widgets/rounded_background_text/rounded_background_text_field.dart';
import 'package:pro_image_editor/pro_image_editor.dart';
import 'package:pro_image_editor/shared/widgets/adaptive_dialog.dart';
import 'package:pro_image_editor/shared/widgets/layer/layer_widget.dart';

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

  testWidgets('typing on the layer keeps its blend mode', (tester) async {
    final state = await pumpEditor(tester);
    final layer = TextLayer(
      text: 'Name',
      scale: 1,
      blendMode: BlendMode.multiply,
    );
    state.addLayer(
      layer,
      autoCorrectZoomOffset: false,
      autoCorrectZoomScale: false,
    );
    await tester.pump();

    state.beginInlineTextEdit(layer, selectAll: true);
    await tester.pump();
    await tester.enterText(find.byType(EditableText), 'Hello');
    state.inlineTextEdit!.done();
    await tester.pump();

    final written = state.activeLayers.whereType<TextLayer>().single;
    expect(written.text, 'Hello');
    expect(written.blendMode, BlendMode.multiply);
  });

  testWidgets('typing on the layer keeps it from wrapping at the bounds', (
    tester,
  ) async {
    final state = await pumpEditor(tester);
    final layer = TextLayer(text: 'Name', scale: 1, wrapAtLayerBounds: false);
    state.addLayer(
      layer,
      autoCorrectZoomOffset: false,
      autoCorrectZoomScale: false,
    );
    await tester.pump();

    state.beginInlineTextEdit(layer, selectAll: true);
    await tester.pump();
    await tester.enterText(find.byType(EditableText), 'Hello');
    state.inlineTextEdit!.done();
    await tester.pump();

    final written = state.activeLayers.whereType<TextLayer>().single;
    expect(written.text, 'Hello');
    expect(written.wrapAtLayerBounds, isFalse);
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

  Future<TextLayer> addTextLayer(
    ProImageEditorState state,
    WidgetTester tester, {
    String text = 'Name',
  }) async {
    final layer = TextLayer(text: text);
    state.addLayer(
      layer,
      autoCorrectZoomOffset: false,
      autoCorrectZoomScale: false,
    );
    await tester.pump();
    return state.activeLayers.whereType<TextLayer>().single;
  }

  testWidgets('cancelling a new text leaves no layer and no undo step', (
    tester,
  ) async {
    final state = await pumpEditor(tester);
    final history = state.stateManager.historyPointer;

    state.openTextEditor();
    await tester.pump();
    expect(state.inlineTextEdit, isNotNull);
    expect(find.byType(EditableText), findsOneWidget);

    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pump();

    expect(state.inlineTextEdit, isNull);
    expect(state.activeLayers, isEmpty);
    expect(state.stateManager.historyPointer, history);
    expect(state.canRedo, isFalse);
  });

  testWidgets('a new text is a single undo step', (tester) async {
    final state = await pumpEditor(tester);
    final history = state.stateManager.historyPointer;

    state.openTextEditor();
    await tester.pump();
    await tester.enterText(find.byType(EditableText), 'Hello');
    state.inlineTextEdit!.done();
    await tester.pump();

    expect(state.activeLayers.whereType<TextLayer>().single.text, 'Hello');
    expect(state.stateManager.historyPointer, history + 1);

    state.undoAction();
    await tester.pump();
    expect(state.activeLayers, isEmpty);
  });

  testWidgets('a new text wraps like one made in the text editor', (
    tester,
  ) async {
    final state = await pumpEditor(tester);

    state.openTextEditor();
    await tester.pump();
    await tester.enterText(find.byType(EditableText), 'Hello');
    state.inlineTextEdit!.done();
    await tester.pump();

    final written = state.activeLayers.whereType<TextLayer>().single;
    expect(written.maxTextWidth, state.sizesManager.bodySize.width - 32 - 2);
  });

  testWidgets('leaving a text unchanged records no undo step', (tester) async {
    final state = await pumpEditor(tester);
    final live = await addTextLayer(state, tester);
    final history = state.stateManager.historyPointer;

    state.beginInlineTextEdit(live);
    await tester.pump();
    state.inlineTextEdit!.done();
    await tester.pump();

    expect(state.stateManager.historyPointer, history);
    expect(state.activeLayers.whereType<TextLayer>().single.text, 'Name');
  });

  testWidgets('a tap outside saves without swallowing the next drag', (
    tester,
  ) async {
    final state = await pumpEditor(tester);
    final live = await addTextLayer(state, tester);

    state.beginInlineTextEdit(live);
    await tester.pump();
    await tester.enterText(find.byType(EditableText), 'Hello');

    final layerRect = tester.getRect(find.byType(LayerWidget));
    await tester.tapAt(layerRect.bottomCenter + const Offset(0, 80));
    await tester.pumpAndSettle();
    expect(state.inlineTextEdit, isNull);
    final placed = state.activeLayers.whereType<TextLayer>().single;
    expect(placed.text, 'Hello');

    await tester.dragFrom(
      tester.getCenter(find.byType(RoundedBackgroundText)),
      const Offset(60, 0),
    );
    await tester.pumpAndSettle();

    final moved = state.activeLayers.whereType<TextLayer>().single;
    expect(moved.offset.dx, greaterThan(placed.offset.dx + 30));
  });

  testWidgets('a drag that starts on the text does not move the layer', (
    tester,
  ) async {
    final state = await pumpEditor(tester);
    final live = await addTextLayer(state, tester, text: 'Some longer name');

    state.beginInlineTextEdit(live);
    await tester.pump();

    final gesture = await tester.startGesture(
      tester.getCenter(find.byType(EditableText)),
    );
    await tester.pump(const Duration(milliseconds: 20));
    await tester.pump(const Duration(milliseconds: 20));
    for (var i = 0; i < 6; i++) {
      await gesture.moveBy(const Offset(0, 12));
      await tester.pump(const Duration(milliseconds: 16));
    }
    await gesture.up();
    await tester.pumpAndSettle();

    final placed = state.activeLayers.whereType<TextLayer>().single;
    expect(placed.offset, live.offset);
    expect(state.inlineTextEdit, isNotNull);
  });

  testWidgets('a click outside with a mouse saves without errors', (
    tester,
  ) async {
    final state = await pumpEditor(tester);
    final live = await addTextLayer(state, tester);

    state.beginInlineTextEdit(live);
    await tester.pump();
    await tester.enterText(find.byType(EditableText), 'Hello');

    final layerRect = tester.getRect(find.byType(LayerWidget));
    await tester.tapAt(
      layerRect.bottomCenter + const Offset(0, 80),
      kind: PointerDeviceKind.mouse,
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(state.inlineTextEdit, isNull);
    expect(state.activeLayers.whereType<TextLayer>().single.text, 'Hello');
  }, variant: TargetPlatformVariant.only(TargetPlatform.macOS));

  testWidgets('undo while typing writes the text before it steps back', (
    tester,
  ) async {
    final state = await pumpEditor(tester);
    final live = await addTextLayer(state, tester);

    state.beginInlineTextEdit(live);
    await tester.pump();
    await tester.enterText(find.byType(EditableText), 'Hello');

    state.undoAction();
    await tester.pump();
    expect(state.inlineTextEdit, isNull);
    expect(state.activeLayers.whereType<TextLayer>().single.text, 'Name');

    state.redoAction();
    await tester.pump();
    expect(state.activeLayers.whereType<TextLayer>().single.text, 'Hello');
  });

  testWidgets('editing the layer being typed keeps the edit open', (
    tester,
  ) async {
    final state = await pumpEditor(tester);
    final live = await addTextLayer(state, tester);

    state.beginInlineTextEdit(live);
    await tester.pump();
    final session = state.inlineTextEdit;
    final history = state.stateManager.historyPointer;
    await tester.enterText(find.byType(EditableText), 'Hello');

    state.editTextLayer(state.activeLayers.whereType<TextLayer>().single);
    await tester.pump();

    expect(state.inlineTextEdit, same(session));
    expect(session!.textCtrl.text, 'Hello');
    expect(state.stateManager.historyPointer, history);
  });

  testWidgets('removing the layer being typed ends the edit', (tester) async {
    final state = await pumpEditor(tester);
    final live = await addTextLayer(state, tester);

    state.beginInlineTextEdit(live);
    await tester.pump();
    state.removeLayer(state.activeLayers.single);
    await tester.pump();

    expect(state.inlineTextEdit, isNull);
    expect(state.activeLayers, isEmpty);
    expect(find.byType(EditableText), findsNothing);
  });

  testWidgets('a format bar outside the editor keeps the edit and its focus', (
    tester,
  ) async {
    final key = GlobalKey<ProImageEditorState>();
    final bar = ValueNotifier(0);
    addTearDown(bar.dispose);
    var aligned = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: Column(
          children: [
            Expanded(
              child: ProImageEditor.memory(
                mockMemoryImage,
                key: key,
                configs: inlineConfigs,
                callbacks: ProImageEditorCallbacks(
                  onImageEditingComplete: (Uint8List bytes) async {},
                ),
              ),
            ),
            ValueListenableBuilder(
              valueListenable: bar,
              builder: (context, _, _) {
                final session = key.currentState?.inlineTextEdit;
                if (session == null) return const SizedBox(height: 48);
                return InlineTextEditChrome(
                  session: session,
                  child: SizedBox(
                    height: 48,
                    child: TextButton(
                      onPressed: () {
                        aligned++;
                        session.toggleTextAlign();
                      },
                      child: const Text('Align'),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
    await tester.pumpAndSettle();
    final state = key.currentState!;
    final live = await addTextLayer(state, tester);
    state.beginInlineTextEdit(live);
    bar.value++;
    await tester.pump();
    await tester.pump();

    await tester.tap(find.text('Align'), kind: PointerDeviceKind.mouse);
    await tester.pump();
    expect(aligned, 1);
    expect(state.inlineTextEdit, isNotNull);
    expect(state.inlineTextEdit!.focusNode.hasFocus, isTrue);
    expect(state.inlineTextEdit!.align, TextAlign.center);

    final layerRect = tester.getRect(find.byType(LayerWidget));
    await tester.tapAt(layerRect.bottomCenter + const Offset(0, 80));
    await tester.pumpAndSettle();
    expect(state.inlineTextEdit, isNull);
    expect(
      state.activeLayers.whereType<TextLayer>().single.align,
      TextAlign.center,
    );
  }, variant: TargetPlatformVariant.only(TargetPlatform.macOS));

  testWidgets('a box handle resizes the box while the text is typed', (
    tester,
  ) async {
    final state = await pumpEditor(
      tester,
      configs: inlineConfigs.copyWith(
        layerInteraction: const LayerInteractionConfigs(
          selectable: LayerInteractionSelectable.enabled,
          enableTextBoxResize: true,
        ),
      ),
    );
    final layer = TextLayer(
      text: 'Name',
      box: const TextLayerBox(size: Size(120, 40)),
    );
    state.addLayer(
      layer,
      autoCorrectZoomOffset: false,
      autoCorrectZoomScale: false,
    );
    await tester.pumpAndSettle();
    state.beginInlineTextEdit(layer);
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(EditableText), 'Hello');
    final session = state.inlineTextEdit;

    final field = tester.getRect(find.byType(RoundedBackgroundTextField));
    final gesture = await tester.startGesture(
      Offset(field.right, field.center.dy),
      kind: PointerDeviceKind.mouse,
      buttons: kPrimaryMouseButton,
    );
    await tester.pump();
    await gesture.moveBy(const Offset(20, 0));
    await tester.pump();
    await gesture.moveBy(const Offset(20, 0));
    await tester.pump();
    await gesture.up();
    await tester.pumpAndSettle();

    expect(state.inlineTextEdit, same(session));
    expect(session!.focusNode.hasFocus, isTrue);
    final resized = state.activeLayers.whereType<TextLayer>().single;
    expect(resized.box!.size.width, closeTo(160, 0.001));

    session.done();
    await tester.pump();
    final written = state.activeLayers.whereType<TextLayer>().single;
    expect(written.text, 'Hello');
    expect(written.box!.size.width, closeTo(160, 0.001));
  }, variant: TargetPlatformVariant.only(TargetPlatform.linux));
}
