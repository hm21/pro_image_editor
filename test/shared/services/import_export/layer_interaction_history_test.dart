import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:pro_image_editor/core/models/layers/layer_interaction.dart';
import 'package:pro_image_editor/pro_image_editor.dart';
import 'package:pro_image_editor/shared/services/content_recorder/controllers/content_recorder_controller.dart';
import 'package:pro_image_editor/shared/services/import_export/export_state_history.dart';

class _MockContentRecorderController extends Mock
    implements ContentRecorderController {}

class _MockBuildContext extends Mock implements BuildContext {}

/// The limits of a layer's interaction have to survive an export and import
/// of the history, and a step that changes one interaction setting must not
/// reset the others.
void main() {
  EmojiLayer layerWith(LayerInteraction interaction) => EmojiLayer(
    id: 'poll',
    emoji: '🙂',
    offset: const Offset(10, 20),
    interaction: interaction,
  );

  final steps = [
    LayerInteraction(enableRotate: false, minScale: 0.5, maxScale: 2),
    LayerInteraction(
      enableRotate: false,
      enableMove: false,
      minScale: 0.5,
      maxScale: 2,
    ),
    LayerInteraction(enableRotate: false, enableMove: false, minScale: 0.5),
  ];

  Future<ImportStateHistory> exportAndImport({
    required bool enableMinify,
  }) async {
    final exporter = ExportStateHistory(
      editorConfigs: const ProImageEditorConfigs(),
      stateHistory: [
        EditorStateHistory(layers: [], transformConfigs: null),
        for (final interaction in steps)
          EditorStateHistory(
            layers: [layerWith(interaction)],
            transformConfigs: null,
          ),
      ],
      imageInfos: const ImageInfos(
        rawSize: Size(100, 200),
        originalRenderedSize: Size(100, 200),
        renderedSize: Size(100, 200),
        cropRectSize: Size(100, 200),
        pixelRatio: 1,
        isRotated: false,
      ),
      editorPosition: steps.length,
      contentRecorderCtrl: _MockContentRecorderController(),
      context: _MockBuildContext(),
      configs: ExportEditorConfigs(
        enableMinify: enableMinify,
        historySpan: ExportHistorySpan.all,
      ),
    );
    return ImportStateHistory.fromJson(
      await exporter.toJson(),
      configs: const ImportEditorConfigs(),
    );
  }

  for (final enableMinify in [false, true]) {
    test('every history step keeps its interaction '
        '(minified: $enableMinify)', () async {
      final imported = await exportAndImport(enableMinify: enableMinify);

      final interactions = [
        for (final step in imported.stateHistory)
          if (step.layers.isNotEmpty) step.layers.single.interaction,
      ];
      expect(interactions, hasLength(steps.length));
      for (var i = 0; i < steps.length; i++) {
        final interaction = interactions[i];
        expect(interaction.enableMove, steps[i].enableMove, reason: 'step $i');
        expect(interaction.enableRotate, isFalse, reason: 'step $i');
        expect(interaction.minScale, steps[i].minScale, reason: 'step $i');
        expect(interaction.maxScale, steps[i].maxScale, reason: 'step $i');
        expect(interaction.bounds, isNull, reason: 'step $i');
      }
    });
  }

  test('a history stored without the limits loads without them', () {
    final imported = ImportStateHistory.fromMap({
      'version': '6.0.0',
      'position': 1,
      'imgSize': {'width': 100, 'height': 200},
      'lastRenderedImgSize': {'width': 100, 'height': 200},
      'references': {
        'poll': {
          'x': 10,
          'y': 20,
          'rotation': 0,
          'scale': 1,
          'flipX': false,
          'flipY': false,
          'interaction': {
            'enableMove': true,
            'enableScale': false,
            'enableRotate': false,
            'enableSelection': true,
            'enableEdit': true,
          },
          'type': 'emoji',
          'emoji': '🙂',
        },
      },
      'history': [
        {'layers': []},
        {
          'layers': [
            {'id': 'poll'},
          ],
        },
        {
          'layers': [
            {
              'id': 'poll',
              'interaction': {'enableMove': false},
            },
          ],
        },
      ],
    }, configs: const ImportEditorConfigs());

    final first = imported.stateHistory[1].layers.single.interaction;
    expect(first.enableScale, isFalse);
    expect(first.minScale, isNull);
    expect(first.maxScale, isNull);

    // Only the changed setting was stored for the last step; the others
    // carry over from the step before it.
    final last = imported.stateHistory[2].layers.single.interaction;
    expect(last.enableMove, isFalse);
    expect(last.enableScale, isFalse);
    expect(last.enableRotate, isFalse);
  });
}
