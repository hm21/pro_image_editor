import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:pro_image_editor/pro_image_editor.dart';

import '../fake/fake_image.dart';

class MockTuneEditorCallbacks extends Mock implements TuneEditorCallbacks {}

void main() {
  group('FilterEditor Tests', () {
    testWidgets('should build without error', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FilterEditor.memory(
              fakeMemoryImage,
              initConfigs: FilterEditorInitConfigs(theme: ThemeData.light()),
            ),
          ),
        ),
      );

      expect(find.byType(FilterEditor), findsOneWidget);
    });

    testWidgets('undo and redo operations work correctly',
        (WidgetTester tester) async {
      final TuneEditor editor = TuneEditor.memory(
        fakeMemoryImage,
        initConfigs: TuneEditorInitConfigs(theme: ThemeData.dark()),
      );

      await tester.pumpWidget(MaterialApp(home: editor));

      final TuneEditorState state = tester.state(find.byType(TuneEditor));

      // Initially, undo/redo should not be possible
      expect(state.canUndo, isFalse);
      expect(state.canRedo, isFalse);

      // Perform an action (change value)
      state
        ..onChangedStart(0.5)
        ..onChanged(0.5)
        ..onChangedEnd(0.5);
      await tester.pump();

      // Undo should now be possible
      expect(state.canUndo, isTrue);
      expect(state.canRedo, isFalse);

      // Undo the action
      state.undo();
      await tester.pump();

      // Redo should now be possible
      expect(state.canUndo, isFalse);
      expect(state.canRedo, isTrue);

      // Redo the action
      state.redo();
      await tester.pump();

      expect(state.canUndo, isTrue);
      expect(state.canRedo, isFalse);
    });
  });
}
