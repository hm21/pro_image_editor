// Flutter imports:
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

// Project imports:
import 'package:pro_image_editor/pro_image_editor.dart';
import '../../../utils/theme_functions.dart';
import 'animations/loading_dialog_opacity_animation.dart';
import 'models/loading_dialog_overlay_details.dart';

/// A singleton class that manages the display of loading dialogs.
///
/// The `LoadingDialog` class provides methods to show and hide a loading
/// dialog.
/// It allows customization of the loading message, dismissibility, and theme.
/// It maintains a stack of active overlays to handle multiple dialogs if
/// needed.
class LoadingDialog extends ChangeNotifier {
  LoadingDialog._();

  /// The singleton instance of `LoadingDialog`.
  static final LoadingDialog instance = LoadingDialog._();

  /// A list of active loading overlays.
  final List<LoadingOverlayDetails> _overlays = [];

  /// Returns `true` if there is an active overlay.
  bool get hasActiveOverlay => _overlays.isNotEmpty;

  /// Returns `true` if the topmost overlay is dismissible.
  bool get isDismissible =>
      _overlays.isNotEmpty ? _overlays.last.isDismissible : true;

  /// Displays a loading dialog in the given [context].
  ///
  /// Parameters:
  /// - [context]: The build context in which to display the dialog.
  /// - [message]: An optional parameter to customize the loading message.
  /// - [isDismissible]: Determines if the dialog can be dismissed. Defaults to
  /// the value of `kDebugMode`.
  /// - [theme]: The theme data for styling the dialog. If not provided, the
  /// current theme of the context is used.
  /// - [configs]: Configuration settings for the Pro Image Editor.
  ///
  /// The method creates an overlay entry with an animated opacity transition,
  /// and inserts it into the overlay stack. Custom widgets for the loading
  /// dialog can be provided via `configs.customWidgets.loadingDialog`.
  void show(
    BuildContext context, {
    String? message,
    bool isDismissible = kDebugMode,
    ThemeData? theme,
    required ProImageEditorConfigs configs,
  }) async {
    theme ??= configs.theme ?? Theme.of(context);
    message ??= configs.i18n.various.loadingDialogMsg;

    var animationKey = GlobalKey<OpacityOverlayAnimationState>();

    OverlayEntry overlay = OverlayEntry(
      builder: (BuildContext context) => OpacityOverlayAnimation(
        key: animationKey,
        onAnimationDone: () {
          /// Remove the overlay after the animation is done.
          _removeOverlay();
        },
        child: configs.customWidgets.loadingDialog != null
            ? configs.customWidgets.loadingDialog!(message!, configs)
            : Stack(
                children: [
                  _buildBackdrop(context, isDismissible),
                  _buildDefaultDialog(
                    theme: theme!,
                    context: context,
                    configs: configs,
                    message: message!,
                  )
                ],
              ),
      ),
    );

    Overlay.of(context).insert(overlay);

    _overlays.add(LoadingOverlayDetails(
      entry: overlay,
      isDismissible: isDismissible,
      animationKey: animationKey,
    ));

    notifyListeners();
  }

  /// Hides the topmost loading dialog.
  ///
  /// The method triggers the hide animation of the dialog,
  /// which will remove the overlay after the animation completes.
  void hide() {
    if (_overlays.isNotEmpty) {
      if (_overlays.last.animationKey.currentState == null) {
        _removeOverlay();
      } else {
        _overlays.last.animationKey.currentState!.hide();
      }
    }
    notifyListeners();
  }

  /// Removes the topmost overlay from the stack.
  void _removeOverlay() {
    if (_overlays.isNotEmpty) {
      _overlays.last.entry.remove();
      _overlays.removeLast();
    }
  }

  /// Builds the default loading dialog widget.
  ///
  /// The dialog can be either a Material or Cupertino styled dialog,
  /// depending on the design mode specified in [configs].
  Widget _buildDefaultDialog({
    required ThemeData theme,
    required BuildContext context,
    required ProImageEditorConfigs configs,
    required String message,
  }) {
    return Center(
      child: configs.designMode == ImageEditorDesignModeE.cupertino
          ? _buildCupertinoDialog(
              theme: theme,
              configs: configs,
              content: _buildDialogContent(
                context: context,
                configs: configs,
                message: message,
              ),
              context: context,
            )
          : _buildMaterialDialog(
              theme: theme,
              content: _buildDialogContent(
                context: context,
                configs: configs,
                message: message,
              ),
            ),
    );
  }

  /// Builds a Material-styled dialog widget.
  ///
  /// The dialog is themed with the provided [theme] and contains the specified
  /// [content].
  Widget _buildMaterialDialog({
    required ThemeData theme,
    required Widget content,
  }) {
    return Theme(
      data: theme,
      child: AlertDialog(
        contentPadding:
            const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        content: content,
      ),
    );
  }

  /// Builds a Cupertino-styled dialog widget.
  ///
  /// The dialog is themed with the provided [theme] and contains the specified
  /// [content].
  /// The theme brightness determines the primary color of the dialog.
  Widget _buildCupertinoDialog({
    required ThemeData theme,
    required BuildContext context,
    required ProImageEditorConfigs configs,
    required Widget content,
  }) {
    return CupertinoTheme(
      data: CupertinoTheme.of(context).copyWith(
        brightness: theme.brightness,
        primaryColor: theme.brightness == Brightness.dark
            ? configs
                .imageEditorTheme.loadingDialogTheme.cupertinoPrimaryColorDark
            : configs
                .imageEditorTheme.loadingDialogTheme.cupertinoPrimaryColorLight,
        textTheme: CupertinoTextThemeData(
          textStyle: TextStyle(
            color: theme.brightness == Brightness.dark
                ? configs.imageEditorTheme.loadingDialogTheme
                    .cupertinoPrimaryColorDark
                : configs.imageEditorTheme.loadingDialogTheme
                    .cupertinoPrimaryColorLight,
          ),
        ),
      ),
      child: CupertinoAlertDialog(
        content: content,
      ),
    );
  }

  /// Builds the content widget for the dialog.
  ///
  /// The content consists of a circular progress indicator and a message.
  Widget _buildDialogContent({
    required BuildContext context,
    required ProImageEditorConfigs configs,
    required String message,
  }) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 500),
      child: Padding(
        padding: const EdgeInsets.only(top: 3.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(right: 20.0),
              child: SizedBox(
                height: 40,
                width: 40,
                child: FittedBox(
                  child: PlatformCircularProgressIndicator(configs: configs),
                ),
              ),
            ),
            Expanded(
              child: Text(
                message,
                style: platformTextStyle(
                  context,
                  configs.designMode,
                ).copyWith(
                  fontSize: 16,
                  color: configs.imageEditorTheme.loadingDialogTheme.textColor,
                ),
                textAlign: TextAlign.start,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds a backdrop for the dialog.
  ///
  /// The backdrop is a semi-transparent modal barrier.
  /// If [isDismissible] is true, tapping the backdrop will dismiss the dialog.
  Widget _buildBackdrop(BuildContext context, bool isDismissible) {
    return ModalBarrier(
      onDismiss: isDismissible ? hide : null,
      color: Colors.black54,
      dismissible: isDismissible,
    );
  }
}
