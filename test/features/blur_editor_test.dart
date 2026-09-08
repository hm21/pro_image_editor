// Flutter imports:
// Package imports:
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:network_image_mock/network_image_mock.dart';
import 'package:pro_image_editor/pro_image_editor.dart';

// Project imports:
import '../mock/mock_image.dart';

void main() {
  final initConfigs = BlurEditorInitConfigs(theme: ThemeData());
  var key = GlobalKey<BlurEditorState>();
  Future<void> pumpBlurEditor(WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: BlurEditor.memory(
            mockMemoryImage,
            key: key,
            initConfigs: initConfigs,
          ),
        ),
      ),
    );
  }

  group('BlurEditor Initialization', () {
    testWidgets('creates BlurEditor using memory image', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: BlurEditor.memory(mockMemoryImage, initConfigs: initConfigs),
        ),
      );

      expect(find.byType(BlurEditor), findsOneWidget);
    });
    testWidgets('creates BlurEditor using network image', (tester) async {
      await mockNetworkImagesFor(() async {
        await tester.pumpWidget(
          MaterialApp(
            home: BlurEditor.network(
              mockNetworkImage,
              initConfigs: initConfigs,
            ),
          ),
        );
      });

      expect(find.byType(BlurEditor), findsOneWidget);
    });
    testWidgets('creates BlurEditor using file image', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: BlurEditor.file(mockFileImage, initConfigs: initConfigs),
        ),
      );

      expect(find.byType(BlurEditor), findsOneWidget);
    });
    testWidgets('creates BlurEditor using file path', (tester) async {
      await tester.pumpWidget(
        MaterialApp(home: BlurEditor.file('', initConfigs: initConfigs)),
      );

      expect(find.byType(BlurEditor), findsOneWidget);
    });
    group('creates BlurEditor using autoSource constructor', () {
      testWidgets('Auto-detects from memory image', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: BlurEditor.autoSource(
              byteArray: mockMemoryImage,
              initConfigs: initConfigs,
            ),
          ),
        );

        expect(find.byType(BlurEditor), findsOneWidget);
      });
      testWidgets('Auto-detects from network image', (tester) async {
        await mockNetworkImagesFor(() async {
          await tester.pumpWidget(
            MaterialApp(
              home: BlurEditor.autoSource(
                networkUrl: mockNetworkImage,
                initConfigs: initConfigs,
              ),
            ),
          );
        });

        expect(find.byType(BlurEditor), findsOneWidget);
      });
      testWidgets('Auto-detects from file image', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: BlurEditor.autoSource(
              file: mockFileImage,
              initConfigs: initConfigs,
            ),
          ),
        );

        expect(find.byType(BlurEditor), findsOneWidget);
      });
      testWidgets('Auto-detects from file path', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: BlurEditor.autoSource(file: '', initConfigs: initConfigs),
          ),
        );

        expect(find.byType(BlurEditor), findsOneWidget);
      });
    });
  });

  group('BlurEditor Behavior', () {
    testWidgets('updates blurFactor when slider is dragged', (tester) async {
      await pumpBlurEditor(tester);
      double initBlur = key.currentState!.blurFactor;

      // Find the slider widget
      final sliderFinder = find.byType(Slider);

      // Ensure the slider is found
      expect(sliderFinder, findsOneWidget);

      // Move the slider to a specific position
      await tester.drag(sliderFinder, const Offset(300.0, 0.0));

      expect(key.currentState!.blurFactor, isNot(initBlur));
    });

    testWidgets('sets blurFactor via setBlurFactor()', (tester) async {
      await pumpBlurEditor(tester);

      final editor = key.currentState!;
      double updatedBlur = 10.0;

      editor.setBlurFactor(updatedBlur);

      expect(editor.blurFactor, updatedBlur);
    });
  });
}
