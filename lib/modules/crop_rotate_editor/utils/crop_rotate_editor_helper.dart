import 'dart:ui';

import 'package:extended_image/extended_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart' show ImageProvider;
import 'package:image/image.dart';
import 'package:image_editor/image_editor.dart';

import '../../../widgets/pro_image_editor_desktop_mode.dart';

/// Crop an image with various editing options and return it as a Uint8List.
///
/// This function allows you to crop an image using the specified editing options and return the result as a Uint8List.
///
/// Parameters:
/// - `rawImage`: A Uint8List representing the raw image data.
/// - `editAction`: An EditActionDetails object specifying editing actions like cropping, flipping, and rotating.
/// - `cropRect`: A Rect representing the crop area.
/// - `imageWidth`: The width of the original image.
/// - `imageHeight`: The height of the original image.
/// - `extendedImage`: An ExtendedImage widget for display.
/// - `imageProvider`: An ImageProvider for the image.
/// - `isExtendedResizeImage`: A boolean indicating whether the image is an ExtendedResizeImage.
///
/// Returns:
/// A Future that resolves to a Uint8List containing the cropped image data.
///
/// Example Usage:
/// ```dart
/// final Uint8List croppedImage = await cropImage(
///   rawImage: imageBytes,
///   editAction: editDetails,
///   cropRect: cropRect,
///   imageWidth: imageWidth,
///   imageHeight: imageHeight,
///   extendedImage: extendedImage,
///   imageProvider: imageProvider,
///   isExtendedResizeImage: isResizeImage,
/// );
/// ```
Future<Uint8List?> cropImage({
  required Uint8List rawImage,
  required EditActionDetails editAction,
  required Rect cropRect,
  required int imageWidth,
  required int imageHeight,
  required ExtendedImage extendedImage,
  required ImageProvider imageProvider,
  required bool isExtendedResizeImage,
}) {
  return isDesktop || isWebMobile
      ? cropImageDataWithDartLibrary(
          rawImage: rawImage,
          editAction: editAction,
          cropRect: cropRect,
          imageWidth: imageWidth,
          imageHeight: imageHeight,
          extendedImage: extendedImage,
          imageProvider: imageProvider,
        )
      : cropImageDataWithNativeLibrary(
          rawImage: rawImage,
          editAction: editAction,
          cropRect: cropRect,
          imageWidth: imageWidth,
          imageHeight: imageHeight,
          isExtendedResizeImage: isExtendedResizeImage,
        );
}

/// Crop image data using Dart's image library.
///
/// This function crops image data using Dart's image library for web and desktop platforms.
///
/// Parameters:
/// - Various parameters for image cropping and editing.
///
/// Returns:
/// A Future that resolves to a Uint8List containing the cropped image data.
///
/// Example Usage:
/// Not typically used directly; it's an internal implementation for specific platforms.
Future<Uint8List?> cropImageDataWithDartLibrary({
  required Uint8List rawImage,
  required EditActionDetails editAction,
  required Rect cropRect,
  required int imageWidth,
  required int imageHeight,
  required ExtendedImage extendedImage,
  required ImageProvider imageProvider,
}) async {
  Uint8List? val;

  ///crop rect base on raw image
  Uint8List data = (isDesktop || isWebMobile) &&
          extendedImage.image is ExtendedNetworkImageProvider
      ? await _loadNetwork(extendedImage.image as ExtendedNetworkImageProvider)
      : rawImage;

  if (data == rawImage && imageProvider is ExtendedResizeImage) {
    cropRect = await _getCropRect(
      cropRect: cropRect,
      imageHeight: imageHeight,
      imageWidth: imageWidth,
      rawImage: rawImage,
    );
  }

  final EditActionDetails action = editAction;

  Image? src;
  //LoadBalancer lb;
  if (isDesktop || isWebMobile) {
    src = decodeImage(data);
  } else {
    src = await compute(decodeImage, data);
  }

  if (src != null) {
    //handle every frame.
    src.frames = src.frames.map((Image image) {
      //clear orientation
      image = bakeOrientation(image);

      if (action.needCrop) {
        image = copyCrop(
          image,
          x: cropRect.left.toInt(),
          y: cropRect.top.toInt(),
          width: cropRect.width.toInt(),
          height: cropRect.height.toInt(),
        );
      }

      if (action.needFlip) {
        late FlipDirection mode;
        if (action.flipY && action.flipX) {
          mode = FlipDirection.both;
        } else if (action.flipY) {
          mode = FlipDirection.horizontal;
        } else if (action.flipX) {
          mode = FlipDirection.vertical;
        }
        image = flip(image, direction: mode);
      }

      if (action.hasRotateAngle) {
        image = copyRotate(image, angle: action.rotateAngle);
      }
      return image;
    }).toList();
    if (src.frames.length == 1) {}
  }

  /// you can encode your image
  ///
  /// it costs much time and blocks ui.
  //var fileData = encodePng(src);

  /// it will not block ui with using isolate.
  //var fileData = await compute(encodePng, src);
  //var fileData = await isolateEncodeImage(src);
  Uint8List? fileData;
  if (src != null) {
    final bool onlyOneFrame = src.numFrames == 1;
    //If there's only one frame, encode it to jpg.
    if (isDesktop || isWebMobile) {
      fileData = onlyOneFrame
          ? encodePng(Image.from(src.frames.first))
          : encodeGif(src);
    } else {
      //fileData = await lb.run<List<int>, Image>(encodeJpg, src);
      fileData = onlyOneFrame
          ? await compute(encodePng, src)
          : await compute(encodeGif, src);
    }
  }
  val = Uint8List.fromList(fileData!);
  return val;
}

/// Crop image data using a native library.
///
/// This function crops image data using a native library for platforms other than web and desktop.
///
/// Parameters:
/// - Various parameters for image cropping and editing.
///
/// Returns:
/// A Future that resolves to a Uint8List containing the cropped image data.
///
/// Example Usage:
/// Not typically used directly; it's an internal implementation for specific platforms.
Future<Uint8List?> cropImageDataWithNativeLibrary({
  required Uint8List rawImage,
  required EditActionDetails editAction,
  required Rect cropRect,
  required int imageWidth,
  required int imageHeight,
  required bool isExtendedResizeImage,
}) async {
  if (isExtendedResizeImage) {
    cropRect = await _getCropRect(
      cropRect: cropRect,
      imageHeight: imageHeight,
      imageWidth: imageWidth,
      rawImage: rawImage,
    );
  }

  final EditActionDetails action = editAction;

  final int rotateAngle = action.rotateAngle.toInt();
  final bool flipHorizontal = action.flipY;
  final bool flipVertical = action.flipX;
  final Uint8List img = rawImage;

  final ImageEditorOption option = ImageEditorOption();

  if (action.needCrop) {
    option.addOption(ClipOption.fromRect(cropRect));
  }

  if (action.needFlip) {
    option.addOption(
        FlipOption(horizontal: flipHorizontal, vertical: flipVertical));
  }

  if (action.hasRotateAngle) {
    option.addOption(RotateOption(rotateAngle));
  }

  option.outputFormat = const OutputFormat.png();

  final Uint8List? result = await ImageEditor.editImage(
    image: img,
    imageEditorOption: option,
  );

  return result;
}

/// Get the crop rectangle based on image dimensions.
///
/// This function calculates the crop rectangle based on the image dimensions.
///
/// Parameters:
/// - Various parameters for calculating the crop rectangle.
///
/// Returns:
/// A Future that resolves to a Rect representing the calculated crop rectangle.
///
/// Example Usage:
/// Not typically used directly; it's an internal implementation for crop calculation.
Future<Rect> _getCropRect({
  required Uint8List rawImage,
  required Rect cropRect,
  required int imageWidth,
  required int imageHeight,
}) async {
  final ImmutableBuffer buffer = await ImmutableBuffer.fromUint8List(rawImage);
  final ImageDescriptor descriptor = await ImageDescriptor.encoded(buffer);
  final double widthRatio = descriptor.width / imageWidth;
  final double heightRatio = descriptor.height / imageHeight;
  return Rect.fromLTRB(
    cropRect.left * widthRatio,
    cropRect.top * heightRatio,
    cropRect.right * widthRatio,
    cropRect.bottom * heightRatio,
  );
}

/// Load an image from a network URL as a Uint8List.
///
/// This function allows you to load an image from a network URL and convert it into a Uint8List.
///
/// Parameters:
/// - `key`: An ExtendedNetworkImageProvider representing the network image.
///
/// Returns:
/// A Future that resolves to a Uint8List containing the image data.
///
/// Example Usage:
/// ```dart
/// final ExtendedNetworkImageProvider imageProvider = ExtendedNetworkImageProvider('https://example.com/image.jpg');
/// final Uint8List imageData = await _loadNetwork(imageProvider);
/// ```
Future<Uint8List> _loadNetwork(ExtendedNetworkImageProvider key) async {
  try {
    final response = await HttpClientHelper.get(
      Uri.parse(key.url),
      headers: key.headers,
      timeLimit: key.timeLimit,
      timeRetry: key.timeRetry,
      retries: key.retries,
      cancelToken: key.cancelToken,
    );
    return response!.bodyBytes;
  } on OperationCanceledError catch (_) {
    debugPrint('User cancel request ${key.url}.');
    return Future<Uint8List>.error(
        StateError('User cancel request ${key.url}.'));
  } catch (e) {
    return Future<Uint8List>.error(StateError('failed load ${key.url}. \n $e'));
  }
}
