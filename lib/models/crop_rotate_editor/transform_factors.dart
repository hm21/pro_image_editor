// ignore_for_file: argument_type_not_assignable

// Flutter imports:
import 'package:flutter/widgets.dart';

// Project imports:
import 'package:pro_image_editor/modules/crop_rotate_editor/utils/rotate_angle.dart';

/// A class representing configuration settings for image transformation.
///
/// This class provides properties and methods to configure and manage image
/// transformations, such as cropping, rotating, scaling, and flipping.
class TransformConfigs {
  /// Creates a [TransformConfigs] instance with the specified parameters.
  ///
  /// The parameters include properties for angle, crop rectangle, original
  /// size, scaling factors, aspect ratio, flip options, and offset.
  ///
  /// Example:
  /// ```
  /// TransformConfigs(
  ///   angle: 0,
  ///   cropRect: Rect.fromLTWH(0, 0, 100, 100),
  ///   originalSize: Size(200, 200),
  ///   cropEditorScreenRatio: 1.0,
  ///   scaleUser: 1.0,
  ///   scaleRotation: 1.0,
  ///   aspectRatio: 1.0,
  ///   flipX: false,
  ///   flipY: false,
  ///   offset: Offset.zero,
  /// )
  /// ```
  TransformConfigs({
    required this.angle,
    required this.cropRect,
    required this.originalSize,
    required this.cropEditorScreenRatio,
    required this.scaleUser,
    required this.scaleRotation,
    required this.aspectRatio,
    required this.flipX,
    required this.flipY,
    required this.offset,
  });

  /// Creates a [TransformConfigs] instance from a map.
  ///
  /// The map should contain keys corresponding to the properties of
  /// `TransformConfigs`, and each key should map to the appropriate value.
  factory TransformConfigs.fromMap(Map<String, dynamic> map) {
    return TransformConfigs(
      angle: map['angle'] ?? 0,
      cropRect: Rect.fromLTRB(
        map['cropRect']?['left'] ?? 0,
        map['cropRect']?['top'] ?? 0,
        map['cropRect']?['right'] ?? 0,
        map['cropRect']?['bottom'] ?? 0,
      ),
      originalSize: Size(
        map['originalSize']?['width'] ?? 0,
        map['originalSize']?['height'] ?? 0,
      ),
      cropEditorScreenRatio: map['cropEditorScreenRatio'] ?? 0,
      scaleUser: map['scaleUser'] ?? 1,
      scaleRotation: map['scaleRotation'] ?? 1,
      aspectRatio: map['aspectRatio'] ?? -1,
      flipX: map['flipX'] ?? false,
      flipY: map['flipY'] ?? false,
      offset: Offset(
        map['offset']?['dx'] ?? 0,
        map['offset']?['dy'] ?? 0,
      ),
    );
  }

  /// Creates an empty [TransformConfigs] instance with default values.
  ///
  /// This factory constructor initializes all properties with default values,
  /// representing a non-configured state.
  factory TransformConfigs.empty() {
    return TransformConfigs(
      angle: 0,
      originalSize: Size.infinite,
      cropRect: Rect.largest,
      cropEditorScreenRatio: 0,
      scaleUser: 1,
      scaleRotation: 1,
      aspectRatio: -1,
      flipX: false,
      flipY: false,
      offset: const Offset(0, 0),
    );
  }

  /// The offset used for transformations.
  ///
  /// This offset represents the position adjustment applied to the image during
  /// transformations.
  final Offset offset;

  /// The crop rectangle specifying the cropped area.
  ///
  /// This rectangle defines the region of the image that is visible after
  /// cropping.
  late Rect cropRect;

  /// The original size of the image before transformation.
  ///
  /// This size represents the dimensions of the image in its unaltered state.
  late Size originalSize;

  /// The screen ratio used in the crop editor.
  ///
  /// This ratio specifies the aspect ratio of the screen in the crop editor,
  /// affecting how the image is displayed and manipulated.
  late double cropEditorScreenRatio;

  /// The angle of rotation applied to the image.
  ///
  /// This angle specifies the degree of rotation, with positive values
  /// indicating clockwise rotation and negative values indicating
  /// counter-clockwise rotation.
  final double angle;

  /// The user-defined scaling factor.
  ///
  /// This factor represents the scaling applied to the image based on user
  /// input, allowing for zooming in and out.
  final double scaleUser;

  /// The scaling factor due to rotation.
  ///
  /// This factor represents the scaling applied to the image due to its
  /// rotation, affecting its overall size and aspect ratio.
  final double scaleRotation;

  /// The aspect ratio of the image.
  ///
  /// This value specifies the ratio of width to height for the image,
  /// determining its overall shape and proportions.
  final double aspectRatio;

  /// Indicates whether the image is flipped horizontally.
  ///
  /// This boolean flag specifies whether the image has been flipped along the
  /// horizontal axis.
  final bool flipX;

  /// Indicates whether the image is flipped vertically.
  ///
  /// This boolean flag specifies whether the image has been flipped along the
  /// vertical axis.
  final bool flipY;

  /// Checks if the transformation configurations are empty.
  ///
  /// This property returns `true` if all properties are in their default states
  /// and no transformations have been applied.
  bool get isEmpty {
    return angle == 0 &&
        originalSize == Size.infinite &&
        cropRect == Rect.largest &&
        cropEditorScreenRatio == 0 &&
        scaleUser == 1 &&
        scaleRotation == 1 &&
        aspectRatio == -1 &&
        flipX == false &&
        flipY == false &&
        offset == const Offset(0, 0);
  }

  /// Checks if the transformation configurations are not empty.
  ///
  /// This property returns `true` if any transformations have been applied.
  bool get isNotEmpty => !isEmpty;

  /// Returns the combined scale from user input and rotation.
  ///
  /// This property calculates the overall scale factor by multiplying the user
  /// scale and the rotation scale.
  double get scale => scaleUser * scaleRotation;

  /// Checks if the image is rotated 90 degrees.
  ///
  /// This property returns `true` if the image is rotated to the left or right
  /// by 90 degrees.
  bool get is90DegRotated {
    RotateAngleSide factor = getRotateAngleSide(angle);
    return factor == RotateAngleSide.left || factor == RotateAngleSide.right;
  }

  /// Converts the transformation configurations to a map.
  ///
  /// This method returns a map representation of the transformation settings,
  /// suitable for serialization or debugging.
  Map<String, dynamic> toMap() {
    if (isEmpty) return {};
    return {
      'angle': angle,
      'cropRect': {
        'left': cropRect.left,
        'top': cropRect.top,
        'right': cropRect.right,
        'bottom': cropRect.bottom,
      },
      'originalSize': {
        'width': originalSize.width,
        'height': originalSize.height,
      },
      'cropEditorScreenRatio': cropEditorScreenRatio,
      'scaleUser': scaleUser,
      'scaleRotation': scaleRotation,
      'aspectRatio': aspectRatio,
      'flipX': flipX,
      'flipY': flipY,
      'offset': {
        'dx': offset.dx,
        'dy': offset.dy,
      },
    };
  }
}

/// An enumeration representing the maximum side of an image.
///
/// This enum defines whether the maximum side of an image is horizontal,
/// vertical, or unset.
enum ImageMaxSide {
  /// Indicates that the maximum side is horizontal.
  horizontal,

  /// Indicates that the maximum side is vertical.
  vertical,

  /// Indicates that the maximum side is unset.
  unset
}
