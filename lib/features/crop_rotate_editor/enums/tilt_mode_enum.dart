/// Describes the active tilt mode.
///
/// Used to indicate whether the tilt is applied horizontally,
/// vertically, or as a rotation.
enum TiltMode {
  /// Tilt around the Y axis (left/right).
  horizontal,

  /// Tilt around the X axis (up/down).
  vertical,

  /// Rotation around the Z axis.
  rotate,
}
