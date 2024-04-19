import 'package:flutter/material.dart';
import 'package:pro_image_editor/models/editor_configs/pro_image_editor_configs.dart';
import 'package:pro_image_editor/modules/crop_rotate_editor/utils/crop_aspect_ratio_button.dart';

class CropAspectRatioOptions extends StatefulWidget {
  final ProImageEditorConfigs configs;
  final double originalAspectRatio;
  final double aspectRatio;

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
