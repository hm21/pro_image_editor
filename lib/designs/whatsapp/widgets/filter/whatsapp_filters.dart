// Dart imports:
import 'dart:math';

// Flutter imports:
import 'package:flutter/material.dart';

import '/pro_image_editor.dart';
import '../../whatsapp.dart';

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
    required this.emptyFilter,
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

  /// A list of empty filter matrices used as a default or placeholder filter.
  final List<List<double>> emptyFilter;

  @override
  Widget build(BuildContext context) {
    final sizesManager = editor.sizesManager;
    final stateManager = editor.stateManager;
    final activeFilters = stateManager.activeFilters;
    final double showFactor = max(
      0,
      min(1, 1 / 120 * whatsAppHelper.filterShowHelper),
    );
    return Positioned(
      left: 0,
      right: 0,
      bottom: -120 + whatsAppHelper.filterShowHelper,
      child: GestureInterceptor(
        child: Opacity(
          opacity: showFactor,
          child: Container(
            margin: const EdgeInsets.only(top: 7),
            color: const Color(0xFF121B22),
            child: FilterEditorItemList(
              mainBodySize: sizesManager.bodySize,
              mainImageSize: sizesManager.decodedImageSize,
              transformConfigs: stateManager.transformConfigs,
              itemScaleFactor: showFactor,
              editorImage: editor.editorImage!,
              blurFactor: stateManager.activeBlur,
              configs: editor.configs,
              selectedFilter: activeFilters.isNotEmpty
                  ? activeFilters.allMatrices
                  : emptyFilter,
              onSelectFilter: (filter) {
                editor.addHistory(
                  filters: [FilterState(matrices: filter.filters)],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
