import '../custom_widgets/progress_indicator_widgets.dart';

export '../custom_widgets/progress_indicator_widgets.dart';

/// Configuration class for customizing progress indicators.
class ProgressIndicatorConfigs {
  /// Creates a new instance of [ProgressIndicatorConfigs].
  const ProgressIndicatorConfigs({
    this.widgets = const ProgressIndicatorWidgets(),
  });

  /// Widgets used for customizing progress indicators.
  final ProgressIndicatorWidgets widgets;

  /// Creates a copy of this configuration with the specified overrides.
  ProgressIndicatorConfigs copyWith({
    ProgressIndicatorWidgets? widgets,
  }) {
    return ProgressIndicatorConfigs(
      widgets: widgets ?? this.widgets,
    );
  }
}
