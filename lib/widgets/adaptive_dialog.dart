import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pro_image_editor/utils/design_mode.dart';

import '../models/theme/theme.dart';

/// A dialog that adapts its appearance based on the design mode.
class AdaptiveDialog extends StatefulWidget {
  /// The design mode to determine the appearance of the dialog.
  final ImageEditorDesignModeE designMode;

  /// The title widget of the dialog.
  final Widget title;

  /// The content widget of the dialog.
  final Widget content;

  /// The list of actions to be displayed in the dialog.
  final List<AdaptiveDialogAction> actions;

  /// The brightness of the dialog.
  final Brightness brightness;

  final ImageEditorTheme imageEditorTheme;

  /// Creates an [AdaptiveDialog].
  ///
  /// The [designMode] determines the appearance of the dialog.
  /// The [title] and [content] are required widgets to display in the dialog.
  /// The [actions] is a list of [AdaptiveDialogAction] widgets to include as buttons.
  /// The [brightness] controls the brightness of the dialog.
  /// The [imageEditorTheme] is the theme specific to the image editor.
  const AdaptiveDialog({
    super.key,
    required this.designMode,
    required this.title,
    required this.content,
    required this.actions,
    required this.brightness,
    required this.imageEditorTheme,
  });

  @override
  State<AdaptiveDialog> createState() => _AdaptiveDialogState();
}

/// The state for the [AdaptiveDialog].
class _AdaptiveDialogState extends State<AdaptiveDialog> {
  @override
  Widget build(BuildContext context) {
    if (widget.designMode == ImageEditorDesignModeE.cupertino) {
      // Return a Cupertino-style dialog when in Cupertino design mode.
      return CupertinoTheme(
        data: CupertinoTheme.of(context).copyWith(
          brightness: widget.brightness,
          primaryColor: widget.brightness == Brightness.dark
              ? widget.imageEditorTheme.adaptiveDialogTheme
                  .cupertinoPrimaryColorDark
              : widget.imageEditorTheme.adaptiveDialogTheme
                  .cupertinoPrimaryColorLight,
          textTheme: CupertinoTextThemeData(
            textStyle: TextStyle(
              color: widget.brightness == Brightness.dark
                  ? widget.imageEditorTheme.adaptiveDialogTheme
                      .cupertinoPrimaryColorDark
                  : widget.imageEditorTheme.adaptiveDialogTheme
                      .cupertinoPrimaryColorLight,
            ),
          ),
        ),
        child: CupertinoAlertDialog(
          title: widget.title,
          content: widget.content,
          actions: widget.actions,
        ),
      );
    } else {
      // Return a Material-style dialog for other design modes.
      return AlertDialog(
        title: widget.title,
        content: widget.content,
        actions: widget.actions,
      );
    }
  }
}

/// An action button that adapts its appearance based on the design mode.
class AdaptiveDialogAction extends StatefulWidget {
  /// The design mode to determine the appearance of the action button.
  final ImageEditorDesignModeE designMode;

  /// The callback function to be executed when the button is pressed.
  final Function() onPressed;

  /// The widget to display as the action button.
  final Widget child;

  /// Creates an [AdaptiveDialogAction].
  ///
  /// The [designMode] determines the appearance of the action button.
  /// The [onPressed] callback is executed when the button is pressed.
  /// The [child] widget is displayed as the action button.
  const AdaptiveDialogAction({
    super.key,
    required this.onPressed,
    required this.child,
    required this.designMode,
  });

  @override
  State<AdaptiveDialogAction> createState() => _AdaptiveDialogActionState();
}

/// The state for the [AdaptiveDialogAction].
class _AdaptiveDialogActionState extends State<AdaptiveDialogAction> {
  @override
  Widget build(BuildContext context) {
    if (widget.designMode == ImageEditorDesignModeE.cupertino) {
      // Return a Cupertino-style action when in Cupertino design mode.
      return CupertinoDialogAction(
          onPressed: widget.onPressed, child: widget.child);
    } else {
      // Return a Material-style action for other design modes.
      return TextButton(onPressed: widget.onPressed, child: widget.child);
    }
  }
}
