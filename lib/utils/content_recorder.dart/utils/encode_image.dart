// Dart imports:
import 'dart:async';
import 'dart:typed_data';

// Package imports:
import 'package:image/image.dart' as img;

// Project imports:
import 'package:pro_image_editor/pro_image_editor.dart';
import 'encoder/jpeg_encoder.dart';

/// Encodes an image into the specified format and returns the encoded data.
///
/// This function processes an [img.Image] object and encodes it into the
/// desired format, such as JPEG or PNG, based on the provided parameters.
/// The function supports encoding both single-frame and multi-frame images.
///
/// The encoding settings can be customized using parameters like quality,
/// chroma subsampling for JPEG, filter options for PNG, and compression
/// levels. The function returns a [Future<Uint8List>] which completes with
/// the encoded image data.
///
/// Parameters:
/// - [image]: The [img.Image] object to be encoded.
/// - [outputFormat]: The format to which the image should be encoded, such
///   as JPEG or PNG.
/// - [singleFrame]: Whether the image is a single frame (true) or part of
///   an animated sequence (false).
/// - [jpegQuality]: The quality level for JPEG encoding, typically a value
///   between 0 and 100.
/// - [jpegChroma]: The chroma subsampling setting for JPEG encoding.
/// - [pngFilter]: The filter type used for PNG encoding.
/// - [pngLevel]: The compression level for PNG encoding.
/// - [destroy$]: An optional [Completer<void>] to signal when to destroy
///   resources or cancel the operation.
///
/// Returns:
/// - A [Future<Uint8List>] that completes with the encoded image data as
///   a byte array.
///
/// Throws:
/// - May throw exceptions related to encoding failures or invalid parameters.

Future<Uint8List> encodeImage({
  required img.Image image,
  required OutputFormat outputFormat,
  required bool singleFrame,
  required int jpegQuality,
  required img.JpegChroma jpegChroma,
  required img.PngFilter pngFilter,
  required int pngLevel,
  Completer<void>? destroy$,
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
