// Flutter imports:
import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:material_ui/material_ui.dart';

import '/pro_image_editor.dart';
import '../frosted_glass.dart';

/// Represents the toolbar for the crop/rotate functionality in the frosted-glass theme.
class FrostedGlassCropRotateToolbar extends StatefulWidget {
  /// Creates a [FrostedGlassCropRotateToolbar].
  ///
  /// This toolbar is designed for image editing applications, providing
  /// interactive buttons for cropping and rotating functionalities. It is part
  /// of the frosted-glass themed user interface.
  /// ```
  const FrostedGlassCropRotateToolbar({
    super.key,
    required this.configs,
    required this.onCancel,
    required this.onRotate,
    required this.onDone,
    required this.onReset,
    required this.openAspectRatios,
  });

  /// The configuration for the image editor.
  final ProImageEditorConfigs configs;

  /// Callback function for canceling the crop/rotate operation.
  final Function() onCancel;

  /// Callback function for rotating the image.
  final Function() onRotate;

  /// Callback function for completing the crop/rotate operation.
  final Function() onDone;

  /// Callback function for resetting the crop/rotate operation.
  final Function() onReset;

  /// Callback function for opening aspect ratios.
  final Function() openAspectRatios;

  @override
  State<FrostedGlassCropRotateToolbar> createState() =>
      _FrostedGlassCropRotateToolbar();
}

class _FrostedGlassCropRotateToolbar
    extends State<FrostedGlassCropRotateToolbar> {
  @override
  Widget build(BuildContext context) {
    const padding = EdgeInsets.symmetric(vertical: 8, horizontal: 16);
    final style = TextStyle(
      color: widget.configs.cropRotateEditor.style.appBarColor,
      fontSize: 16,
    );
    final tools = widget.configs.cropRotateEditor.tools;

    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [
        FrostedGlassEffect(
          radius: BorderRadius.zero,
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (tools.contains(CropRotateTool.rotate))
                IconButton(
                  onPressed: widget.onRotate,
                  tooltip: widget.configs.i18n.cropRotateEditor.rotate,
                  icon: Icon(widget.configs.cropRotateEditor.icons.rotate),
                  color: widget.configs.cropRotateEditor.style.appBarColor,
                )
              else
                const SizedBox.shrink(),
              if (tools.contains(CropRotateTool.reset))
                CupertinoButton(
                  onPressed: widget.onReset,
                  padding: padding,
                  child: Text(
                    widget.configs.i18n.cropRotateEditor.reset,
                    style: style,
                  ),
                ),
              if (tools.contains(CropRotateTool.aspectRatio))
                IconButton(
                  onPressed: widget.openAspectRatios,
                  tooltip: widget.configs.i18n.cropRotateEditor.ratio,
                  icon: Icon(widget.configs.cropRotateEditor.icons.aspectRatio),
                  color: widget.configs.cropRotateEditor.style.appBarColor,
                )
              else
                const SizedBox.shrink(),
            ],
          ),
        ),
        Container(
          color: Colors.black26,
          child: FrostedGlassEffect(
            radius: BorderRadius.zero,
            child: SafeArea(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CupertinoButton(
                    onPressed: widget.onCancel,
                    padding: padding,
                    child: Text(
                      widget.configs.i18n.cropRotateEditor.cancel,
                      style: style,
                    ),
                  ),
                  CupertinoButton(
                    onPressed: widget.onDone,
                    padding: padding,
                    child: Text(
                      widget.configs.i18n.cropRotateEditor.done,
                      style: style.copyWith(fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
