import 'package:flutter/material.dart';

/// An extension on [BoxConstraints] that provides additional functionality
/// for converting constraint values into a [Map].
/// ```
extension BoxConstraintsExtension on BoxConstraints {
  /// Converts the [BoxConstraints] properties into a [Map<String, double>].
  ///
  /// The returned map contains the following keys:
  /// - `'minWidth'`: The minimum width constraint.
  /// - `'maxWidth'`: The maximum width constraint.
  /// - `'minHeight'`: The minimum height constraint.
  /// - `'maxHeight'`: The maximum height constraint.
  Map<String, double> toMap() {
    return {
      'minWidth': minWidth,
      'maxWidth': maxWidth,
      'minHeight': minHeight,
      'maxHeight': maxHeight,
    };
  }
}
