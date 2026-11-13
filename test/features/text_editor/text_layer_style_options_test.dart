import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:pro_image_editor/features/main_editor/services/layer_copy_manager.dart';

import 'package:pro_image_editor/features/text_editor/widgets/rounded_background_text/rounded_background_text.dart';
import 'package:pro_image_editor/features/text_editor/widgets/rounded_background_text/rounded_background_text_field.dart';
import 'package:pro_image_editor/pro_image_editor.dart';
import 'package:pro_image_editor/shared/services/import_export/utils/key_minifier.dart';
import 'package:pro_image_editor/shared/utils/text_capitals.dart';
import 'package:pro_image_editor/shared/widgets/layer/widgets/layer_widget_text_item.dart';

void main() {
  group('textInCapitals', () {
    test('capitalizes every letter and keeps the length', () {
      expect(textInCapitals('Hello wörld 👋'), 'HELLO WÖRLD 👋');
    });

    test('turns ß into a capital sharp s', () {
      expect(textInCapitals('Straße'), 'STRAẞE');
    });

    test('keeps a letter whose capital is longer', () {
      // `ŉ` capitalizes to two characters.
      expect(textInCapitals('ŉ'), 'ŉ');
    });
  });

  group('TextLayer.uppercase', () {
    test('is off by default and not written', () {
      final layer = TextLayer(text: 'Hi');

      expect(layer.uppercase, isFalse);
      expect(layer.displayText, 'Hi');
      expect(layer.toMap(), isNot(contains('uppercase')));
    });

    test('draws capitals and keeps the typed text', () {
      final layer = TextLayer(text: 'Hi there', uppercase: true);

      expect(layer.displayText, 'HI THERE');
      expect(layer.text, 'Hi there');
    });

    test('survives a map round trip, minified too', () {
      final layer = TextLayer(text: 'Hi', uppercase: true);
      final minifier = EditorKeyMinifier(enableMinify: true);

      expect(
        TextLayer.fromMap(TextLayer(text: 'Base'), layer.toMap()).uppercase,
        isTrue,
      );
      final minified = {
        for (final entry in layer.toMap().entries)
          minifier.convertLayerKey(entry.key): entry.value,
      };
      expect(
        (Layer.fromMap(minified, minifier: minifier) as TextLayer).uppercase,
        isTrue,
      );
      expect(layer.copyWith(text: 'Other').uppercase, isTrue);
    });

    test('turns back off in a later history step', () {
      final reference = TextLayer(text: 'Hi', uppercase: true);
      final updated = reference.copyWith(uppercase: false);

      // The import merges each history entry over the previous state.
      final restored = TextLayer.fromMap(reference, {
        ...reference.toMap(),
        ...updated.toMapFromReference(reference),
      });

      expect(restored.uppercase, isFalse);
    });

    test('is kept by a layer copy', () {
      final layer = TextLayer(text: 'Hi', uppercase: true);

      expect(LayerCopyManager().createCopyTextLayer(layer).uppercase, isTrue);
    });
  });

  group('TextLayer.toMapFromReference', () {
    test('writes a removed font weight and style as null', () {
      final reference = TextLayer(
        text: 'Hi',
        textStyle: const TextStyle(
          fontWeight: FontWeight.w700,
          fontStyle: FontStyle.italic,
        ),
      );
      final updated = reference.copyWith(textStyle: const TextStyle());

      final diff = updated.toMapFromReference(reference);

      expect(diff, containsPair('fontWeight', null));
      expect(diff, containsPair('fontStyle', null));
    });

    test('writes a removed decoration as null', () {
      final reference = TextLayer(
        text: 'Hi',
        textStyle: const TextStyle(decoration: TextDecoration.underline),
      );
      final updated = reference.copyWith(textStyle: const TextStyle());

      final diff = updated.toMapFromReference(reference);
      final restored = TextLayer.fromMap(reference, {
        ...reference.toMap(),
        ...diff,
      });

      expect(diff, containsPair('decoration', null));
      expect(restored.textStyle?.decoration, isNull);
    });
  });

  group(LayerWidgetTextItem, () {
    Future<RoundedBackgroundText> pumpLayer(
      WidgetTester tester,
      TextLayer layer,
    ) async {
      final showMoveCursor = ValueNotifier(false);
      addTearDown(showMoveCursor.dispose);
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: LayerWidgetTextItem(
                layer: layer,
                textEditorConfigs: const TextEditorConfigs(),
                showMoveCursor: showMoveCursor,
              ),
            ),
          ),
        ),
      );
      return tester.widget<RoundedBackgroundText>(
        find.byType(RoundedBackgroundText),
      );
    }

    testWidgets('grows letter and word spacing with the rendered font size', (
      tester,
    ) async {
      final text = await pumpLayer(
        tester,
        TextLayer(
          text: 'Hello',
          scale: 2,
          fontScale: 1.5,
          textStyle: const TextStyle(letterSpacing: 2, wordSpacing: 4),
        ),
      );

      expect(text.text.style!.letterSpacing, 6);
      expect(text.text.style!.wordSpacing, 12);
    });

    testWidgets('draws the text in capitals when it is uppercase', (
      tester,
    ) async {
      final text = await pumpLayer(
        tester,
        TextLayer(text: 'Hello', uppercase: true),
      );

      expect(text.text.toPlainText(), 'HELLO');
    });
  });

  group(TextEditor, () {
    final key = GlobalKey<TextEditorState>();

    Future<TextLayer?> edit(
      WidgetTester tester,
      TextLayer? layer,
      void Function(TextEditorState editor) change, {
      Future<void> Function(WidgetTester tester)? beforeDone,
      ProImageEditorConfigs configs = const ProImageEditorConfigs(),
    }) async {
      TextLayer? result;
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => TextButton(
              onPressed: () async {
                result = await Navigator.of(context).push<TextLayer>(
                  MaterialPageRoute(
                    builder: (_) => TextEditor(
                      key: key,
                      theme: ThemeData.dark(),
                      layer: layer,
                      configs: configs,
                    ),
                  ),
                );
              },
              child: const Text('open'),
            ),
          ),
        ),
      );
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();

      final editor = key.currentState!;
      change(editor);
      await tester.pump();
      await beforeDone?.call(tester);
      editor.done();
      await tester.pumpAndSettle();
      return result;
    }

    testWidgets('writes capitals onto the layer and keeps the typed text', (
      tester,
    ) async {
      final result = await edit(
        tester,
        TextLayer(text: 'Hello'),
        (editor) => editor.setUppercase(true),
      );

      expect(result!.uppercase, isTrue);
      expect(result.text, 'Hello');
    });

    testWidgets('opens a layer in capitals with them on', (tester) async {
      final result = await edit(
        tester,
        TextLayer(text: 'Hello', uppercase: true),
        (editor) {
          expect(editor.uppercase, isTrue);
          // The glyphs the field paints beneath its editable text.
          final painted = tester.widget<RoundedBackgroundText>(
            find.descendant(
              of: find.byType(RoundedBackgroundTextField),
              matching: find.byType(RoundedBackgroundText),
            ),
          );
          expect(painted.text.toPlainText(), 'HELLO');
        },
      );

      expect(result!.uppercase, isTrue);
    });

    testWidgets('bends the text in capitals while the field is unfocused', (
      tester,
    ) async {
      await edit(
        tester,
        TextLayer(text: 'Hello', uppercase: true, curvature: 0.5),
        (editor) {
          editor.focusNode.unfocus();
        },
        beforeDone: (tester) async {
          await tester.pump();
          final texts = tester
              .widgetList<RoundedBackgroundText>(
                find.descendant(
                  of: find.byType(RoundedBackgroundTextField),
                  matching: find.byType(RoundedBackgroundText),
                ),
              )
              .map((text) => text.text.toPlainText());
          expect(texts, contains('HELLO'));
          expect(texts, isNot(contains('Hello')));
        },
      );
    });

    testWidgets('shows the layer spacing and decoration while typing', (
      tester,
    ) async {
      await edit(
        tester,
        TextLayer(
          text: 'Hello',
          fontScale: 2,
          textStyle: const TextStyle(
            letterSpacing: 3,
            decoration: TextDecoration.underline,
          ),
        ),
        (editor) {
          final field = tester.widget<RoundedBackgroundTextField>(
            find.byType(RoundedBackgroundTextField),
          );
          expect(field.style.letterSpacing, 6);
          expect(field.style.decoration, TextDecoration.underline);
        },
      );
    });

    testWidgets('decorates only the composing region with the composing '
        'decoration', (tester) async {
      await edit(
        tester,
        TextLayer(text: 'Hello', uppercase: true),
        (editor) {
          editor.textCtrl.value = const TextEditingValue(
            text: 'Hello',
            composing: TextRange(start: 1, end: 3),
          );
          const style = TextStyle(decoration: TextDecoration.lineThrough);
          final context = key.currentContext!;

          final composing = editor.textCtrl.buildTextSpan(
            context: context,
            style: style,
            withComposing: true,
          );
          expect(composing.style, style);
          expect(composing.toPlainText(), 'HELLO');
          final parts = composing.children!.cast<TextSpan>();
          expect(parts.map((part) => part.text), ['H', 'EL', 'LO']);
          expect(parts[0].style, isNull);
          expect(parts[1].style!.decoration, TextDecoration.underline);
          expect(parts[2].style, isNull);

          final plain = editor.textCtrl.buildTextSpan(
            context: context,
            style: style,
            withComposing: false,
          );
          expect(plain.style, style);
          expect(plain.text, 'HELLO');
        },
        configs: const ProImageEditorConfigs(
          textEditor: TextEditorConfigs(
            composingTextDecoration: TextDecoration.underline,
          ),
        ),
      );
    });

    testWidgets('turns spell check off while the text shows in capitals', (
      tester,
    ) async {
      final spellCheck = SpellCheckConfiguration(
        spellCheckService: _MisspelledEverywhere(),
      );
      SpellCheckConfiguration? fieldSpellCheck() => tester
          .widget<TextField>(find.byType(TextField))
          .spellCheckConfiguration;

      await edit(
        tester,
        TextLayer(text: 'Helo'),
        (editor) {
          expect(fieldSpellCheck(), isNotNull);
          editor.setUppercase(true);
        },
        beforeDone: (tester) async {
          expect(fieldSpellCheck(), isNull);
          final shown = tester
              .state<EditableTextState>(find.byType(EditableText))
              .buildTextSpan()
              .toPlainText();
          expect(shown, 'HELO');
        },
        configs: ProImageEditorConfigs(
          textEditor: TextEditorConfigs(spellCheckConfiguration: spellCheck),
        ),
      );
    });
  });

  group(InlineTextEditSession, () {
    test('writes capitals onto the layer', () {
      final layer = TextLayer(text: 'Hello');
      var changes = 0;
      final session = InlineTextEditSession.start(
        layer: layer,
        configs: const TextEditorConfigs(),
        onChanged: () => changes++,
        onTextChanged: () {},
        onDone: () {},
        onCancel: () {},
      );
      addTearDown(session.dispose);

      session.setUppercase(true);

      expect(changes, 1);
      expect(session.hasChanges(layer), isTrue);
      expect(session.buildResult(layer).uppercase, isTrue);
      expect(session.buildResult(layer).text, 'Hello');
    });
  });
}

/// Marks every word as misspelled.
class _MisspelledEverywhere implements SpellCheckService {
  @override
  Future<List<SuggestionSpan>?> fetchSpellCheckSuggestions(
    Locale locale,
    String text,
  ) async => [
    SuggestionSpan(TextRange(start: 0, end: text.length), const ['Hello']),
  ];
}
