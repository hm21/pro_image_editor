import 'dart:async';

import 'package:flutter/material.dart';

import '/core/models/editor_callbacks/main_editor/main_editor_callbacks.dart';
import '/core/models/editor_configs/pro_image_editor_configs.dart';
import '/core/models/history/state_history.dart';
import '/core/models/layers/layer.dart';
import '/shared/services/import_export/constants/export_import_version.dart';
import '/shared/services/import_export/enums/export_import_enum.dart';
import '/shared/services/import_export/export_state_history.dart';
import '/shared/services/import_export/import_state_history.dart';
import '/shared/services/import_export/models/export_state_history_configs.dart';
import '/shared/utils/decode_image.dart';
import '../controllers/main_editor_controllers.dart';
import 'sizes_manager.dart';
import 'state_manager.dart';

/// A service to manage the state history of the main editor, including
/// screenshots and size configurations.
class MainEditorStateHistoryService {
  /// Creates a `MainEditorStateHistoryService` with the provided configurations
  /// and dependencies.
  ///
  /// - [configs]: Configuration settings for the main editor.
  /// - [takeScreenshot]: Callback for capturing a screenshot of the editor.
  /// - [sizesManager]: Manages size-related settings and adjustments.
  /// - [stateManager]: Handles state changes and history management.
  /// - [controllers]: Contains the controllers for managing editor behaviors.
  /// - [mainEditorCallbacks]: Optional callbacks for additional editor actions.
  MainEditorStateHistoryService({
    required this.configs,
    required this.takeScreenshot,
    required this.sizesManager,
    required this.stateManager,
    required this.controllers,
    required this.mainEditorCallbacks,
  });

  /// Manages size-related settings and adjustments.
  final SizesManager sizesManager;

  /// Handles state changes and history management.
  final StateManager stateManager;

  /// Contains the controllers for managing editor behaviors.
  final MainEditorControllers controllers;

  /// Configuration settings for the main editor.
  final ProImageEditorConfigs configs;

  /// Optional callbacks for additional editor actions.
  final MainEditorCallbacks? mainEditorCallbacks;

  /// Callback for capturing a screenshot of the editor.
  final Function() takeScreenshot;

  /// A flag indicating whether an import operation is currently in progress.
  ///
  /// This is used to track the state of an import process, where `true` means
  /// the import is ongoing, and `false` means no import is in progress.
  bool isImportInProgress = false;

  /// Imports state history and performs necessary recalculations.
  Future<void> importStateHistory(
    ImportStateHistory import,
    BuildContext context,
    Function() setState,
  ) async {
    isImportInProgress = true;
    // Recalculate position and size if needed
    if (import.configs.recalculateSizeAndPosition ||
        import.version == ExportImportVersion.version_1_0_0) {
      _recalculateSizeAndPosition(import);
    }

    // Precache widget layers
    await _precacheLayers(import, context);

    // Merge or replace state history
    if (import.configs.mergeMode == ImportEditorMergeMode.replace) {
      _replaceStateHistory(import);
    } else {
      _mergeStateHistory(import);
    }

    // Update state and UI
    stateManager.updateActiveItems();
    mainEditorCallbacks?.handleUpdateUI();
    isImportInProgress = false;
  }

  /// Exports the current state history.
  ExportStateHistory exportStateHistory({
    ExportEditorConfigs configs = const ExportEditorConfigs(),
    required BuildContext context,
    required ImageInfos imageInfos,
  }) {
    return ExportStateHistory(
      editorConfigs: this.configs,
      stateHistory: stateManager.stateHistory,
      imageInfos: imageInfos,
      editorPosition: stateManager.historyPointer,
      configs: configs,
      contentRecorderCtrl: controllers.screenshot,
      context: context,
    );
  }

  void _recalculateSizeAndPosition(ImportStateHistory import) {
    // A single layer instance can be shared across multiple history entries.
    // Mutating it in place once per entry would compound the scale factor, so
    // track processed instances by object identity and rescale each at most
    // once. `Layer.==` is content-based, hence `Set<Layer>.identity()` to keep
    // independent-but-equal copies distinct.
    final processed = Set<Layer>.identity();

    for (EditorStateHistory el in import.stateHistory) {
      for (Layer layer in el.layers) {
        if (!processed.add(layer)) continue;
        if (import.configs.recalculateSizeAndPosition) {
          Size currentImageSize = sizesManager.decodedImageSize;
          Size lastRenderedImgSize = import.lastRenderedImgSize;

          double scaleWidth =
              currentImageSize.width / lastRenderedImgSize.width;
          double scaleHeight =
              currentImageSize.height / lastRenderedImgSize.height;

          scaleWidth = scaleWidth.isFinite ? scaleWidth : 1;
          scaleHeight = scaleHeight.isFinite ? scaleHeight : 1;

          double scale = (scaleWidth + scaleHeight) / 2;

          layer
            ..scale *= scale
            ..offset = Offset(
              layer.offset.dx * scaleWidth,
              layer.offset.dy * scaleHeight,
            );
        }

        if (import.version == ExportImportVersion.version_1_0_0) {
          layer.offset -= Offset(
            sizesManager.bodySize.width / 2 - sizesManager.imageScreenGaps.left,
            sizesManager.bodySize.height / 2 - sizesManager.imageScreenGaps.top,
          );
        }
      }
    }
  }

  Future<void> _precacheLayers(
    ImportStateHistory import,
    BuildContext context,
  ) async {
    await Future.wait(
      import.requirePrecacheList.toSet().map(
        (item) => precacheImage(item.toImageProvider(), context),
      ),
    );
  }

  void _replaceStateHistory(ImportStateHistory import) {
    bool enableInitialEmptyState = import.configs.enableInitialEmptyState;
    bool enableEmptyHistory =
        import.stateHistory.isEmpty || enableInitialEmptyState;

    stateManager
      // Important to reset first the historyPointer
      ..historyPointer = 0
      ..screenshots = []
      ..stateHistory = [
        if (enableEmptyHistory)
          EditorStateHistory(
            transformConfigs: TransformConfigs.empty(),
            blur: 0,
            layers: [],
            tuneAdjustments: [],
          ),
        ...import.stateHistory,
      ]
      ..historyPointer = import.editorPosition + (enableEmptyHistory ? 1 : 0);

    for (var i = 0; i < import.stateHistory.length; i++) {
      controllers.screenshot.addEmptyScreenshot(
        screenshots: stateManager.screenshots,
      );
    }
  }

  void _mergeStateHistory(ImportStateHistory import) {
    for (var el in stateManager.screenshots) {
      el.broken = true;
    }

    for (var el in import.stateHistory) {
      if (import.configs.mergeMode == ImportEditorMergeMode.merge) {
        el.layers.insertAll(0, stateManager.stateHistory.last.layers);
        el.filters.insertAll(0, stateManager.stateHistory.last.filters);
        el.tuneAdjustments.insertAll(
          0,
          stateManager.stateHistory.last.tuneAdjustments,
        );
      }
    }

    for (var i = 0; i < import.stateHistory.length; i++) {
      stateManager.stateHistory.add(import.stateHistory[i]);
      if (i < import.stateHistory.length - 1) {
        controllers.screenshot.addEmptyScreenshot(
          screenshots: stateManager.screenshots,
        );
      } else {
        takeScreenshot();
      }
    }
    stateManager.historyPointer = stateManager.stateHistory.length - 1;
  }
}
