import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:pro_image_editor/core/platform/io/io_helper.dart' show File;
import 'package:pro_image_editor/pro_image_editor.dart';
import 'package:pro_image_editor/shared/services/import_export/constants/export_import_version.dart';
import 'package:pro_image_editor/shared/services/import_export/utils/key_minifier.dart';

import 'constants/history_mock/mock_import_history_6_0_0.dart';
import 'constants/history_mock/mock_import_history_6_0_0_minified.dart';

void main() {
  group('ImportStateHistory', () {
    test('fromJsonFile parses JSON and returns ImportStateHistory', () async {
      final json = const JsonEncoder().convert(kMockHistory_6_0_0);

      final tempDir = Directory.systemTemp.createTempSync();
      final tempFile = File('${tempDir.path}/test.json');
      await tempFile.writeAsString(json);

      final result = ImportStateHistory.fromJsonFile(tempFile);
      await tempFile.delete();

      expect(result, isA<ImportStateHistory>());
      expect(result.editorPosition, 7);
      expect(result.version, '6.0.0');
      expect(result.imgSize, const Size(1024.0, 1792.0));
      expect(result.lastRenderedImgSize, const Size(327.0, 572.0));
      expect(result.stateHistory.length, 8);
      expect(result.stateHistory.first.blur, 2.0);
      expect(result.stateHistory.first.layers.length, 1);
    });

    test('fromJson parses JSON string and returns ImportStateHistory', () {
      final json = const JsonEncoder().convert(kMockHistory_6_0_0);

      final result = ImportStateHistory.fromJson(json);

      expect(result.editorPosition, 7);
      expect(result.version, '6.0.0');
      expect(result.imgSize, const Size(1024.0, 1792.0));
      expect(result.lastRenderedImgSize, const Size(327.0, 572.0));
      expect(result.stateHistory.length, 8);
      expect(result.stateHistory.first.blur, 2.0);
    });

    test('fromMap with minified keys', () {
      final result = ImportStateHistory.fromMap(kMockHistoryMinified_6_0_0);

      expect(result.version, '6.0.0');
      expect(result.editorPosition, 7);
      expect(result.imgSize, const Size(1024.0, 1792.0));
      expect(result.lastRenderedImgSize, const Size(385.0, 674.0));
      expect(result.stateHistory.length, 8);
      expect(result.stateHistory.first.blur, 2.0);
    });

    test('parse filters for version 1.0.0', () {
      final filtersData = [
        {
          'filters': [ColorFilterAddons.brightness(0.5)],
          'opacity': 0.5,
        },
      ];
      final result = ImportStateHistory.parseFilters(filtersData, '1.0.0');
      expect(result.length, 1);
      expect(result[0].length, 20);
    });

    test('parse filters for version 5.0.0', () {
      final filtersData = [ColorFilterAddons.brightness(0.5)];
      final result = ImportStateHistory.parseFilters(filtersData, '5.0.0');
      expect(result, filtersData);
    });

    test('parse widget records for version 1.0.0', () {
      final map = {
        'stickers': [
          [1, 2, 3],
        ],
      };
      final result = ImportStateHistory.parseWidgetRecords(
        map,
        '1.0.0',
        EditorKeyMinifier(enableMinify: false),
      );
      expect(result, [
        Uint8List.fromList([1, 2, 3]),
      ]);
    });

    test('parse widget records for version 5.0.0', () {
      final map = {
        'widgetRecords': [
          [4, 5, 6],
        ],
      };
      final result = ImportStateHistory.parseWidgetRecords(
        map,
        '5.0.0',
        EditorKeyMinifier(enableMinify: false),
      );
      expect(result, [
        Uint8List.fromList([4, 5, 6]),
      ]);
    });

    group('paint strokes across history steps', () {
      Map<String, dynamic> stroke(double x) => {
        'mode': 'freeStyle',
        'offsets': [
          {'x': x, 'y': 0},
          {'x': x + 1, 'y': 1},
        ],
        'erasedOffsets': <Map<String, dynamic>>[],
        'color': 0xFFFF0000,
        'strokeWidth': 4,
        'opacity': 1,
      };

      Map<String, dynamic> historyMap(List<Map<String, dynamic>> stepLayers) =>
          {
            'version': ExportImportVersion.latest,
            'position': stepLayers.length - 1,
            'references': {
              'drawing': {
                'id': 'drawing',
                'type': 'paint',
                'opacity': 1,
                'rawSize': {'w': 10, 'h': 10},
                'item': stroke(0),
                'items': [stroke(0), stroke(5)],
              },
            },
            'history': [
              for (final layer in stepLayers)
                {
                  'layers': [layer],
                },
            ],
          };

      ImportStateHistory importSteps(List<Map<String, dynamic>> stepLayers) =>
          ImportStateHistory.fromMap(historyMap(stepLayers));

      List<PaintedModel> strokesOf(ImportStateHistory history, int step) =>
          (history.stateHistory[step].layers.single as PaintLayer).items;

      test('steps that keep the strokes share their points', () {
        final history = importSteps([
          {'id': 'drawing'},
          {'id': 'drawing', 'x': 4},
          {'id': 'drawing', 'x': 8},
        ]);

        for (var step = 1; step < 3; step++) {
          for (var i = 0; i < 2; i++) {
            expect(
              identical(
                strokesOf(history, step)[i].offsets,
                strokesOf(history, 0)[i].offsets,
              ),
              isTrue,
            );
          }
        }
      });

      test('each step still holds strokes of its own', () {
        final history = importSteps([
          {'id': 'drawing'},
          {'id': 'drawing', 'x': 4},
        ]);

        expect(
          identical(strokesOf(history, 1).first, strokesOf(history, 0).first),
          isFalse,
        );
      });

      test('a step that rewrites the strokes reads its own points', () {
        final history = importSteps([
          {'id': 'drawing'},
          {
            'id': 'drawing',
            'items': [stroke(20)],
          },
        ]);

        expect(strokesOf(history, 0), hasLength(2));
        expect(strokesOf(history, 1), hasLength(1));
        expect(strokesOf(history, 1).first.offsets.first, const Offset(20, 0));
      });

      test('a map changed in place is read again by the next import', () {
        final map = historyMap([
          {'id': 'drawing'},
        ]);
        ImportStateHistory.fromMap(map);
        final reference = map['references']['drawing'] as Map<String, dynamic>;
        (reference['items'] as List)[0] = stroke(30);

        final history = ImportStateHistory.fromMap(map);

        expect(strokesOf(history, 0).first.offsets.first, const Offset(30, 0));
      });
    });
  });
}
