import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:pro_image_editor/features/paint_editor/models/eraser_model.dart';
import 'package:pro_image_editor/pro_image_editor.dart';

const Size _canvas = Size(100, 100);
const Color _ground = Color(0xFFFFFFFF);

/// A brush that strokes the freehand path twice, in two draw calls.
class _TwoPassBrush extends PathBuilderFreestyle {
  _TwoPassBrush({
    required super.item,
    required super.scale,
    required super.paintEditorConfigs,
  });

  @override
  void draw({required Canvas canvas, required Size size}) {
    if (offsets.length <= 1) return;
    build();
    drawInLayer(
      canvas: canvas,
      size: size,
      paintContent: () {
        canvas
          ..drawPath(path, painter)
          ..drawPath(path, painter..strokeWidth = painter.strokeWidth / 2);
      },
    );
  }
}

PaintedModel _stroke({List<ErasedOffset> erased = const []}) => PaintedModel(
  mode: PaintMode.custom1,
  offsets: const [Offset(10, 50), Offset(50, 50), Offset(90, 50)],
  erasedOffsets: [...erased],
  color: const Color(0xFF000000),
  strokeWidth: 20,
  opacity: 1,
);

Future<Color> _pixelAt(
  WidgetTester tester,
  PaintedModel item,
  Offset point, {
  double opacity = 1,
}) async {
  late final ByteData bytes;
  await tester.runAsync(() async {
    final bounds = Offset.zero & _canvas;
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder, bounds)
      ..drawRect(bounds, Paint()..color = _ground);
    DrawPaintItem(
      item: item,
      opacity: opacity,
      paintEditorConfigs: const PaintEditorConfigs(
        customPathBuilders: {PaintMode.custom1: _TwoPassBrush.new},
        freeStyleCustomModes: {PaintMode.custom1},
      ),
    ).paint(canvas, _canvas);
    final image = await recorder.endRecording().toImage(100, 100);
    bytes = (await image.toByteData())!;
    image.dispose();
  });
  final i = (point.dy.toInt() * _canvas.width.toInt() + point.dx.toInt()) * 4;
  return Color.fromARGB(
    bytes.getUint8(i + 3),
    bytes.getUint8(i),
    bytes.getUint8(i + 1),
    bytes.getUint8(i + 2),
  );
}

void main() {
  group('PathBuilderBase.drawInLayer', () {
    testWidgets('paints the content of a custom brush', (tester) async {
      final color = await _pixelAt(tester, _stroke(), const Offset(50, 50));
      expect(color, const Color(0xFF000000));
    });

    testWidgets('clears the erased areas from every draw call', (tester) async {
      final item = _stroke(
        erased: const [ErasedOffset(offset: Offset(50, 50), radius: 15)],
      );

      expect(await _pixelAt(tester, item, const Offset(50, 50)), _ground);
      expect(
        await _pixelAt(tester, item, const Offset(15, 50)),
        const Color(0xFF000000),
      );
    });

    testWidgets('fades overlapping draw calls once, not twice', (tester) async {
      final color = await _pixelAt(
        tester,
        _stroke(),
        const Offset(50, 50),
        opacity: 0.5,
      );
      // Both passes cover the centre; faded as one they leave mid grey.
      expect(color.r, closeTo(0.5, 0.02));
    });
  });
}
