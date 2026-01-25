// Dart imports:
import 'dart:async';
import 'dart:convert';

// Flutter imports:
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import '/core/models/editor_configs/pro_image_editor_configs.dart';
import '/core/models/history/state_history.dart';
import '/core/models/layers/layer.dart';
import '/core/platform/io/io_helper.dart';
import '/features/filter_editor/types/filter_matrix.dart';
import '/features/tune_editor/models/tune_adjustment_matrix.dart';
import '/shared/extensions/export_string_extension.dart';
import '/shared/extensions/num_extension.dart';
import '/shared/utils/decode_image.dart';
import '../content_recorder/controllers/content_recorder_controller.dart';
import 'constants/export_import_version.dart';
import 'enums/export_import_enum.dart';
import 'models/export_state_history_configs.dart';
import 'utils/key_minifier.dart';

/// Class responsible for exporting the state history of the editor.
///
/// This class allows you to export the state history of the editor,
/// including layers, filters, widgets, and other configurations.
class ExportStateHistory {
  /// Constructs an [ExportStateHistory] object with the given parameters.
  ExportStateHistory({
    required ProImageEditorConfigs editorConfigs,
    required List<EditorStateHistory> stateHistory,
    required ImageInfos imageInfos,
    required int editorPosition,
    required ContentRecorderController contentRecorderCtrl,
    required BuildContext context,
    ExportEditorConfigs configs = const ExportEditorConfigs(),
  })  : _configs = configs,
        _editorConfigs = editorConfigs,
        _stateHistory = stateHistory,
        _imageInfos = imageInfos,
        _contentRecorderCtrl = contentRecorderCtrl,
        _context = context,
        _editorPosition = editorPosition;

  /// The current position of the editor in the state history.
  ///
  /// This integer value represents the index of the editor's current state
  /// within the history, allowing for tracking and management of undo/redo
  /// actions.
  final int _editorPosition;

  /// The list of editor state history entries.
  ///
  /// This list contains [EditorStateHistory] objects representing each
  /// state of the editor, enabling navigation through different editing stages.
  final List<EditorStateHistory> _stateHistory;

  /// The controller for recording content changes.
  ///
  /// This [ContentRecorderController] is used to manage the recording and
  /// playback of content changes within the editor, allowing for precise
  /// capture of editing actions.
  late final ContentRecorderController _contentRecorderCtrl;

  /// The configuration settings for the image editor.
  ///
  /// This [ProImageEditorConfigs] object contains various configuration
  /// settings for the editor, influencing its behavior and appearance.
  final ProImageEditorConfigs _editorConfigs;

  /// The configuration settings for exporting the editor state.
  ///
  /// This [ExportEditorConfigs] object contains settings specific to the
  /// export process, influencing how the state history is exported.
  final ExportEditorConfigs _configs;

  /// Information about the image being edited.
  ///
  /// This [ImageInfos] object provides detailed information about the image,
  /// including metadata and transformation data.
  final ImageInfos _imageInfos;

  /// The build context of the editor.
  ///
  /// This [BuildContext] is used for widget building and accessing theme
  /// data within the editor, providing a connection to the widget tree.
  final BuildContext _context;

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
  /// the system's temporary directory with the default name
  /// 'editor_state_history.json'.
  Future<File> toFile({String? path}) async {
    assert(!kIsWeb, 'This function is not supported on the web.');

    // Get the system's temporary directory
    String tempDir = kIsWeb ? '' : Directory.systemTemp.path;

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

  /// Converts the state history to a Map.
  ///
  /// Returns a Map representing the state history of the editor,
  /// including layers, filters and other configurations.
  Future<Map<String, dynamic>> toMap() async {
    EditorKeyMinifier minifier = EditorKeyMinifier(
      enableMinify: _configs.enableMinify,
    );
    List<Map<String, dynamic>> history = [];
    List<Uint8List> widgetRecords = [];
    List<EditorStateHistory> changes = List.from(_stateHistory);

    if (changes.isNotEmpty) changes.removeAt(0);

    /// Helper function to collect history states up to a given position.
    EditorStateHistory accumulateHistory(int position) {
      FilterMatrix filters = [];
      List<TuneAdjustmentMatrix> tuneAdjustments = [];
      double? blur;
      TransformConfigs? transformConfigs;

      for (var item in changes.getRange(0, position)) {
        if (item.filters.isNotEmpty) filters.addAll(item.filters);
        if (item.blur != null) blur = item.blur;
        if (item.tuneAdjustments.isNotEmpty) {
          tuneAdjustments = item.tuneAdjustments;
        }
        if (item.transformConfigs != null) {
          transformConfigs = item.transformConfigs;
        }
      }

      return EditorStateHistory(
        blur: blur,
        filters: filters,
        layers: position <= 0 ? [] : changes[position - 1].layers,
        transformConfigs: transformConfigs,
        tuneAdjustments: tuneAdjustments,
      );
    }

    /// Choose history span
    switch (_configs.historySpan) {
      case ExportHistorySpan.current:
        changes = [accumulateHistory(_editorPosition)];
        break;
      case ExportHistorySpan.currentAndBackward:
        changes.removeRange(_editorPosition, changes.length);
        break;
      case ExportHistorySpan.currentAndForward:
        int position = _editorPosition;

        if (position != 0) {
          var history = accumulateHistory(position);
          changes.removeRange(0, position - 1);
          changes[0] = history;
        }
        break;
      case ExportHistorySpan.all:
        break;
    }

    Map<String, dynamic> references = {};
    Map<String, dynamic> lastLayerStateHelper = {};

    final int maxDecimalPlaces = _configs.maxDecimalPlaces;
    final bool enableMinify = _configs.enableMinify;

    /// Build Layers and filters
    for (EditorStateHistory element in changes) {
      List<Map<String, dynamic>> layers = await _convertLayers(
        element: element,
        widgetRecords: widgetRecords,
        imageInfos: _imageInfos,
        layerReferences: references,
        lastLayerStateHelper: lastLayerStateHelper,
      );

      layers = minifier.convertListOfLayerKeys(layers);

      Map<String, dynamic> transformConfigsMap =
          element.transformConfigs?.toMap(
                maxDecimalPlaces: maxDecimalPlaces,
                enableMinify: enableMinify,
              ) ??
              {};

      bool enableTuneExport =
          _configs.exportTuneAdjustments && element.tuneAdjustments.isNotEmpty;
      bool enableBlurExport = _configs.exportBlur && element.blur != null;
      bool enableFilterExport =
          _configs.exportFilter && element.filters.isNotEmpty;
      bool enableCropRotateExport =
          _configs.exportCropRotate && transformConfigsMap.isNotEmpty;

      history.add({
        if (layers.isNotEmpty) 'layers'.toHistoryKey(minifier): layers,
        if (enableFilterExport)
          'filters'.toHistoryKey(minifier): element.filters
              .map((item) => item
                  .map((value) => value.roundSmart(maxDecimalPlaces))
                  .toList())
              .toList(),
        if (enableTuneExport)
          'tune'.toHistoryKey(minifier): element.tuneAdjustments
              .where((item) => item.value != 0.0)
              .map((item) => item.toMap(maxDecimalPlaces: maxDecimalPlaces))
              .toList(),
        if (enableBlurExport) 'blur'.toHistoryKey(minifier): element.blur,
        if (enableCropRotateExport)
          'transform'.toHistoryKey(minifier): transformConfigsMap,
      });
    }
    references = minifier.convertReferenceKeys(references);

    var convertedLayer = minifier.convertLayerId(history, references);
    references = convertedLayer.references;
    history = convertedLayer.history;

    return {
      'version'.toMainKey(minifier): ExportImportVersion.latest,
      if (_configs.enableMinify) 'minify'.toMainKey(minifier): true,
      'position'.toMainKey(minifier):
          _configs.historySpan == ExportHistorySpan.current ||
                  _configs.historySpan == ExportHistorySpan.currentAndForward
              ? 0
              : _editorPosition - 1,
      if (history.isNotEmpty) 'history'.toMainKey(minifier): history,
      if (widgetRecords.isNotEmpty)
        'widgetRecords'.toMainKey(minifier): widgetRecords,
      if (references.isNotEmpty) 'references'.toMainKey(minifier): references,
      'imgSize'.toMainKey(minifier): {
        'width'.toSizeKey(minifier):
            _imageInfos.rawSize.width.roundSmart(maxDecimalPlaces),
        'height'.toSizeKey(minifier):
            _imageInfos.rawSize.height.roundSmart(maxDecimalPlaces),
      },
      'lastRenderedImgSize'.toMainKey(minifier): {
        'width'.toSizeKey(minifier):
            _imageInfos.originalRenderedSize.width.roundSmart(maxDecimalPlaces),
        'height'.toSizeKey(minifier): _imageInfos.originalRenderedSize.height
            .roundSmart(maxDecimalPlaces),
      },
    };
  }

  Future<List<Map<String, dynamic>>> _convertLayers({
    required EditorStateHistory element,
    required List<Uint8List?> widgetRecords,
    required ImageInfos imageInfos,
    required Map<String, dynamic> layerReferences,
    required Map<String, dynamic> lastLayerStateHelper,
  }) async {
    List<Map<String, dynamic>> convertedLayers = [];
    void updateReference(Layer layer, {int? recordPosition}) {
      if (recordPosition == null) {
        layerReferences[layer.id] ??= layer.toMap(
          maxDecimalPlaces: _configs.maxDecimalPlaces,
          enableMinify: _configs.enableMinify,
        );
      } else {
        layerReferences[layer.id] ??= (layer as WidgetLayer).toMap(
          recordPosition: recordPosition,
          maxDecimalPlaces: _configs.maxDecimalPlaces,
          enableMinify: _configs.enableMinify,
        );
      }
      convertedLayers.add(
        layer.toMapFromReference(lastLayerStateHelper[layer.id] ?? layer),
      );
    }

    for (var layer in element.layers) {
      if ((_configs.exportPaint && layer.isPaintLayer) ||
          (_configs.exportText && layer.isTextLayer) ||
          (_configs.exportEmoji && layer.isEmojiLayer)) {
        updateReference(layer);
      } else if (_configs.exportWidgets && layer.isWidgetLayer) {
        WidgetLayer widgetLayer = layer as WidgetLayer;

        if (widgetLayer.exportConfigs.hasParameter) {
          updateReference(widgetLayer);
        } else {
          /// Convert the widget to Uint8List in the case the user didn't add
          /// any export config parameter to restore the widget.
          updateReference(widgetLayer, recordPosition: widgetRecords.length);

          double imageWidth =
              (layer.width ?? _editorConfigs.stickerEditor.initWidth) *
                  layer.scale;

          Size targetSize = Size(
              imageWidth,
              MediaQuery.sizeOf(_context).height /
                  MediaQuery.sizeOf(_context).width *
                  imageWidth);

          Uint8List? result = await _contentRecorderCtrl.capture(
            widget: layer.widget,
            outputFormat: OutputFormat.png,
            imageInfos: imageInfos,
            targetSize: targetSize,
          );
          widgetRecords.add(result);
        }
      }

      lastLayerStateHelper[layer.id] = layer;
    }

    return convertedLayers;
  }
}
