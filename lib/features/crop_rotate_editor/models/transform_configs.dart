// Flutter imports:
import 'dart:math';

import 'package:flutter/widgets.dart';

import '/core/constants/int_constants.dart';
import '/features/crop_rotate_editor/enums/crop_rotate_angle_side.dart';
import '/features/crop_rotate_editor/utils/rotate_angle.dart';
import '/pro_image_editor.dart';
import '/shared/extensions/export_bool_extension.dart';
import '/shared/extensions/num_extension.dart';
import '/shared/utils/parser/bool_parser.dart';

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
  ///   cropMode: CropMode.rectangular
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
    this.cropMode = CropMode.rectangular,
    this.tiltRotate = 0,
    this.tiltHorizontal = 0,
    this.tiltVertical = 0,
  });

  /// Creates a [TransformConfigs] instance from a map.
  ///
  /// The map should contain keys corresponding to the properties of
  /// `TransformConfigs`, and each key should map to the appropriate value.
  factory TransformConfigs.fromMap(Map<String, dynamic> map) {
    final cropMode = map['cropMode'] == 'oval'
        ? CropMode.oval
        : CropMode.rectangular;

    return TransformConfigs(
      angle: safeParseDouble(map['angle']),
      cropRect: Rect.fromLTRB(
        safeParseDouble(map['cropRect']?['left']),
        safeParseDouble(map['cropRect']?['top']),
        safeParseDouble(map['cropRect']?['right']),
        safeParseDouble(map['cropRect']?['bottom']),
      ),
      originalSize: Size(
        safeParseDouble(map['originalSize']?['width']),
        safeParseDouble(map['originalSize']?['height']),
      ),
      cropEditorScreenRatio: safeParseDouble(
        map['cropEditorScreenRatio'],
        fallback: 0,
      ),
      scaleUser: safeParseDouble(map['scaleUser'], fallback: 1),
      scaleRotation: safeParseDouble(map['scaleRotation'], fallback: 1),
      aspectRatio: safeParseDouble(map['aspectRatio'], fallback: -1),
      flipX: safeParseBool(map['flipX']),
      flipY: safeParseBool(map['flipY']),
      cropMode: cropMode,
      tiltRotate: safeParseDouble(map['tiltRotate']),
      tiltHorizontal: safeParseDouble(map['tiltHorizontal']),
      tiltVertical: safeParseDouble(map['tiltVertical']),
      offset: Offset(
        safeParseDouble(map['offset']?['dx']),
        safeParseDouble(map['offset']?['dy']),
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
      cropMode: CropMode.rectangular,
      tiltRotate: 0,
      tiltHorizontal: 0,
      tiltVertical: 0,
    );
  }

  /// The current cropping mode applied to the image.
  ///
  /// This determines how the crop operation behaves, such as oval or
  /// rectangular.
  final CropMode cropMode;

  /// Returns `true` if the current crop mode is set to rectangular cropping.
  ///
  /// This getter checks whether the [cropMode] is equal to
  /// [CropMode.rectangular], indicating that the cropper is operating in
  /// rectangular mode.
  bool get isRectangularCropper => cropMode == CropMode.rectangular;

  /// Returns `true` if the current crop mode is set to oval cropping.
  ///
  /// This getter checks whether the [cropMode] is equal to [CropMode.oval],
  /// indicating that the cropper is in oval mode.
  bool get isOvalCropper => cropMode == CropMode.oval;

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

  /// The current tilt (rotation) in radians around the Z axis.
  final double tiltRotate;

  /// The current tilt in radians around the Y axis (left/right).
  final double tiltHorizontal;

  /// The current tilt in radians around the X axis (up/down).
  final double tiltVertical;

  /// Returns `true` if any perspective/skew tilt is applied.
  ///
  /// Checks whether [tiltRotate], [tiltHorizontal], or [tiltVertical]
  /// is non-zero.
  bool get isTilted =>
      tiltRotate != 0 || tiltHorizontal != 0 || tiltVertical != 0;

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
        tiltRotate == 0 &&
        tiltHorizontal == 0 &&
        tiltVertical == 0 &&
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

  /// Converts the angle (in radians) to the number of 90-degree turns
  /// (quarter turns).
  ///
  /// The method assumes that a 90-degree turn is equivalent to π/2 radians.
  /// It calculates the number of quarter turns by dividing the angle by π/2
  /// and rounding the result to the nearest integer.
  ///
  /// Returns:
  ///   An integer representing the number of 90-degree turns.
  int angleToTurns() {
    const double halfPi = 3.141592653589793 / 2; // 90 degrees
    return (angle / halfPi).round();
  }

  /// Converts the transformation configurations to a map.
  ///
  /// This method returns a map representation of the transformation settings,
  /// suitable for serialization or debugging.
  Map<String, dynamic> toMap({
    int maxDecimalPlaces = kMaxSafeDecimalPlaces,
    bool enableMinify = false,
  }) {
    if (isEmpty) return {};
    return {
      'angle': angle.roundSmart(maxDecimalPlaces),
      'cropRect': {
        'left': cropRect.left.roundSmart(maxDecimalPlaces),
        'top': cropRect.top.roundSmart(maxDecimalPlaces),
        'right': cropRect.right.roundSmart(maxDecimalPlaces),
        'bottom': cropRect.bottom.roundSmart(maxDecimalPlaces),
      },
      'originalSize': {
        'width': originalSize.width.roundSmart(maxDecimalPlaces),
        'height': originalSize.height.roundSmart(maxDecimalPlaces),
      },
      'cropEditorScreenRatio': cropEditorScreenRatio.roundSmart(
        maxDecimalPlaces,
      ),
      'scaleUser': scaleUser.roundSmart(maxDecimalPlaces),
      'scaleRotation': scaleRotation.roundSmart(maxDecimalPlaces),
      'aspectRatio': aspectRatio.roundSmart(maxDecimalPlaces),
      'flipX': flipX.minify(enableMinify),
      'flipY': flipY.minify(enableMinify),
      'cropMode': cropMode.name,
      'tiltRotate': tiltRotate.roundSmart(maxDecimalPlaces),
      'tiltHorizontal': tiltHorizontal.roundSmart(maxDecimalPlaces),
      'tiltVertical': tiltVertical.roundSmart(maxDecimalPlaces),
      'offset': {
        'dx': offset.dx.roundSmart(maxDecimalPlaces),
        'dy': offset.dy.roundSmart(maxDecimalPlaces),
      },
    };
  }

  /// Returns the top-left offset of the crop area in the original image
  /// coordinates.
  ///
  /// [rawImageSize] is the size of the unscaled original image.
  /// Takes into account user transformations like pan and zoom.
  Offset getCropStartOffset(Size rawImageSize) {
    double originalWidth = rawImageSize.width;
    double originalHeight = rawImageSize.height;

    double renderWidth = originalSize.width;
    double renderHeight = originalSize.height;

    Offset transformOffset = offset;

    double horizontalPadding = (renderWidth - cropRect.width / scaleUser) / 2;
    double verticalPadding = (renderHeight - cropRect.height / scaleUser) / 2;

    /// Calculate crop offset in original coordinates
    Offset cropOffset = Offset(
      horizontalPadding - transformOffset.dx,
      verticalPadding - transformOffset.dy,
    );

    /// Calculate scale factors for the offset
    double offsetXScale = renderWidth / cropOffset.dx;
    double offsetYScale = renderHeight / cropOffset.dy;

    return Offset(
      max(0, originalWidth / offsetXScale),
      max(0, originalHeight / offsetYScale),
    );
  }

  /// Returns the size of the crop area in the original image coordinates.
  ///
  /// [rawImageSize] is the size of the unscaled original image.
  /// The result is scaled based on the user's zoom level.
  Size getCropSize(Size rawImageSize) {
    double originalWidth = rawImageSize.width;
    double originalHeight = rawImageSize.height;

    double renderWidth = originalSize.width;
    double renderHeight = originalSize.height;

    /// Calculate scale factors based on crop dimensions
    double widthScale = renderWidth / cropRect.width;
    double heightScale = renderHeight / cropRect.height;

    return Size(originalWidth / widthScale, originalHeight / heightScale) /
        scaleUser;
  }

  /// Creates a copy of this [TransformConfigs] object with the given fields
  /// replaced by new values.
  TransformConfigs copyWith({
    CropMode? cropMode,
    Offset? offset,
    double? angle,
    double? scaleUser,
    double? scaleRotation,
    double? aspectRatio,
    bool? flipX,
    bool? flipY,
    Rect? cropRect,
    Size? originalSize,
    double? cropEditorScreenRatio,
    double? tiltRotate,
    double? tiltHorizontal,
    double? tiltVertical,
  }) {
    return TransformConfigs(
      cropMode: cropMode ?? this.cropMode,
      offset: offset ?? this.offset,
      angle: angle ?? this.angle,
      scaleUser: scaleUser ?? this.scaleUser,
      scaleRotation: scaleRotation ?? this.scaleRotation,
      aspectRatio: aspectRatio ?? this.aspectRatio,
      flipX: flipX ?? this.flipX,
      flipY: flipY ?? this.flipY,
      cropRect: cropRect ?? this.cropRect,
      originalSize: originalSize ?? this.originalSize,
      cropEditorScreenRatio:
          cropEditorScreenRatio ?? this.cropEditorScreenRatio,
      tiltRotate: tiltRotate ?? this.tiltRotate,
      tiltHorizontal: tiltHorizontal ?? this.tiltHorizontal,
      tiltVertical: tiltVertical ?? this.tiltVertical,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is TransformConfigs &&
        other.offset == offset &&
        other.cropRect == cropRect &&
        other.originalSize == originalSize &&
        other.cropEditorScreenRatio == cropEditorScreenRatio &&
        other.angle == angle &&
        other.scaleUser == scaleUser &&
        other.scaleRotation == scaleRotation &&
        other.aspectRatio == aspectRatio &&
        other.flipX == flipX &&
        other.flipY == flipY &&
        other.tiltRotate == tiltRotate &&
        other.tiltHorizontal == tiltHorizontal &&
        other.tiltVertical == tiltVertical &&
        other.cropMode == cropMode;
  }

  @override
  int get hashCode {
    return offset.hashCode ^
        angle.hashCode ^
        cropRect.hashCode ^
        originalSize.hashCode ^
        cropEditorScreenRatio.hashCode ^
        scaleUser.hashCode ^
        scaleRotation.hashCode ^
        aspectRatio.hashCode ^
        flipX.hashCode ^
        flipY.hashCode ^
        tiltRotate.hashCode ^
        tiltHorizontal.hashCode ^
        tiltVertical.hashCode ^
        cropMode.hashCode;
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
  unset,
}
