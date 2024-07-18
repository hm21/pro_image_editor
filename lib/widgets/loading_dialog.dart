// Dart imports:
import 'dart:async';

// Flutter imports:
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

// Project imports:
import 'package:pro_image_editor/pro_image_editor.dart';
import '../utils/theme_functions.dart';

class LoadingDialog {
  String _msg = '';
  dynamic state;

  bool _isVisible = false;
  bool _isDisposed = false;

  Completer? _completer;

  /// Some packages like "Asuka" require the same context like in the dialog
  /// to close the dialog.
  BuildContext? _dialogContext;

  set msg(String message) {
    _msg = message;
    if (state != null) {
      state(() {});
    }
  }

  /// Displays a loading dialog in the given [context].
  ///
  /// - `message` is an optional parameter to customize the loading message.
  /// - `isDismissible` determines if the dialog can be dismissed.
  /// - `theme` is the theme data for styling the dialog.
  /// - `imageEditorTheme` is the theme specific to the image editor.
  /// - `designMode` specifies the design mode for the image editor.
  /// - `i18n` provides internationalization support.
  ///
  /// Returns a [Future] that completes when the dialog is dismissed.
  show(
    BuildContext context, {
    String? message,
    bool isDismissible = kDebugMode,
    ThemeData? theme,
    required ProImageEditorConfigs configs,
  }) async {
    if (_isDisposed) throw ErrorHint('Loading-Dialog is already disposed!');

    theme ??= configs.theme ?? Theme.of(context);

    if (message == null) {
      msg = configs.i18n.various.loadingDialogMsg;
    } else {
      msg = message;
    }
    _isVisible = true;

    _completer = Completer();

    final content = PopScope(
      canPop: isDismissible,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 500),
        child: StatefulBuilder(builder: (context, StateSetter setState) {
          state = setState;

          return Padding(
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
                      child:
                          PlatformCircularProgressIndicator(configs: configs),
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    _msg,
                    style: platformTextStyle(
                      context,
                      configs.designMode,
                    ).copyWith(
                      fontSize: 16,
                      color:
                          configs.imageEditorTheme.loadingDialogTheme.textColor,
                    ),
                    textAlign: TextAlign.start,
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );

    showAdaptiveDialog(
      context: context,
      barrierDismissible: isDismissible,
      builder: (context) {
        _dialogContext = context;

        if (_completer != null && !_completer!.isCompleted) {
          _completer?.complete();
        }

        if (_isDisposed && context.mounted) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (context.mounted) Navigator.of(context).pop();
          });
        }
        if (configs.customWidgets.loadingDialog != null) {
          return configs.customWidgets.loadingDialog!;
        }
        return configs.designMode == ImageEditorDesignModeE.cupertino
            ? CupertinoTheme(
                data: CupertinoTheme.of(context).copyWith(
                  brightness: theme!.brightness,
                  primaryColor: theme.brightness == Brightness.dark
                      ? configs.imageEditorTheme.loadingDialogTheme
                          .cupertinoPrimaryColorDark
                      : configs.imageEditorTheme.loadingDialogTheme
                          .cupertinoPrimaryColorLight,
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
              )
            : Theme(
                data: theme!,
                child: AlertDialog(
                  contentPadding:
                      const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                  content: content,
                ),
              );
      },
    );

    if (configs.imageGenerationConfigs.awaitLoadingDialogContext) {
      await _completer!.future;
    }
  }

  /// Hides the loading dialog.
  hide(BuildContext context) {
    if (_completer != null && !_completer!.isCompleted) _completer?.complete();

    if (_isVisible) Navigator.pop(_dialogContext ?? context);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _isDisposed = true;
    });
  }
}
