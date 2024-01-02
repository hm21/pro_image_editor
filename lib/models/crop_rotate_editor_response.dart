import 'package:flutter/services.dart';

/// The `CropRotateEditorResponse` class represents the response data from a crop and rotate editor operation.
class CropRotateEditorResponse {
  /// The edited image data as a `Uint8List`.
  final Uint8List? bytes;

  /// Indicates whether the rotation angle is a multiple of pi/2 (90 degrees).
  final bool isHalfPi;

  /// Indicates whether the image is flipped vertically.
  final bool flipY;

  /// Indicates whether the image is flipped horizontally.
  final bool flipX;

  /// The cropping rectangle applied to the image.
  final Rect cropRect;

  /// The rotation in radians applied to the image.
  final double rotationRadian;

  /// The rotation angle in degrees applied to the image.
  final double rotationAngle;

  /// The scaling factor applied to the image.
  final double scale;

  /// The X-coordinate position of the image.
  final double posX;

  /// The Y-coordinate position of the image.
  final double posY;

  /// Creates a new `CropRotateEditorResponse` with the provided data.
  CropRotateEditorResponse({
    required this.bytes,
    required this.isHalfPi,
    required this.cropRect,
    required this.flipY,
    required this.flipX,
    required this.posX,
    required this.posY,
    required this.scale,
    required this.rotationRadian,
    required this.rotationAngle,
  });
}
