import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:pro_image_editor/models/layer.dart';
import 'package:pro_image_editor/modules/paint_editor/utils/draw/draw_canvas.dart';
import 'package:pro_image_editor/pro_image_editor.dart';

import '../utils/example_helper.dart';

class SelectableLayerExample extends StatefulWidget {
  const SelectableLayerExample({super.key});

  @override
  State<SelectableLayerExample> createState() => _SelectableLayerExampleState();
}

class _SelectableLayerExampleState extends State<SelectableLayerExample>
    with ExampleHelperState<SelectableLayerExample> {
  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () async {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                LayoutBuilder(builder: (context, constraints) {
              return _buildEditor();
            }),
          ),
        );
      },
      leading: const Icon(Icons.select_all_outlined),
      title: const Text('Selectable layer'),
      trailing: const Icon(Icons.chevron_right),
    );
  }

  Widget _buildEditor() {
    return ProImageEditor.asset(
      'assets/demo.png',
      key: editorKey,
      onImageEditingComplete: onImageEditingComplete,
      onCloseEditor: onCloseEditor,
      configs: const ProImageEditorConfigs(
        layerInteraction: LayerInteraction(
          /// Choose between `auto`, `enabled` and `disabled`.
          ///
          /// Mode `auto`:
          /// Automatically determines if the layer is selectable based on the device type.
          /// If the device is a desktop-device, the layer is selectable; otherwise, the layer is not selectable.
          selectable: LayerInteractionSelectable.enabled,
        ),
        imageEditorTheme: ImageEditorTheme(
          layerInteraction: ThemeLayerInteraction(
            buttonRadius: 10,
            strokeWidth: 1.2,
            borderElementWidth: 7,
            borderElementSpace: 5,
            borderColor: Colors.blue,
            removeCursor: SystemMouseCursors.click,
            rotateScaleCursor: SystemMouseCursors.click,
            editCursor: SystemMouseCursors.click,
            hoverCursor: SystemMouseCursors.move,
            borderStyle: LayerInteractionBorderStyle.solid,
            showTooltips: false,
          ),
        ),
        icons: ImageEditorIcons(
          layerInteraction: IconsLayerInteraction(
            remove: Icons.clear,
            edit: Icons.edit_outlined,
            rotateScale: Icons.sync,
          ),
        ),
        i18n: I18n(
          layerInteraction: I18nLayerInteraction(
            remove: 'Remove',
            edit: 'Edit',
            rotateScale: 'Rotate and Scale',
          ),
        ),
      ),
    );
  }
}

class ReorderLayerSheet extends StatefulWidget {
  final List<Layer> layers;
  final ReorderCallback onReorder;

  const ReorderLayerSheet({
    super.key,
    required this.layers,
    required this.onReorder,
  });

  @override
  State<ReorderLayerSheet> createState() => _ReorderLayerSheetState();
}

class _ReorderLayerSheetState extends State<ReorderLayerSheet> {
  @override
  Widget build(BuildContext context) {
    return ReorderableListView.builder(
      header: const Padding(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Text(
          'Reorder',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.w500),
        ),
      ),
      footer: const SizedBox(height: 30),
      dragStartBehavior: DragStartBehavior.down,
      itemBuilder: (context, index) {
        Layer layer = widget.layers[index];
        return ListTile(
          key: ValueKey(layer),
          tileColor: Theme.of(context).cardColor,
          title: layer.runtimeType == TextLayerData
              ? Text(
                  (layer as TextLayerData).text,
                  style: const TextStyle(fontSize: 20),
                )
              : layer.runtimeType == EmojiLayerData
                  ? Text(
                      (layer as EmojiLayerData).emoji,
                      style: const TextStyle(fontSize: 24),
                    )
                  : layer.runtimeType == PaintingLayerData
                      ? SizedBox(
                          height: 40,
                          child: FittedBox(
                            alignment: Alignment.centerLeft,
                            child: CustomPaint(
                              size: (layer as PaintingLayerData).size,
                              willChange: true,
                              isComplex:
                                  layer.item.mode == PaintModeE.freeStyle,
                              painter: DrawCanvas(
                                item: layer.item,
                                scale: layer.scale,
                                enabledHitDetection: false,
                                freeStyleHighPerformanceScaling: false,
                                freeStyleHighPerformanceMoving: false,
                              ),
                            ),
                          ),
                        )
                      : layer.runtimeType == StickerLayerData
                          ? SizedBox(
                              height: 40,
                              child: FittedBox(
                                alignment: Alignment.centerLeft,
                                child: (layer as StickerLayerData).sticker,
                              ),
                            )
                          : Text(
                              layer.id.toString(),
                            ),
          trailing: const Icon(Icons.drag_handle_rounded),
        );
      },
      itemCount: widget.layers.length,
      onReorder: widget.onReorder,
    );
  }
}
