import 'dart:math' as math;
import 'dart:typed_data';

import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:pro_image_editor/features/text_editor/utils/text_curve.dart';
import 'package:pro_image_editor/features/text_editor/widgets/rounded_background_text/rounded_background_text.dart';
import 'package:pro_image_editor/features/text_editor/widgets/rounded_background_text/rounded_background_text_field.dart';
import 'package:pro_image_editor/pro_image_editor.dart';
import 'package:pro_image_editor/shared/widgets/layer/widgets/layer_widget_text_item.dart';

typedef _Image = ({ByteData bytes, int width, int height});

void main() {
  // The test font draws every glyph as a filled square of the font size.
  const style = TextStyle(fontSize: 20, color: Color(0xFFFFFFFF));

  Widget app(Widget child) => MaterialApp(
    home: Align(alignment: Alignment.topLeft, child: child),
  );

  /// The pixels [child] paints, read as a whole image.
  Future<_Image> render(WidgetTester tester, Widget child) async {
    final boundaryKey = GlobalKey();
    await tester.pumpWidget(
      app(RepaintBoundary(key: boundaryKey, child: child)),
    );
    final boundary =
        boundaryKey.currentContext!.findRenderObject()!
            as RenderRepaintBoundary;
    return (await tester.runAsync(() async {
      final image = await boundary.toImage();
      final data = await image.toByteData();
      final result = (bytes: data!, width: image.width, height: image.height);
      image.dispose();
      return result;
    }))!;
  }

  Color pixel(_Image image, int x, int y) {
    final index = (y * image.width + x) * 4;
    return Color.fromARGB(
      image.bytes.getUint8(index + 3),
      image.bytes.getUint8(index),
      image.bytes.getUint8(index + 1),
      image.bytes.getUint8(index + 2),
    );
  }

  int opaquePixels(_Image image) {
    var count = 0;
    for (var i = 3; i < image.bytes.lengthInBytes; i += 4) {
      if (image.bytes.getUint8(i) > 0) count++;
    }
    return count;
  }

  RoundedBackgroundText text(
    String value, {
    double curvature = 0,
    TextStyle textStyle = style,
    Color? background,
    TextGradient? gradient,
    int? visibleLength,
    TextAlign align = TextAlign.left,
  }) {
    return RoundedBackgroundText(
      value,
      style: textStyle,
      textAlign: align,
      backgroundColor: background,
      maxTextWidth: double.infinity,
      enableHitBoxCorrection: true,
      reserveEffectSpace: true,
      gradient: gradient,
      visibleLength: visibleLength,
      curvature: curvature,
    );
  }

  Size sizeOf(WidgetTester tester) =>
      tester.getSize(find.byType(RoundedBackgroundText));

  group(TextCurve, () {
    TextCurve curve(double curvature) => TextCurve.create(
      curvature: curvature,
      width: 300,
      centerX: 150,
      referenceY: 40,
    )!;

    test('stays straight at a curvature of 0', () {
      for (final curvature in [0.0, double.nan]) {
        expect(
          TextCurve.create(
            curvature: curvature,
            width: 300,
            centerX: 150,
            referenceY: 40,
          ),
          isNull,
        );
      }
    });

    test('sweeps the widest line through 300° at a curvature of 1', () {
      expect(curve(1).radius, closeTo(300 / (5 * math.pi / 3), 1e-9));
      expect(curve(0.5).radius, closeTo(curve(1).radius * 2, 1e-9));
      // Beyond 1 it bends no further.
      expect(curve(3).radius, curve(1).radius);
    });

    test('bends less where short text would reach the center', () {
      final bent = TextCurve.create(
        curvature: 1,
        width: 30,
        centerX: 15,
        referenceY: 0,
        minRadius: 40,
      )!;

      expect(bent.radius, 40);
    });

    test('keeps the middle column and bends the ends of an arch down', () {
      final arch = curve(0.5);

      expect(arch.map(const Offset(150, 10)), const Offset(150, 10));
      final end = arch.map(const Offset(300, 40));
      expect(end.dx, lessThan(300));
      expect(end.dy, greaterThan(40));
      expect(arch.angleAt(300), greaterThan(0));
    });

    test('bends the ends of a bowl up', () {
      final bowl = curve(-0.5);

      final end = bowl.map(const Offset(300, 40));
      expect(end.dx, lessThan(300));
      expect(end.dy, lessThan(40));
      expect(bowl.angleAt(300), lessThan(0));
    });

    test('keeps the length of the reference line along the arc', () {
      final arch = curve(0.5);
      final start = arch.map(const Offset(150, 40));
      final end = arch.map(const Offset(160, 40));
      final chordAngle = 10 / arch.radius;
      final chord = 2 * arch.radius * math.sin(chordAngle / 2);

      expect((end - start).distance, closeTo(chord, 1e-9));
    });

    test('unplace undoes place', () {
      final arch = curve(0.8);
      const pivot = Offset(250, 40);
      const point = Offset(240, 20);

      final placed = arch.place(pivot, point);
      final back = arch.unplace(pivot, placed);
      expect(back.dx, closeTo(point.dx, 1e-9));
      expect(back.dy, closeTo(point.dy, 1e-9));
      // The pivot itself lands on the arc.
      expect(arch.place(pivot, pivot), arch.map(pivot));
    });
  });

  group(TextCurvePiece, () {
    List<String> piecesOf(
      String value, {
      bool keepSpaces = false,
      TextDirection direction = TextDirection.ltr,
    }) {
      final painter = TextPainter(
        text: TextSpan(text: value, style: style),
        textDirection: direction,
      )..layout();
      addTearDown(painter.dispose);
      return [
        for (final piece in TextCurvePiece.split(
          painter,
          keepSpaces: keepSpaces,
        ))
          value.substring(piece.start, piece.end),
      ];
    }

    test('keeps every letter whole with its marks', () {
      expect(piecesOf('aéb'), ['a', 'é', 'b']);
    });

    test('keeps emoji sequences whole', () {
      const family = '👨‍👩‍👧';
      const flag = '🇨🇭';
      const thumb = '👍🏽';
      expect(piecesOf('a$family$flag${thumb}b'), [
        'a',
        family,
        flag,
        thumb,
        'b',
      ]);
    });

    test('leaves spaces out unless they draw a decoration', () {
      expect(piecesOf('a b  '), ['a', 'b']);
      expect(piecesOf('a b  ', keepSpaces: true), ['a', ' ', 'b']);
    });

    test('keeps the words of a joining script whole', () {
      expect(piecesOf('مرحبا بالعالم'), ['مرحبا', 'بالعالم']);
      expect(piecesOf('नमस्ते'), ['नमस्ते']);
    });

    test('splits every line on its own', () {
      expect(piecesOf('ab\ncd'), ['a', 'b', 'c', 'd']);
    });

    test('places right-to-left text from the right', () {
      final painter = TextPainter(
        text: const TextSpan(text: 'אבג', style: style),
        textDirection: TextDirection.rtl,
      )..layout();
      addTearDown(painter.dispose);
      final pieces = TextCurvePiece.split(painter, keepSpaces: false);

      expect(pieces, hasLength(3));
      expect(pieces.first.rect.left, greaterThan(pieces.last.rect.left));
    });
  });

  group('RoundedBackgroundText curvature', () {
    testWidgets('an almost straight curve keeps the straight size', (
      tester,
    ) async {
      await tester.pumpWidget(app(text('Hello world')));
      final straight = sizeOf(tester);
      await tester.pumpWidget(app(text('Hello world', curvature: 0.001)));
      final bent = sizeOf(tester);

      expect(bent.width, closeTo(straight.width, 1));
      expect(bent.height, closeTo(straight.height, 1));
    });

    testWidgets('a full curve wraps a line most of the way around a circle', (
      tester,
    ) async {
      const value = 'Around and around we go';
      await tester.pumpWidget(app(text(value)));
      final straight = sizeOf(tester);
      await tester.pumpWidget(app(text(value, curvature: 1)));
      final bent = sizeOf(tester);

      expect(bent.width, lessThan(straight.width * 0.5));
      expect(bent.height, greaterThan(straight.height * 3));
      // Nearly round.
      expect(bent.width / bent.height, closeTo(1, 0.25));
    });

    testWidgets('an arch and a bowl bend the same text alike', (tester) async {
      await tester.pumpWidget(app(text('Hello world', curvature: 0.5)));
      final arch = sizeOf(tester);
      await tester.pumpWidget(app(text('Hello world', curvature: -0.5)));
      final bowl = sizeOf(tester);

      expect(bowl.width, closeTo(arch.width, arch.width * 0.15));
      expect(bowl.height, closeTo(arch.height, arch.height * 0.15));
    });

    testWidgets('hits the bent background, not the space it bends around', (
      tester,
    ) async {
      await tester.pumpWidget(
        app(text('Around and around we go', curvature: 1)),
      );
      final size = sizeOf(tester);
      final paint = tester.renderObject<RenderCustomPaint>(
        find.descendant(
          of: find.byType(RoundedBackgroundText),
          matching: find.byType(CustomPaint),
        ),
      );
      bool hits(Offset position) =>
          paint.hitTest(BoxHitTestResult(), position: position);

      // The letters run over the top of the circle, around a hole.
      expect(hits(Offset(size.width / 2, 12)), isTrue);
      expect(hits(size.center(Offset.zero)), isFalse);
    });

    testWidgets('is exported exactly as it shows', (tester) async {
      final widget = text(
        'Curved export',
        curvature: 0.6,
        background: const Color(0xFF2040C0),
      );
      final shown = await render(tester, widget);
      final context = tester.element(find.byType(RoundedBackgroundText));
      final exported = (await tester.runAsync(() async {
        final image = await widget.toImage(
          context,
          size: sizeOf(tester),
          pixelRatio: 1,
        );
        final data = await image.toByteData();
        final result = (bytes: data!, width: image.width, height: image.height);
        image.dispose();
        return result;
      }))!;

      expect(exported.width, shown.width);
      expect(exported.height, shown.height);
      var different = 0;
      for (var y = 0; y < shown.height; y++) {
        for (var x = 0; x < shown.width; x++) {
          if (pixel(shown, x, y) != pixel(exported, x, y)) different++;
        }
      }
      expect(different, 0);
    });

    testWidgets('a text that types itself out keeps its size', (tester) async {
      final full = await render(tester, text('Typewriter', curvature: 0.5));
      final fullSize = sizeOf(tester);
      final part = await render(
        tester,
        text('Typewriter', curvature: 0.5, visibleLength: 4),
      );

      expect(sizeOf(tester), fullSize);
      expect(opaquePixels(part), lessThan(opaquePixels(full)));
      expect(opaquePixels(part), greaterThan(0));
    });

    testWidgets('runs a gradient across the bent text as it shows', (
      tester,
    ) async {
      const red = Color(0xFFFF0000);
      const blue = Color(0xFF0000FF);
      final image = await render(
        tester,
        text(
          'Gradient on a curve',
          curvature: 1,
          gradient: const TextGradient(colors: [red, blue], angle: math.pi / 2),
        ),
      );

      // Top to bottom: the letters over the top of the circle are red, the
      // ones at its ends, far below, blue.
      Color? top;
      Color? bottom;
      for (var y = 0; y < image.height && top == null; y++) {
        for (var x = 0; x < image.width; x++) {
          final color = pixel(image, x, y);
          if (color.a == 1) {
            top = color;
            break;
          }
        }
      }
      for (var y = image.height - 1; y >= 0 && bottom == null; y--) {
        for (var x = 0; x < image.width; x++) {
          final color = pixel(image, x, y);
          if (color.a == 1) {
            bottom = color;
            break;
          }
        }
      }
      expect(top!.r, greaterThan(top.b));
      expect(bottom!.b, greaterThan(bottom.r));
    });

    testWidgets('draws large text from a smaller font as well', (tester) async {
      final image = await render(
        tester,
        text(
          'BIG',
          curvature: 0.5,
          textStyle: style.copyWith(fontSize: 120),
          background: const Color(0xFF00A000),
        ),
      );

      expect(opaquePixels(image), greaterThan(0));
      expect(tester.takeException(), isNull);
    });

    testWidgets('text with a line limit stays straight', (tester) async {
      Widget limited(double curvature) => DefaultTextStyle(
        style: style,
        maxLines: 1,
        child: text('Limited to a line', curvature: curvature),
      );
      await tester.pumpWidget(app(limited(0)));
      final straight = sizeOf(tester);
      await tester.pumpWidget(app(limited(1)));

      expect(sizeOf(tester), straight);
    });

    testWidgets('bends the text inside a box of the same size', (tester) async {
      await tester.pumpWidget(
        app(
          RoundedBackgroundText(
            'Inside a fixed box',
            style: style,
            backgroundColor: const Color(0xFFFF8000),
            maxTextWidth: double.infinity,
            enableHitBoxCorrection: true,
            box: const TextLayerBox(size: Size(200, 120)),
            curvature: -0.5,
          ),
        ),
      );

      expect(sizeOf(tester), const Size(200, 120));
    });
  });

  group('LayerWidgetTextItem curvature', () {
    testWidgets('paints the layer bent, highlights included', (tester) async {
      const highlight = Color(0xFFFFD60A);
      final layer = TextLayer(
        text: 'Light up',
        color: const Color(0xFFFFFFFF),
        background: const Color(0x00000000),
        curvature: 0.5,
        highlights: const [
          TextHighlight(
            start: 0,
            end: 5,
            startTime: Duration.zero,
            endTime: Duration(seconds: 1),
          ),
        ],
      );
      await tester.pumpWidget(
        app(
          LayerWidgetTextItem(
            layer: layer,
            textEditorConfigs: const TextEditorConfigs(),
            showMoveCursor: ValueNotifier(false),
          ),
        ),
      );
      expect(
        tester
            .widget<RoundedBackgroundText>(find.byType(RoundedBackgroundText))
            .curvature,
        0.5,
      );

      final context = tester.element(find.byType(LayerWidgetTextItem));
      final size = tester.getSize(find.byType(LayerWidgetTextItem));
      final bytes = (await tester.runAsync(() async {
        final image = await LayerWidgetTextItem.renderContent(
          context,
          layer: layer,
          textEditorConfigs: const TextEditorConfigs(),
          size: size,
          pixelRatio: 1,
          highlightIndex: 0,
        );
        final data = await image.toByteData();
        image.dispose();
        return data;
      }))!;
      var highlighted = 0;
      for (var i = 0; i < bytes.lengthInBytes; i += 4) {
        final matches =
            bytes.getUint8(i) == 0xFF &&
            bytes.getUint8(i + 1) == 0xD6 &&
            bytes.getUint8(i + 2) == 0x0A &&
            bytes.getUint8(i + 3) == 0xFF;
        if (matches) highlighted++;
      }
      expect(highlighted, greaterThan(0), reason: 'no $highlight pixels');
    });
  });

  group('RoundedBackgroundTextField curvature', () {
    late TextEditingController controller;
    late FocusNode focusNode;

    setUp(() {
      controller = TextEditingController(text: 'Bent while unfocused');
      focusNode = FocusNode();
    });
    tearDown(() {
      controller.dispose();
      focusNode.dispose();
    });

    Future<void> pumpField(WidgetTester tester, {double curvature = 0.5}) {
      return tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: IntrinsicWidth(
                child: RoundedBackgroundTextField(
                  controller: controller,
                  focusNode: focusNode,
                  configs: const TextEditorConfigs(),
                  style: style,
                  backgroundColor: const Color(0xFF000000),
                  textAlign: TextAlign.center,
                  curvature: curvature,
                ),
              ),
            ),
          ),
        ),
      );
    }

    Iterable<RoundedBackgroundText> bentTexts(WidgetTester tester) => tester
        .widgetList<RoundedBackgroundText>(find.byType(RoundedBackgroundText))
        .where((text) => text.curvature != 0);

    testWidgets('shows the text bent while it does not have focus', (
      tester,
    ) async {
      await pumpField(tester);

      expect(bentTexts(tester), hasLength(1));
      expect(bentTexts(tester).single.curvature, 0.5);
    });

    testWidgets('shows the text straight to type into once focused', (
      tester,
    ) async {
      await pumpField(tester);
      final editable = tester.state(find.byType(EditableText));

      await tester.tap(find.byType(EditableText), warnIfMissed: false);
      await tester.pump();

      expect(focusNode.hasFocus, isTrue);
      expect(bentTexts(tester), isEmpty);
      // The same field, with its state.
      expect(tester.state(find.byType(EditableText)), same(editable));

      focusNode.unfocus();
      await tester.pump();
      expect(bentTexts(tester), hasLength(1));
    });

    testWidgets('keeps its size while the bent text shows', (tester) async {
      await pumpField(tester, curvature: 0);
      final straight = tester.getSize(find.byType(RoundedBackgroundTextField));
      await pumpField(tester);

      expect(tester.getSize(find.byType(RoundedBackgroundTextField)), straight);
    });

    testWidgets('shows the hint straight while empty', (tester) async {
      controller.clear();
      await pumpField(tester);

      expect(bentTexts(tester), isEmpty);
    });
  });

  group('TextEditor curvature', () {
    testWidgets('writes the curvature set via setCurvature onto the layer', (
      tester,
    ) async {
      final key = GlobalKey<TextEditorState>();
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
                      layer: TextLayer(text: 'Bend me', curvature: 0.25),
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
      expect(editor.curvature, 0.25);

      editor
        ..setCurvature(3)
        ..focusNode.unfocus();
      await tester.pump();
      expect(editor.curvature, 1);
      // Previewed bent while the keyboard is away.
      expect(
        tester
            .widgetList<RoundedBackgroundText>(
              find.byType(RoundedBackgroundText),
            )
            .where((text) => text.curvature == 1),
        hasLength(1),
      );

      editor
        ..setCurvature(-0.75)
        ..done();
      await tester.pumpAndSettle();

      expect(result?.curvature, -0.75);
    });
  });

  group('InlineTextEditSession curvature', () {
    test('starts from the layer and writes a change back', () {
      final layer = TextLayer(text: 'Inline', curvature: 0.3);
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

      expect(session.curvature, 0.3);
      expect(session.hasChanges(layer), isFalse);

      session.setCurvature(-5);
      expect(session.curvature, -1);
      expect(changes, 1);
      expect(session.hasChanges(layer), isTrue);
      expect(session.buildResult(layer).curvature, -1);

      session.setCurvature(0);
      expect(session.buildResult(layer).curvature, 0);
    });
  });
}
