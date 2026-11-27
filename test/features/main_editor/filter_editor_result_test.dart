// Flutter imports:
import 'package:flutter/services.dart';
// Package imports:
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
// Project imports:
import 'package:pro_image_editor/pro_image_editor.dart';

import '../../mock/mock_image.dart';

void main() {
  Future<ProImageEditorState> pumpEditor(
    WidgetTester tester, {
    required bool enableMultiSelection,
  }) async {
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
            filterEditor: FilterEditorConfigs(
              enableMultiSelection: enableMultiSelection,
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

  Future<void> applyFilter(
    WidgetTester tester,
    ProImageEditorState state,
    FilterModel filter,
  ) async {
    state.openFilterEditor();
    await tester.pumpAndSettle();
    state.filterEditor.currentState!
      ..setFilter(filter)
      ..done();
    await tester.pumpAndSettle();
  }

  testWidgets('a second filter is added once on top of the first', (
    tester,
  ) async {
    final state = await pumpEditor(tester, enableMultiSelection: true);

    await applyFilter(tester, state, PresetFilters.addictiveRed);
    await applyFilter(tester, state, PresetFilters.addictiveBlue);

    final filters = state.stateManager.activeFilters;
    expect(filters.map((filter) => filter.matrices), [
      PresetFilters.addictiveRed.filters,
      PresetFilters.addictiveBlue.filters,
    ]);
  });

  testWidgets('without multi-selection the picked filter replaces the first', (
    tester,
  ) async {
    final state = await pumpEditor(tester, enableMultiSelection: false);

    await applyFilter(tester, state, PresetFilters.addictiveRed);
    await applyFilter(tester, state, PresetFilters.addictiveBlue);

    final filters = state.stateManager.activeFilters;
    expect(filters.map((filter) => filter.matrices), [
      PresetFilters.addictiveBlue.filters,
    ]);
  });
}
