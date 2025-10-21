import 'package:flutter/material.dart';

import '/core/models/editor_configs/pro_image_editor_configs.dart';
import '/shared/widgets/gesture/gesture_interceptor_widget.dart';
import '../../styles/whatsapp_appbar_button_style.dart';

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
        return widget.openEditor
            ? const SizedBox.shrink()
            : Row(
                children: _buildToolList(constraints.maxWidth),
              );
      }),
    );
  }

  List<Widget> _buildToolList(double screenWidth) {
    final double space = screenWidth < 300 ? 5 : 10;
    final gap = SizedBox(width: space);

    final tools = widget.configs.mainEditor.tools;

    final items = <Widget>[
      // Close button (always visible)
      GestureInterceptor(
        child: IconButton(
          tooltip: widget.configs.i18n.cancel,
          onPressed: widget.onClose,
          icon: Icon(widget.configs.mainEditor.icons.closeEditor),
          style: whatsAppButtonStyle,
        ),
      ),
      const Spacer(),
      gap,

      // Undo button
      AnimatedSwitcher(
        duration: const Duration(milliseconds: 150),
        transitionBuilder: (child, animation) => ScaleTransition(
          scale: animation,
          child: FadeTransition(opacity: animation, child: child),
        ),
        child: widget.canUndo
            ? GestureInterceptor(
                child: IconButton(
                  tooltip: widget.configs.i18n.undo,
                  onPressed: widget.onTapUndo,
                  icon: Icon(widget.configs.mainEditor.icons.undoAction),
                  style: whatsAppButtonStyle,
                ),
              )
            : const SizedBox.shrink(),
      ),
    ];

    // Dynamic tools
    for (final tool in tools) {
      switch (tool) {
        case SubEditorMode.cropRotate:
          items.addAll([
            gap,
            GestureInterceptor(
              child: IconButton(
                tooltip: widget
                    .configs.i18n.cropRotateEditor.bottomNavigationBarText,
                onPressed: widget.onTapCropRotateEditor,
                icon: Icon(widget.configs.cropRotateEditor.icons.bottomNavBar),
                style: whatsAppButtonStyle,
              ),
            ),
          ]);
          break;

        case SubEditorMode.emoji:
          items.addAll([
            gap,
            GestureInterceptor(
              child: IconButton(
                key: const ValueKey('whatsapp-open-sticker-editor-btn'),
                tooltip:
                    widget.configs.i18n.stickerEditor.bottomNavigationBarText,
                onPressed: widget.onTapStickerEditor,
                icon: Icon(widget.configs.stickerEditor.icons.bottomNavBar),
                style: whatsAppButtonStyle,
              ),
            ),
          ]);
          break;

        case SubEditorMode.text:
          items.addAll([
            gap,
            GestureInterceptor(
              child: IconButton(
                tooltip: widget.configs.i18n.textEditor.bottomNavigationBarText,
                onPressed: widget.onTapTextEditor,
                icon: Icon(widget.configs.textEditor.icons.bottomNavBar),
                style: whatsAppButtonStyle,
              ),
            ),
          ]);
          break;

        case SubEditorMode.paint:
          items.addAll([
            gap,
            GestureInterceptor(
              child: IconButton(
                tooltip:
                    widget.configs.i18n.paintEditor.bottomNavigationBarText,
                onPressed: widget.onTapPaintEditor,
                icon: Icon(widget.configs.paintEditor.icons.bottomNavBar),
                style: whatsAppButtonStyle,
              ),
            ),
          ]);
          break;

        // ignore tools that aren't relevant for this WhatsApp-like toolbar
        default:
          continue;
      }
    }

    return items;
  }
}
