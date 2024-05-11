/// A utility class containing commonly used crop aspect ratios.
class CropAspectRatios {
  /// Represents a custom aspect ratio.
  ///
  /// Use this value when a custom aspect ratio is desired.
  static const double custom = -1;

  /// Represents the original aspect ratio.
  ///
  /// Use this value to maintain the original aspect ratio of an image or content.
  static const double original = 0;

  /// Represents a 1:1 aspect ratio.
  static const double ratio1_1 = 1;

  /// Represents a 4:3 aspect ratio.
  static const double ratio4_3 = 4 / 3;

  /// Represents a 3:4 aspect ratio.
  static const double ratio3_4 = 3 / 4;

  /// Represents a 16:9 aspect ratio.
  static const double ratio16_9 = 16 / 9;

  /// Represents a 9:16 aspect ratio.
  static const double ratio9_16 = 9 / 16;
}
