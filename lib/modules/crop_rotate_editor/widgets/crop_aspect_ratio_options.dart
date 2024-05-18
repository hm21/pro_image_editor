// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:pro_image_editor/models/editor_configs/pro_image_editor_configs.dart';
import 'package:pro_image_editor/modules/crop_rotate_editor/widgets/crop_aspect_ratio_button.dart';

/// Provides a widget for selecting crop aspect ratio options within an image editor.
///
/// This widget displays a list of available aspect ratios for cropping an image,
/// allowing the user to select from the list. Each aspect ratio option is represented
/// as a [ListTile] containing an [AspectRatioButton] and the corresponding aspect ratio text.
///
/// The selected aspect ratio is returned to the calling widget via [Navigator.pop]
/// when an aspect ratio option is tapped.
class CropAspectRatioOptions extends StatefulWidget {
  /// The configuration settings for the image editor.
  final ProImageEditorConfigs configs;

  /// The original aspect ratio of the image being edited.
  final double originalAspectRatio;

  /// The currently selected aspect ratio.
  final double aspectRatio;

  /// Constructs a [CropAspectRatioOptions] widget.
  ///
  /// The [configs], [originalAspectRatio], and [aspectRatio] parameters are required.
  const CropAspectRatioOptions({
    super.key,
    required this.aspectRatio,
    required this.originalAspectRatio,
    required this.configs,
  });

  @override
  State<CropAspectRatioOptions> createState() => _CropAspectRatioOptionsState();
}

class _CropAspectRatioOptionsState extends State<CropAspectRatioOptions> {
  late ScrollController _scrollCtrl;

  @override
  void initState() {
    _scrollCtrl = ScrollController();
    super.initState();
  }

  @override
  void dispose() {
    _scrollCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
            child: Text(
              widget.configs.i18n.cropRotateEditor.ratio,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 24,
                color: widget.configs.imageEditorTheme.cropRotateEditor
                    .aspectRatioSheetForegroundColor,
              ),
            ),
          ),
          Flexible(
            child: Scrollbar(
              controller: _scrollCtrl,
              child: ListView.builder(
                primary: false,
                shrinkWrap: true,
                controller: _scrollCtrl,
                itemCount:
                    widget.configs.cropRotateEditorConfigs.aspectRatios.length,
                itemBuilder: (context, index) {
                  var item = widget
                      .configs.cropRotateEditorConfigs.aspectRatios[index];
                  return ListTile(
                    leading: SizedBox(
                      height: 38,
                      child: FittedBox(
                        child: AspectRatioButton(
                          aspectRatio: item.value == 0
                              ? widget.originalAspectRatio
                              : item.value,
                          isSelected: item.value == widget.aspectRatio,
                        ),
                      ),
                    ),
                    title: Text(
                      item.text,
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 16,
                        color: widget.configs.imageEditorTheme.cropRotateEditor
                            .aspectRatioSheetForegroundColor,
                      ),
                    ),
                    onTap: () {
                      Navigator.pop(context, item.value);
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
