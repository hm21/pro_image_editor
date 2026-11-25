import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

/// Renders the `pixelate` shader over an input whose pixels encode their own
/// position, so each output pixel tells which input pixel it shows.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const side = 40;
  late ui.FragmentProgram program;
  late ui.Image input;

  setUpAll(() async {
    program = await ui.FragmentProgram.fromAsset(
      'lib/shared/shaders/pixelate.frag',
    );
    final pixels = Uint8List(side * side * 4);
    for (var y = 0; y < side; y++) {
      for (var x = 0; x < side; x++) {
        final i = (y * side + x) * 4;
        pixels[i] = x * 6;
        pixels[i + 1] = y * 6;
        pixels[i + 3] = 255;
      }
    }
    final completer = Completer<ui.Image>();
    ui.decodeImageFromPixels(
      pixels,
      side,
      side,
      ui.PixelFormat.rgba8888,
      completer.complete,
    );
    input = await completer.future;
  });

  /// Renders blocks of [blockSize], from [origin] when [layerSpace] is set,
  /// and returns the input pixel each output pixel shows.
  Future<Offset Function(int x, int y)> render({
    required double blockSize,
    bool layerSpace = false,
    Offset origin = Offset.zero,
  }) async {
    final shader = program.fragmentShader()
      ..setFloat(0, side.toDouble())
      ..setFloat(1, side.toDouble())
      ..setFloat(2, blockSize)
      ..setFloat(3, side.toDouble())
      ..setFloat(4, side.toDouble())
      ..setFloat(5, 1)
      ..setFloat(6, origin.dx)
      ..setFloat(7, origin.dy)
      ..setFloat(8, layerSpace ? 1 : 0)
      ..setImageSampler(0, input);
    final recorder = ui.PictureRecorder();
    ui.Canvas(
      recorder,
    ).drawRect(const Rect.fromLTWH(0, 0, 40, 40), Paint()..shader = shader);
    final image = await recorder.endRecording().toImage(side, side);
    final data = (await image.toByteData())!;
    image.dispose();
    shader.dispose();
    return (x, y) {
      final i = (y * side + x) * 4;
      return Offset(
        (data.getUint8(i) / 6).roundToDouble(),
        (data.getUint8(i + 1) / 6).roundToDouble(),
      );
    };
  }

  test('fills each block of the screen grid with one color', () async {
    final source = await render(blockSize: 5);

    expect(source(11, 13), source(14, 10));
    expect(source(11, 13), isNot(source(16, 13)));
    expect(source(11, 13), isNot(source(11, 16)));
  });

  test('fills each block from the origin with the color at its center in '
      'layer space', () async {
    final source = await render(
      blockSize: 5,
      layerSpace: true,
      origin: const Offset(2, 2),
    );

    expect(source(3, 5), const Offset(4, 4));
    expect(source(8, 11), const Offset(9, 9));
  });
}
