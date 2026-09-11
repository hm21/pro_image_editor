import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:pro_image_editor/pro_image_editor.dart';

import '../../../mock/layers/emoji_layer_mock.dart';
import '../../../mock/layers/paint_layer_mock.dart';
import '../../../mock/layers/text_layer_mock.dart';
import '../../../mock/layers/widget_layer_mock.dart';
import '../../../mock/mock_image.dart';

void main() {
  const exportConfigs = ExportEditorConfigs(
    enableMinify: true,
    historySpan: ExportHistorySpan.current,
    maxDecimalPlaces: 16,
  );
  final importConfigs = ImportEditorConfigs(
    mergeMode: ImportEditorMergeMode.replace,
    widgetLoader: (id, {meta}) {
      if (id == 'widget-mock-container') {
        return widgetLayerMock.widget;
      }
      return Container();
    },
  );

  Future<ProImageEditorState> pumpTestEditor(
    WidgetTester tester, {
    ProImageEditorConfigs configs = const ProImageEditorConfigs(
      progressIndicatorConfigs: ProgressIndicatorConfigs(
        widgets: ProgressIndicatorWidgets(
          circularProgressIndicator: SizedBox.shrink(),
        ),
      ),
      imageGeneration: ImageGenerationConfigs(
        enableBackgroundGeneration: false,
        enableIsolateGeneration: false,
      ),
    ),
    ProImageEditorCallbacks callbacks = const ProImageEditorCallbacks(),
  }) async {
    final key = GlobalKey<ProImageEditorState>();

    await tester.pumpWidget(
      MaterialApp(
        home: ProImageEditor.memory(
          mockMemoryImage,
          key: key,
          configs: configs,
          callbacks: callbacks,
        ),
      ),
    );

    expect(find.byType(ProImageEditor), findsOneWidget);
    return key.currentState!;
  }

  Future<void> runExportImport(
    ProImageEditorState editor, {
    Function()? onAfterImport,
  }) async {
    // Export current state
    final history = await editor.exportStateHistory(configs: exportConfigs);
    final historyJson = await history.toJson();

    // Import the exported state
    final importHistory = ImportStateHistory.fromJson(
      historyJson,
      configs: importConfigs,
    );

    onAfterImport?.call();

    await editor.importStateHistory(importHistory);
  }

  group('ProImageEditor import/export', () {
    testWidgets('restores all layers correctly after export/import', (
      WidgetTester tester,
    ) async {
      await tester.runAsync(() async {
        final editor = await pumpTestEditor(tester);

        // Add one of each layer type
        editor
          ..addLayer(emojiLayerMock)
          ..addLayer(textLayerMock)
          ..addLayer(paintLayerMock)
          ..addLayer(widgetLayerMock);

        expect(editor.activeLayers.length, 4);
        expect(editor.stateManager.historyPointer, 4);

        await runExportImport(
          editor,
          onAfterImport: () {
            editor.removeAllLayers();
            expect(editor.activeLayers.length, 0);
          },
        );

        expect(editor.activeLayers.length, 4);
        expect(editor.stateManager.historyPointer, 1);
      });
    });

    testWidgets('restores blur correctly after export/import', (
      WidgetTester tester,
    ) async {
      await tester.runAsync(() async {
        final editor = await pumpTestEditor(tester);

        const blurFactor = 7.0;
        editor.addHistory(blur: blurFactor);

        expect(editor.stateManager.activeBlur, blurFactor);
        expect(editor.stateManager.historyPointer, 1);

        await runExportImport(
          editor,
          onAfterImport: () {
            editor.addHistory(blur: 1);
            expect(editor.stateManager.activeBlur, 1);
          },
        );

        expect(editor.stateManager.activeBlur, blurFactor);
        expect(editor.stateManager.historyPointer, 1);
      });
    });

    testWidgets('restores filters correctly after export/import', (
      WidgetTester tester,
    ) async {
      await tester.runAsync(() async {
        final editor = await pumpTestEditor(tester);

        final testFilters = PresetFilters.addictiveRed.filters;
        editor.addHistory(
          filters: [FilterState(name: 'filter', matrices: testFilters)],
        );

        expect(editor.stateManager.activeFilters.allMatrices, testFilters);
        expect(editor.stateManager.historyPointer, 1);

        await runExportImport(
          editor,
          onAfterImport: () {
            editor.addHistory(filters: const []);
            expect(editor.stateManager.activeFilters.allMatrices.length, 0);
          },
        );

        expect(editor.stateManager.activeFilters.allMatrices, testFilters);
        expect(editor.stateManager.historyPointer, 1);
      });
    });

    testWidgets('restores tune-adjustments correctly after export/import', (
      WidgetTester tester,
    ) async {
      await tester.runAsync(() async {
        final editor = await pumpTestEditor(tester);

        final tuneMatrix = TuneAdjustmentMatrix(
          id: 'brightness',
          value: 10,
          matrix: ColorFilterAddons.brightness(10),
        );

        editor.addHistory(tuneAdjustments: [tuneMatrix.copy()]);

        expect(editor.stateManager.activeTuneAdjustments, [tuneMatrix.copy()]);
        expect(editor.stateManager.historyPointer, 1);

        await runExportImport(
          editor,
          onAfterImport: () {
            editor.addHistory(tuneAdjustments: []);
            expect(editor.stateManager.activeTuneAdjustments.length, 0);
          },
        );

        expect(editor.stateManager.activeTuneAdjustments, [tuneMatrix.copy()]);
        expect(editor.stateManager.historyPointer, 1);
      });
    });

    testWidgets('restores transformations correctly after export/import', (
      WidgetTester tester,
    ) async {
      await tester.runAsync(() async {
        final editor = await pumpTestEditor(tester);

        final transformConfigs = TransformConfigs(
          angle: pi / 2,
          cropRect: Rect.zero,
          originalSize: Size.zero,
          cropEditorScreenRatio: 0,
          scaleUser: 1,
          scaleRotation: 1,
          aspectRatio: 1,
          flipX: false,
          flipY: false,
          offset: Offset.zero,
        );

        editor.addHistory(transformConfigs: transformConfigs);

        expect(editor.stateManager.transformConfigs, transformConfigs);
        expect(editor.stateManager.historyPointer, 1);

        await runExportImport(
          editor,
          onAfterImport: () {
            editor.addHistory(transformConfigs: TransformConfigs.empty());
            expect(editor.stateManager.transformConfigs.isEmpty, isTrue);
          },
        );

        expect(editor.stateManager.transformConfigs, transformConfigs);
        expect(editor.stateManager.historyPointer, 1);
      });
    });

    testWidgets(
      'rescales a slide animation\'s start point with the offset when the '
      'history was recorded at another size',
      (WidgetTester tester) async {
        await tester.runAsync(() async {
          final editor = await pumpTestEditor(tester);

          const slideFrom = Offset(50, 100);
          editor.addLayer(
            TextLayer(
              text: 'slides in',
              offset: const Offset(20, 40),
              animations: const [
                LayerAnimation(
                  type: LayerAnimationType.slide,
                  phase: AnimationPhase.animateIn,
                  duration: Duration(milliseconds: 400),
                  slideFrom: slideFrom,
                ),
              ],
            ),
          );

          final history = await editor.exportStateHistory(
            configs: const ExportEditorConfigs(
              enableMinify: false,
              historySpan: ExportHistorySpan.current,
            ),
          );
          final map = await history.toMap();
          // Pretend the history was recorded on a canvas half this size, so
          // the import has to scale every layer up by 2 on both axes.
          final recorded = map['lastRenderedImgSize'] as Map<String, dynamic>;
          map['lastRenderedImgSize'] = {
            'width': (recorded['width'] as num) / 2,
            'height': (recorded['height'] as num) / 2,
          };

          editor.removeAllLayers();
          await editor.importStateHistory(
            ImportStateHistory.fromMap(map, configs: importConfigs),
          );

          final imported = editor.activeLayers.single;
          expect(imported.offset, const Offset(40, 80));
          expect(imported.animations.single.slideFrom, slideFrom * 2);
        });
      },
    );
  });
}
