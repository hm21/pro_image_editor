import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:pro_image_editor/models/crop_rotate_editor/transform_factors.dart';
import 'package:pro_image_editor/models/import_export/import_state_history_configs.dart';
import 'package:pro_image_editor/models/layer.dart';

import '../editor_image.dart';
import '../history/blur_state_history.dart';
import '../history/filter_state_history.dart';
import '../history/state_history.dart';

/// This class represents the state history of an imported editor session.
class ImportStateHistory {
  /// The position of the editor.
  final int editorPosition;

  /// The size of the imported image.
  final Size imgSize;

  /// The state history of the imported editor images.
  final List<EditorImage> imgStateHistory;

  /// The state history of each editor state in the session.
  final List<EditorStateHistory> stateHistory;

  /// The configurations for importing the editor state history.
  final ImportEditorConfigs configs;

  /// Constructs an [ImportStateHistory] instance.
  ImportStateHistory._({
    required this.editorPosition,
    required this.imgSize,
    required this.imgStateHistory,
    required this.stateHistory,
    required this.configs,
  });

  /// Creates an [ImportStateHistory] instance from a map representation.
  factory ImportStateHistory.fromMap(
    Map map, {
    ImportEditorConfigs configs = const ImportEditorConfigs(),
  }) {
    List<EditorStateHistory> stateHistory = [];
    List<EditorImage> imgStateHistory = [];
    List<Uint8List> stickers = [];
    for (var sticker in List.from(map['stickers'] ?? [])) {
      stickers.add(Uint8List.fromList(List.from(sticker)));
    }

    for (var image in List.from(map['cropRotateImages'] ?? [])) {
      imgStateHistory
          .add(EditorImage(byteArray: Uint8List.fromList(List.from(image))));
    }

    for (var el in List.from(map['history'] ?? [])) {
      BlurStateHistory blur = BlurStateHistory();
      List<Layer> layers = [];
      List<FilterStateHistory> filters = [];

      if (el['blur'] != null) {
        blur = BlurStateHistory.fromMap(el['blur']);
      }
      for (var layer in List.from(el['layers'] ?? [])) {
        layers.add(Layer.fromMap(layer, stickers));
      }
      for (var filter in List.from(el['filters'] ?? [])) {
        filters.add(FilterStateHistory.fromMap(filter));
      }

      stateHistory.add(
        EditorStateHistory(
          bytesRefIndex: el['listPosition'] ?? 0,
          blur: blur,
          layers: layers,
          filters: filters,
          transformConfigs: TransformConfigs.empty(),
        ),
      );
    }

    return ImportStateHistory._(
      editorPosition: map['position'],
      imgSize:
          Size(map['imgSize']?['width'] ?? 0, map['imgSize']?['height'] ?? 0),
      imgStateHistory: imgStateHistory,
      stateHistory: stateHistory,
      configs: configs,
    );
  }

  /// Creates an [ImportStateHistory] instance from a JSON string.
  factory ImportStateHistory.fromJson(
    String json, {
    ImportEditorConfigs configs = const ImportEditorConfigs(),
  }) {
    return ImportStateHistory.fromMap(jsonDecode(json), configs: configs);
  }

  /// Creates an [ImportStateHistory] instance from a JSON file.
  factory ImportStateHistory.fromJsonFile(
    File file, {
    ImportEditorConfigs configs = const ImportEditorConfigs(),
  }) {
    String json = file.readAsStringSync();
    return ImportStateHistory.fromJson(json, configs: configs);
  }
}
