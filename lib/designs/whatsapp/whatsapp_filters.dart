// Dart imports:
import 'dart:math';

// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:pro_image_editor/designs/whatsapp/whatsapp.dart';
import 'package:pro_image_editor/pro_image_editor.dart';

class WhatsappFilters extends StatelessWidget {
  final ProImageEditorState editor;
  final WhatsAppHelper whatsAppHelper;

  const WhatsappFilters({
    super.key,
    required this.editor,
    required this.whatsAppHelper,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 0,
      right: 0,
      bottom: -120 + whatsAppHelper.filterShowHelper,
      child: Opacity(
        opacity: max(0, min(1, 1 / 120 * whatsAppHelper.filterShowHelper)),
        child: Container(
          margin: const EdgeInsets.only(top: 7),
          color: const Color(0xFF121B22),
          child: FilterEditorItemList(
            mainBodySize: editor.sizesManager.bodySize,
            mainImageSize: editor.sizesManager.decodedImageSize,
            transformConfigs: editor.stateManager.transformConfigs,
            itemScaleFactor:
                max(0, min(1, 1 / 120 * whatsAppHelper.filterShowHelper)),
            editorImage: editor.editorImage,
            blurFactor: editor.stateManager.activeBlur,
            configs: editor.configs,
            selectedFilter: editor.stateManager.activeFilters.isNotEmpty
                ? editor.stateManager.activeFilters
                : PresetFilters.none.filters,
            onSelectFilter: (filter) {
              editor.addHistory(filters: filter.filters);
            },
          ),
        ),
      ),
    );
  }
}
