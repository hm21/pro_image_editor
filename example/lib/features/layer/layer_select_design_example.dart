import 'package:material_ui/material_ui.dart';
import 'package:pro_image_editor/designs/layer_selection/float_select/float_select.dart';
import 'package:pro_image_editor/pro_image_editor.dart';

import '/core/mixin/example_helper.dart';

/// The example for custom layer selection designs.
class LayerSelectDesignExample extends StatefulWidget {
  /// Creates a new [LayerSelectDesignExample] widget.
  const LayerSelectDesignExample({super.key});

  @override
  State<LayerSelectDesignExample> createState() =>
      _LayerSelectDesignExampleState();
}

class _LayerSelectDesignExampleState extends State<LayerSelectDesignExample>
    with ExampleHelperState<LayerSelectDesignExample> {
  final _imageUrl = 'https://picsum.photos/id/19/2000';

  @override
  void initState() {
    super.initState();
    preCacheImage(networkUrl: _imageUrl);
  }

  late final _callbacks = ProImageEditorCallbacks(
    onImageEditingStarted: onImageEditingStarted,
    onImageEditingComplete: onImageEditingComplete,
    onCloseEditor: (editorMode) => onCloseEditor(
      editorMode: editorMode,
      enablePop: !isDesktopMode(context),
    ),
    mainEditorCallbacks: MainEditorCallbacks(
      helperLines: HelperLinesCallbacks(onLineHit: vibrateLineHit),
    ),
  );

  late final _configs = ProImageEditorConfigs(
    mainEditor: MainEditorConfigs(
      widgets: MainEditorWidgets(
        /// Hide the default "remove-Area" cuz the overlay includes a delete
        /// button.
        removeLayerArea: (_, __, ___, ____) => const SizedBox.shrink(),
      ),
    ),
    layerInteraction: LayerInteractionConfigs(
      selectable: LayerInteractionSelectable.enabled,
      widgets: LayerInteractionWidgets(
        overlayChildBuilder: (rebuildStream, info, layer, interactions) {
          return ReactiveWidget(
            stream: rebuildStream,
            builder: (_) => FloatSelectionOverlay(
              info: info,
              layer: layer,
              interactions: interactions,
              editorKey: editorKey,
              safeArea: MediaQuery.viewPaddingOf(context),
              configs: const FloatSelectConfigs(

                  /// style: const FloatSelectStyle(),
                  /// i18n: const FloatSelectI18n(),
                  /// widgets: const FloatSelectWidgets(),
                  /// enableEditButton: true,
                  /// enableForwardButton: false,
                  /// enableBackwardButton: false,
                  /// enableMoveToFrontButton: false,
                  /// enableMoveToBackButton: false,
                  /// enableDuplicateButton: true,
                  /// enableDeleteButton: true,
                  ),
            ),
          );
        },
      ),
    ),
  );

  @override
  Widget build(BuildContext context) {
    if (!isPreCached) return const PrepareImageWidget();

    return ProImageEditor.network(
      _imageUrl,
      key: editorKey,
      callbacks: _callbacks,
      configs: _configs,
    );
  }
}
