import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pro_image_editor/shared/widgets/censor/layer_space_pixelate_filter.dart';

/// Renders the `pixelate_areas` shader over an input whose pixels encode
/// their own position, so each output pixel tells which input pixel it shows.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const side = 40;
  late ui.FragmentProgram program;
  late ui.Image input;

  setUpAll(() async {
    program = await ui.FragmentProgram.fromAsset(
      'lib/shared/shaders/pixelate_areas.frag',
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

  /// An area of [rect] in device pixels, with blocks from its corner.
  LayerSpacePixelateArea area(
    Rect rect, {
    required double blockSize,
    bool isOval = false,
  }) {
    return LayerSpacePixelateArea.of(
      fromDevice: Matrix4.translationValues(-rect.left, -rect.top, 0),
      size: rect.size,
      grid: LayerSpacePixelateGrid(blockSize: blockSize, origin: rect.topLeft),
      isOval: isOval,
      deviceSize: const Size(40, 40),
      fitToWidth: true,
    );
  }

  /// Renders [areas], the bottom one first, and returns the input pixel each
  /// output pixel shows.
  Future<Offset Function(int x, int y)> render(
    List<LayerSpacePixelateArea> areas,
  ) async {
    final shader = program.fragmentShader()
      ..setFloat(0, side.toDouble())
      ..setFloat(1, side.toDouble())
      ..setFloat(2, side.toDouble())
      ..setFloat(3, side.toDouble())
      ..setFloat(4, 1)
      ..setFloat(5, areas.length.toDouble())
      ..setImageSampler(0, input);
    for (var i = 0; i < areas.length; i++) {
      areas[i].writeTo(shader, 8 + i * LayerSpacePixelateArea.uniformLength);
    }
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

  test('leaves the input as it is without areas', () async {
    final source = await render([]);

    expect(source(5, 7), const Offset(5, 7));
  });

  test('fills each block with the color at its center', () async {
    final source = await render([
      area(const Rect.fromLTWH(10, 10, 20, 20), blockSize: 5),
    ]);

    expect(source(12, 13), const Offset(12, 12));
    expect(source(16, 11), const Offset(17, 12));
  });

  test('takes the grid of the topmost area where areas overlap', () async {
    final bottom = area(const Rect.fromLTWH(10, 10, 20, 20), blockSize: 5);
    final top = area(const Rect.fromLTWH(20, 20, 15, 15), blockSize: 3);

    expect((await render([bottom, top]))(25, 25), const Offset(24, 24));
    expect((await render([top, bottom]))(25, 25), const Offset(27, 27));
  });

  test('takes the grid of the area below outside an oval', () async {
    final source = await render([
      area(const Rect.fromLTWH(0, 0, 40, 40), blockSize: 3),
      area(const Rect.fromLTWH(10, 10, 20, 20), blockSize: 5, isOval: true),
    ]);

    expect(source(11, 11), const Offset(10, 10));
    expect(source(20, 20), const Offset(22, 22));
  });

  test('pixelates a pixel no area covers in the nearest grid', () async {
    // The pass follows an area that moves without repainting one frame
    // late, so an area can show pixels just outside where the pass has it.
    final source = await render([
      area(const Rect.fromLTWH(0, 0, 10, 10), blockSize: 5),
      area(const Rect.fromLTWH(28, 0, 10, 10), blockSize: 3),
    ]);

    expect(source(24, 2), const Offset(23, 1));
  });
}
