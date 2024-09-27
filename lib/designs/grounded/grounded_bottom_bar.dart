import 'package:flutter/material.dart';
import 'package:pro_image_editor/models/editor_configs/pro_image_editor_configs.dart';

/// A widget that represents the bottom action bar in the image editor.
///
/// The [GroundedBottomBar] provides the essential actions for closing,
/// completing, undoing, and redoing edits in the image editor. It is designed
/// to work within the context of the ProImageEditor, offering customizable
/// icons and themes based on [ProImageEditorConfigs].
class GroundedBottomBar extends StatefulWidget {
  /// Constructor for the [GroundedBottomBar].
  ///
  /// Requires the [configs], [done], and [close] parameters, with optional
  /// parameters for undo and redo functionality.
  const GroundedBottomBar({
    super.key,
    required this.configs,
    this.undo,
    this.redo,
    required this.done,
    required this.close,
    this.enableUndo = false,
    this.enableRedo = false,
  });

  /// Configuration settings for the image editor.
  final ProImageEditorConfigs configs;

  /// Function to handle undo action.
  final Function()? undo;

  /// Function to handle redo action.
  final Function()? redo;

  /// Function to handle completion of editing.
  final Function() done;

  /// Function to handle closing the editor.
  final Function() close;

  /// Boolean flag to enable or disable the undo action.
  final bool enableUndo;

  /// Boolean flag to enable or disable the redo action.
  final bool enableRedo;

  @override
  State<GroundedBottomBar> createState() => _GroundedBottomBarState();
}

/// State class for [GroundedBottomBar].
///
/// This state manages the UI for the bottom action bar, including the display
/// of undo, redo, close, and done buttons. It ensures that the appropriate
/// buttons are enabled or disabled based on the editor's state.
class _GroundedBottomBarState extends State<GroundedBottomBar> {
  @override
  Widget build(BuildContext context) {
    Color foreGroundColor =
        widget.configs.imageEditorTheme.appBarForegroundColor;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 12),
      color: const Color(0xFF222222),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            tooltip: widget.configs.i18n.cancel,
            onPressed: widget.close,
            icon: Icon(
              widget.configs.icons.closeEditor,
              color: foreGroundColor,
            ),
          ),
          if (widget.redo != null)
            Row(
              children: [
                IconButton(
                  tooltip: widget.configs.i18n.undo,
                  onPressed: widget.undo,
                  icon: Icon(
                    widget.configs.icons.undoAction,
                    color: widget.enableUndo
                        ? foreGroundColor
                        : foreGroundColor.withAlpha(80),
                  ),
                ),
                const SizedBox(width: 3),
                IconButton(
                  tooltip: widget.configs.i18n.redo,
                  onPressed: widget.redo,
                  icon: Icon(
                    widget.configs.icons.redoAction,
                    color: widget.enableRedo
                        ? foreGroundColor
                        : foreGroundColor.withAlpha(80),
                  ),
                ),
              ],
            ),
          IconButton(
            tooltip: widget.configs.i18n.done,
            onPressed: widget.done,
            icon: Icon(
              widget.configs.icons.doneIcon,
              color: foreGroundColor,
            ),
          ),
        ],
      ),
    );
  }
}
