import 'dart:math';

import 'package:flutter/widgets.dart';

import '../../pro_image_editor.dart';

/// Extension for [double] values that provides safe clamping methods.
extension DoubleExtension on double {
  /// Clamps the double value between [lowerLimit] and [upperLimit],
  /// ensuring [lowerLimit] is not greater than [upperLimit].
  ///
  /// Returns the clamped value as a double.
  ///
  /// Example:
  /// ```dart
  /// 3.5.safeMinClamp(8, 5); // returns 5
  /// 5.5.safeMinClamp(2, 10); // returns 5.5
  /// 12.0.safeMinClamp(2, 10); // returns 10.0
  /// ```
  double safeMinClamp(num lowerLimit, num upperLimit) {
    return clamp(min(lowerLimit, upperLimit), upperLimit).toDouble();
  }

  /// Clamps the double value between [lowerLimit] and [upperLimit],
  /// ensuring [upperLimit] is not less than [lowerLimit].
  ///
  /// Returns the clamped value as a double.
  ///
  /// Example:
  /// ```dart
  /// 12.safeMinClamp(8, 5); // returns 8
  /// 1.5.safeMaxClamp(2, 10); // returns 2.0
  /// 5.5.safeMaxClamp(2, 10); // returns 5.5
  /// ```
  double safeMaxClamp(num lowerLimit, num upperLimit) {
    return clamp(lowerLimit, max(lowerLimit, upperLimit)).toDouble();
  }

  /// Converts the current double value to device pixels based on the device's
  /// pixel ratio.
  ///
  /// This method multiplies the current value by the device pixel ratio
  /// obtained from the [MediaQuery] of the provided [BuildContext], and then
  /// converts the result to an integer.
  ///
  /// - [context]: The [BuildContext] used to retrieve the device's pixel ratio.
  ///
  /// Returns an integer representing the value in device pixels.
  int toDevicePixels(BuildContext context) {
    return (this * MediaQuery.devicePixelRatioOf(context)).toInt();
  }

  /// Rounds the number to the given number of decimal places.
  ///
  /// Example:
  /// ```dart
  /// 3.14159.roundToDecimals(2); // returns 3.14
  /// ```
  double roundToDecimals(int decimals) {
    if (isNaN || isInfinite) return this;

    return safeParseDouble(toStringAsFixed(decimals));
  }

  /// Converts the current double value from degrees to radians.
  double get degToRad => this * (pi / 180.0);

  /// Converts the current double value from radians to degrees.
  double get radToDeg => this * (180.0 / pi);
}
