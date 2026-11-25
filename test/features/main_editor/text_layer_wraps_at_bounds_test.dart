import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:pro_image_editor/pro_image_editor.dart';

import '../../mock/mock_image.dart';

void main() {
  const text = 'The quick brown fox jumps over the lazy dog';

  Widget buildEditor(GlobalKey<ProImageEditorState> key) {
    return ProImageEditor.memory(
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
    );
  }

  Future<ProImageEditorState> pumpEditor(WidgetTester tester) async {
    final key = GlobalKey<ProImageEditorState>();
    await tester.pumpWidget(MaterialApp(home: buildEditor(key)));
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

    testWidgets('returns false while the editor is deactivated', (
      tester,
    ) async {
      final key = GlobalKey<ProImageEditorState>();
      final showEditor = ValueNotifier(true);
      addTearDown(showEditor.dispose);
      final layer = TextLayer(text: text, scale: 6);
      bool? isActive;
      bool? isMounted;
      bool? wraps;

      await tester.pumpWidget(
        MaterialApp(
          home: ValueListenableBuilder(
            valueListenable: showEditor,
            builder: (context, show, _) => Column(
              children: [
                if (show) Expanded(child: buildEditor(key)),
                // Removing the editor deactivates it before this rebuilds,
                // and it stays mounted until the end of the frame.
                Builder(
                  builder: (context) {
                    if (!show) {
                      final state = key.currentState!;
                      isActive = (state.context as Element).debugIsActive;
                      isMounted = state.mounted;
                      wraps = state.textLayerWrapsAtBounds(layer);
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ],
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(key.currentState!.textLayerWrapsAtBounds(layer), isTrue);

      showEditor.value = false;
      await tester.pump();

      expect(isActive, isFalse);
      expect(isMounted, isTrue);
      expect(wraps, isFalse);
    });

    testWidgets('reports a layer the bounds wrap after the editor moves', (
      tester,
    ) async {
      final key = GlobalKey<ProImageEditorState>();
      final moved = ValueNotifier(false);
      addTearDown(moved.dispose);

      await tester.pumpWidget(
        MaterialApp(
          home: ValueListenableBuilder(
            valueListenable: moved,
            builder: (context, isMoved, _) => isMoved
                ? Padding(padding: EdgeInsets.zero, child: buildEditor(key))
                : buildEditor(key),
          ),
        ),
      );
      await tester.pumpAndSettle();
      final state = key.currentState!;

      // The global key carries the editor into its new parent, which
      // deactivates it and activates it again.
      moved.value = true;
      await tester.pumpAndSettle();

      expect(key.currentState, same(state));
      expect(
        state.textLayerWrapsAtBounds(TextLayer(text: text, scale: 6)),
        isTrue,
      );
    });
  });
}
