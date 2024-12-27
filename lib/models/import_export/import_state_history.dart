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
import 'package:pro_image_editor/utils/parser/double_parser.dart';
import 'package:pro_image_editor/utils/parser/int_parser.dart';
import 'package:pro_image_editor/utils/parser/size_parser.dart';
import '../history/state_history.dart';
import '../tune_editor/tune_adjustment_matrix.dart';
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
    required this.lastRenderedImgSize,
    required this.stateHistory,
    required this.configs,
    required this.version,
  });

  /// Creates an [ImportStateHistory] instance from a map representation.
  factory ImportStateHistory.fromMap(
    Map<String, dynamic> map, {
    ImportEditorConfigs configs = const ImportEditorConfigs(),
  }) {
    /// Initialize default values
    final version =
        map['version'] as String? ?? ExportImportVersion.version_1_0_0;
    final stateHistory = <EditorStateHistory>[];
    final stickers = (map['stickers'] as List<dynamic>? ?? [])
        .map((sticker) => Uint8List.fromList(List.from(sticker)))
        .toList();
    final lastRenderedImgSize = safeParseSize(map['lastRenderedImgSize']);

    /// Parse history
    for (final historyItem in (map['history'] as List<dynamic>? ?? [])) {
      /// Layers
      final layers = (historyItem['layers'] as List<dynamic>? ?? [])
          .map((layer) => Layer.fromMap(layer, stickers))
          .toList();

      /// Blur
      final blur = safeParseDouble(historyItem['blur']);

      /// Filters
      final filters = _parseFilters(historyItem['filters'], version);

      /// Tune Adjustments
      final tuneAdjustments = (historyItem['tune'] as List<dynamic>? ?? [])
          .map((tune) => TuneAdjustmentMatrix.fromMap(tune))
          .toList();

      /// Transformations
      final transformConfigs = historyItem['transform'] != null &&
              Map.from(historyItem['transform']).isNotEmpty
          ? TransformConfigs.fromMap(historyItem['transform'])
          : TransformConfigs.empty();

      stateHistory.add(EditorStateHistory(
        blur: blur,
        layers: layers,
        filters: filters,
        tuneAdjustments: tuneAdjustments,
        transformConfigs: transformConfigs,
      ));
    }

    return ImportStateHistory._(
      editorPosition: safeParseInt(map['position']),
      imgSize: safeParseSize(map['imgSize']),
      lastRenderedImgSize: lastRenderedImgSize,
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

  /// Helper to parse filters
  static List<List<double>> _parseFilters(dynamic filtersData, String version) {
    if (filtersData == null) return [];

    switch (version) {
      case ExportImportVersion.version_1_0_0:
        return (filtersData as List<dynamic>).expand((el) {
          final filterMatrix = List<List<double>>.from(el['filters'] ?? []);
          final opacity = safeParseDouble(el['opacity'], fallback: 1);
          if (opacity != 1) {
            filterMatrix.add(ColorFilterAddons.opacity(opacity));
          }
          return filterMatrix;
        }).toList();
      default:
        return (filtersData as List<dynamic>)
            .map((el) => List<double>.from(el))
            .toList();
    }
  }

  /// The position of the editor.
  final int editorPosition;

  /// The size of the imported image.
  final Size imgSize;

  /// The size of the last used screen.
  final Size lastRenderedImgSize;

  /// The state history of each editor state in the session.
  final List<EditorStateHistory> stateHistory;

  /// The configurations for importing the editor state history.
  final ImportEditorConfigs configs;

  /// Version from import/export history for backward compatibility.
  final String version;
}
