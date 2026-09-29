import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:pro_image_editor/core/models/editor_configs/pro_image_editor_configs.dart';
import 'package:pro_image_editor/core/models/layers/layer.dart';
import 'package:pro_image_editor/features/main_editor/services/layer_copy_manager.dart';
import 'package:pro_image_editor/features/main_editor/services/layer_interaction_manager.dart';

void main() {
  TextLayer outlinedLayer() => TextLayer(
    text: 'Outlined',
    outlineWidth: 2.5,
    outlineColor: const Color(0xFFFF0000),
    textStyle: const TextStyle(
      shadows: [Shadow(blurRadius: 4, offset: Offset(1, 2))],
    ),
  );

  group(LayerCopyManager, () {
    test('keeps the outline and shadows of a text layer', () {
      final layer = outlinedLayer();

      final copy = LayerCopyManager().copyLayer(layer) as TextLayer;

      expect(copy, isNot(same(layer)));
      expect(copy.outlineWidth, 2.5);
      expect(copy.outlineColor, const Color(0xFFFF0000));
      expect(copy.textStyle?.shadows, layer.textStyle?.shadows);
    });
  });

  group(LayerInteractionManager, () {
    test('keeps the outline of a text layer it groups', () {
      final layer = outlinedLayer();
      final other = TextLayer(text: 'Other');
      final manager =
          LayerInteractionManager(
              helperLinesCallbacks: null,
              configs: const ProImageEditorConfigs(),
              onSelectedLayersChanged: null,
            )
            ..addSelectedLayer(layer.id)
            ..addSelectedLayer(other.id);

      List<Layer>? history;
      manager.groupSelectedLayers([layer, other], (layers) => history = layers);

      final grouped = history!.whereType<TextLayer>().firstWhere(
        (candidate) => candidate.id == layer.id,
      );
      expect(grouped.groupId, isNotNull);
      expect(grouped.outlineWidth, 2.5);
      expect(grouped.outlineColor, const Color(0xFFFF0000));
    });
  });
}
