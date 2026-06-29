/// Configuration options for the tilt editor.
///
/// Controls visibility of tilt controls and defines min/max
/// ranges for rotation, vertical tilt, and horizontal tilt.
class TiltConfigs {
  /// Creates a [TiltConfigs] with optional overrides.
  const TiltConfigs({
    this.showTiltButton = true,
    this.showTiltRotate = true,
    this.showTiltVertical = true,
    this.showTiltHorizontal = true,
    this.tiltRotateMin = -45.0,
    this.tiltRotateMax = 45.0,
    this.tiltVerticalMin = -30.0,
    this.tiltVerticalMax = 30.0,
    this.tiltHorizontalMin = -30.0,
    this.tiltHorizontalMax = 30.0,
  }) : assert(
         tiltRotateMin <= tiltRotateMax,
         '[tiltRotateMin] must be <= [tiltRotateMax]',
       ),
       assert(
         tiltVerticalMin <= tiltVerticalMax,
         '[tiltVerticalMin] must be <= [tiltVerticalMax]',
       ),
       assert(
         tiltHorizontalMin <= tiltHorizontalMax,
         '[tiltHorizontalMin] must be <= [tiltHorizontalMax]',
       );

  /// Whether to show a button that opens the tilt editor.
  final bool showTiltButton;

  /// Whether the rotate tilt control should be shown.
  final bool showTiltRotate;

  /// Whether the vertical tilt control (up/down) should be shown.
  final bool showTiltVertical;

  /// Whether the horizontal tilt control (left/right) should be shown.
  final bool showTiltHorizontal;

  /// Minimum allowed rotate tilt in degrees.
  final double tiltRotateMin;

  /// Maximum allowed rotate tilt in degrees.
  final double tiltRotateMax;

  /// Minimum allowed vertical tilt (up/down) in degrees.
  final double tiltVerticalMin;

  /// Maximum allowed vertical tilt (up/down) in degrees.
  final double tiltVerticalMax;

  /// Minimum allowed horizontal tilt (left/right) in degrees.
  final double tiltHorizontalMin;

  /// Maximum allowed horizontal tilt (left/right) in degrees.
  final double tiltHorizontalMax;

  /// Returns a copy of this [TiltConfigs] with the given values replaced.
  TiltConfigs copyWith({
    bool? showTiltButton,
    bool? showTiltRotate,
    bool? showTiltVertical,
    bool? showTiltHorizontal,
    double? tiltRotateMin,
    double? tiltRotateMax,
    double? tiltVerticalMin,
    double? tiltVerticalMax,
    double? tiltHorizontalMin,
    double? tiltHorizontalMax,
  }) {
    return TiltConfigs(
      showTiltButton: showTiltButton ?? this.showTiltButton,
      showTiltRotate: showTiltRotate ?? this.showTiltRotate,
      showTiltVertical: showTiltVertical ?? this.showTiltVertical,
      showTiltHorizontal: showTiltHorizontal ?? this.showTiltHorizontal,
      tiltRotateMin: tiltRotateMin ?? this.tiltRotateMin,
      tiltRotateMax: tiltRotateMax ?? this.tiltRotateMax,
      tiltVerticalMin: tiltVerticalMin ?? this.tiltVerticalMin,
      tiltVerticalMax: tiltVerticalMax ?? this.tiltVerticalMax,
      tiltHorizontalMin: tiltHorizontalMin ?? this.tiltHorizontalMin,
      tiltHorizontalMax: tiltHorizontalMax ?? this.tiltHorizontalMax,
    );
  }
}
