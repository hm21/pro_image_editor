// Dart imports:
import 'dart:math';

double easeInOut(double t) {
  return t < 0.5 ? 0.5 * pow(2 * t, 2) : 0.5 * (2 - pow(2 * (1 - t), 2));
}

double decelerate(double t) {
  t = 1.0 - t;
  return 1.0 - t * t;
}

double linear(double t) {
  return t;
}
