import 'dart:typed_data';
import 'package:image/image.dart' as img;

/// Function to remove transparent areas from the image
Uint8List? removeTransparentImgAreas(Uint8List bytes) {
  // Decode the image
  img.Image? image = img.decodeImage(bytes);
  if (image == null) return null;

  // Determine the bounding box of non-transparent pixels
  int minX = image.width, minY = image.height, maxX = 0, maxY = 0;
  for (int y = 0; y < image.height; y++) {
    for (int x = 0; x < image.width; x++) {
      // Extract the alpha component to check for transparency
      if (image.getPixel(x, y).a != 0) {
        // Check if pixel is not fully transparent
        if (x < minX) minX = x;
        if (y < minY) minY = y;
        if (x > maxX) maxX = x;
        if (y > maxY) maxY = y;
      }
    }
  }

  // Check if there are any non-transparent pixels
  if (maxX < minX || maxY < minY) {
    return Uint8List.fromList(img.encodePng(image));
  }

  // Crop the image to the bounding box
  img.Image croppedImage = img.copyCrop(image,
      x: minX, y: minY, width: maxX - minX + 1, height: maxY - minY + 1);

  // Encode the cropped image to bytes
  Uint8List croppedBytes = Uint8List.fromList(img.encodePng(croppedImage));
  return croppedBytes;
}
