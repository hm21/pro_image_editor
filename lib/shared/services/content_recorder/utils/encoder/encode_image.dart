// Dart imports:
import 'dart:async';
import 'dart:typed_data';

import '/core/models/editor_configs/image_generation_configs/output_formats.dart';
import '/core/models/multi_threading/thread_request_model.dart';
import '/plugins/image/src/formats/formats.dart';
import '/plugins/image/src/formats/jpeg/jpeg_chroma.dart';
import '/plugins/image/src/formats/png/png_filter.dart';
import '/plugins/image/src/image/image.dart';

/// Encodes an image into the specified format and returns the encoded data.
///
/// This function processes an [Image] object and encodes it into the
/// desired format, such as JPEG or PNG, based on the provided parameters.
/// The function supports encoding both single-frame and multi-frame images.
///
/// The encoding settings can be customized using parameters like quality,
/// chroma subsampling for JPEG, filter options for PNG, and compression
/// levels. The function returns a [Future<Uint8List>] which completes with
/// the encoded image data.
///
/// Parameters:
/// - [image]: The [Image] object to be encoded.
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
  required Image image,
  required OutputFormat outputFormat,
  required bool singleFrame,
  required int jpegQuality,
  required JpegChroma jpegChroma,
  required PngFilter pngFilter,
  required int pngLevel,
  required int jpegBackgroundColor,
  Completer<void>? destroy$,
}) async {
  Uint8List bytes;
  switch (outputFormat) {
    case OutputFormat.jpg:
      bytes = await encodeJpg(
        image,
        quality: jpegQuality,
        chroma: jpegChroma,
        destroy$: destroy$,
        backgroundColor: jpegBackgroundColor,
      );
      break;
    case OutputFormat.png:
      bytes = encodePng(
        image,
        filter: pngFilter,
        level: pngLevel,
        singleFrame: singleFrame,
      );
      break;
    case OutputFormat.tiff:
      bytes = encodeTiff(image, singleFrame: singleFrame);
      break;
    case OutputFormat.bmp:
      bytes = encodeBmp(image);
      break;
    case OutputFormat.cur:
      bytes = encodeCur(image, singleFrame: singleFrame);
      break;
    case OutputFormat.pvr:
      bytes = encodePvr(image, singleFrame: singleFrame);
      break;
    case OutputFormat.tga:
      bytes = encodeTga(image);
      break;
    case OutputFormat.ico:
      bytes = encodeIco(image, singleFrame: singleFrame);
      break;
  }
  return bytes;
}

/// Encodes an image based on the provided [ThreadRequest].
///
/// This function takes a [ThreadRequest] object and uses its properties to
/// encode the image accordingly. The encoding process can handle different
/// output formats, JPEG quality and chroma settings, and PNG filter and level
/// settings.
///
/// Parameters:
/// - [threadRequest]: The request object containing the image and encoding
///   settings.
///
/// Returns:
/// - A [Future] that completes with the encoded image as a [Uint8List].
Future<Uint8List> encodeImageFromThreadRequest(ThreadRequest threadRequest) {
  return encodeImage(
    image: threadRequest.image,
    outputFormat: threadRequest.outputFormat,
    singleFrame: threadRequest.singleFrame,
    jpegQuality: threadRequest.jpegQuality,
    jpegChroma: threadRequest.jpegChroma,
    pngFilter: threadRequest.pngFilter,
    pngLevel: threadRequest.pngLevel,
    jpegBackgroundColor: threadRequest.jpegBackgroundColor,
  );
}
