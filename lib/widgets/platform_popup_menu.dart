// Flutter imports:
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

// Project imports:
import '../utils/design_mode.dart';

/// A platform-aware popup button that displays a context menu based on the
/// platform design mode.
///
/// The `PlatformPopupBtn` widget provides a button that opens a context menu
/// with options when clicked. It adapts its appearance and behavior to the
/// current platform's design mode, supporting both Cupertino and Material
/// styles.
///
/// Parameters:
/// - [options]: A list of `PopupMenuOption` objects representing the menu
/// items to display.
/// - [designMode]: The design mode to use for rendering the button and menu,
/// either `ImageEditorDesignModeE.cupertino` or
/// `ImageEditorDesignModeE.material`.
/// - [title]: The tooltip text displayed when hovering over the button.
/// - [message]: An optional message to display at the top of the menu
/// (Cupertino style only).
class PlatformPopupBtn extends StatefulWidget {
  /// Creates a [PlatformPopupBtn].
  ///
  /// The [options], [designMode], and [title] parameters are required.
  /// The [message] parameter is optional and can be used to provide additional
  /// information or context for the popup button.
  ///
  /// Example:
  /// ```
  /// PlatformPopupBtn(
  ///   options: myOptionsList,
  ///   designMode: ImageEditorDesignModeE.android,
  ///   title: 'Options',
  ///   message: 'Choose an option',
  /// )
  /// ```
  const PlatformPopupBtn({
    super.key,
    required this.options,
    required this.designMode,
    required this.title,
    this.message,
  });

  /// A list of [PopupMenuOption]s to be displayed when the popup button is
  /// activated.
  ///
  /// Each option represents a selectable item in the menu, with associated
  /// actions defined in their respective `onTap` callbacks.
  final List<PopupMenuOption> options;

  /// The design mode that specifies the appearance and behavior of the popup
  /// menu.
  ///
  /// This can be used to tailor the menu's style to different platforms,
  /// such as Android or iOS, by using the [ImageEditorDesignModeE] enumeration.
  final ImageEditorDesignModeE designMode;

  /// The title of the popup button.
  ///
  /// This string is displayed on the button itself, indicating the purpose of
  /// the menu or providing context for the available options.
  final String title;

  /// An optional message to be displayed alongside the popup button.
  ///
  /// This message can provide additional information or context to the user,
  /// enhancing the understanding of the button's purpose or function.
  final String? message;

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
            builder: _cupertinoSheetContent,
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
                    Text(option.label ?? ''),
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

/// A class that represents an option in a popup menu.
///
/// Each option can display an icon and either a widget or text label.
/// When the option is tapped, a specified action is executed.

class PopupMenuOption {
  /// Creates a [PopupMenuOption].
  ///
  /// The [onTap] and [icon] parameters are required. At least one of
  /// [child] or [label]
  /// must be provided to represent the content of the menu option.
  ///
  /// Example:
  /// ```
  /// PopupMenuOption(
  ///   icon: Icon(Icons.edit),
  ///   label: 'Edit',
  ///   onTap: () {
  ///     // Handle edit action
  ///   },
  /// )
  /// ```
  PopupMenuOption({
    required this.onTap,
    required this.icon,
    this.child,
    this.label,
  }) : assert(child != null || label != null, 'child or label is required');

  /// The widget to be displayed as the content of the menu option.
  ///
  /// This can be used to provide a custom widget for the option's appearance.
  /// If [child] is provided, [label] should be null.
  Widget? child;

  /// The text label to be displayed for the menu option.
  ///
  /// This provides a simple text representation for the option.
  /// If [label] is provided, [child] should be null.
  String? label;

  /// The icon to be displayed alongside the menu option.
  ///
  /// This is typically used to visually represent the action associated with
  /// the menu option.
  Widget icon;

  /// The callback function to be executed when the menu option is tapped.
  ///
  /// This function defines the action that occurs when the user selects this
  /// option from the menu.
  Function() onTap;
}
