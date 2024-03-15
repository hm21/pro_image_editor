import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../models/theme/theme.dart';
import '../models/i18n/i18n.dart';
import '../utils/design_mode.dart';
import '../utils/theme_functions.dart';
import 'platform_circular_progress_indicator.dart';

class LoadingDialog {
  String _msg = '';
  dynamic state;

  bool _isVisible = false;
  bool _isDisposed = false;

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
    required ThemeData theme,
    required ImageEditorTheme imageEditorTheme,
    required ImageEditorDesignModeE designMode,
    required I18n i18n,
  }) async {
    if (message == null) {
      msg = i18n.various.loadingDialogMsg;
    } else {
      msg = message;
    }
    _isVisible = true;

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
                      child: PlatformCircularProgressIndicator(
                        designMode: designMode,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    _msg,
                    style: platformTextStyle(
                      context,
                      designMode,
                    ).copyWith(
                      fontSize: 16,
                      color: imageEditorTheme.loadingDialogTextColor,
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

    return showAdaptiveDialog(
      context: context,
      barrierDismissible: isDismissible,
      builder: (context) {
        if (_isDisposed) Navigator.of(context).pop();
        return designMode == ImageEditorDesignModeE.cupertino
            ? CupertinoTheme(
                data: CupertinoTheme.of(context).copyWith(
                  brightness: theme.brightness,
                  primaryColor: theme.brightness == Brightness.dark
                      ? Colors.white
                      : Colors.black,
                  textTheme: CupertinoTextThemeData(
                    textStyle: TextStyle(
                      color: theme.brightness == Brightness.dark
                          ? Colors.white
                          : Colors.black,
                    ),
                  ),
                ),
                child: CupertinoAlertDialog(
                  content: content,
                ),
              )
            : Theme(
                data: theme,
                child: AlertDialog(
                  contentPadding:
                      const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                  content: content,
                ),
              );
      },
    );
  }

  /// Hides the loading dialog.
  hide(BuildContext context) {
    if (_isVisible) {
      Navigator.pop(context);
    }
    _isDisposed = true;
  }
}
