import 'dart:ui' as ui;

import '/plugins/image/src/image/image.dart' as img;

/// Converts a Flutter ui.Image to img.Image suitable for processing.
///
/// [uiImage] - The image to be converted.
/// [imageByteFormat] - The byte format to use when extracting pixel data.
///   Defaults to `rawStraightRgba` which prevents black border artifacts
///   around transparent edges. Use `rawRgba` for premultiplied alpha which
///   may be slightly faster but can cause dark fringing.
Future<img.Image> convertFlutterUiToImage(
  ui.Image uiImage, {
  ui.ImageByteFormat imageByteFormat = ui.ImageByteFormat.rawStraightRgba,
}) async {
  final uiBytes = await uiImage.toByteData(format: imageByteFormat);

  final image = img.Image.fromBytes(
    width: uiImage.width,
    height: uiImage.height,
    bytes: uiBytes!.buffer,
    numChannels: 4,
  );

  return image;
}
