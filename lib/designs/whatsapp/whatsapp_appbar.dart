// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:pro_image_editor/models/editor_configs/pro_image_editor_configs.dart';
import 'utils/whatsapp_appbar_button_style.dart';

/// Represents the app bar for the WhatsApp theme.
class WhatsAppAppBar extends StatefulWidget {
  /// Constructs a WhatsAppAppBar widget with the specified parameters.
  const WhatsAppAppBar({
    super.key,
    required this.canUndo,
    required this.openEditor,
    required this.configs,
    required this.onClose,
    required this.onTapUndo,
    required this.onTapCropRotateEditor,
    required this.onTapStickerEditor,
    required this.onTapTextEditor,
    required this.onTapPaintEditor,
  });

  /// The configuration for the image editor.
  final ProImageEditorConfigs configs;

  /// Indicates whether the undo action is available.
  final bool canUndo;

  /// Indicates whether the editor is open.
  final bool openEditor;

  /// Callback function for closing the editor.
  final Function() onClose;

  /// Callback function for undoing an action.
  final Function() onTapUndo;

  /// Callback function for tapping the crop/rotate editor button.
  final Function() onTapCropRotateEditor;

  /// Callback function for tapping the sticker editor button.
  final Function() onTapStickerEditor;

  /// Callback function for tapping the text editor button.
  final Function() onTapTextEditor;

  /// Callback function for tapping the paint editor button.
  final Function() onTapPaintEditor;

  @override
  State<WhatsAppAppBar> createState() => _WhatsAppAppBarState();
}

class _WhatsAppAppBarState extends State<WhatsAppAppBar> {
  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 10,
      left: 10,
      right: 10,
      child: LayoutBuilder(builder: (context, constraints) {
        double screenW = constraints.maxWidth;
        final double space = screenW < 300 ? 5 : 10;
        var gap = SizedBox(width: space);
        return widget.openEditor
            ? const SizedBox.shrink()
            : Row(
                children: [
                  IconButton(
                    tooltip: widget.configs.i18n.cancel,
                    onPressed: widget.onClose,
                    icon: Icon(widget.configs.icons.closeEditor),
                    style: whatsAppButtonStyle,
                  ),
                  const Spacer(),
                  gap,
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 150),
                    transitionBuilder: (child, animation) => ScaleTransition(
                      scale: animation,
                      child: FadeTransition(
                        opacity: animation,
                        child: child,
                      ),
                    ),
                    child: widget.canUndo
                        ? IconButton(
                            tooltip: widget.configs.i18n.undo,
                            onPressed: widget.onTapUndo,
                            icon: Icon(widget.configs.icons.undoAction),
                            style: whatsAppButtonStyle,
                          )
                        : const SizedBox.shrink(),
                  ),
                  if (widget.configs.cropRotateEditorConfigs.enabled) ...[
                    gap,
                    IconButton(
                      tooltip: widget.configs.i18n.cropRotateEditor
                          .bottomNavigationBarText,
                      onPressed: widget.onTapCropRotateEditor,
                      icon: Icon(
                          widget.configs.icons.cropRotateEditor.bottomNavBar),
                      style: whatsAppButtonStyle,
                    ),
                  ],
                  if (widget.configs.stickerEditorConfigs?.enabled == true ||
                      widget.configs.emojiEditorConfigs.enabled) ...[
                    gap,
                    IconButton(
                      key: const ValueKey('whatsapp-open-sticker-editor-btn'),
                      tooltip: widget
                          .configs.i18n.stickerEditor.bottomNavigationBarText,
                      onPressed: widget.onTapStickerEditor,
                      icon:
                          Icon(widget.configs.icons.stickerEditor.bottomNavBar),
                      style: whatsAppButtonStyle,
                    ),
                  ],
                  if (widget.configs.textEditorConfigs.enabled) ...[
                    gap,
                    IconButton(
                      tooltip: widget
                          .configs.i18n.textEditor.bottomNavigationBarText,
                      onPressed: widget.onTapTextEditor,
                      icon: Icon(widget.configs.icons.textEditor.bottomNavBar),
                      style: whatsAppButtonStyle,
                    ),
                  ],
                  if (widget.configs.paintEditorConfigs.enabled) ...[
                    gap,
                    IconButton(
                      tooltip: widget
                          .configs.i18n.paintEditor.bottomNavigationBarText,
                      onPressed: widget.onTapPaintEditor,
                      icon: Icon(
                          widget.configs.icons.paintingEditor.bottomNavBar),
                      style: whatsAppButtonStyle,
                    ),
                  ],
                ],
              );
      }),
    );
  }
}
