// Dart imports:
import 'dart:math';

/// A utility class providing various color filter transformations.
///
/// This class contains static methods that generate color filter matrices
/// for applying different effects to images, such as overlaying colors,
/// scaling RGB values, converting to grayscale, applying sepia tones,
/// and more.
class ColorFilterAddons {
  /// Generates a color overlay filter matrix.
  ///
  /// This method returns a color matrix that applies an overlay effect using
  /// the specified RGB values and scale. The resulting effect blends the
  /// original colors with the specified overlay colors.
  ///
  /// Parameters:
  /// - [r]: The red component of the overlay color.
  /// - [g]: The green component of the overlay color.
  /// - [b]: The blue component of the overlay color.
  /// - [scale]: The blending scale factor, where `0` is no overlay and `1` is
  ///   full overlay.
  static List<double> colorOverlay(double r, double g, double b, double scale) {
    double invScale = 1 - scale;
    // Blend each channel towards the overlay color: out = (1 - scale) * in +
    // scale * color. The offset must be added, not subtracted, otherwise the
    // image is tinted towards the complementary color instead of [r, g, b].
    return [
      invScale,
      0,
      0,
      0,
      r * scale,
      0,
      invScale,
      0,
      0,
      g * scale,
      0,
      0,
      invScale,
      0,
      b * scale,
      0,
      0,
      0,
      1,
      0,
    ];
  }

  /// Generates an RGB scale filter matrix.
  ///
  /// This method returns a color matrix that scales the red, green, and blue
  /// components of an image by the specified factors.
  ///
  /// Parameters:
  /// - [r]: The scale factor for the red component.
  /// - [g]: The scale factor for the green component.
  /// - [b]: The scale factor for the blue component.
  static List<double> rgbScale(double r, double g, double b) {
    return [r, 0, 0, 0, 0, 0, g, 0, 0, 0, 0, 0, b, 0, 0, 0, 0, 0, 1, 0];
  }

  /// Generates an additive color filter matrix.
  ///
  /// This method returns a color matrix that adds the specified RGB values to
  /// each pixel in an image, creating an additive color effect.
  ///
  /// Parameters:
  /// - [r]: The red component to add.
  /// - [g]: The green component to add.
  /// - [b]: The blue component to add.
  static List<double> addictiveColor(double r, double g, double b) {
    return [1, 0, 0, 0, r, 0, 1, 0, 0, g, 0, 0, 1, 0, b, 0, 0, 0, 1, 0];
  }

  /// Generates a temperature adjustment filter matrix.
  ///
  /// This method adjusts the color temperature of an image by increasing
  /// the warm (red) or cool (blue) tones.
  ///
  /// Parameters:
  /// - [value]: The temperature adjustment factor, where negative values
  ///   cool the image and positive values warm it.
  static List<double> temperature(double value) {
    // A positive value warms the image (adds red and green),
    // a negative value cools it (adds blue and reduces red/green).
    double r = value > 0 ? value : 0;
    double b = value < 0 ? -value : 0;

    return [
      1 + r, 0, 0, 0, 0, // Red channel adjustment
      0, 1 + r * 0.5, 0, 0, 0, // Green channel adjustment (half of red)
      0, 0, 1 + b, 0, 0, // Blue channel adjustment
      0, 0, 0, 1, 0, // Alpha channel (unchanged)
    ];
  }

  /// Generates a grayscale filter matrix.
  ///
  /// This method returns a color matrix that converts an image to grayscale
  /// using the luminance values for the RGB components.
  static List<double> grayscale() {
    const double lumR = 0.2126;
    const double lumG = 0.7152;
    const double lumB = 0.0722;
    return [
      lumR,
      lumG,
      lumB,
      0,
      0,
      lumR,
      lumG,
      lumB,
      0,
      0,
      lumR,
      lumG,
      lumB,
      0,
      0,
      0,
      0,
      0,
      1,
      0,
    ];
  }

  /// Generates a sepia filter matrix.
  ///
  /// This method returns a color matrix that applies a sepia tone effect to
  /// an image, using the specified intensity value.
  ///
  /// Parameters:
  /// - [value]: The intensity of the sepia effect, where `0` is no effect and
  ///   `1` is full effect.
  static List<double> sepia(double value) {
    double inv0_607 = 1 - 0.607 * value;
    double inv0_314 = 1 - 0.314 * value;
    double inv0_869 = 1 - 0.869 * value;
    return [
      inv0_607,
      0.769 * value,
      0.189 * value,
      0,
      0,
      0.349 * value,
      inv0_314,
      0.168 * value,
      0,
      0,
      0.272 * value,
      0.534 * value,
      inv0_869,
      0,
      0,
      0,
      0,
      0,
      1,
      0,
    ];
  }

  /// Generates an invert color filter matrix.
  ///
  /// This method returns a color matrix that inverts the colors of an image,
  /// effectively creating a negative effect.
  static List<double> invert() {
    const double offset = 255.0;
    return [
      -1,
      0,
      0,
      0,
      offset,
      0,
      -1,
      0,
      0,
      offset,
      0,
      0,
      -1,
      0,
      offset,
      0,
      0,
      0,
      1,
      0,
    ];
  }

  /// Generates a brightness adjustment filter matrix.
  ///
  /// This method returns a color matrix that adjusts the brightness of an
  /// image by the specified value.
  ///
  /// Parameters:
  /// - [value]: The brightness adjustment factor, where negative values darken
  ///   the image and positive values lighten the image.
  static List<double> brightness(double value) {
    value = value <= 0 ? value * 255 : value * 100;
    if (value == 0) {
      return [1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 0];
    }
    return [
      1,
      0,
      0,
      0,
      value,
      0,
      1,
      0,
      0,
      value,
      0,
      0,
      1,
      0,
      value,
      0,
      0,
      0,
      1,
      0,
    ];
  }

  /// Generates a contrast adjustment filter matrix.
  ///
  /// This method returns a color matrix that adjusts the contrast of an image
  /// by the specified value.
  ///
  /// Parameters:
  /// - [value]: The contrast adjustment factor, where negative values decrease
  ///   contrast and positive values increase contrast.
  static List<double> contrast(double value) {
    double adj = value * 255;
    double factor = (259 * (adj + 255)) / (255 * (259 - adj));
    double offset = 128 * (1 - factor);
    return [
      factor,
      0,
      0,
      0,
      offset,
      0,
      factor,
      0,
      0,
      offset,
      0,
      0,
      factor,
      0,
      offset,
      0,
      0,
      0,
      1,
      0,
    ];
  }

  /// Generates a hue adjustment filter matrix.
  ///
  /// This method returns a color matrix that adjusts the hue of an image by
  /// the specified value.
  ///
  /// Parameters:
  /// - [value]: The hue adjustment factor, where positive values rotate the
  ///   hue clockwise and negative values rotate it counterclockwise.
  static List<double> hue(double value) {
    if (value == 0) {
      // No hue adjustment
      return [1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 0];
    }

    // Convert value to radians. Note this maps value == 1 to π (a 180°
    // rotation), so a full 360° rotation corresponds to value == 2.
    value *= pi;

    double cosVal = cos(value); // Cosine of the angle
    double sinVal = sin(value); // Sine of the angle

    // Luminance coefficients for RGB
    const double lumR = 0.213;
    const double lumG = 0.715;
    const double lumB = 0.072;

    // Compute the matrix values
    return [
      lumR + cosVal * (1 - lumR) + sinVal * -lumR, // Red-to-red
      lumG + cosVal * -lumG + sinVal * -lumG, // Red-to-green
      lumB + cosVal * -lumB + sinVal * (1 - lumB), // Red-to-blue
      0,
      0,
      lumR + cosVal * -lumR + sinVal * 0.143, // Green-to-red
      lumG + cosVal * (1 - lumG) + sinVal * 0.14, // Green-to-green
      lumB + cosVal * -lumB + sinVal * -0.283, // Green-to-blue
      0,
      0,
      lumR + cosVal * -lumR + sinVal * -(1 - lumR), // Blue-to-red
      lumG + cosVal * -lumG + sinVal * lumG, // Blue-to-green
      lumB + cosVal * (1 - lumB) + sinVal * lumB, // Blue-to-blue
      0,
      0,
      0,
      0,
      0,
      1,
      0,
    ];
  }

  /// Generates a saturation adjustment filter matrix.
  ///
  /// This method returns a color matrix that adjusts the saturation of an
  /// image by the specified value.
  ///
  /// Parameters:
  /// - [value]: The saturation adjustment factor, where negative values
  ///   decrease saturation and positive values increase saturation.
  static List<double> saturation(double value) {
    if (value == 0) {
      return [1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 0];
    }
    double x = 1 + (value > 0 ? 3 * value : value);
    double xInverted = 1 - x;
    const double lumR = 0.3086;
    const double lumG = 0.6094;
    const double lumB = 0.082;

    return [
      lumR * xInverted + x,
      lumG * xInverted,
      lumB * xInverted,
      0,
      0,
      lumR * xInverted,
      lumG * xInverted + x,
      lumB * xInverted,
      0,
      0,
      lumR * xInverted,
      lumG * xInverted,
      lumB * xInverted + x,
      0,
      0,
      0,
      0,
      0,
      1,
      0,
    ];
  }

  /// Generates an exposure adjustment filter matrix.
  ///
  /// This method returns a color matrix that adjusts the exposure of an image
  /// by the specified value.
  ///
  /// Parameters:
  /// - [value]: The exposure adjustment factor, where positive values increase
  ///   exposure (brighten the image) and negative values decrease exposure
  ///   (darken the image).
  static List<double> exposure(double value) {
    // Exposure adjustment affects all color channels uniformly.
    double exposureFactor = pow(2, value).toDouble();
    return [
      exposureFactor, 0, 0, 0, 0, // Red channel
      0, exposureFactor, 0, 0, 0, // Green channel
      0, 0, exposureFactor, 0, 0, // Blue channel
      0, 0, 0, 1, 0, // Alpha channel (no change)
    ];
  }

  /// Generates a fade effect filter matrix.
  ///
  /// Produces a classic washed-out "fade" by lowering the contrast and lifting
  /// the black point, so shadows turn milky while the overall image loses
  /// punch. Both operations are linear, so they map cleanly onto a color
  /// matrix.
  ///
  /// Parameters:
  /// - [value]: The intensity of the fade effect. `0` leaves the image
  ///   unchanged, higher values make it more faded. Negative values invert the
  ///   effect (more contrast and a lowered black point).
  static List<double> fade(double value) {
    if (value == 0) {
      return [1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 0];
    }

    double factor = 1 - 0.2 * value; // Reduce contrast.
    double lift = 30 * value; // Raise the black point (0..255).

    return [
      factor, 0, 0, 0, lift, // Red channel
      0, factor, 0, 0, lift, // Green channel
      0, 0, factor, 0, lift, // Blue channel
      0, 0, 0, 1, 0, // Alpha channel (unchanged)
    ];
  }

  /// Generates a tint adjustment filter matrix.
  ///
  /// Shifts the image along the green–magenta axis, the natural complement to
  /// [temperature] (which works on the blue–amber axis). This is a linear
  /// per-channel offset, so it maps cleanly onto a color matrix.
  ///
  /// Parameters:
  /// - [value]: The tint adjustment factor. `0` keeps the original colors,
  ///   positive values push towards magenta and negative values towards green.
  static List<double> tint(double value) {
    if (value == 0) {
      return [1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 0];
    }

    // Magenta adds to red/blue and removes green; green does the inverse.
    double offset = value * 100;

    return [
      1, 0, 0, 0, offset, // Red channel
      0, 1, 0, 0, -offset, // Green channel
      0, 0, 1, 0, offset, // Blue channel
      0, 0, 0, 1, 0, // Alpha channel (unchanged)
    ];
  }
}
