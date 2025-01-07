import 'package:flutter/widgets.dart';

import '../editor_configs/pro_image_editor_configs.dart';

/// Defines customizable widgets for the dialog in the editor.
class DialogWidgets {
  /// Creates a new instance of [DialogWidgets].
  const DialogWidgets({
    this.loadingDialog,
  });

  /// Replace the existing loading dialog.
  ///
  /// **Example:**
  /// ```dart
  /// loadingDialog: (message, configs) => Stack(
  ///   children: [
  ///     ModalBarrier(
  ///       onDismiss: kDebugMode ? LoadingDialog.instance.hide : null,
  ///       color: Colors.black54,
  ///       dismissible: kDebugMode,
  ///     ),
  ///     Center(
  ///       child: Theme(
  ///         data: Theme.of(context),
  ///         child: AlertDialog(
  ///           contentPadding:
  ///               const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
  ///           content: ConstrainedBox(
  ///             constraints: const BoxConstraints(maxWidth: 500),
  ///             child: Padding(
  ///               padding: const EdgeInsets.only(top: 3.0),
  ///               child: Row(
  ///                 crossAxisAlignment: CrossAxisAlignment.center,
  ///                 mainAxisAlignment: MainAxisAlignment.start,
  ///                 children: [
  ///                   Padding(
  ///                     padding: const EdgeInsets.only(right: 20.0),
  ///                     child: SizedBox(
  ///                       height: 40,
  ///                       width: 40,
  ///                       child: FittedBox(
  ///                         child: PlatformCircularProgressIndicator(
  ///                           configs: configs,
  ///                         ),
  ///                       ),
  ///                     ),
  ///                   ),
  ///                   Expanded(
  ///                     child: Text(
  ///                       message,
  ///                       style: platformTextStyle(
  ///                         context,
  ///                         configs.designMode,
  ///                       ).copyWith(
  ///                         fontSize: 16,
  ///                         color: configs.imageEditorTheme
  ///                             .loadingDialogTheme.textColor,
  ///                       ),
  ///                       textAlign: TextAlign.start,
  ///                     ),
  ///                   ),
  ///                 ],
  ///               ),
  ///             ),
  ///           ),
  ///         ),
  ///       ),
  ///     ),
  ///   ],
  /// ),
  /// ```
  final Widget Function(String message, ProImageEditorConfigs configs)?
      loadingDialog;

  /// Creates a copy of this widget configuration with specified overrides.
  DialogWidgets copyWith({
    Widget Function(String message, ProImageEditorConfigs configs)?
        loadingDialog,
  }) {
    return DialogWidgets(loadingDialog: loadingDialog ?? this.loadingDialog);
  }
}
