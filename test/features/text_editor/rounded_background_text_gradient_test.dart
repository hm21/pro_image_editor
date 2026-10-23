import 'dart:math' as math;
import 'dart:typed_data';

import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:pro_image_editor/features/text_editor/widgets/rounded_background_text/rounded_background_text.dart';
import 'package:pro_image_editor/features/text_editor/widgets/rounded_background_text/rounded_background_text_field.dart';
import 'package:pro_image_editor/pro_image_editor.dart';
import 'package:pro_image_editor/shared/widgets/layer/layer_widget.dart';

void main() {
  const red = Color(0xFFFF0000);
  const blue = Color(0xFF0000FF);
  const green = Color(0xFF00FF00);
  // The test font draws every glyph as a filled square of the font size.
  const style = TextStyle(fontSize: 40, color: Color(0xFFFFFFFF));
  const horizontal = TextGradient(colors: [red, blue]);

  /// The pixels [child] paints, read as a whole image.
  Future<({ByteData bytes, int width, int height})> render(
    WidgetTester tester,
    Widget child,
  ) async {
    final boundaryKey = GlobalKey();
    await tester.pumpWidget(
      MaterialApp(
        home: Align(
          alignment: Alignment.topLeft,
          child: RepaintBoundary(key: boundaryKey, child: child),
        ),
      ),
    );
    final boundary =
        boundaryKey.currentContext!.findRenderObject()!
            as RenderRepaintBoundary;
    final bytes = (await tester.runAsync(() async {
      final image = await boundary.toImage();
      final data = await image.toByteData();
      image.dispose();
      return data;
    }))!;
    return (
      bytes: bytes,
      width: boundary.size.width.round(),
      height: boundary.size.height.round(),
    );
  }

  Color pixel(({ByteData bytes, int width, int height}) image, int x, int y) {
    final index = (y * image.width + x) * 4;
    return Color.fromARGB(
      image.bytes.getUint8(index + 3),
      image.bytes.getUint8(index),
      image.bytes.getUint8(index + 1),
      image.bytes.getUint8(index + 2),
    );
  }

  int red8(Color color) => (color.r * 255).round();
  int blue8(Color color) => (color.b * 255).round();

  /// Matches a color within a few steps of [expected] on each channel, which
  /// leaves room for the dithering a gradient is drawn with.
  Matcher closeToColor(Color expected) => predicate<Color>(
    (actual) => [
      (actual.a - expected.a).abs(),
      (actual.r - expected.r).abs(),
      (actual.g - expected.g).abs(),
      (actual.b - expected.b).abs(),
    ].every((difference) => difference <= 3 / 255),
    'within 3 steps of $expected',
  );

  group('RoundedBackgroundText gradient', () {
    testWidgets('runs from its first color to its last across the text', (
      tester,
    ) async {
      final image = await render(
        tester,
        RoundedBackgroundText(
          'HHHH',
          style: style,
          maxTextWidth: 400,
          gradient: horizontal,
        ),
      );

      final start = pixel(image, 2, 20);
      final end = pixel(image, 157, 20);
      expect(red8(start), greaterThan(240));
      expect(blue8(start), lessThan(15));
      expect(red8(end), lessThan(15));
      expect(blue8(end), greaterThan(240));
    });

    testWidgets('spaces more than two colors evenly without stops', (
      tester,
    ) async {
      final image = await render(
        tester,
        RoundedBackgroundText(
          'HHHH',
          style: style,
          maxTextWidth: 400,
          gradient: const TextGradient(colors: [red, green, blue]),
        ),
      );

      final middle = pixel(image, 80, 20);
      expect((middle.g * 255).round(), greaterThan(240));
      expect(red8(middle), lessThan(15));
      expect(blue8(middle), lessThan(15));
    });

    testWidgets('runs in the direction of its angle', (tester) async {
      final image = await render(
        tester,
        RoundedBackgroundText(
          'H\nH',
          style: style,
          maxTextWidth: 400,
          gradient: const TextGradient(colors: [red, blue], angle: math.pi / 2),
        ),
      );

      final top = pixel(image, 20, 2);
      final bottom = pixel(image, 20, image.height - 3);
      expect(red8(top), greaterThan(240));
      expect(blue8(bottom), greaterThan(240));
      // The two ends of a line are the same color.
      expect(pixel(image, 2, 20), closeToColor(pixel(image, 37, 20)));
    });

    testWidgets('keeps each letter in its final color while revealing', (
      tester,
    ) async {
      final whole = await render(
        tester,
        RoundedBackgroundText(
          'HHHH',
          style: style,
          maxTextWidth: 400,
          gradient: horizontal,
        ),
      );
      final revealed = await render(
        tester,
        RoundedBackgroundText(
          'HHHH',
          style: style,
          maxTextWidth: 400,
          gradient: horizontal,
          visibleLength: 1,
        ),
      );

      expect(pixel(revealed, 37, 20), closeToColor(pixel(whole, 37, 20)));
      expect(pixel(revealed, 100, 20).a, 0);
    });

    testWidgets('leaves a part with its own color in that color', (
      tester,
    ) async {
      final image = await render(
        tester,
        const RoundedBackgroundText.rich(
          text: TextSpan(
            style: style,
            children: [
              TextSpan(text: 'HH'),
              TextSpan(
                text: 'HH',
                style: TextStyle(color: green),
              ),
            ],
          ),
          maxTextWidth: 400,
          gradient: horizontal,
        ),
      );

      expect(pixel(image, 140, 20), green);
      expect(red8(pixel(image, 2, 20)), greaterThan(240));
    });

    testWidgets('fills with the text color when it cannot be drawn', (
      tester,
    ) async {
      final image = await render(
        tester,
        RoundedBackgroundText(
          'HHHH',
          style: style,
          maxTextWidth: 400,
          gradient: const TextGradient(colors: [red]),
        ),
      );

      expect(pixel(image, 2, 20), style.color);
    });
  });

  group('TextLayer gradient', () {
    testWidgets('fills the glyphs of a text layer', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Stack(
              children: [
                LayerWidget(
                  editorBodySize: const Size(400, 400),
                  layer: TextLayer(
                    text: 'HHHH',
                    color: const Color(0xFFFFFFFF),
                    colorMode: LayerBackgroundMode.onlyColor,
                    gradient: horizontal,
                  ),
                  configs: const ProImageEditorConfigs(),
                ),
              ],
            ),
          ),
        ),
      );

      final text = tester.widget<RoundedBackgroundText>(
        find.byType(RoundedBackgroundText),
      );
      expect(text.gradient, horizontal);
    });
  });

  group('TextEditor gradient', () {
    final key = GlobalKey<TextEditorState>();
    TextLayer? result;

    Future<TextEditorState> open(WidgetTester tester, TextLayer? layer) async {
      result = null;
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
                      // Shows the shadows of the text while it is typed.
                      configs: const ProImageEditorConfigs(
                        textEditor: TextEditorConfigs(
                          style: TextEditorStyle(inputShadows: null),
                        ),
                      ),
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
      return key.currentState!;
    }

    Future<TextLayer?> finish(
      WidgetTester tester,
      TextEditorState editor,
    ) async {
      editor.done();
      await tester.pumpAndSettle();
      return result;
    }

    testWidgets('gives the edited text the gradient it was set to', (
      tester,
    ) async {
      final editor = await open(tester, TextLayer(text: 'Hello'));
      editor.setGradient(horizontal);

      expect((await finish(tester, editor))!.gradient, horizontal);
    });

    testWidgets('fills the text being typed with the gradient', (tester) async {
      const shadow = Shadow(color: Color(0xFF000000), offset: Offset(2, 2));
      final editor = await open(
        tester,
        TextLayer(
          text: 'Hello',
          textStyle: const TextStyle(shadows: [shadow]),
        ),
      );
      editor.setGradient(horizontal);
      await tester.pump();

      final field = find.byType(RoundedBackgroundTextField);
      final background = tester.widget<RoundedBackgroundText>(
        find.descendant(
          of: field,
          matching: find.byType(RoundedBackgroundText),
        ),
      );
      final input = tester.widget<TextField>(
        find.descendant(of: field, matching: find.byType(TextField)),
      );
      expect(background.gradient, horizontal);
      // The editable glyphs stay clear, so the gradient beneath them shows,
      // and cast no shadow over it: the shadow falls under the gradient.
      expect(input.style?.color, Colors.transparent);
      expect(input.style?.shadows, isEmpty);
      expect(background.text.style?.shadows, isNotEmpty);
    });

    testWidgets('keeps the gradient of the layer it edits', (tester) async {
      final editor = await open(
        tester,
        TextLayer(text: 'Hello', gradient: horizontal),
      );

      expect(editor.gradient, horizontal);
      expect((await finish(tester, editor))!.gradient, horizontal);
    });

    testWidgets('removes the gradient when it is set to none', (tester) async {
      final editor = await open(
        tester,
        TextLayer(text: 'Hello', gradient: horizontal),
      );
      editor.setGradient(null);

      expect((await finish(tester, editor))!.gradient, isNull);
    });
  });
}
