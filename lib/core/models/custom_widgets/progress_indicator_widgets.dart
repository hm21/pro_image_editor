import 'package:flutter/widgets.dart';

/// Configuration class for customizing progress indicators.
class ProgressIndicatorWidgets {
  /// Creates a new instance of [ProgressIndicatorWidgets].
  const ProgressIndicatorWidgets({
    this.circularProgressIndicator,
  });

  /// Custom widget to replace the default [CircularProgressIndicator].
  final Widget? circularProgressIndicator;

  /// Creates a copy of this configuration with the specified overrides.
  ProgressIndicatorWidgets copyWith({
    Widget? circularProgressIndicator,
  }) {
    return ProgressIndicatorWidgets(
      circularProgressIndicator:
          circularProgressIndicator ?? this.circularProgressIndicator,
    );
  }
}
