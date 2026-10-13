import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:pro_image_editor/pro_image_editor.dart';

import '../../mock/mock_image.dart';

void main() {
  const configs = ProImageEditorConfigs(
    progressIndicatorConfigs: ProgressIndicatorConfigs(
      widgets: ProgressIndicatorWidgets(
        circularProgressIndicator: SizedBox.shrink(),
      ),
    ),
    mainEditor: MainEditorConfigs(captureImageOnDone: false),
    imageGeneration: ImageGenerationConfigs(
      enableIsolateGeneration: false,
      enableBackgroundGeneration: false,
    ),
  );

  /// Pushes the editor on its own route and adds a layer so the editor has
  /// unsaved changes.
  Future<ProImageEditorState> pushEditorWithChanges(
    WidgetTester tester,
    ProImageEditorCallbacks Function(BuildContext routeContext) callbacks,
  ) async {
    final key = GlobalKey<ProImageEditorState>();
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => TextButton(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (routeContext) => ProImageEditor.memory(
                  mockMemoryImage,
                  key: key,
                  configs: configs,
                  callbacks: callbacks(routeContext),
                ),
              ),
            ),
            child: const Text('open'),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    final state = key.currentState!
      ..addLayer(
        EmojiLayer(emoji: '🍎'),
        blockSelectLayer: true,
        autoCorrectZoomOffset: false,
        autoCorrectZoomScale: false,
      );
    await tester.pumpAndSettle();
    await tester.runAsync(state.decodeImage);
    await tester.pumpAndSettle();
    return state;
  }

  /// Takes a few frames like a real capture, so the loading dialog is on
  /// screen when the editor hides it.
  Future<void> simulateCapture(CompleteParameters _) async {
    await WidgetsBinding.instance.endOfFrame;
    await WidgetsBinding.instance.endOfFrame;
  }

  testWidgets('maybePop in onCloseEditor closes the editor when the pop scope '
      'is disabled', (tester) async {
    late ProImageEditorState state;
    state = await pushEditorWithChanges(
      tester,
      (routeContext) => ProImageEditorCallbacks(
        onCompleteWithParameters: simulateCapture,
        onCloseEditor: (editorMode) async {
          state.isPopScopeDisabled = true;
          await WidgetsBinding.instance.endOfFrame;
          if (!routeContext.mounted) return;
          await Navigator.of(routeContext).maybePop();
        },
      ),
    );

    state.doneEditing();
    await tester.pumpAndSettle();

    expect(find.byType(ProImageEditor), findsNothing);
    expect(find.text('Close Image Editor?'), findsNothing);
  });

  testWidgets('a back gesture after done closes the editor once the loading '
      'dialog is gone', (tester) async {
    late ProImageEditorState state;
    late BuildContext routeContext;
    state = await pushEditorWithChanges(tester, (context) {
      routeContext = context;
      return ProImageEditorCallbacks(
        onCompleteWithParameters: simulateCapture,
        onCloseEditor: (editorMode) => state.isPopScopeDisabled = true,
      );
    });

    state.doneEditing();
    await tester.pumpAndSettle();
    await Navigator.of(routeContext).maybePop();
    await tester.pumpAndSettle();

    expect(find.byType(ProImageEditor), findsNothing);
  });
}
