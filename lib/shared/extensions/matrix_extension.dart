import 'package:flutter/widgets.dart';

/// Extension on [Matrix4] to simplify perspective and tilt transforms.
extension MatrixExtension on Matrix4 {
  /// Returns a new [Matrix4] with a perspective entry applied.
  ///
  /// The entry at row=3, col=2 is set to a small value (0.001) to
  /// simulate depth perspective.
  Matrix4 perspective() {
    return this..setEntry(3, 2, 0.001);
  }

  /// Applies tilt and rotation transforms to this [Matrix4].
  ///
  /// - [rotate]: rotation in radians around the Z axis.
  /// - [vertical]: tilt in radians around the X axis (up/down).
  /// - [horizontal]: tilt in radians around the Y axis (left/right).
  ///
  /// Returns a [Matrix4] with perspective and the tilt applied.
  Matrix4 tilt({
    required double rotate,
    required double vertical,
    required double horizontal,
  }) {
    return perspective()
      ..rotateZ(rotate)
      ..rotateX(vertical)
      ..rotateY(horizontal);
  }
}
