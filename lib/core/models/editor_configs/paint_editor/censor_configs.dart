import 'dart:ui';

/// A configuration class for defining blur settings for censoring content.
class CensorConfigs {
  /// Creates a new instance of [CensorConfigs].
  const CensorConfigs({
    this.blurSigmaX = 14.0,
    this.blurSigmaY = 14.0,
    this.pixelBlockSize = 80.0,
    this.enableRoundArea = false,
    this.blurBlendMode = BlendMode.srcOver,
    this.pixelateBlendMode = BlendMode.srcOver,
    this.pixelateInLayerSpace = false,
  });

  /// A boolean flag to enable or disable the use of a round area for the
  /// censor tool instant of a rectangle area.
  ///
  /// **Default** `false`
  final bool enableRoundArea;

  /// The standard deviation for the Gaussian blur in the horizontal direction.
  ///
  /// **Default** `14.0`
  final double blurSigmaX;

  /// The standard deviation for the Gaussian blur in the vertical direction.
  ///
  /// **Default** `14.0`
  final double blurSigmaY;

  /// The blend mode used for the blur effect.
  ///
  /// This determines how the blur effect will be blended with the underlying
  /// image.
  ///
  /// **Default** `BlendMode.srcOver`
  final BlendMode blurBlendMode;

  /// The size of each pixel block used for the pixelation effect.
  ///
  /// This value determines how large each pixel block will be when applying the
  /// pixelation effect to an image. A larger value will create a stronger
  /// pixelation effect, while a smaller value will result in finer pixelation.
  ///
  /// **Default** `80.0`
  final double pixelBlockSize;

  /// The blend mode used for the pixelate effect.
  ///
  /// This determines how the pixelate effect will be blended with the
  /// underlying image.
  ///
  /// **Default** `BlendMode.srcOver`
  final BlendMode pixelateBlendMode;

  /// Whether the pixelation is measured in the censor area's own coordinates.
  ///
  /// When `true`, [pixelBlockSize] is in the area's logical pixels, so the
  /// blocks grow and shrink with the layer's scale, the editor's zoom and any
  /// transform around the editor, as the blur does. The blocks start at the
  /// area's top-left corner and take the color at their center, which is how
  /// an export that pixelates the same area in its own pixels lines them up.
  ///
  /// When `false`, the blocks keep their size on screen whatever the area's
  /// scale, and line up with the screen.
  ///
  /// **Default** `false`
  final bool pixelateInLayerSpace;

  /// Returns a new [CensorConfigs] instance with updated values.
  ///
  /// If a parameter is not provided, the existing value is retained.
  CensorConfigs copyWith({
    double? blurSigmaX,
    double? blurSigmaY,
    double? pixelBlockSize,
    bool? enableRoundArea,
    BlendMode? blurBlendMode,
    BlendMode? pixelateBlendMode,
    bool? pixelateInLayerSpace,
  }) {
    return CensorConfigs(
      blurSigmaX: blurSigmaX ?? this.blurSigmaX,
      blurSigmaY: blurSigmaY ?? this.blurSigmaY,
      pixelBlockSize: pixelBlockSize ?? this.pixelBlockSize,
      enableRoundArea: enableRoundArea ?? this.enableRoundArea,
      blurBlendMode: blurBlendMode ?? this.blurBlendMode,
      pixelateBlendMode: pixelateBlendMode ?? this.pixelateBlendMode,
      pixelateInLayerSpace: pixelateInLayerSpace ?? this.pixelateInLayerSpace,
    );
  }
}
