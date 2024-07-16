// Dart imports:
import 'dart:async';
import 'dart:convert';
import 'dart:io';

// Flutter imports:
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

// Project imports:
import 'package:pro_image_editor/pro_image_editor.dart';
import '../../utils/content_recorder.dart/content_recorder_controller.dart';
import '../history/state_history.dart';
import 'utils/export_import_version.dart';

/// Class responsible for exporting the state history of the editor.
///
/// This class allows you to export the state history of the editor,
/// including layers, filters, stickers, and other configurations.
class ExportStateHistory {
  final int editorPosition;
  final Size imgSize;
  final List<EditorStateHistory> stateHistory;
  late ContentRecorderController contentRecorderCtrl;
  final ProImageEditorConfigs editorConfigs;
  final ExportEditorConfigs _configs;
  final ImageInfos imageInfos;
  final BuildContext context;

  /// Constructs an [ExportStateHistory] object with the given parameters.
  ///
  /// The [stateHistory], [_imgStateHistory], [imgSize], and [editorPosition]
  /// parameters are required, while the [configs] parameter is optional and
  /// defaults to [ExportEditorConfigs()].
  ExportStateHistory({
    required this.editorConfigs,
    required this.stateHistory,
    required this.imageInfos,
    required this.imgSize,
    required this.editorPosition,
    required this.contentRecorderCtrl,
    required this.context,
    ExportEditorConfigs configs = const ExportEditorConfigs(),
  }) : _configs = configs;

  /// Converts the state history to a Map.
  ///
  /// Returns a Map representing the state history of the editor,
  /// including layers, filters, stickers, and other configurations.
  Future<Map> toMap() async {
    List history = [];
    List<Uint8List> stickers = [];
    List<EditorStateHistory> changes = List.from(stateHistory);

    if (changes.isNotEmpty) changes.removeAt(0);

    /// Choose history span
    switch (_configs.historySpan) {
      case ExportHistorySpan.current:
        if (editorPosition > 0) {
          changes = [changes[editorPosition - 1]];
        }
        break;
      case ExportHistorySpan.currentAndBackward:
        changes.removeRange(editorPosition, changes.length);
        break;
      case ExportHistorySpan.currentAndForward:
        changes.removeRange(0, editorPosition - 1);
        break;
      case ExportHistorySpan.all:
        break;
    }

    /// Build Layers and filters
    for (EditorStateHistory element in changes) {
      List layers = [];

      await _convertLayers(
        element: element,
        layers: layers,
        stickers: stickers,
        imageInfos: imageInfos,
      );

      Map transformConfigsMap = element.transformConfigs.toMap();
      history.add({
        if (layers.isNotEmpty) 'layers': layers,
        if (_configs.exportFilter && element.filters.isNotEmpty)
          'filters': element.filters,
        'blur': element.blur,
        if (transformConfigsMap.isNotEmpty) 'transform': transformConfigsMap,
      });
    }

    return {
      'version': ExportImportVersion.version_2_0_0,
      'position': _configs.historySpan == ExportHistorySpan.current ||
              _configs.historySpan == ExportHistorySpan.currentAndForward
          ? 0
          : editorPosition - 1,
      if (history.isNotEmpty) 'history': history,
      if (stickers.isNotEmpty) 'stickers': stickers,
      'imgSize': {
        'width': imageInfos.rawSize.width,
        'height': imageInfos.rawSize.height,
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
    required ImageInfos imageInfos,
  }) async {
    for (var layer in element.layers) {
      if ((_configs.exportPainting && layer.runtimeType == PaintingLayerData) ||
          (_configs.exportText && layer.runtimeType == TextLayerData) ||
          (_configs.exportEmoji && layer.runtimeType == EmojiLayerData)) {
        layers.add(layer.toMap());
      } else if (_configs.exportSticker &&
          layer.runtimeType == StickerLayerData) {
        layers.add((layer as StickerLayerData).toStickerMap(stickers.length));

        double imageWidth =
            (editorConfigs.stickerEditorConfigs?.initWidth ?? 100) *
                layer.scale;
        Size targetSize = Size(
            imageWidth,
            MediaQuery.of(context).size.height /
                MediaQuery.of(context).size.width *
                imageWidth);

        Uint8List? result = await contentRecorderCtrl.captureFromWidget(
          layer.sticker,
          format: OutputFormat.png,
          imageInfos: imageInfos,
          targetSize: targetSize,
        );
        if (result == null) return;

        stickers.add(result);
      }
    }
  }
}
