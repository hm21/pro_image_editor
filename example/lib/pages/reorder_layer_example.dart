// Flutter imports:
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

// Package imports:
import 'package:pro_image_editor/pro_image_editor.dart';

// Project imports:
import '../utils/example_constants.dart';
import '../utils/example_helper.dart';

class ReorderLayerExample extends StatefulWidget {
  const ReorderLayerExample({super.key});

  @override
  State<ReorderLayerExample> createState() => _ReorderLayerExampleState();
}

class _ReorderLayerExampleState extends State<ReorderLayerExample>
    with ExampleHelperState<ReorderLayerExample> {
  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () async {
        await precacheImage(
            AssetImage(ExampleConstants.of(context)!.demoAssetPath), context);
        if (!context.mounted) return;
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => _buildEditor(),
          ),
        );
      },
      leading: const Icon(Icons.sort),
      title: const Text('Reorder layer level'),
      trailing: const Icon(Icons.chevron_right),
    );
  }

  Widget _buildEditor() {
    return ProImageEditor.asset(
      ExampleConstants.of(context)!.demoAssetPath,
      key: editorKey,
      callbacks: ProImageEditorCallbacks(
        onImageEditingStarted: onImageEditingStarted,
        onImageEditingComplete: onImageEditingComplete,
        onCloseEditor: onCloseEditor,
      ),
      configs: ProImageEditorConfigs(
        designMode: platformDesignMode,
        customWidgets: ImageEditorCustomWidgets(
          mainEditor: CustomWidgetsMainEditor(
            bodyItems: (editor, rebuildStream) {
              return [
                ReactiveCustomWidget(
                  stream: rebuildStream,
                  builder: (_) =>
                      editor.selectedLayerIndex >= 0 || editor.isSubEditorOpen
                          ? const SizedBox.shrink()
                          : Positioned(
                              bottom: 20,
                              left: 0,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.lightBlue.shade200,
                                  borderRadius: const BorderRadius.only(
                                    topRight: Radius.circular(100),
                                    bottomRight: Radius.circular(100),
                                  ),
                                ),
                                child: IconButton(
                                  onPressed: () {
                                    showModalBottomSheet(
                                      context: context,
                                      builder: (context) {
                                        return ReorderLayerSheet(
                                          layers: editor.activeLayers,
                                          onReorder: (oldIndex, newIndex) {
                                            editor.moveLayerListPosition(
                                              oldIndex: oldIndex,
                                              newIndex: newIndex,
                                            );
                                            Navigator.pop(context);
                                          },
                                        );
                                      },
                                    );
                                  },
                                  icon: const Icon(
                                    Icons.reorder,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                ),
              ];
            },
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
                              painter: DrawPainting(
                                item: layer.item,
                                scale: layer.scale,
                                enabledHitDetection: false,
                                freeStyleHighPerformance: false,
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
        );
      },
      itemCount: widget.layers.length,
      onReorder: widget.onReorder,
    );
  }
}
