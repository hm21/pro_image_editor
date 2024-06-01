// Dart imports:
import 'dart:math';

class ColorFilterAddons {
  static List<double> colorOverlay(
    double r,
    double g,
    double b,
    double scale,
  ) {
    double invScale = 1 - scale;
    return [
      invScale,
      0,
      0,
      0,
      -r * scale,
      0,
      invScale,
      0,
      0,
      -g * scale,
      0,
      0,
      invScale,
      0,
      -b * scale,
      0,
      0,
      0,
      1,
      0
    ];
  }

  static List<double> rgbScale(double r, double g, double b) {
    return [r, 0, 0, 0, 0, 0, g, 0, 0, 0, 0, 0, b, 0, 0, 0, 0, 0, 1, 0];
  }

  static List<double> addictiveColor(double r, double g, double b) {
    return [1, 0, 0, 0, r, 0, 1, 0, 0, g, 0, 0, 1, 0, b, 0, 0, 0, 1, 0];
  }

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
      0
    ];
  }

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
      0
    ];
  }

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
      0
    ];
  }

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
      0
    ];
  }

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
      0
    ];
  }

  static List<double> hue(double value) {
    if (value == 0) {
      return [1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 0];
    }
    value *= pi;
    double cosVal = cos(value);
    double sinVal = sin(value);
    const double lumR = 0.213;
    const double lumG = 0.715;
    const double lumB = 0.072;

    return [
      lumR + cosVal * (1 - lumR) + sinVal * -lumR,
      lumG + cosVal * -lumG + sinVal * -lumG,
      lumB + cosVal * -lumB + sinVal * (1 - lumB),
      0,
      0,
      lumR + cosVal * -lumR + sinVal * 0.143,
      lumG + cosVal * (1 - lumG) + sinVal * 0.14,
      lumB + cosVal * -lumB + sinVal * -0.283,
      0,
      0,
      lumR + cosVal * -lumR + sinVal * -(1 - lumR),
      lumG + cosVal * -lumG + sinVal * lumG,
      lumB + cosVal * (1 - lumB) + sinVal * lumB,
      0,
      0,
      0,
      0,
      0,
      1,
      0
    ];
  }

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
      0
    ];
  }

  static List<double> opacity(double value) {
    return [1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, value, 0];
  }
}
