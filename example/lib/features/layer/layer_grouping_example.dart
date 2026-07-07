import 'package:example/core/constants/example_constants.dart';
import 'package:flutter/material.dart';
import 'package:pro_image_editor/pro_image_editor.dart';
import 'package:pro_image_editor/shared/widgets/layer/interaction_helper/layer_interaction_button.dart';

import '/core/mixin/example_helper.dart';

/// The example for layer grouping.
class LayerGroupingExample extends StatefulWidget {
  /// Creates a new [LayerGroupingExample] widget.
  const LayerGroupingExample({super.key});

  @override
  State<LayerGroupingExample> createState() => _LayerGroupingExampleState();
}

class _LayerGroupingExampleState extends State<LayerGroupingExample>
    with ExampleHelperState<LayerGroupingExample> {
  @override
  void initState() {
    super.initState();
    preCacheImage(assetPath: kImageEditorExampleAssetPath);
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

  final _layerInteractionConfigs = LayerInteractionConfigs(
    enableLayerDragSelection: true,
    enableLongPressMultiSelection: true,
    selectable: LayerInteractionSelectable.enabled,
    widgets: LayerInteractionWidgets(
      children: [
        (rebuildStream, layer, interactions) => ReactiveWidget(
              stream: rebuildStream,
              builder: (_) => layer.isPaintLayer || layer.isTextLayer
                  ? Positioned(
                      top: 0,
                      left: 0,
                      child: Transform.rotate(
                        angle: -layer.rotation,
                        child: MouseRegion(
                          cursor: SystemMouseCursors.click,
                          child: Listener(
                            child: GestureDetector(
                              onTap: interactions.edit,
                              child: Tooltip(
                                message: 'Edit',
                                child: Container(
                                  padding: const EdgeInsets.all(3),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10 * 2),
                                    color: Colors.white,
                                  ),
                                  child: const Icon(
                                    Icons.edit,
                                    color: Colors.black,
                                    size: 10 * 2,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
        (rebuildStream, layer, interactions) => ReactiveWidget(
              stream: rebuildStream,
              builder: (_) => Positioned(
                top: 0,
                right: 0,
                child: LayerInteractionButton(
                  rotation: -layer.rotation,
                  onTap: interactions.remove,
                  buttonRadius: 10,
                  cursor: SystemMouseCursors.click,
                  icon: Icons.clear,
                  tooltip: 'Remove',
                  color: Colors.black,
                  background: Colors.white,
                ),
              ),
            ),
        (rebuildStream, layer, interactions) => ReactiveWidget(
              stream: rebuildStream,
              builder: (_) => Positioned(
                bottom: 0,
                right: 0,
                child: LayerInteractionButton(
                  rotation: -layer.rotation,
                  onScaleRotateDown: interactions.scaleRotateDown,
                  onScaleRotateUp: interactions.scaleRotateUp,
                  buttonRadius: 10,
                  cursor: SystemMouseCursors.click,
                  icon: Icons.sync,
                  tooltip: 'Rotate and Scale',
                  color: Colors.black,
                  background: Colors.white,
                ),
              ),
            ),
        (rebuildStream, layer, interactions) => ReactiveWidget(
              stream: rebuildStream,
              builder: (_) => Positioned(
                bottom: 0,
                left: 0,
                child: LayerInteractionButton(
                  rotation: -layer.rotation,
                  onTap: () {
                    if (layer.groupId != null) {
                      interactions.ungroup();
                    } else {
                      interactions.group();
                    }
                  },
                  buttonRadius: 10,
                  cursor: SystemMouseCursors.click,
                  icon: layer.groupId == null ? Icons.group : Icons.group_off,
                  tooltip: layer.groupId == null ? 'Group' : 'Ungroup',
                  color: Colors.black,
                  background: Colors.white,
                ),
              ),
            ),
      ],
    ),
  );

  @override
  Widget build(BuildContext context) {
    if (!isPreCached) return const PrepareImageWidget();

    return ProImageEditor.asset(
      kImageEditorExampleAssetPath,
      key: editorKey,
      callbacks: _callbacks,
      configs: ProImageEditorConfigs(
        layerInteraction: _layerInteractionConfigs,
        mainEditor: MainEditorConfigs(
            mobilePanInteraction: MobilePanInteraction.dragSelect,
            widgets: MainEditorWidgets(
              bodyItems: (editor, rebuildStream) => [
                ReactiveWidget(
                  builder: (_) => _buildActionButtons(editor),
                  stream: rebuildStream,
                ),
              ],
            )),
      ),
    );
  }

  Widget _buildActionButtons(ProImageEditorState editor) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 12,
          children: [
            FilledButton(
              onPressed: () {
                editor.enableMultiSelectMode = !editor.enableMultiSelectMode;
              },
              child: Text(
                editor.enableMultiSelectMode
                    ? 'Selection-Mode'
                    : 'Default-Mode',
              ),
            ),
            FilledButton(
              onPressed: editor.selectAllLayers,
              child: const Text('Select All'),
            ),
            FilledButton(
              onPressed: editor.unselectAllLayers,
              child: const Text('Unselect All'),
            ),
            FilledButton(
              // Combine the selected paint layers into a single paint layer.
              // Disabled unless at least two non-censor paint layers are
              // selected.
              onPressed: editor.canMergeSelectedLayers
                  ? () => editor.mergeSelectedLayers()
                  : null,
              child: const Text('Combine Paint Layers'),
            ),
          ],
        ),
      ),
    );
  }
}
