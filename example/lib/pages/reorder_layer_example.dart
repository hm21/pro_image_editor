// Flutter imports:
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

// Package imports:
import 'package:pro_image_editor/pro_image_editor.dart';

// Project imports:
import '../utils/example_constants.dart';
import '../utils/example_helper.dart';

/// A widget that demonstrates the ability to reorder layers within a UI.
///
/// The [ReorderLayerExample] widget is a stateful widget that allows users
/// to reorder different layers, typically used in applications like image
/// or graphic editors. This feature enables users to adjust the stacking
/// order of layers for better control over the composition.
///
/// The state for this widget is managed by the [_ReorderLayerExampleState]
/// class.
///
/// Example usage:
/// ```dart
/// ReorderLayerExample();
/// ```
class ReorderLayerExample extends StatefulWidget {
  /// Creates a new [ReorderLayerExample] widget.
  const ReorderLayerExample({super.key});

  @override
  State<ReorderLayerExample> createState() => _ReorderLayerExampleState();
}

/// The state for the [ReorderLayerExample] widget.
///
/// This class manages the logic and state required for reordering layers
/// within the [ReorderLayerExample] widget.
class _ReorderLayerExampleState extends State<ReorderLayerExample>
    with ExampleHelperState<ReorderLayerExample> {
  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () async {
        await precacheImage(
            AssetImage(ExampleConstants.of(context)!.demoAssetPath), context);
        if (!context.mounted) return;
        await Navigator.push(
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

/// A widget that provides a sheet for reordering layers.
///
/// The [ReorderLayerSheet] widget allows users to view and reorder a list of
/// layers within an application. It is typically used in scenarios where the
/// user needs to manage the stacking order of different layers, such as in
/// an image or graphic editor.
///
/// This widget requires a list of [Layer] objects and a [ReorderCallback]
/// function to handle the reorder logic.
///
/// The state for this widget is managed by the [_ReorderLayerSheetState] class.
///
/// Example usage:
/// ```dart
/// ReorderLayerSheet(
///   layers: myLayers,
///   onReorder: (oldIndex, newIndex) { /* reorder logic */ },
/// );
/// ```
class ReorderLayerSheet extends StatefulWidget {
  /// Creates a new [ReorderLayerSheet] widget.
  ///
  /// The [layers] parameter is required and represents the list of layers
  /// that can be reordered. The [onReorder] callback is required to handle
  /// the logic when layers are reordered.
  const ReorderLayerSheet({
    super.key,
    required this.layers,
    required this.onReorder,
  });

  /// A list of [Layer] objects that can be reordered by the user.
  final List<Layer> layers;

  /// A callback that is triggered when the user reorders the layers.
  /// This function receives the [oldIndex] and [newIndex] to indicate
  /// how the layers were reordered.
  final ReorderCallback onReorder;

  @override
  State<ReorderLayerSheet> createState() => _ReorderLayerSheetState();
}

/// The state for the [ReorderLayerSheet] widget.
///
/// This class manages the logic and state required for displaying and
/// interacting with the reorderable list of layers.
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
