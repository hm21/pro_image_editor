import 'dart:math';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:pro_image_editor/core/models/layers/text_gradient.dart';
import 'package:pro_image_editor/features/text_editor/utils/scaled_text_lines.dart';

/// Where a rendering has ink: one band per line of text, each with the
/// horizontal extent of its ink.
typedef _Band = ({int top, int bottom, int left, int right});

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const offset = Offset(20, 20);

  TextPainter layout(
    InlineSpan text, {
    TextAlign textAlign = TextAlign.left,
    double maxWidth = double.infinity,
  }) {
    return TextPainter(
      text: text,
      textAlign: textAlign,
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: maxWidth);
  }

  Future<ByteData> render(Size size, void Function(Canvas canvas) paint) async {
    final recorder = ui.PictureRecorder();
    paint(Canvas(recorder));
    final picture = recorder.endRecording();
    final image = await picture.toImage(size.width.ceil(), size.height.ceil());
    picture.dispose();
    final bytes = await image.toByteData();
    image.dispose();
    return bytes!;
  }

  List<_Band> inkBands(ByteData bytes, Size size) {
    final width = size.width.ceil();
    final height = size.height.ceil();
    bool isInk(int x, int y) => bytes.getUint8((y * width + x) * 4 + 3) > 127;

    final bands = <_Band>[];
    int? top;
    var left = width;
    var right = -1;
    for (var y = 0; y <= height; y++) {
      var rowLeft = width;
      var rowRight = -1;
      if (y < height) {
        for (var x = 0; x < width; x++) {
          if (!isInk(x, y)) continue;
          rowLeft = min(rowLeft, x);
          rowRight = max(rowRight, x);
        }
      }
      if (rowRight >= 0) {
        top ??= y;
        left = min(left, rowLeft);
        right = max(right, rowRight);
      } else if (top != null) {
        bands.add((top: top, bottom: y - 1, left: left, right: right));
        top = null;
        left = width;
        right = -1;
      }
    }
    return bands;
  }

  /// Renders [source] and [scaled] and expects their ink, line by line,
  /// within a pixel of each other.
  Future<void> expectSameInk(TextPainter source, ScaledTextLines scaled) async {
    final size = Size(source.width + offset.dx * 2, source.height + 40);
    final real = await render(size, (canvas) => source.paint(canvas, offset));
    final copied = await render(size, (canvas) => scaled.paint(canvas, offset));

    final realBands = inkBands(real, size);
    final copiedBands = inkBands(copied, size);
    expect(realBands, isNotEmpty);
    expect(copiedBands, hasLength(realBands.length));
    for (var i = 0; i < realBands.length; i++) {
      final a = realBands[i];
      final b = copiedBands[i];
      expect(b.top, closeTo(a.top, 1), reason: 'top of line $i');
      expect(b.bottom, closeTo(a.bottom, 1), reason: 'bottom of line $i');
      expect(b.left, closeTo(a.left, 1), reason: 'left of line $i');
      expect(b.right, closeTo(a.right, 1), reason: 'right of line $i');
    }
  }

  group(ScaledTextLines, () {
    group('canDraw', () {
      bool canDraw(
        InlineSpan text, {
        TextAlign textAlign = TextAlign.left,
        int? maxLines,
      }) {
        return ScaledTextLines.canDraw(
          text,
          textAlign: textAlign,
          maxLines: maxLines,
        );
      }

      test('draws plain and nested text spans', () {
        expect(
          canDraw(
            const TextSpan(
              text: 'Hello ',
              children: [TextSpan(text: 'world')],
            ),
          ),
          isTrue,
        );
      });

      test('leaves justified text to its painter', () {
        expect(
          canDraw(const TextSpan(text: 'Hello'), textAlign: TextAlign.justify),
          isFalse,
        );
      });

      test('leaves text with a line limit to its painter', () {
        expect(canDraw(const TextSpan(text: 'Hello'), maxLines: 2), isFalse);
      });

      test('leaves text with a placeholder to its painter', () {
        expect(
          canDraw(
            const TextSpan(
              text: 'Hello',
              children: [WidgetSpan(child: SizedBox())],
            ),
          ),
          isFalse,
        );
      });

      test('leaves text with a mask filter to its painter', () {
        expect(
          canDraw(
            TextSpan(
              text: 'Hello',
              style: TextStyle(
                foreground: Paint()
                  ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
              ),
            ),
          ),
          isFalse,
        );
      });
    });

    group('segments', () {
      List<({String text, bool isEmoji})> split(String text) {
        return [
          for (final segment in ScaledTextLines.segments(text, 0, text.length))
            (
              text: text.substring(segment.start, segment.end),
              isEmoji: segment.isEmoji,
            ),
        ];
      }

      test('keeps text without emoji in one run', () {
        expect(split('Hello world'), [(text: 'Hello world', isEmoji: false)]);
      });

      test('separates emoji from the text around them', () {
        expect(split('Wow 🎉 yes'), [
          (text: 'Wow ', isEmoji: false),
          (text: '🎉', isEmoji: true),
          (text: ' yes', isEmoji: false),
        ]);
      });

      test('keeps modifiers, flags, keycaps and joined emoji whole', () {
        for (final emoji in ['👍🏽', '🇨🇭', '1️⃣', '👨‍👩‍👧', '🏖️']) {
          expect(split('a${emoji}b'), [
            (text: 'a', isEmoji: false),
            (text: emoji, isEmoji: true),
            (text: 'b', isEmoji: false),
          ], reason: emoji);
        }
      });
    });

    group('create', () {
      const style = TextStyle(fontSize: 120, color: Color(0xFFFFFFFF));

      Future<void> expectSame(
        InlineSpan text, {
        TextAlign textAlign = TextAlign.left,
        double maxWidth = double.infinity,
      }) async {
        final source = layout(text, textAlign: textAlign, maxWidth: maxWidth);
        final scaled = ScaledTextLines.create(
          source,
          scale: 120 / 5.25,
          emojiScale: 120 / 32,
        );
        expect(scaled, isNotNull);
        await expectSameInk(source, scaled!);
        scaled.dispose();
        source.dispose();
      }

      test('draws a line where its painter draws it', () async {
        await expectSame(const TextSpan(text: 'Hello', style: style));
      });

      for (final align in [TextAlign.left, TextAlign.center, TextAlign.right]) {
        test('draws wrapped lines where their painter draws them, '
            '${align.name} aligned', () async {
          await expectSame(
            const TextSpan(text: 'One two three four', style: style),
            textAlign: align,
            maxWidth: 1000,
          );
        });
      }

      test('draws lines after a line break where their painter does', () async {
        await expectSame(
          const TextSpan(text: 'One\n\nthree', style: style),
          textAlign: TextAlign.center,
        );
      });

      test('draws spans in other sizes where their painter does', () async {
        await expectSame(
          const TextSpan(
            text: 'Big ',
            style: style,
            children: [TextSpan(text: 'small', style: TextStyle(fontSize: 60))],
          ),
        );
      });

      test('draws a stroke as wide as its painter does', () async {
        await expectSame(
          TextSpan(
            text: 'Hi',
            style: style.copyWith(
              foreground: Paint()
                ..style = PaintingStyle.stroke
                ..strokeWidth = 16
                ..color = const Color(0xFF000000),
            ),
          ),
        );
      });

      // Across the lines and down them, where the copies' baselines lie
      // below their own origin.
      for (final angle in [0.0, pi / 2, pi / 4]) {
        test('spreads a gradient at $angle as its painter does', () async {
          final gradient = TextGradient(
            colors: const [Color(0xFFFF0000), Color(0xFF0000FF)],
            angle: angle,
          );
          TextSpan span(Shader shader) => TextSpan(
            text: 'One two three',
            style: style.copyWith(foreground: Paint()..shader = shader),
          );
          final probe = layout(
            span(gradient.createShader(Rect.zero)),
            maxWidth: 1000,
          );
          final bounds = Offset.zero & probe.size;
          probe.dispose();
          final source = layout(
            span(gradient.createShader(bounds)),
            maxWidth: 1000,
          );
          final scaled = ScaledTextLines.create(
            source,
            scale: 120 / 5.25,
            emojiScale: 120 / 32,
            gradient: gradient,
            gradientBounds: bounds,
          )!;

          // Painted at the origin, where the text's shader lies.
          final size = source.size;
          final real = await render(size, (c) => source.paint(c, Offset.zero));
          final copied = await render(
            size,
            (c) => scaled.paint(c, Offset.zero),
          );
          final width = size.width.ceil();
          var compared = 0;
          var difference = 0;
          for (var i = 0; i < real.lengthInBytes; i += 4) {
            // Only inside glyphs both draw, away from antialiased edges.
            if (real.getUint8(i + 3) < 255 || copied.getUint8(i + 3) < 255) {
              continue;
            }
            compared++;
            difference += (real.getUint8(i) - copied.getUint8(i)).abs();
            difference += (real.getUint8(i + 2) - copied.getUint8(i + 2)).abs();
          }
          expect(compared, greaterThan(width));
          expect(difference / compared, lessThan(8));
          scaled.dispose();
          source.dispose();
        });
      }
    });
  });
}
