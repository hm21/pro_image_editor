import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pro_image_editor/models/editor_configs/pro_image_editor_configs.dart';
import 'package:pro_image_editor/utils/design_mode.dart';
import 'package:pro_image_editor/widgets/pro_image_editor_desktop_mode.dart';

/// Represents the "Done" button for the WhatsApp theme.
class WhatsAppDoneBtn extends StatefulWidget {
  /// The configuration for the image editor.
  final ProImageEditorConfigs configs;

  /// The foreground color of the button.
  final Color foregroundColor;

  /// Callback function for when the button is pressed.
  final Function() onPressed;

  /// Constructs a WhatsAppDoneBtn widget with the specified parameters.
  const WhatsAppDoneBtn({
    super.key,
    required this.configs,
    required this.foregroundColor,
    required this.onPressed,
  });

  @override
  State<WhatsAppDoneBtn> createState() => _WhatsAppDoneBtnState();
}

class _WhatsAppDoneBtnState extends State<WhatsAppDoneBtn> {
  @override
  Widget build(BuildContext context) {
    if (widget.configs.designMode == ImageEditorDesignModeE.material) {
      return _buildMaterialBtn();
    } else {
      return _buildCupertinoBtn();
    }
  }

  Widget _buildMaterialBtn() {
    return OutlinedButton(
      onPressed: widget.onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: widget.foregroundColor,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        minimumSize: Size(0, isDesktop ? 40 : 33),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        side: BorderSide(
          width: 1,
          color: widget.foregroundColor,
        ),
      ),
      child: Text(widget.configs.i18n.done),
    );
  }

  Widget _buildCupertinoBtn() {
    return CupertinoButton(
      onPressed: widget.onPressed,
      padding: const EdgeInsets.symmetric(horizontal: 7),
      minSize: 0,
      child: Text(
        widget.configs.i18n.done,
        style: TextStyle(
          color: widget.foregroundColor,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
