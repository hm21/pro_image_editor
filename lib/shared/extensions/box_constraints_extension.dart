import 'package:material_ui/material_ui.dart';

import '/core/constants/int_constants.dart';
import 'num_extension.dart';

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
  Map<String, num> toMap({int maxDecimalPlaces = kMaxSafeDecimalPlaces}) {
    return {
      'minWidth': minWidth.roundSmart(maxDecimalPlaces),
      'maxWidth': maxWidth.roundSmart(maxDecimalPlaces),
      'minHeight': minHeight.roundSmart(maxDecimalPlaces),
      'maxHeight': maxHeight.roundSmart(maxDecimalPlaces),
    };
  }
}
