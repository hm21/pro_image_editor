import 'package:flutter/material.dart';
import 'package:pro_image_editor/models/aspect_ratio_item.dart';
import 'package:pro_image_editor/models/editor_configs/crop_rotate_editor_configs.dart';
import 'package:pro_image_editor/models/i18n/i18n.dart';
import 'package:pro_image_editor/modules/crop_rotate_editor/utils/crop_aspect_ratio_button.dart';
import 'package:pro_image_editor/widgets/pro_image_editor_desktop_mode.dart';

import '../../../widgets/flat_icon_text_button.dart';

class CropAspectRatioOptions extends StatefulWidget {
  final I18nCropRotateEditor i18n;
  final CropRotateEditorConfigs configs;
  final double aspectRatio;

  const CropAspectRatioOptions({
    super.key,
    required this.aspectRatio,
    required this.configs,
    required this.i18n,
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
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        color: Colors.black87,
        height: 100,
        child: Scrollbar(
          controller: _scrollCtrl,
          scrollbarOrientation: ScrollbarOrientation.bottom,
          thumbVisibility: isDesktop,
          trackVisibility: isDesktop,
          child: SingleChildScrollView(
            controller: _scrollCtrl,
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: ConstrainedBox(
              constraints: BoxConstraints(minWidth: MediaQuery.of(context).size.width),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: widget.configs.aspectRatios.map((item) {
                  return GestureDetector(
                    child: FlatIconTextButton(
                      label: Text(
                        item.text,
                        style: const TextStyle(color: Colors.white),
                      ),
                      icon: SizedBox(
                        height: 38,
                        child: FittedBox(
                          child: AspectRatioButton(
                            aspectRatio: item.value,
                            isSelected: item.value == widget.aspectRatio,
                          ),
                        ),
                      ),
                    ),
                    onTap: () {
                      Navigator.pop(context, item.value);
                    },
                  );
                }).toList(),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
