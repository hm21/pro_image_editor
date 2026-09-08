// Dart imports:
import 'dart:math';
import 'dart:typed_data';
import 'dart:ui' as ui;

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_test/flutter_test.dart';
import 'package:pro_image_editor/features/paint_editor/enums/paint_editor_enum.dart';
import 'package:pro_image_editor/features/paint_editor/models/painted_model.dart';
import 'package:pro_image_editor/features/paint_editor/widgets/draw_paint_item.dart';

const Size _canvas = Size(120, 120);

/// A stroke that crosses itself several times, so any double blending of
/// overlapping parts would show up.
PaintedModel _selfCrossingStroke() {
  final offsets = <Offset?>[];
  for (var i = 0; i <= 60; i++) {
    final t = i / 60 * 6 * pi;
    offsets.add(Offset(60 + cos(t) * 40, 60 + sin(t * 1.7) * 40));
  }
  return PaintedModel(
    mode: PaintMode.freeStyle,
    offsets: offsets,
    erasedOffsets: [],
    color: const Color(0xFF2E7D32),
    strokeWidth: 14,
    opacity: 1,
  );
}

Future<ByteData> _render(void Function(Canvas canvas) paint) async {
  final bounds = Rect.fromLTWH(0, 0, _canvas.width, _canvas.height);
  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder, bounds)
    // Opaque ground, so the comparison covers the blended result.
    ..drawRect(bounds, Paint()..color = const Color(0xFFFFFFFF));

  paint(canvas);
  final image = await recorder.endRecording().toImage(
    _canvas.width.toInt(),
    _canvas.height.toInt(),
  );
  final bytes = await image.toByteData();
  image.dispose();
  return bytes!;
}

void main() {
  testWidgets('baking the opacity matches an Opacity wrapper', (tester) async {
    const opacity = 0.4;
    final item = _selfCrossingStroke();

    late final ByteData reference;
    late final ByteData baked;

    // Encoding an image needs real async, which the fake clock would stall.
    await tester.runAsync(() async {
      // Reference: what `Opacity(opacity: 0.4)` does - render the item into an
      // offscreen layer and composite that with alpha.
      reference = await _render((canvas) {
        canvas.saveLayer(
          Rect.fromLTWH(0, 0, _canvas.width, _canvas.height),
          Paint()..color = const Color(0x66000000),
        );
        DrawPaintItem(item: item).paint(canvas, _canvas);
        canvas.restore();
      });

      // The new path: the opacity is multiplied into the stroke color.
      baked = await _render((canvas) {
        DrawPaintItem(item: item, opacity: opacity).paint(canvas, _canvas);
      });
    });

    expect(reference.lengthInBytes, baked.lengthInBytes);

    var maxChannelDelta = 0;
    var differingPixels = 0;
    for (var i = 0; i < reference.lengthInBytes; i += 4) {
      var pixelDiffers = false;
      for (var channel = 0; channel < 4; channel++) {
        final delta =
            (reference.getUint8(i + channel) - baked.getUint8(i + channel))
                .abs();
        if (delta > maxChannelDelta) maxChannelDelta = delta;
        if (delta != 0) pixelDiffers = true;
      }
      if (pixelDiffers) differingPixels++;
    }

    // Both routes blend the same coverage with the same color, so only
    // rounding of the alpha may differ by a single step.
    expect(
      maxChannelDelta,
      lessThanOrEqualTo(1),
      reason:
          'baked opacity shifted a channel by $maxChannelDelta on '
          '$differingPixels pixels',
    );
  });

  testWidgets('a fully transparent item paints nothing', (tester) async {
    final item = _selfCrossingStroke();

    late final ByteData blank;
    late final ByteData invisible;
    await tester.runAsync(() async {
      blank = await _render((_) {});
      invisible = await _render((canvas) {
        DrawPaintItem(item: item, opacity: 0).paint(canvas, _canvas);
      });
    });

    for (var i = 0; i < blank.lengthInBytes; i++) {
      expect(invisible.getUint8(i), blank.getUint8(i));
    }
  });

  testWidgets('an opaque item is unchanged', (tester) async {
    final item = _selfCrossingStroke();

    late final ByteData withoutOpacity;
    late final ByteData withFullOpacity;
    await tester.runAsync(() async {
      withoutOpacity = await _render((canvas) {
        DrawPaintItem(item: item).paint(canvas, _canvas);
      });
      withFullOpacity = await _render((canvas) {
        DrawPaintItem(item: item, opacity: 1).paint(canvas, _canvas);
      });
    });

    for (var i = 0; i < withoutOpacity.lengthInBytes; i++) {
      expect(withFullOpacity.getUint8(i), withoutOpacity.getUint8(i));
    }
  });
}
