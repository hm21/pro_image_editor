// Flutter imports:
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

// Project imports:
import 'package:pro_image_editor/designs/frosted_glass/frosted_glass.dart';
import '../../pro_image_editor.dart';

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
    var padding = const EdgeInsets.symmetric(vertical: 8, horizontal: 16);
    var style = TextStyle(
      color: widget
          .configs.imageEditorTheme.cropRotateEditor.appBarForegroundColor,
      fontSize: 16,
    );

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
              if (widget.configs.cropRotateEditorConfigs.canRotate)
                IconButton(
                  onPressed: widget.onRotate,
                  tooltip: widget.configs.i18n.cropRotateEditor.rotate,
                  icon: Icon(widget.configs.icons.cropRotateEditor.rotate),
                  color: widget.configs.imageEditorTheme.cropRotateEditor
                      .appBarForegroundColor,
                )
              else
                const SizedBox.shrink(),
              if (widget.configs.cropRotateEditorConfigs.canReset)
                CupertinoButton(
                  onPressed: widget.onReset,
                  padding: padding,
                  child: Text(
                    widget.configs.i18n.cropRotateEditor.reset,
                    style: style,
                  ),
                ),
              if (widget.configs.cropRotateEditorConfigs.canChangeAspectRatio)
                IconButton(
                  onPressed: widget.openAspectRatios,
                  tooltip: widget.configs.i18n.cropRotateEditor.ratio,
                  icon: Icon(widget.configs.icons.cropRotateEditor.aspectRatio),
                  color: widget.configs.imageEditorTheme.cropRotateEditor
                      .appBarForegroundColor,
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
