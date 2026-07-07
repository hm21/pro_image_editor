// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Package imports:
import 'package:flutter_test/flutter_test.dart';

// Project imports:
import 'package:pro_image_editor/pro_image_editor.dart';

import '../../mock/mock_image.dart';

const _matrixA = <double>[
  0.8, 0, 0, 0, 0, //
  0, 0.8, 0, 0, 0, //
  0, 0, 0.8, 0, 0, //
  0, 0, 0, 1, 0, //
];
const _matrixB = <double>[
  1, 0, 0, 0, 10, //
  0, 1, 0, 0, 10, //
  0, 0, 1, 0, 10, //
  0, 0, 0, 1, 0, //
];

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

  testWidgets('merges the active filters into one, undo restores them', (
    tester,
  ) async {
    final state = await pumpEditor(tester);

    state.addHistory(
      filters: [
        FilterState(name: 'a', matrices: [_matrixA]),
        FilterState(name: 'b', matrices: [_matrixB]),
      ],
    );
    await tester.pump();

    expect(state.stateManager.activeFilters.length, 2);
    expect(state.canMergeFilters, isTrue);

    final historyLengthBefore = state.stateHistory.length;
    final merged = state.mergeFilters();
    await tester.pump();

    expect(merged, isNotNull);
    expect(state.stateManager.activeFilters.length, 1);
    expect(state.stateManager.activeFilters.first.matrices.length, 1);
    expect(state.stateHistory.length, historyLengthBefore + 1);

    // A single undo restores the two original filters.
    state.undoAction();
    await tester.pump();
    expect(state.stateManager.activeFilters.length, 2);
  });

  testWidgets('mergeFilters returns null with fewer than two filters', (
    tester,
  ) async {
    final state = await pumpEditor(tester);

    state.addHistory(
      filters: [
        FilterState(name: 'a', matrices: [_matrixA]),
      ],
    );
    await tester.pump();

    expect(state.canMergeFilters, isFalse);
    expect(state.mergeFilters(), isNull);
    expect(state.stateManager.activeFilters.length, 1);
  });
}
