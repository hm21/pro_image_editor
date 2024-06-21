// Dart imports:
import 'dart:async';
import 'dart:typed_data';

// Package imports:
import 'package:image/image.dart' as img;

// Project imports:
import 'package:pro_image_editor/pro_image_editor.dart';
import 'encoder/jpeg_encoder.dart';

Future<Uint8List> encodeImage({
  required img.Image image,
  required OutputFormat outputFormat,
  required bool singleFrame,
  required int jpegQuality,
  required img.JpegChroma jpegChroma,
  required img.PngFilter pngFilter,
  required int pngLevel,
  Completer? destroy$,
}) async {
  Uint8List bytes;
  switch (outputFormat) {
    case OutputFormat.jpg:
      bytes = await JpegHealthyEncoder(quality: jpegQuality).encode(
        image,
        chroma: jpegChroma,
        destroy$: destroy$,
      );
      break;
    case OutputFormat.png:
      bytes = img.encodePng(
        image,
        filter: pngFilter,
        level: pngLevel,
        singleFrame: singleFrame,
      );
      break;
    case OutputFormat.tiff:
      bytes = img.encodeTiff(image, singleFrame: singleFrame);
      break;
    case OutputFormat.bmp:
      bytes = img.encodeBmp(image);
      break;
    case OutputFormat.cur:
      bytes = img.encodeCur(image, singleFrame: singleFrame);
      break;
    case OutputFormat.pvr:
      bytes = img.encodePvr(image, singleFrame: singleFrame);
      break;
    case OutputFormat.tga:
      bytes = img.encodeTga(image);
      break;
    case OutputFormat.ico:
      bytes = img.encodeIco(image, singleFrame: singleFrame);
      break;
    default:
      throw ArgumentError('Unsupported output format: $outputFormat');
  }
  return bytes;
}
