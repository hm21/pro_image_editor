import 'dart:ui' as ui;

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pro_image_editor/core/models/editor_configs/image_generation_configs/image_generation_configs.dart';
import 'package:pro_image_editor/shared/services/content_recorder/controllers/content_recorder_controller.dart';

Future<ui.Image> _createTestImage({int width = 10, int height = 10}) async {
  final recorder = ui.PictureRecorder();
  Canvas(recorder).drawRect(
    Rect.fromLTWH(0, 0, width.toDouble(), height.toDouble()),
    Paint()..color = const Color(0xFFFF0000),
  );
  return recorder.endRecording().toImage(width, height);
}

void main() {
  group('ContentRecorderController.convertRawImageData', () {
    late ContentRecorderController controller;

    setUp(() {
      controller = ContentRecorderController(
        isVideoEditor: false,
        configs: const ImageGenerationConfigs(
          outputFormat: OutputFormat.png,
          enableIsolateGeneration: false,
          enableBackgroundGeneration: false,
          processorConfigs: ProcessorConfigs(
            processorMode: ProcessorMode.minimum,
          ),
        ),
      );
    });

    tearDown(() async {
      await controller.destroy();
    });

    test('converts image to PNG bytes', () async {
      final image = await _createTestImage();
      final bytes = await controller.convertRawImageData(
        image: image,
        outputFormat: OutputFormat.png,
      );
      expect(bytes, isNotNull);
      expect(bytes!, isNotEmpty);
      // PNG magic bytes
      expect(bytes[0], 0x89);
      expect(bytes[1], 0x50); // 'P'
      expect(bytes[2], 0x4E); // 'N'
      expect(bytes[3], 0x47); // 'G'
    });

    test('converts image with cropToDrawingBounds false', () async {
      final image = await _createTestImage();
      final bytes = await controller.convertRawImageData(
        image: image,
        outputFormat: OutputFormat.png,
        cropToDrawingBounds: false,
      );
      expect(bytes, isNotNull);
      expect(bytes!, isNotEmpty);
    });

    test('converts image with cropToDrawingBounds true', () async {
      final image = await _createTestImage();
      final bytes = await controller.convertRawImageData(
        image: image,
        outputFormat: OutputFormat.png,
        cropToDrawingBounds: true,
      );
      expect(bytes, isNotNull);
      expect(bytes!, isNotEmpty);
    });

    test('converts image with explicit outputFormat override', () async {
      final image = await _createTestImage();
      final bytes = await controller.convertRawImageData(
        image: image,
        outputFormat: OutputFormat.png,
      );
      expect(bytes, isNotNull);
      expect(bytes!, isNotEmpty);
    });

    test('cropToDrawingBounds false preserves full image dimensions', () async {
      // Create an image with transparent borders and content in the center
      final recorder = ui.PictureRecorder();
      Canvas(recorder).drawRect(
        const Rect.fromLTWH(8, 8, 4, 4),
        Paint()..color = const Color(0xFFFF0000),
      );
      final image = await recorder.endRecording().toImage(20, 20);

      final bytesNoCrop = await controller.convertRawImageData(
        image: image,
        outputFormat: OutputFormat.png,
        cropToDrawingBounds: false,
      );

      final bytesCrop = await controller.convertRawImageData(
        image: image,
        outputFormat: OutputFormat.png,
        cropToDrawingBounds: true,
      );

      expect(bytesNoCrop, isNotNull);
      expect(bytesCrop, isNotNull);
      // With cropping enabled, the image should be smaller (fewer bytes)
      // because transparent areas are removed
      expect(bytesCrop!.length, lessThan(bytesNoCrop!.length));
    });
  });
}
