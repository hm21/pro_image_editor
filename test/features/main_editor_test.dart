// Flutter imports:
import 'package:flutter/services.dart';
// Package imports:
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:network_image_mock/network_image_mock.dart';
// Project imports:
import 'package:pro_image_editor/pro_image_editor.dart';
import 'package:pro_image_editor/shared/widgets/layer/layer_widget.dart';

import '../mock/mock_image.dart';

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
  final callbacks = ProImageEditorCallbacks(
    onImageEditingComplete: (Uint8List bytes) async {},
  );

  group('MainEditor Initialization', () {
    testWidgets('creates MainEditor using memory image', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ProImageEditor.memory(
            mockMemoryImage,
            configs: configs,
            callbacks: callbacks,
          ),
        ),
      );

      expect(find.byType(ProImageEditor), findsOneWidget);
    });
    testWidgets('creates MainEditor using network image', (
      WidgetTester tester,
    ) async {
      await mockNetworkImagesFor(() async {
        await tester.pumpWidget(
          MaterialApp(
            home: ProImageEditor.network(
              mockNetworkImage,
              configs: configs,
              callbacks: callbacks,
            ),
          ),
        );
      });

      expect(find.byType(ProImageEditor), findsOneWidget);
    });
    testWidgets('creates MainEditor using file image', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ProImageEditor.file(
            mockFileImage,
            configs: configs,
            callbacks: callbacks,
          ),
        ),
      );

      expect(find.byType(ProImageEditor), findsOneWidget);
    });
    testWidgets('creates MainEditor using file path', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ProImageEditor.file('', configs: configs, callbacks: callbacks),
        ),
      );

      expect(find.byType(ProImageEditor), findsOneWidget);
    });
    testWidgets('creates MainEditor using blank', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ProImageEditor.blank(
            const Size(1080, 1920),
            configs: configs,
            callbacks: callbacks,
          ),
        ),
      );

      expect(find.byType(ProImageEditor), findsOneWidget);
    });
    group('creates MainEditor using autoSource constructor', () {
      testWidgets('Auto-detects from memory image', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          MaterialApp(
            home: ProImageEditor.autoSource(
              byteArray: mockMemoryImage,
              configs: configs,
              callbacks: callbacks,
            ),
          ),
        );

        expect(find.byType(ProImageEditor), findsOneWidget);
      });
      testWidgets('Auto-detects from network image', (
        WidgetTester tester,
      ) async {
        await mockNetworkImagesFor(() async {
          await tester.pumpWidget(
            MaterialApp(
              home: ProImageEditor.autoSource(
                networkUrl: mockNetworkImage,
                configs: configs,
                callbacks: callbacks,
              ),
            ),
          );
        });

        expect(find.byType(ProImageEditor), findsOneWidget);
      });
      testWidgets('Auto-detects from file image', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: ProImageEditor.autoSource(
              file: mockFileImage,
              configs: configs,
              callbacks: callbacks,
            ),
          ),
        );

        expect(find.byType(ProImageEditor), findsOneWidget);
      });
      testWidgets('Auto-detects from file path', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: ProImageEditor.autoSource(
              file: '',
              configs: configs,
              callbacks: callbacks,
            ),
          ),
        );

        expect(find.byType(ProImageEditor), findsOneWidget);
      });
    });
  });

  group('MainEditor sub-editor launch tests', () {
    testWidgets('Launches PaintEditor via button tap', (
      WidgetTester tester,
    ) async {
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

      final openBtn = find.byKey(const ValueKey('open-paint-editor-btn'));
      expect(openBtn, findsOneWidget);
      await tester.tap(openBtn);

      await tester.pumpAndSettle();
      expect(find.byType(PaintEditor), findsOneWidget);
    });

    testWidgets('Launches TextEditor via button tap', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ProImageEditor.memory(
            mockMemoryImage,
            configs: configs,
            callbacks: ProImageEditorCallbacks(
              onImageEditingComplete: (Uint8List bytes) async {},
            ),
          ),
        ),
      );

      final openBtn = find.byKey(const ValueKey('open-text-editor-btn'));
      expect(openBtn, findsOneWidget);
      await tester.tap(openBtn);

      await tester.pumpAndSettle();
      expect(find.byType(TextEditor), findsOneWidget);
    });

    testWidgets('Launches FilterEditor via button tap', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ProImageEditor.memory(
            mockMemoryImage,
            configs: configs,
            callbacks: ProImageEditorCallbacks(
              onImageEditingComplete: (Uint8List bytes) async {},
            ),
          ),
        ),
      );

      final openBtn = find.byKey(const ValueKey('open-filter-editor-btn'));
      expect(openBtn, findsOneWidget);
      await tester.tap(openBtn);

      await tester.pumpAndSettle();
      expect(find.byType(FilterEditor), findsOneWidget);
    });

    testWidgets('Launches BlurEditor via button tap', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ProImageEditor.memory(
            mockMemoryImage,
            configs: configs,
            callbacks: ProImageEditorCallbacks(
              onImageEditingComplete: (Uint8List bytes) async {},
            ),
          ),
        ),
      );

      final openBtn = find.byKey(const ValueKey('open-blur-editor-btn'));
      expect(openBtn, findsOneWidget);
      await tester.tap(openBtn);

      await tester.pumpAndSettle();
      expect(find.byType(BlurEditor), findsOneWidget);
    });

    testWidgets('Launches EmojiEditor via button tap and waits for animation', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ProImageEditor.memory(
            mockMemoryImage,
            configs: configs,
            callbacks: ProImageEditorCallbacks(
              onImageEditingComplete: (Uint8List bytes) async {},
            ),
          ),
        ),
      );

      final openBtn = find.byKey(const ValueKey('open-emoji-editor-btn'));
      expect(openBtn, findsOneWidget);
      await tester.tap(openBtn);

      // Wait for the modal bottom sheet animation to complete
      await tester.pump(); // Start the animation
      await tester.pump(const Duration(seconds: 1)); // Wait for it to finish

      expect(find.byType(EmojiEditor), findsOneWidget);
    });
  });

  testWidgets(
    'MainEditor Undo/Redo operations restore editor state correctly',
    (WidgetTester tester) async {
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

      // Open text editor
      final openBtn = find.byKey(const ValueKey('open-text-editor-btn'));
      expect(openBtn, findsOneWidget);
      await tester.tap(openBtn);

      await tester.pumpAndSettle();

      // Write text
      await tester.enterText(find.byType(EditableText), 'Hello, World!');
      expect(find.text('Hello, World!'), findsOneWidget);

      // Press done button
      final doneBtn = find.byKey(const ValueKey('TextEditorDoneButton'));
      expect(doneBtn, findsOneWidget);
      await tester.tap(doneBtn);
      await tester.pumpAndSettle();

      // Ensure layer is created
      final layers1 = find.byType(LayerWidget);
      expect(layers1, findsOneWidget);
      // Press undo button
      final undoBtn = find.byKey(const ValueKey('MainEditorUndoButton'));
      expect(undoBtn, findsOneWidget);
      await tester.tap(undoBtn);
      await tester.pumpAndSettle();

      // Ensure layer is removed
      final layers2 = find.byType(LayerWidget);
      expect(layers2, findsNothing);

      // Press redo button
      final redoBtn = find.byKey(const ValueKey('MainEditorRedoButton'));
      expect(redoBtn, findsOneWidget);
      await tester.tap(redoBtn);
      await tester.pumpAndSettle();

      // Ensure layer exist again
      final layers3 = find.byType(LayerWidget);
      expect(layers3, findsOneWidget);
    },
  );

  group('MainEditor bottom-sheet tests with layout constraints', () {
    const widgetKey = ValueKey('example-widget');
    const expectedConstraints = BoxConstraints(maxWidth: 720);

    testWidgets('StickerEditor opens with max width constraint', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ProImageEditor.memory(
            mockMemoryImage,
            callbacks: ProImageEditorCallbacks(
              onImageEditingComplete: (Uint8List bytes) async {},
            ),
            configs: ProImageEditorConfigs(
              mainEditor: const MainEditorConfigs(
                tools: [SubEditorMode.sticker],
              ),
              stickerEditor: StickerEditorConfigs(
                builder: (setLayer, scrollController) =>
                    Container(key: widgetKey),
                style: StickerEditorStyle(
                  editorBoxConstraintsBuilder: (context, configs) =>
                      expectedConstraints,
                ),
              ),
            ),
          ),
        ),
      );
      final openBtn = find.byKey(const ValueKey('open-sticker-editor-btn'));
      expect(openBtn, findsOneWidget);
      await tester.tap(openBtn);

      // Wait for the modal bottom sheet animation to complete
      await tester.pump(); // Start the animation
      await tester.pump(const Duration(seconds: 1)); // Wait for it to finish

      expect(find.byKey(widgetKey), findsOneWidget);
      expect(
        tester.getRect(find.byKey(widgetKey)).width,
        expectedConstraints.maxWidth,
      );
    });

    testWidgets('EmojiEditor opens with max width constraint', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ProImageEditor.memory(
            mockMemoryImage,
            configs: ProImageEditorConfigs(
              emojiEditor: EmojiEditorConfigs(
                style: EmojiEditorStyle(
                  editorBoxConstraintsBuilder: (context, configs) =>
                      expectedConstraints,
                ),
              ),
            ),
            callbacks: ProImageEditorCallbacks(
              onImageEditingComplete: (Uint8List bytes) async {},
            ),
          ),
        ),
      );

      final openBtn = find.byKey(const ValueKey('open-emoji-editor-btn'));
      expect(openBtn, findsOneWidget);
      await tester.tap(openBtn);

      // Wait for the modal bottom sheet animation to complete
      await tester.pump(); // Start the animation
      await tester.pump(const Duration(seconds: 1)); // Wait for it to finish

      expect(find.byType(EmojiEditor), findsOneWidget);
      expect(
        tester.getRect(find.byType(EmojiEditor)).width,
        expectedConstraints.maxWidth,
      );
    });
  });

  testWidgets(
    're-applying tune adjustments replaces the previous session',
    (WidgetTester tester) async {
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

      Future<void> applyTune(double brightness) async {
        final openBtn = find.byKey(const ValueKey('open-tune-editor-btn'));
        expect(openBtn, findsOneWidget);
        await tester.tap(openBtn);
        await tester.pumpAndSettle();

        final TuneEditorState tuneState = tester.state(find.byType(TuneEditor));
        tuneState
          ..onChangedStart(brightness)
          ..onChanged(brightness)
          ..onChangedEnd(brightness);
        await tester.pump();

        await tester.tap(find.byTooltip('Done'));
        await tester.pumpAndSettle();
      }

      await applyTune(-0.4);
      final firstPass = List<TuneAdjustmentMatrix>.from(
        key.currentState!.stateManager.activeTuneAdjustments,
      );
      expect(firstPass.where((item) => item.id == 'brightness').length, 1);
      expect(
        firstPass.firstWhere((item) => item.id == 'brightness').value,
        -0.4,
      );

      await applyTune(-0.4);
      final secondPass = key.currentState!.stateManager.activeTuneAdjustments;
      expect(
        secondPass.where((item) => item.id == 'brightness').length,
        1,
      );
      expect(secondPass.length, firstPass.length);
      expect(
        secondPass.firstWhere((item) => item.id == 'brightness').value,
        -0.4,
      );
    },
  );

  testWidgets(
    're-applying tune keeps timed and unknown adjustments',
    (WidgetTester tester) async {
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

      final timedBrightness = TuneAdjustmentMatrix(
        id: 'brightness',
        value: -0.2,
        matrix: ColorFilterAddons.brightness(-0.2),
        startTime: const Duration(seconds: 1),
        endTime: const Duration(seconds: 4),
      );
      final custom = TuneAdjustmentMatrix(
        id: 'custom-vignette',
        value: 0.5,
        matrix: ColorFilterAddons.brightness(0.5),
      );
      key.currentState!.addHistory(
        tuneAdjustments: [timedBrightness, custom],
      );
      await tester.pump();

      final openBtn = find.byKey(const ValueKey('open-tune-editor-btn'));
      expect(openBtn, findsOneWidget);
      await tester.tap(openBtn);
      await tester.pumpAndSettle();

      final TuneEditorState tuneState = tester.state(find.byType(TuneEditor));
      tuneState
        ..onChangedStart(-0.4)
        ..onChanged(-0.4)
        ..onChangedEnd(-0.4);
      await tester.pump();

      await tester.tap(find.byTooltip('Done'));
      await tester.pumpAndSettle();

      final result = key.currentState!.stateManager.activeTuneAdjustments;
      expect(
        result.where((item) => item.id == 'brightness' && item.hasTimeline),
        [timedBrightness],
      );
      expect(
        result.where((item) => item.id == 'custom-vignette'),
        [custom],
      );
      expect(
        result
            .where((item) => item.id == 'brightness' && !item.hasTimeline)
            .length,
        1,
      );
      expect(
        result
            .firstWhere((item) => item.id == 'brightness' && !item.hasTimeline)
            .value,
        -0.4,
      );
    },
  );
}
