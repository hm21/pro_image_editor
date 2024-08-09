// Dart imports:
import 'dart:typed_data';

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_test/flutter_test.dart';

// Project imports:
import 'package:pro_image_editor/pro_image_editor.dart';
import 'package:pro_image_editor/widgets/layer_widget.dart';
import 'fake/fake_image.dart';

void main() {
  ProImageEditorConfigs configs = const ProImageEditorConfigs(
    customWidgets: ImageEditorCustomWidgets(
      circularProgressIndicator: SizedBox.shrink(),
    ),
    imageGenerationConfigs: ImageGenerationConfigs(
      generateInsideSeparateThread: false,
      generateImageInBackground: false,
    ),
  );

  testWidgets('ProImageEditor initializes correctly',
      (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(
      home: ProImageEditor.memory(
        fakeMemoryImage,
        configs: configs,
        callbacks: ProImageEditorCallbacks(
          onImageEditingComplete: (Uint8List bytes) async {},
        ),
      ),
    ));

    expect(find.byType(ProImageEditor), findsOneWidget);
  });

  testWidgets('ProImageEditor performs undo and redo action',
      (WidgetTester tester) async {
    final key = GlobalKey<ProImageEditorState>();
    await tester.pumpWidget(MaterialApp(
        home: ProImageEditor.memory(
      fakeMemoryImage,
      key: key,
      configs: configs,
      callbacks: ProImageEditorCallbacks(
        onImageEditingComplete: (Uint8List bytes) async {},
      ),
    )));

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
  });

  group('ProImageEditor open subeditors', () {
    testWidgets('ProImageEditor opens PaintingEditor',
        (WidgetTester tester) async {
      final key = GlobalKey<ProImageEditorState>();
      await tester.pumpWidget(
        MaterialApp(
          home: ProImageEditor.memory(
            fakeMemoryImage,
            key: key,
            configs: configs,
            callbacks: ProImageEditorCallbacks(
              onImageEditingComplete: (Uint8List bytes) async {},
            ),
          ),
        ),
      );

      final openBtn = find.byKey(const ValueKey('open-painting-editor-btn'));
      expect(openBtn, findsOneWidget);
      await tester.tap(openBtn);

      await tester.pumpAndSettle();
      expect(find.byType(PaintingEditor), findsOneWidget);
    });

    testWidgets('ProImageEditor opens TextEditor', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(
          home: ProImageEditor.memory(
        fakeMemoryImage,
        configs: configs,
        callbacks: ProImageEditorCallbacks(
          onImageEditingComplete: (Uint8List bytes) async {},
        ),
      )));

      final openBtn = find.byKey(const ValueKey('open-text-editor-btn'));
      expect(openBtn, findsOneWidget);
      await tester.tap(openBtn);

      await tester.pumpAndSettle();
      expect(find.byType(TextEditor), findsOneWidget);
    });

    testWidgets('ProImageEditor opens FilterEditor',
        (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(
          home: ProImageEditor.memory(
        fakeMemoryImage,
        configs: configs,
        callbacks: ProImageEditorCallbacks(
          onImageEditingComplete: (Uint8List bytes) async {},
        ),
      )));

      final openBtn = find.byKey(const ValueKey('open-filter-editor-btn'));
      expect(openBtn, findsOneWidget);
      await tester.tap(openBtn);

      await tester.pumpAndSettle();
      expect(find.byType(FilterEditor), findsOneWidget);
    });

    testWidgets('ProImageEditor opens BlurEditor', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(
          home: ProImageEditor.memory(
        fakeMemoryImage,
        configs: configs,
        callbacks: ProImageEditorCallbacks(
          onImageEditingComplete: (Uint8List bytes) async {},
        ),
      )));

      final openBtn = find.byKey(const ValueKey('open-blur-editor-btn'));
      expect(openBtn, findsOneWidget);
      await tester.tap(openBtn);

      await tester.pumpAndSettle();
      expect(find.byType(BlurEditor), findsOneWidget);
    });

    testWidgets('ProImageEditor opens EmojiEditor',
        (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(
          home: ProImageEditor.memory(
        fakeMemoryImage,
        configs: configs,
        callbacks: ProImageEditorCallbacks(
          onImageEditingComplete: (Uint8List bytes) async {},
        ),
      )));

      final openBtn = find.byKey(const ValueKey('open-emoji-editor-btn'));
      expect(openBtn, findsOneWidget);
      await tester.tap(openBtn);

      // Wait for the modal bottom sheet animation to complete
      await tester.pump(); // Start the animation
      await tester.pump(const Duration(seconds: 1)); // Wait for it to finish

      expect(find.byType(EmojiEditor), findsOneWidget);
    });
  });

  group('When applying constraints to the opened bottom sheet', () {
    const widgetKey = ValueKey('example-widget');
    const expectedConstraints = BoxConstraints(
      maxWidth: 720,
    );

    testWidgets('ProImageEditor opens StickerEditor with constraints',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ProImageEditor.memory(
            fakeMemoryImage,
            callbacks: ProImageEditorCallbacks(
              onImageEditingComplete: (Uint8List bytes) async {},
            ),
            configs: ProImageEditorConfigs(
              emojiEditorConfigs: const EmojiEditorConfigs(
                enabled: false,
              ),
              stickerEditorConfigs: StickerEditorConfigs(
                enabled: true,
                buildStickers: (setLayer, scrollController) => Container(
                  key: widgetKey,
                ),
              ),
              imageEditorTheme: ImageEditorTheme(
                stickerEditor: StickerEditorTheme(
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

    testWidgets('ProImageEditor opens StickerEditor with global constraints',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ProImageEditor.memory(
            fakeMemoryImage,
            callbacks: ProImageEditorCallbacks(
              onImageEditingComplete: (Uint8List bytes) async {},
            ),
            configs: ProImageEditorConfigs(
              emojiEditorConfigs: const EmojiEditorConfigs(
                enabled: false,
              ),
              stickerEditorConfigs: StickerEditorConfigs(
                enabled: true,
                buildStickers: (setLayer, scrollController) => Container(
                  key: widgetKey,
                ),
              ),
              imageEditorTheme: ImageEditorTheme(
                editorBoxConstraintsBuilder: (context, configs) =>
                    expectedConstraints,
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

    testWidgets('ProImageEditor opens EmojiEditor with constraints',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ProImageEditor.memory(
            fakeMemoryImage,
            configs: ProImageEditorConfigs(
              imageEditorTheme: ImageEditorTheme(
                  emojiEditor: EmojiEditorTheme(
                editorBoxConstraintsBuilder: (context, configs) =>
                    expectedConstraints,
              )),
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

    testWidgets('ProImageEditor opens EmojiEditor with global constraints',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ProImageEditor.memory(
            fakeMemoryImage,
            configs: ProImageEditorConfigs(
              imageEditorTheme: ImageEditorTheme(
                editorBoxConstraintsBuilder: (context, configs) =>
                    expectedConstraints,
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
}
