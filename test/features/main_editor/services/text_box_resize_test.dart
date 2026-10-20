import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:pro_image_editor/core/models/editor_configs/pro_image_editor_configs.dart';
import 'package:pro_image_editor/core/models/layers/layer.dart';
import 'package:pro_image_editor/features/main_editor/services/layer_interaction_manager.dart';

void main() {
  // The layers the editor shows, which the resize looks its layer up in.
  late List<Layer> shown;

  LayerInteractionManager manager() => LayerInteractionManager(
    helperLinesCallbacks: null,
    configs: const ProImageEditorConfigs(
      textEditor: TextEditorConfigs(layerFractionalOffset: Offset.zero),
    ),
    onSelectedLayersChanged: null,
  );

  TextLayer boxedLayer() {
    final layer = TextLayer(
      text: 'Name',
      offset: const Offset(10, 20),
      scale: 2,
      box: const TextLayerBox(size: Size(100, 40)),
    );
    shown = [layer];
    return layer;
  }

  void drag(LayerInteractionManager manager, Offset to, {double zoom = 1}) {
    manager.calculateTextBoxResize(
      details: ScaleUpdateDetails(focalPoint: to),
      editorScaleFactor: zoom,
      layers: shown,
    );
  }

  group('LayerInteractionManager text box resize', () {
    test('resizes from where the drag started', () {
      final layer = boxedLayer();
      final interactions = manager()
        ..startTextBoxResize(layer, TextLayerBoxHandle.bottomRight);

      expect(interactions.isResizingTextBox, isTrue);
      drag(interactions, const Offset(300, 300));
      expect(layer.box!.size, const Size(100, 40));

      drag(interactions, const Offset(320, 310));
      expect(layer.box!.size, const Size(110, 45));
      expect(layer.offset, const Offset(10, 20));
      expect(layer.scale, 2);
    });

    test('measures the drag on the canvas, not on the zoomed screen', () {
      final layer = boxedLayer();
      final interactions = manager()
        ..startTextBoxResize(layer, TextLayerBoxHandle.right);

      drag(interactions, const Offset(100, 0), zoom: 2);
      drag(interactions, const Offset(140, 0), zoom: 2);

      expect(layer.box!.size, const Size(110, 40));
    });

    test('keeps the alignment and overflow of the box', () {
      final layer = boxedLayer()
        ..box = const TextLayerBox(
          size: Size(100, 40),
          verticalAlign: TextLayerBoxVerticalAlign.center,
          overflow: TextLayerBoxOverflow.shrink,
        );
      final interactions = manager()
        ..startTextBoxResize(layer, TextLayerBoxHandle.right);

      drag(interactions, Offset.zero);
      drag(interactions, const Offset(20, 0));

      expect(layer.box!.verticalAlign, TextLayerBoxVerticalAlign.center);
      expect(layer.box!.overflow, TextLayerBoxOverflow.shrink);
    });

    test('resizes the copy the history step shows, by id', () {
      final layer = boxedLayer();
      final interactions = manager()
        ..startTextBoxResize(layer, TextLayerBoxHandle.right);
      // The gesture's history step replaces the shown layer with a copy.
      final copy = layer.copyWith();
      shown = [copy];

      drag(interactions, Offset.zero);
      drag(interactions, const Offset(20, 0));

      expect(copy.box!.size, const Size(110, 40));
      expect(layer.box!.size, const Size(100, 40));
    });

    test('measures from where the handle was pressed', () {
      final layer = boxedLayer();
      final interactions = manager()
        ..startTextBoxResize(
          layer,
          TextLayerBoxHandle.right,
          pointerPosition: const Offset(300, 0),
        );

      drag(interactions, const Offset(320, 0));

      expect(layer.box!.size, const Size(110, 40));
    });

    test('ignores a layer without a box', () {
      final layer = TextLayer(text: 'Free');
      final interactions = manager()
        ..startTextBoxResize(layer, TextLayerBoxHandle.right);

      expect(interactions.isResizingTextBox, isFalse);
    });

    test('stops resizing once ended', () {
      final layer = boxedLayer();
      final interactions = manager()
        ..startTextBoxResize(layer, TextLayerBoxHandle.right)
        ..endTextBoxResize();

      expect(interactions.isResizingTextBox, isFalse);
      drag(interactions, Offset.zero);
      drag(interactions, const Offset(20, 0));
      expect(layer.box!.size, const Size(100, 40));
    });
  });
}
