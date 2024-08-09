// Flutter imports:
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

// Project imports:
import 'package:pro_image_editor/models/editor_configs/pro_image_editor_configs.dart';

/// Represents the "Done" button for the WhatsApp theme.
class WhatsAppDoneBtn extends StatefulWidget {
  /// Constructs a WhatsAppDoneBtn widget with the specified parameters.
  const WhatsAppDoneBtn({
    super.key,
    required this.configs,
    required this.foregroundColor,
    required this.onPressed,
  });

  /// The configuration for the image editor.
  final ProImageEditorConfigs configs;

  /// The foreground color of the button.
  final Color foregroundColor;

  /// Callback function for when the button is pressed.
  final Function() onPressed;

  @override
  State<WhatsAppDoneBtn> createState() => _WhatsAppDoneBtnState();
}

class _WhatsAppDoneBtnState extends State<WhatsAppDoneBtn> {
  bool get isMaterial =>
      widget.configs.designMode == ImageEditorDesignModeE.material;

  @override
  Widget build(BuildContext context) {
    if (isMaterial) {
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
        side: isMaterial
            ? const BorderSide(width: 0, color: Colors.transparent)
            : BorderSide(
                width: 1,
                color: widget.foregroundColor,
              ),
        backgroundColor: isMaterial ? Colors.black38 : null,
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
