// Dart imports:
import 'dart:math';

/// Applies an ease-in-out interpolation function to the input value [t].
/// Returns a value between 0 and 1 based on the input.
double easeInOut(double t) {
  return t < 0.5 ? 0.5 * pow(2 * t, 2) : 0.5 * (2 - pow(2 * (1 - t), 2));
}

/// Applies a decelerating interpolation function to the input value [t].
/// Returns a value between 0 and 1 based on the input.
double decelerate(double t) {
  t = 1.0 - t;
  return 1.0 - t * t;
}

/// Applies a linear interpolation function to the input value [t].
/// Returns the input value unchanged.
double linear(double t) {
  return t;
}
