// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:pro_image_editor/pro_image_editor.dart';
import 'utils/whatsapp_appbar_button_style.dart';
import 'whatsapp_done_btn.dart';

/// Represents the app bar for the paint functionality in the WhatsApp theme.
class WhatsAppPaintAppBar extends StatefulWidget {
  /// Creates a [WhatsAppPaintAppBar] widget.
  const WhatsAppPaintAppBar({
    super.key,
    required this.canUndo,
    required this.activeColor,
    required this.configs,
    required this.onClose,
    required this.onDone,
    required this.onTapUndo,
  });

  /// Indicates whether the undo action is available.
  final bool canUndo;

  /// The active color for the paint.
  final Color activeColor;

  /// The configuration for the image editor.
  final ProImageEditorConfigs configs;

  /// Callback function for closing the editor.
  final Function() onClose;

  /// Callback function for completing the paint operation.
  final Function() onDone;

  /// Callback function for undoing a paint action.
  final Function() onTapUndo;

  @override
  State<WhatsAppPaintAppBar> createState() => _WhatsAppPaintAppBarState();
}

class _WhatsAppPaintAppBarState extends State<WhatsAppPaintAppBar> {
  final double _space = 10;

  @override
  Widget build(BuildContext context) {
    var gap = SizedBox(width: _space);

    return Positioned(
      top: _space,
      left: _space,
      right: _space,
      child: SafeArea(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (widget.configs.designMode == ImageEditorDesignModeE.cupertino)
              _buildDoneBtn(),
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
                  : Opacity(
                      opacity: 0,
                      child: IconButton(
                        onPressed: null,
                        icon: Icon(widget.configs.icons.undoAction),
                        style: whatsAppButtonStyle,
                      ),
                    ),
            ),
            gap,
            if (widget.configs.designMode == ImageEditorDesignModeE.material)
              _buildDoneBtn()
            else
              IconButton(
                tooltip:
                    widget.configs.i18n.paintEditor.bottomNavigationBarText,
                onPressed: () {},
                icon: Icon(widget.configs.icons.paintingEditor.bottomNavBar),
                style: whatsAppButtonStyle.copyWith(
                  backgroundColor: WidgetStateProperty.all(widget.activeColor),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDoneBtn() {
    return WhatsAppDoneBtn(
      foregroundColor:
          widget.configs.imageEditorTheme.paintingEditor.appBarForegroundColor,
      configs: widget.configs,
      onPressed: widget.onDone,
    );
  }
}
