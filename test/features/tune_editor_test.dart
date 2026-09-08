import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mockito/mockito.dart';
import 'package:network_image_mock/network_image_mock.dart';
import 'package:pro_image_editor/pro_image_editor.dart';

import '../mock/mock_image.dart';

class MockTuneEditorCallbacks extends Mock implements TuneEditorCallbacks {}

void main() {
  final initConfigs = TuneEditorInitConfigs(theme: ThemeData());
  Future<void> pumpEditor(WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: TuneEditor.memory(mockMemoryImage, initConfigs: initConfigs),
        ),
      ),
    );
  }

  group('TuneEditor Initialization', () {
    testWidgets('creates TuneEditor using memory image', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: TuneEditor.memory(mockMemoryImage, initConfigs: initConfigs),
        ),
      );

      expect(find.byType(TuneEditor), findsOneWidget);
    });
    testWidgets('creates TuneEditor using network image', (
      WidgetTester tester,
    ) async {
      await mockNetworkImagesFor(() async {
        await tester.pumpWidget(
          MaterialApp(
            home: TuneEditor.network(
              mockNetworkImage,
              initConfigs: initConfigs,
            ),
          ),
        );
      });

      expect(find.byType(TuneEditor), findsOneWidget);
    });
    testWidgets('creates TuneEditor using file image', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: TuneEditor.file(mockFileImage, initConfigs: initConfigs),
        ),
      );

      expect(find.byType(TuneEditor), findsOneWidget);
    });
    testWidgets('creates TuneEditor using file path', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(home: TuneEditor.file('', initConfigs: initConfigs)),
      );

      expect(find.byType(TuneEditor), findsOneWidget);
    });
    group('creates TuneEditor using autoSource constructor', () {
      testWidgets('Auto-detects from memory image', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          MaterialApp(
            home: TuneEditor.autoSource(
              byteArray: mockMemoryImage,
              initConfigs: initConfigs,
            ),
          ),
        );

        expect(find.byType(TuneEditor), findsOneWidget);
      });
      testWidgets('Auto-detects from network image', (
        WidgetTester tester,
      ) async {
        await mockNetworkImagesFor(() async {
          await tester.pumpWidget(
            MaterialApp(
              home: TuneEditor.autoSource(
                networkUrl: mockNetworkImage,
                initConfigs: initConfigs,
              ),
            ),
          );
        });

        expect(find.byType(TuneEditor), findsOneWidget);
      });
      testWidgets('Auto-detects from file image', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: TuneEditor.autoSource(
              file: mockFileImage,
              initConfigs: initConfigs,
            ),
          ),
        );

        expect(find.byType(TuneEditor), findsOneWidget);
      });
      testWidgets('Auto-detects from file path', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: TuneEditor.autoSource(file: '', initConfigs: initConfigs),
          ),
        );

        expect(find.byType(TuneEditor), findsOneWidget);
      });
    });
  });

  group('TuneEditor Behavior', () {
    testWidgets('undo and redo operations work correctly', (
      WidgetTester tester,
    ) async {
      await pumpEditor(tester);

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
