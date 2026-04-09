import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:pro_image_editor/core/constants/int_constants.dart';
import 'package:pro_image_editor/core/models/editor_configs/pro_image_editor_configs.dart';
import 'package:pro_image_editor/core/models/history/state_history.dart';
import 'package:pro_image_editor/core/models/layers/layer.dart';
import 'package:pro_image_editor/features/filter_editor/filter_editor.dart';
import 'package:pro_image_editor/shared/services/content_recorder/controllers/content_recorder_controller.dart';
import 'package:pro_image_editor/shared/services/import_export/enums/export_import_enum.dart';
import 'package:pro_image_editor/shared/services/import_export/export_state_history.dart';
import 'package:pro_image_editor/shared/services/import_export/models/export_state_history_configs.dart';
import 'package:pro_image_editor/shared/services/import_export/utils/key_minifier.dart';
import 'package:pro_image_editor/shared/utils/decode_image.dart';

class MockContentRecorderController extends Mock
    implements ContentRecorderController {}

class MockBuildContext extends Mock implements BuildContext {}

class DummyLayer extends Layer {
  DummyLayer(String id) : super(id: id, scale: 1.0);

  @override
  Map<String, dynamic> toMap({
    int maxDecimalPlaces = kMaxSafeDecimalPlaces,
    bool enableMinify = false,
  }) => {'id': id, 'scale': scale};

  @override
  Map<String, dynamic> toMapFromReference(
    Layer reference, {
    int maxDecimalPlaces = kMaxSafeDecimalPlaces,
    bool enableMinify = false,
  }) => toMap();
}

void main() {
  group('ExportStateHistory', () {
    late ProImageEditorConfigs editorConfigs;
    late List<EditorStateHistory> stateHistory;
    late ImageInfos imageInfos;
    late int editorPosition;
    late MockContentRecorderController contentRecorderCtrl;
    late MockBuildContext context;

    setUp(() {
      editorConfigs = const ProImageEditorConfigs();
      stateHistory = [
        EditorStateHistory(
          blur: null,
          layers: [],
          transformConfigs: null,
          tuneAdjustments: [],
        ),
        EditorStateHistory(
          blur: 2.0,
          filters: [FilterState(matrices: presetFiltersList.first.filters)],
          layers: [DummyLayer('layer1')],
          transformConfigs: null,
        ),
      ];
      imageInfos = const ImageInfos(
        rawSize: Size(100, 200),
        originalRenderedSize: Size(50, 100),
        renderedSize: Size(100, 200),
        cropRectSize: Size(100, 200),
        pixelRatio: 1,
        isRotated: false,
      );
      editorPosition = 1;
      contentRecorderCtrl = MockContentRecorderController();
      context = MockBuildContext();
    });

    test('toJson returns valid JSON string', () async {
      final exporter = ExportStateHistory(
        editorConfigs: editorConfigs,
        stateHistory: stateHistory,
        imageInfos: imageInfos,
        editorPosition: editorPosition,
        contentRecorderCtrl: contentRecorderCtrl,
        context: context,
        configs: const ExportEditorConfigs(enableMinify: false),
      );
      final json = await exporter.toJson();
      expect(json, isA<String>());
      expect(json, contains('version'));
    });

    test('toMap returns correct structure', () async {
      final exporter = ExportStateHistory(
        editorConfigs: editorConfigs,
        stateHistory: stateHistory,
        imageInfos: imageInfos,
        editorPosition: editorPosition,
        contentRecorderCtrl: contentRecorderCtrl,
        context: context,
        configs: const ExportEditorConfigs(enableMinify: false),
      );
      final map = await exporter.toMap();
      expect(map, isA<Map<String, dynamic>>());
      expect(map.containsKey('version'), isTrue);
      expect(map.containsKey('history'), isTrue);
      expect(map['imgSize'], isA<Map<dynamic, dynamic>>());
      expect(map['lastRenderedImgSize'], isA<Map<dynamic, dynamic>>());
    });

    test('toMap respects ExportHistorySpan.current', () async {
      final exporter = ExportStateHistory(
        editorConfigs: editorConfigs,
        stateHistory: stateHistory,
        imageInfos: imageInfos,
        editorPosition: editorPosition,
        contentRecorderCtrl: contentRecorderCtrl,
        context: context,
        configs: const ExportEditorConfigs(
          historySpan: ExportHistorySpan.current,
          enableMinify: false,
        ),
      );
      final map = await exporter.toMap();
      expect(map['position'], 0);
      expect((map['history'] as List).length, 1);
    });

    test('toMap respects ExportHistorySpan.all', () async {
      final exporter = ExportStateHistory(
        editorConfigs: editorConfigs,
        stateHistory: stateHistory,
        imageInfos: imageInfos,
        editorPosition: editorPosition,
        contentRecorderCtrl: contentRecorderCtrl,
        context: context,
        configs: const ExportEditorConfigs(
          historySpan: ExportHistorySpan.all,
          enableMinify: false,
        ),
      );
      final map = await exporter.toMap();
      expect((map['history'] as List).length, stateHistory.length - 1);
    });

    test('toMap with minify enabled', () async {
      final exporter = ExportStateHistory(
        editorConfigs: editorConfigs,
        stateHistory: stateHistory,
        imageInfos: imageInfos,
        editorPosition: editorPosition,
        contentRecorderCtrl: contentRecorderCtrl,
        context: context,
        configs: const ExportEditorConfigs(enableMinify: true),
      );
      final map = await exporter.toMap();
      final minifier = EditorKeyMinifier(enableMinify: true);

      expect(map.containsKey(minifier.convertMainKey('minify')), isTrue);
      expect(map.containsKey(minifier.convertMainKey('version')), isTrue);
      expect(map.containsKey(minifier.convertMainKey('history')), isTrue);
    });
  });
}
