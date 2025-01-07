import 'adaptive_dialog_style.dart';
import 'loading_dialog_style.dart';

export 'adaptive_dialog_style.dart';
export 'loading_dialog_style.dart';

/// Style configuration class for dialogs used in the editor.
class DialogStyle {
  /// Creates a new instance of [DialogStyle].
  const DialogStyle({
    this.loadingDialog = const LoadingDialogStyle(),
    this.adaptiveDialog = const AdaptiveDialogStyle(),
  });

  /// Style configuration for the loading dialog.
  final LoadingDialogStyle loadingDialog;

  /// Style configuration for adaptive dialogs.
  final AdaptiveDialogStyle adaptiveDialog;

  /// Creates a copy of this style configuration with the specified overrides.
  DialogStyle copyWith({
    LoadingDialogStyle? loadingDialog,
    AdaptiveDialogStyle? adaptiveDialog,
  }) {
    return DialogStyle(
      loadingDialog: loadingDialog ?? this.loadingDialog,
      adaptiveDialog: adaptiveDialog ?? this.adaptiveDialog,
    );
  }
}
