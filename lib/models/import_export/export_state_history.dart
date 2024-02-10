import 'dart:convert';
import 'dart:typed_data';

import 'package:screenshot/screenshot.dart';

import '../changes/changes.dart';
import '../layer.dart';
import 'export_state_history_configs.dart';

class ExportStateHistory {
  final List<ImageEditorChanges> _changes;
  final ExportEditorConfigs _configs;
  final int _editorPosition;

  ExportStateHistory(
    this._changes,
    this._editorPosition, {
    ExportEditorConfigs configs = const ExportEditorConfigs(),
  }) : _configs = configs;

  Future<Map> toMap() async {
    ScreenshotController screenshotController = ScreenshotController();
    Map map = {
      'position': _editorPosition,
      'history': [],
      'images': [],
    };
    List<Uint8List> stickers = [];
    List<ImageEditorChanges> changes = List.from(_changes);
    if (changes.isNotEmpty) changes.removeAt(0);
    if (!_configs.redoHistory) changes.removeRange(_editorPosition, changes.length);

    for (var element in changes) {
      var layers = [];
      // TODO: Add Filters, Crop-Rotate
      for (var layer in element.layers) {
        if ((_configs.exportPainting && layer.runtimeType == PaintingLayerData) ||
            (_configs.exportText && layer.runtimeType == TextLayerData) ||
            (_configs.exportEmoji && layer.runtimeType == EmojiLayerData)) {
          layers.add(layer.toMap());
        } else if (_configs.exportStickers && layer.runtimeType == StickerLayerData) {
          layers.add((layer as StickerLayerData).toStickerMap(stickers.length));
          stickers.add(await screenshotController.captureFromWidget(layer.sticker));
        }
      }

      (map['history'] as List).add(layers);
    }

    if (stickers.isNotEmpty) map['stickers'] = stickers;

    return map;
  }

  Future<String> toJson() async {
    return jsonEncode(await toMap());
  }
}
