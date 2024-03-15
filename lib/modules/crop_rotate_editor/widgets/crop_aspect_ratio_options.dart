import 'package:flutter/material.dart';
import 'package:pro_image_editor/models/aspect_ratio_item.dart';
import 'package:pro_image_editor/models/i18n/i18n.dart';
import 'package:pro_image_editor/modules/crop_rotate_editor/utils/crop_aspect_ratio_button.dart';
import 'package:pro_image_editor/widgets/pro_image_editor_desktop_mode.dart';

import '../../../widgets/flat_icon_text_button.dart';
import '../utils/crop_aspect_ratios.dart';

class CropAspectRatioOptions extends StatefulWidget {
  final I18nCropRotateEditor i18n;
  final double aspectRatio;

  const CropAspectRatioOptions({
    super.key,
    required this.aspectRatio,
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

  /// Returns a list of predefined aspect ratios.
  List<AspectRatioItem> get _aspectRatios {
    return [
      AspectRatioItem(text: widget.i18n.aspectRatioFree, value: CropAspectRatios.custom),
      AspectRatioItem(text: widget.i18n.aspectRatioOriginal, value: CropAspectRatios.original),
      AspectRatioItem(text: '1/1', value: CropAspectRatios.ratio1_1),
      AspectRatioItem(text: '4/3', value: CropAspectRatios.ratio4_3),
      AspectRatioItem(text: '3/4', value: CropAspectRatios.ratio3_4),
      AspectRatioItem(text: '16/9', value: CropAspectRatios.ratio16_9),
      AspectRatioItem(text: '9/16', value: CropAspectRatios.ratio9_16)
    ];
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
          child: ListView.builder(
            controller: _scrollCtrl,
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            itemBuilder: (_, int index) {
              final AspectRatioItem item = _aspectRatios[index];
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
            },
            itemCount: _aspectRatios.length,
          ),
        ),
      ),
    );
  }
}
