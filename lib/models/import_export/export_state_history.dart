import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:pro_image_editor/models/import_export/utils/export_import_enum.dart';
import 'package:screenshot/screenshot.dart';

import '../editor_image.dart';
import '../history/state_history.dart';
import '../layer.dart';
import 'export_state_history_configs.dart';
import 'utils/export_import_version.dart';

/// Class responsible for exporting the state history of the editor.
///
/// This class allows you to export the state history of the editor,
/// including layers, filters, stickers, and other configurations.
class ExportStateHistory {
  final int _editorPosition;
  final Size _imgSize;
  final List<EditorImage> _imgStateHistory;
  final List<EditorStateHistory> stateHistory;
  late ScreenshotController _screenshotController;
  final ExportEditorConfigs _configs;

  /// Constructs an [ExportStateHistory] object with the given parameters.
  ///
  /// The [stateHistory], [_imgStateHistory], [_imgSize], and [_editorPosition]
  /// parameters are required, while the [configs] parameter is optional and
  /// defaults to [ExportEditorConfigs()].
  ExportStateHistory(
    this.stateHistory,
    this._imgStateHistory,
    this._imgSize,
    this._editorPosition, {
    ExportEditorConfigs configs = const ExportEditorConfigs(),
  }) : _configs = configs;

  /// Converts the state history to a Map.
  ///
  /// Returns a Map representing the state history of the editor,
  /// including layers, filters, stickers, and other configurations.
  Future<Map> toMap() async {
    _screenshotController = ScreenshotController();

    List history = [];
    List cropRotateImages = [];
    List<Uint8List> stickers = [];
    List<EditorStateHistory> changes = List.from(stateHistory);

    if (changes.isNotEmpty) changes.removeAt(0);

    /// Choose history span
    switch (_configs.historySpan) {
      case ExportHistorySpan.current:
        changes = [changes[_editorPosition - 1]];
        break;
      case ExportHistorySpan.currentAndBackward:
        changes.removeRange(_editorPosition, changes.length);
        break;
      case ExportHistorySpan.currentAndForward:
        changes.removeRange(0, _editorPosition - 1);
        break;
      case ExportHistorySpan.all:
        break;
    }

    /// Build Layers and filters
    for (var element in changes) {
      List layers = [];
      List filters = [];
      Map<int, int> cropImagePostionHelper = {};

      await _convertLayers(
        element: element,
        layers: layers,
        stickers: stickers,
      );

      if (_configs.exportFilter) {
        for (var filter in element.filters) {
          filters.add(filter.toMap());
        }
      }

      /// Add Crop-Rotate images
      /// TODO: Replace only with state after replace the crop-rotate-editor with
      /// own solution
      if (_configs.exportCropRotate &&
          !cropImagePostionHelper.containsKey(element.bytesRefIndex)) {
        cropImagePostionHelper[element.bytesRefIndex] = cropRotateImages.length;
        cropRotateImages
            .add(await _imgStateHistory[element.bytesRefIndex].safeByteArray);
      }

      var layerMap = {
        if (_configs.exportCropRotate)
          'listPosition': cropImagePostionHelper[element.bytesRefIndex] ?? 0,
        if (layers.isNotEmpty) 'layers': layers,
        if (filters.isNotEmpty) 'filters': filters,
      };

      if (layerMap.isNotEmpty) history.add(layerMap);
    }

    return {
      'version': ExportImportVersion.version_1_0_0,
      'position': _configs.historySpan == ExportHistorySpan.current ||
              _configs.historySpan == ExportHistorySpan.currentAndForward
          ? 0
          : _editorPosition - 1,
      if (history.isNotEmpty) 'history': history,
      if (stickers.isNotEmpty) 'stickers': stickers,
      if (cropRotateImages.isNotEmpty) 'cropRotateImages': cropRotateImages,
      'imgSize': {
        'width': _imgSize.width,
        'height': _imgSize.height,
      },
    };
  }

  /// Converts the state history to a JSON string.
  ///
  /// Returns a JSON string representing the state history of the editor.
  Future<String> toJson() async {
    return jsonEncode(await toMap());
  }

  /// Converts the state history to a JSON file.
  ///
  /// Returns a File representing the JSON file containing the state history
  /// of the editor. The optional [path] parameter specifies the path where
  /// the file should be saved. If not provided, the file will be saved in
  /// the system's temporary directory with the default name 'editor_state_history.json'.
  Future<File> toFile({String? path}) async {
    // Get the system's temporary directory
    String tempDir = Directory.systemTemp.path;

    String filePath = path ?? '$tempDir/editor_state_history.json';

    // Create a temporary file
    File tempFile = File(filePath);

    // Write JSON String to the temporary file
    await tempFile.writeAsString(await toJson());

    if (kDebugMode) {
      debugPrint('Export state history to file location: $filePath');
    }

    return tempFile;
  }

  Future<void> _convertLayers({
    required EditorStateHistory element,
    required List layers,
    required List stickers,
  }) async {
    for (var layer in element.layers) {
      if ((_configs.exportPainting && layer.runtimeType == PaintingLayerData) ||
          (_configs.exportText && layer.runtimeType == TextLayerData) ||
          (_configs.exportEmoji && layer.runtimeType == EmojiLayerData)) {
        layers.add(layer.toMap());
      } else if (_configs.exportSticker &&
          layer.runtimeType == StickerLayerData) {
        layers.add((layer as StickerLayerData).toStickerMap(stickers.length));
        stickers
            .add(await _screenshotController.captureFromWidget(layer.sticker));
      }
    }
  }
}
