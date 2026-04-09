// Dart imports:
import 'dart:convert';

// Flutter imports:
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '/core/models/editor_image.dart';
import '/core/models/history/state_history.dart';
import '/core/models/layers/layer.dart';
import '/core/platform/io/io_helper.dart';
import '/features/crop_rotate_editor/models/transform_configs.dart';
import '/features/filter_editor/constants/identity_matrix_constant.dart';
import '/features/filter_editor/types/filter_state.dart';
import '/features/filter_editor/utils/lerp_color_matrix_utils.dart';
import '/features/tune_editor/models/tune_adjustment_matrix.dart';
import '../../utils/parser/double_parser.dart';
import '../../utils/parser/int_parser.dart';
import '../../utils/parser/size_parser.dart';
import './utils/history_compatibility/history_compatibility_layer_interaction.dart';
import 'constants/export_import_version.dart';
import 'models/import_state_history_configs.dart';
import 'utils/key_minifier.dart';

/// This class represents the state history of an imported editor session.
class ImportStateHistory {
  /// Constructs an [ImportStateHistory] instance.
  ImportStateHistory._({
    required this.editorPosition,
    required this.imgSize,
    required this.lastRenderedImgSize,
    required this.stateHistory,
    required this.configs,
    required this.version,
    required this.requirePrecacheList,
  });

  /// Creates an [ImportStateHistory] instance from a JSON file.
  factory ImportStateHistory.fromJsonFile(
    File file, {
    ImportEditorConfigs configs = const ImportEditorConfigs(),
  }) {
    String json = file.readAsStringSync();
    return ImportStateHistory.fromJson(json, configs: configs);
  }

  /// Creates an [ImportStateHistory] instance from a JSON string.
  factory ImportStateHistory.fromJson(
    String json, {
    ImportEditorConfigs configs = const ImportEditorConfigs(),
  }) {
    return ImportStateHistory.fromMap(jsonDecode(json), configs: configs);
  }

  /// Creates an [ImportStateHistory] instance from a map representation.
  factory ImportStateHistory.fromMap(
    Map<String, dynamic> map, {
    ImportEditorConfigs configs = const ImportEditorConfigs(),
  }) {
    bool isMinified = map['m'] == true;

    EditorKeyMinifier minifier = EditorKeyMinifier(enableMinify: isMinified);

    final blurKey = minifier.convertHistoryKey('blur');
    final tuneKey = minifier.convertHistoryKey('tune');
    final filtersKey = minifier.convertHistoryKey('filters');
    final transformKey = minifier.convertHistoryKey('transform');

    /// Initialize default values
    final version =
        map[minifier.convertMainKey('version')] as String? ??
        ExportImportVersion.version_1_0_0;
    final stateHistory = <EditorStateHistory>[];
    final widgetRecords = parseWidgetRecords(map, version, minifier);
    final lastRenderedImgSize = safeParseSize(
      map[minifier.convertMainKey('lastRenderedImgSize')],
    );
    final List<EditorImage> requirePrecacheList = [];

    Map<String, Map<String, dynamic>> lastLayerStateHelper = {
      ...map[minifier.convertMainKey('references')] ?? {},
    };

    var historyList =
        (map[minifier.convertMainKey('history')] as List<dynamic>? ?? []);

    /// Parse history
    for (final historyItem in historyList) {
      /// Layers
      List<Layer> layers = [];
      switch (version) {
        case ExportImportVersion.version_1_0_0:
        case ExportImportVersion.version_2_0_0:
        case ExportImportVersion.version_3_0_1:
        case ExportImportVersion.version_3_0_0:
        case ExportImportVersion.version_4_0_0:
          layers = (historyItem['layers'] as List<dynamic>? ?? []).map((
            rawLayer,
          ) {
            historyCompatibilityLayerInteraction(
              layerMap: rawLayer,
              minifier: minifier,
              version: version,
            );
            return Layer.fromMap(
              rawLayer,
              widgetRecords: widgetRecords,
              widgetLoader: configs.widgetLoader,
              requirePrecache: requirePrecacheList.add,
            );
          }).toList();
          break;
        default:
          for (var rawLayer in List.from(
            historyItem[minifier.convertHistoryKey('layers')] ?? [],
          )) {
            String id = rawLayer['id'];
            Map<String, dynamic> convertedLayerMap = {
              ...lastLayerStateHelper[id] ?? {},
              ...rawLayer,
            };

            if (version == ExportImportVersion.version_5_0_0) {
              historyCompatibilityLayerInteraction(
                layerMap: convertedLayerMap,
                minifier: minifier,
                version: version,
              );
            }

            layers.add(
              Layer.fromMap(
                convertedLayerMap,
                widgetRecords: widgetRecords,
                widgetLoader: configs.widgetLoader,
                requirePrecache: requirePrecacheList.add,
                minifier: minifier,
                id: id,
              ),
            );

            lastLayerStateHelper[id] = Map<String, dynamic>.from(
              convertedLayerMap,
            );
          }
      }

      /// Blur
      final blur = historyItem[blurKey] != null
          ? safeParseDouble(historyItem[blurKey])
          : null;

      /// Filters
      final filters = parseFilterStates(historyItem[filtersKey], version);

      /// Tune Adjustments
      final tuneAdjustments = (historyItem[tuneKey] as List<dynamic>? ?? [])
          .map((tune) => TuneAdjustmentMatrix.fromMap(tune))
          .toList();

      /// Transformations
      final transformConfigs =
          historyItem[transformKey] != null &&
              Map.from(historyItem[transformKey]).isNotEmpty
          ? TransformConfigs.fromMap(historyItem[transformKey])
          : stateHistory.isNotEmpty
          ? stateHistory.last.transformConfigs
          : TransformConfigs.empty();

      stateHistory.add(
        EditorStateHistory(
          blur: blur,
          layers: layers,
          filters: filters,
          tuneAdjustments: tuneAdjustments,
          transformConfigs: transformConfigs,
        ),
      );
    }

    return ImportStateHistory._(
      editorPosition: safeParseInt(map[minifier.convertMainKey('position')]),
      imgSize: safeParseSize(map[minifier.convertMainKey('imgSize')]),
      lastRenderedImgSize: lastRenderedImgSize,
      stateHistory: stateHistory,
      configs: configs,
      version: version,
      requirePrecacheList: requirePrecacheList,
    );
  }

  /// Parses filter data into a list of [FilterState].
  ///
  /// New format (list of Maps each with `matrices` key + optional timeline
  /// fields) is parsed via [FilterState.fromMap]. Older formats (plain list
  /// of matrices) are handled by [parseFilters] and wrapped in a single
  /// [FilterState].
  @visibleForTesting
  static List<FilterState> parseFilterStates(
    dynamic filtersData,
    String version,
  ) {
    if (filtersData == null) return const [];

    // New format: list of FilterState maps
    if (filtersData is List &&
        filtersData.isNotEmpty &&
        filtersData.first is Map) {
      final firstMap = filtersData.first as Map;
      if (firstMap.containsKey('matrices')) {
        return filtersData
            .map(
              (e) => FilterState.fromMap(Map<String, dynamic>.from(e as Map)),
            )
            .toList();
      }
    }

    // Single FilterState map (backward compat with previous format)
    if (filtersData is Map<String, dynamic> &&
        filtersData.containsKey('matrices')) {
      return [FilterState.fromMap(filtersData)];
    }

    // Old formats: plain list of matrices
    final matrices = parseFilters(filtersData, version);
    if (matrices.isEmpty) return const [];
    return [FilterState(matrices: matrices)];
  }

  /// Helper to parse filters
  @visibleForTesting
  static List<List<double>> parseFilters(dynamic filtersData, String version) {
    if (filtersData == null) return [];

    if (version.toVersionNumber() <=
        ExportImportVersion.version_1_0_0.toVersionNumber()) {
      return (filtersData as List<dynamic>).expand((el) {
        final filterMatrix = <List<double>>[];
        final rawFilters = List<List<dynamic>>.from(el['filters'] ?? []);
        final opacity = safeParseDouble(el['opacity'], fallback: 1.0);

        for (final f in rawFilters) {
          final matrix = List<double>.from(f.map(safeParseDouble));

          if (opacity == 1.0) {
            filterMatrix.add(matrix);
          } else {
            filterMatrix.add(lerpColorMatrix(identityMatrix, matrix, opacity));
          }
        }

        return filterMatrix;
      }).toList();
    } else if (version.toVersionNumber() <=
        ExportImportVersion.version_6_2_0.toVersionNumber()) {
      final result = <List<double>>[];

      for (final List<dynamic> matrix in filtersData) {
        final opacity = safeParseDouble(matrix[18]);

        final originalMatrix = List<double>.from(matrix.map(safeParseDouble));
        if (opacity != 1) {
          var updatedMatrix = lerpColorMatrix(
            identityMatrix,
            originalMatrix,
            opacity,
          );

          /// Set opacity to 1 as the other values are updated with lerp.
          updatedMatrix[18] = 1.0;
          result.add(updatedMatrix);
        } else {
          result.add(originalMatrix);
        }
      }

      // Apply opacity by blending with identity
      return result;
    } else {
      return (filtersData as List<dynamic>)
          .map(
            (el) =>
                List<double>.from((el as List<dynamic>).map(safeParseDouble)),
          )
          .toList();
    }
  }

  /// Helper to parse widget records
  @visibleForTesting
  static List<Uint8List> parseWidgetRecords(
    Map<String, dynamic> map,
    String version,
    EditorKeyMinifier minifier,
  ) {
    List<dynamic> items = [];
    switch (version) {
      case ExportImportVersion.version_1_0_0:
      case ExportImportVersion.version_2_0_0:
      case ExportImportVersion.version_3_0_0:
      case ExportImportVersion.version_3_0_1:
        items = (map['stickers'] as List<dynamic>? ?? []);
        break;
      default:
        items =
            (map[minifier.convertMainKey('widgetRecords')] as List<dynamic>? ??
            []);
        break;
    }

    return items.map((item) => Uint8List.fromList(List.from(item))).toList();
  }

  /// A list of widget layers that need to be pre-cached.
  ///
  /// This list contains images that should be loaded and cached in memory
  /// before they are used in the editor to ensure smooth performance and
  /// quick access.
  final List<EditorImage> requirePrecacheList;

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
