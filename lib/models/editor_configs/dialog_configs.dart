import '../custom_widgets/dialog_widgets.dart';
import '../styles/dialog_style.dart';

export '../custom_widgets/dialog_widgets.dart';
export '../styles/dialog_style.dart';

/// Configuration class for customizing the dialog in the editor.
class DialogConfigs {
  /// Creates a new instance of [DialogConfigs].
  const DialogConfigs({
    this.widgets = const DialogWidgets(),
    this.style = const DialogStyle(),
  });

  /// Widgets used for customizing the dialogs.
  final DialogWidgets widgets;

  /// Style configuration for dialogs in the editor.
  final DialogStyle style;

  /// Creates a copy of this configuration with the specified overrides.
  DialogConfigs copyWith({
    DialogWidgets? widgets,
    DialogStyle? style,
  }) {
    return DialogConfigs(
      widgets: widgets ?? this.widgets,
      style: style ?? this.style,
    );
  }
}
