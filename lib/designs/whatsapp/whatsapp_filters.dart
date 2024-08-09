// Dart imports:
import 'dart:math';

// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:pro_image_editor/designs/whatsapp/whatsapp.dart';
import 'package:pro_image_editor/pro_image_editor.dart';

/// A stateless widget that represents a collection of filters in the WhatsApp
/// theme.
///
/// This widget provides a user interface for selecting and applying filters to
/// images, using a design inspired by WhatsApp.
class WhatsappFilters extends StatelessWidget {
  /// Creates a [WhatsappFilters] widget.
  ///
  /// This widget displays a list of available filters and allows users to
  /// select and apply them to an image within the editor.
  ///
  /// Example:
  /// ```
  /// WhatsappFilters(
  ///   editor: myEditorState,
  ///   whatsAppHelper: myWhatsAppHelper,
  /// )
  /// ```
  const WhatsappFilters({
    super.key,
    required this.editor,
    required this.whatsAppHelper,
  });

  /// The state of the image editor associated with these filters.
  ///
  /// This state provides access to the current image and operations for
  /// applying filters, integrating with the editor's workflow.
  final ProImageEditorState editor;

  /// Helper functions and utilities for WhatsApp-themed filter operations.
  ///
  /// This helper provides methods and properties specific to the WhatsApp
  /// filter functionality, aiding in managing and applying filters.
  final WhatsAppHelper whatsAppHelper;

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
