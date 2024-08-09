// ignore_for_file: argument_type_not_assignable

// Dart imports:
import 'dart:convert';
import 'dart:io';

// Flutter imports:
import 'package:flutter/services.dart';

// Project imports:
import 'package:pro_image_editor/models/crop_rotate_editor/transform_factors.dart';
import 'package:pro_image_editor/models/import_export/import_state_history_configs.dart';
import 'package:pro_image_editor/models/layer/layer.dart';
import 'package:pro_image_editor/modules/filter_editor/utils/filter_generator/filter_addons.dart';
import '../history/state_history.dart';
import 'utils/export_import_version.dart';

/// This class represents the state history of an imported editor session.
class ImportStateHistory {
  /// Creates an [ImportStateHistory] instance from a JSON file.
  factory ImportStateHistory.fromJsonFile(
    File file, {
    ImportEditorConfigs configs = const ImportEditorConfigs(),
  }) {
    String json = file.readAsStringSync();
    return ImportStateHistory.fromJson(json, configs: configs);
  }

  /// Constructs an [ImportStateHistory] instance.
  ImportStateHistory._({
    required this.editorPosition,
    required this.imgSize,
    required this.stateHistory,
    required this.configs,
    required this.version,
  });

  /// Creates an [ImportStateHistory] instance from a map representation.
  factory ImportStateHistory.fromMap(
    Map<String, dynamic> map, {
    ImportEditorConfigs configs = const ImportEditorConfigs(),
  }) {
    List<EditorStateHistory> stateHistory = [];
    List<Uint8List> stickers = [];

    String version =
        (map['version'] as String?) ?? ExportImportVersion.version_1_0_0;

    for (var sticker in List.from(map['stickers'] ?? [])) {
      stickers.add(Uint8List.fromList(List.from(sticker)));
    }

    for (var el in List.from(map['history'] ?? [])) {
      double blur = 0;
      List<Layer> layers = [];

      if (el['blur'] != null) {
        blur = double.tryParse((el['blur'] ?? '0').toString()) ?? 0;
      }
      for (var layer in List.from(el['layers'] ?? [])) {
        layers.add(Layer.fromMap(layer, stickers));
      }

      List<List<double>> filters = [];
      if (version == ExportImportVersion.version_1_0_0) {
        for (var el in List.from(el['filters'] ?? [])) {
          List<List<double>> filterMatrix = List.from(el['filters'] ?? []);
          double opacity =
              double.tryParse((el['opacity'] ?? '1').toString()) ?? 1;
          if (opacity != 1) {
            filterMatrix.add(ColorFilterAddons.opacity(opacity));
          }

          filters.addAll(filterMatrix);
        }
      } else {
        List<List<double>> filterList = [];
        for (var el in List.from(el['filters'] ?? [])) {
          List<double> filtersRaw = [];

          for (var raw in List.from(el)) {
            filtersRaw.add(raw);
          }

          filterList.add(filtersRaw);
        }

        filters = filterList;
      }

      stateHistory.add(
        EditorStateHistory(
          blur: blur,
          layers: layers,
          filters: filters,
          transformConfigs:
              el['transform'] != null && Map.from(el['transform']).isNotEmpty
                  ? TransformConfigs.fromMap(el['transform'])
                  : TransformConfigs.empty(),
        ),
      );
    }

    return ImportStateHistory._(
      editorPosition: map['position'],
      imgSize:
          Size(map['imgSize']?['width'] ?? 0, map['imgSize']?['height'] ?? 0),
      stateHistory: stateHistory,
      configs: configs,
      version: version,
    );
  }

  /// Creates an [ImportStateHistory] instance from a JSON string.
  factory ImportStateHistory.fromJson(
    String json, {
    ImportEditorConfigs configs = const ImportEditorConfigs(),
  }) {
    return ImportStateHistory.fromMap(jsonDecode(json), configs: configs);
  }

  /// The position of the editor.
  final int editorPosition;

  /// The size of the imported image.
  final Size imgSize;

  /// The state history of each editor state in the session.
  final List<EditorStateHistory> stateHistory;

  /// The configurations for importing the editor state history.
  final ImportEditorConfigs configs;

  /// Version from import/export history for backward compatibility.
  final String version;
}
