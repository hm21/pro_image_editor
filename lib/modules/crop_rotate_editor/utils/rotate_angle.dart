// Dart imports:
import 'dart:math';

/// Calculates the rotation angle side based on the given angle factor.
///
/// The [angleFactor] is the factor used to calculate the rotation angle side.
/// It should be a value in radians.
///
/// Returns a [RotateAngleSide] enum value representing the rotation angle side.
RotateAngleSide getRotateAngleSide(double angleFactor) {
  double pi2 = pi * 2;
  String factor = (angleFactor % pi2).toStringAsFixed(3);

  if (factor == (pi * 1.5).toStringAsFixed(3)) {
    return RotateAngleSide.left;
  } else if (factor == pi.toStringAsFixed(3)) {
    return RotateAngleSide.bottom;
  } else if (factor == (pi / 2).toStringAsFixed(3)) {
    return RotateAngleSide.right;
  } else {
    return RotateAngleSide.top;
  }
}

/// Enum representing different rotation angle sides.
enum RotateAngleSide {
  /// Represents the left rotation angle side.
  left,

  /// Represents the bottom rotation angle side.
  bottom,

  /// Represents the right rotation angle side.
  right,

  /// Represents the top rotation angle side.
  top,
}
