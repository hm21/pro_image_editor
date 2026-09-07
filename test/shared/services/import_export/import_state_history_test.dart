import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:pro_image_editor/core/platform/io/io_helper.dart' show File;
import 'package:pro_image_editor/pro_image_editor.dart';
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
  });
}
