import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../utils/design_mode.dart';

/// A platform-aware popup button that displays a context menu based on the platform design mode.
///
/// The `PlatformPopupBtn` widget provides a button that opens a context menu with options
/// when clicked. It adapts its appearance and behavior to the current platform's design mode,
/// supporting both Cupertino and Material styles.
///
/// Parameters:
/// - [options]: A list of `PopupMenuOption` objects representing the menu items to display.
/// - [designMode]: The design mode to use for rendering the button and menu, either
///   `ImageEditorDesignModeE.cupertino` or `ImageEditorDesignModeE.material`.
/// - [title]: The tooltip text displayed when hovering over the button.
/// - [message]: An optional message to display at the top of the menu (Cupertino style only).
class PlatformPopupBtn extends StatefulWidget {
  final List<PopupMenuOption> options;
  final ImageEditorDesignModeE designMode;
  final String title;
  final String? message;

  const PlatformPopupBtn({
    super.key,
    required this.options,
    required this.designMode,
    required this.title,
    this.message,
  });

  @override
  State<PlatformPopupBtn> createState() => _PlatformPopupBtnState();
}

/// The state class for the `PlatformPopupBtn` widget.
class _PlatformPopupBtnState extends State<PlatformPopupBtn> {
  @override
  Widget build(BuildContext context) {
    if (widget.designMode == ImageEditorDesignModeE.cupertino) {
      return IconButton(
        tooltip: widget.title,
        onPressed: () {
          showCupertinoModalPopup(
            context: context,
            builder: (context) => _cupertinoSheetContent(context),
          );
        },
        icon: const Icon(Icons.more_horiz),
      );
    } else {
      return _buildMaterialPopupBtn();
    }
  }

  Widget _buildMaterialPopupBtn() {
    return PopupMenuButton<PopupMenuOption>(
      tooltip: widget.title,
      onSelected: (option) {},
      itemBuilder: (context) => widget.options.map(
        (option) {
          return PopupMenuItem(
            value: option,
            height: kMinInteractiveDimension,
            onTap: option.onTap,
            child: option.child ??
                Row(
                  children: [
                    option.icon,
                    const SizedBox(width: 12),
                    Text(option.label ?? ""),
                  ],
                ),
          );
        },
      ).toList(),
      icon: const Icon(Icons.more_vert),
    );
  }

  Widget _cupertinoSheetContent(BuildContext context) {
    return CupertinoActionSheet(
      title: Text(widget.title),
      message: widget.message != null ? Text(widget.message!) : null,
      actions: widget.options.map(
        (option) {
          return CupertinoActionSheetAction(
            isDefaultAction: false,
            isDestructiveAction: false,
            onPressed: option.onTap,
            child: option.child ?? Text(option.label!),
          );
        },
      ).toList(),
      cancelButton: CupertinoActionSheetAction(
        isDefaultAction: false,
        isDestructiveAction: true,
        onPressed: () => Navigator.pop(context),
        child: const Text('Cancel'),
      ),
    );
  }
}

/// Represents an option in a popup menu.
class PopupMenuOption {
  Widget? child;
  String? label;
  Widget icon;
  Function() onTap;

  PopupMenuOption({
    required this.onTap,
    required this.icon,
    this.child,
    this.label,
  }) : assert(child != null || label != null, 'child or label is required');
}
