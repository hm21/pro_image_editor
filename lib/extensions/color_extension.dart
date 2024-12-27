import 'package:flutter/material.dart';

/// Extension on the [Color] class to provide a method for converting a color
/// to its hexadecimal representation.
extension ColorToHex on Color {
  /// Converts a [Color] to its hexadecimal representation.
  int toHex({bool leadingHashSign = true}) {
    int floatToInt8(double x) {
      return (x * 255.0).round() & 0xff;
    }

    return floatToInt8(a) << 24 |
        floatToInt8(r) << 16 |
        floatToInt8(g) << 8 |
        floatToInt8(b) << 0;
  }
}
