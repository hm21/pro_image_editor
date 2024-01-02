import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pro_image_editor/utils/design_mode.dart';

class AdaptiveDialog extends StatefulWidget {
  final ImageEditorDesignModeE designMode;
  final Widget title;
  final Widget content;
  final List<AdaptiveDialogAction> actions;

  const AdaptiveDialog({
    super.key,
    required this.designMode,
    required this.title,
    required this.content,
    required this.actions,
  });

  @override
  State<AdaptiveDialog> createState() => _AdaptiveDialogState();
}

class _AdaptiveDialogState extends State<AdaptiveDialog> {
  @override
  Widget build(BuildContext context) {
    if (widget.designMode == ImageEditorDesignModeE.cupertino) {
      return CupertinoAlertDialog(
        title: widget.title,
        content: widget.content,
        actions: widget.actions,
      );
    } else {
      return AlertDialog(
        title: widget.title,
        content: widget.content,
        actions: widget.actions,
      );
    }
  }
}

class AdaptiveDialogAction extends StatefulWidget {
  final ImageEditorDesignModeE designMode;
  final Function() onPressed;
  final Widget child;

  const AdaptiveDialogAction({
    super.key,
    required this.onPressed,
    required this.child,
    required this.designMode,
  });

  @override
  State<AdaptiveDialogAction> createState() => _AdaptiveDialogActionState();
}

class _AdaptiveDialogActionState extends State<AdaptiveDialogAction> {
  @override
  Widget build(BuildContext context) {
    if (widget.designMode == ImageEditorDesignModeE.cupertino) {
      return CupertinoDialogAction(onPressed: widget.onPressed, child: widget.child);
    } else {
      return TextButton(onPressed: widget.onPressed, child: widget.child);
    }
  }
}
