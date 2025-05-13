import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pro_image_editor/core/utils/size_utils.dart';

import '/core/models/editor_callbacks/pro_image_editor_callbacks.dart';
import '/core/models/editor_configs/pro_image_editor_configs.dart';
import '/core/models/layers/layer.dart';
import '/features/main_editor/controllers/main_editor_controllers.dart';
import '/features/main_editor/services/layer_interaction_manager.dart';
import '/features/main_editor/services/sizes_manager.dart';
import '/plugins/defer_pointer/defer_pointer.dart';
import '/shared/utils/unique_id_generator.dart';
import '/shared/widgets/extended/mouse_region/extended_rebuild_mouse_region.dart';
import '/shared/widgets/layer/layer_widget.dart';
import '../main_editor.dart';


/// A widget that manages and displays layers in the main editor, handling
/// interactions, configurations, and callbacks for user actions.
class MainEditorLayers extends StatefulWidget {
  /// Creates a `MainEditorLayers` widget with the necessary configurations,
  /// managers, and callbacks.
  ///
  /// - [state]: Represents the current state of the editor.
  /// - [configs]: Configuration settings for the editor.
  /// - [callbacks]: Provides callbacks for editor interactions.
  /// - [sizesManager]: Manages size-related settings and adjustments.
  /// - [controllers]: Manages the main editor's controllers.
  /// - [layerInteraction]: Configurations for layer interactions.
  /// - [layerInteractionManager]: Handles interactions with editor layers.
  /// - [mouseCursorsKey]: Key for managing mouse cursor regions.
  /// - [activeLayers]: List of active layers in the editor.
  /// - [selectedLayerIndex]: The index of the currently selected layer.
  /// - [isSubEditorOpen]: Indicates whether a sub-editor is currently open.
  /// - [checkInteractiveViewer]: Callback to check the state of the
  ///   interactive viewer.
  /// - [onTextLayerTap]: Callback triggered when a text layer is tapped.
  /// - [setTempLayer]: Callback to temporarily set a layer for interaction.
  /// - [onContextMenuToggled]: Callback triggered when the context menu is
  ///   toggled.
  const MainEditorLayers({
    super.key,
    required this.controllers,
    required this.layerInteraction,
    required this.layerInteractionManager,
    required this.configs,
    required this.callbacks,
    required this.sizesManager,
    required this.selectedLayerIndex,
    required this.activeLayers,
    required this.isSubEditorOpen,
    required this.checkInteractiveViewer,
    required this.onTextLayerTap,
    required this.state,
    required this.setTempLayer,
    required this.onContextMenuToggled,
  });

  /// Represents the current state of the editor.
  final ProImageEditorState state;

  /// Configuration settings for the editor.
  final ProImageEditorConfigs configs;

  /// Provides callbacks for editor interactions.
  final ProImageEditorCallbacks callbacks;

  /// Manages size-related settings and adjustments.
  final SizesManager sizesManager;

  /// Manages the main editor's controllers.
  final MainEditorControllers controllers;

  /// Configurations for layer interactions.
  final LayerInteractionConfigs layerInteraction;

  /// Handles interactions with editor layers.
  final LayerInteractionManager layerInteractionManager;

  /// List of active layers in the editor.
  final List<Layer> activeLayers;

  /// The index of the currently selected layer.
  final int selectedLayerIndex;

  /// Indicates whether a sub-editor is currently open.
  final bool isSubEditorOpen;

  /// Callback to check the state of the interactive viewer.
  final Function() checkInteractiveViewer;

  /// Callback triggered when a text layer is tapped.
  final Function(TextLayer layer) onTextLayerTap;

  /// Callback to temporarily set a layer for interaction.
  final Function(Layer layer) setTempLayer;

  /// Callback triggered when the context menu is toggled.
  final Function(bool isOpen)? onContextMenuToggled;

  @override
  State<MainEditorLayers> createState() => _MainEditorLayersState();
}

class _MainEditorLayersState extends State<MainEditorLayers> {
  final _deferId = ValueNotifier(generateUniqueId());

  /// Represents the dimensions of the body.
  Size editorBodySize = Size.infinite;

  /// Key for managing mouse cursor regions.
  final _mouseCursorsKey = GlobalKey<ExtendedRebuildMouseRegionState>();

  // Helper methods for handling layer interactions
  void _handleEditTap(int index, Layer layer) {
    if (layer is TextLayer) {
      widget.onTextLayerTap(layer);
    } else if (layer is WidgetLayer) {
      widget.callbacks.stickerEditorCallbacks?.onTapEditSticker
          ?.call(widget.state, layer, index);
    }
  }

  void _handleLayerTap(Layer layer) {
    if (widget.layerInteractionManager.layersAreSelectable(widget.configs) &&
        layer.interaction.enableSelection) {
      widget.layerInteractionManager.selectedLayerId =
          layer.id == widget.layerInteractionManager.selectedLayerId
              ? ''
              : layer.id;
      widget.checkInteractiveViewer();
    } else if (layer is TextLayer && layer.interaction.enableEdit) {
      widget.onTextLayerTap(layer);
    }
  }

  void _handleTapUp(Layer layer) {
    if (widget.layerInteractionManager.hoverRemoveBtn) {
      widget.state.removeLayer(layer);
    }
    widget.controllers.uiLayerCtrl.add(null);
    widget.callbacks.mainEditorCallbacks?.handleUpdateUI();
    widget.state.selectedLayerIndex = -1;
    widget.checkInteractiveViewer();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _deferId.value = generateUniqueId();
    });
  }

  void _handleTapDown(int index, Layer layer) {
    widget.state.selectedLayerIndex = index;
    widget.setTempLayer(layer);
    widget.checkInteractiveViewer();
  }

  void _handleScaleRotateDown(int index, Size layerOriginalSize, Layer layer) {
    widget.state.selectedLayerIndex = index;
    widget.layerInteractionManager
      ..rotateScaleLayerSizeHelper = layerOriginalSize
      ..rotateScaleLayerScaleHelper = layer.scale;
    widget.checkInteractiveViewer();
  }

  void _handleScaleRotateUp() {
    widget.layerInteractionManager
      ..rotateScaleLayerSizeHelper = null
      ..rotateScaleLayerScaleHelper = null;
    widget.state.setState(() => widget.state.selectedLayerIndex = -1);
    widget.checkInteractiveViewer();
    widget.callbacks.mainEditorCallbacks?.handleUpdateUI();
  }

  void _handleRemoveLayer(Layer layer) {
    widget.state.setState(() => widget.state.removeLayer(layer));
    widget.callbacks.mainEditorCallbacks?.handleUpdateUI();
  }

  /// Handles mouse hover events to change the cursor style
  void _handleMouseHover(PointerHoverEvent event) {
    final bool hasHit = widget.activeLayers
        .any((element) => element is PaintLayer && element.item.hit);

    final activeCursor = _mouseCursorsKey.currentState!.currentCursor;
    final moveCursor = widget.layerInteraction.style.hoverCursor;

    if (hasHit && activeCursor != moveCursor) {
      _mouseCursorsKey.currentState!.setCursor(moveCursor);
    } else if (!hasHit && activeCursor != SystemMouseCursors.basic) {
      _mouseCursorsKey.currentState!.setCursor(SystemMouseCursors.basic);
    }
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      ignoring: widget.selectedLayerIndex >= 0,
      child: StreamBuilder<bool>(
        stream: widget.controllers.layerHeroResetCtrl.stream,
        initialData: false,
        builder: (context, resetLayerSnapshot) {
          // Render an empty container when resetting layers
          if (resetLayerSnapshot.data!) return const SizedBox.shrink();

          return LayoutBuilder(builder: (context, constraints) {
            editorBodySize = constraints.biggest;
            return _buildLayerRepaintBoundary();
          });
        },
      ),
    );
  }

  /// Builds the layer repaint boundary widget
  Widget _buildLayerRepaintBoundary() {
    return RepaintBoundary(
      child: ExtendedRebuildMouseRegion(
        key: _mouseCursorsKey,
        onHover: isDesktop ? _handleMouseHover : null,
        child: ValueListenableBuilder(
            valueListenable: _deferId,
            builder: (_, deferId, __) {
              return DeferredPointerHandler(
                id: deferId,
                selectedLayerId: widget.layerInteractionManager.selectedLayerId,
                child: StreamBuilder(
                  stream: widget.controllers.uiLayerCtrl.stream,
                  builder: (context, snapshot) {
                    return Stack(
                      children: widget.activeLayers
                          .asMap()
                          .entries
                          .map(_buildLayerWidget)
                          .toList(),
                    );
                  },
                ),
              );
            }),
      ),
    );
  }

  /// Builds a single layer widget
  Widget _buildLayerWidget(MapEntry<int, Layer> entry) {
    var bodySize = 
      getValidSizeOrDefault(widget.sizesManager.bodySize, editorBodySize);

    int index = entry.key;
    Layer layer = entry.value;
    return LayerWidget(
      key: layer.key,
      configs: widget.configs,
      callbacks: widget.callbacks,
      editorCenterX: bodySize.width / 2,
      editorCenterY: bodySize.height / 2,
      layerData: layer,
      enableHitDetection: widget.layerInteractionManager.enabledHitDetection,
      selected: widget.layerInteractionManager.selectedLayerId == layer.id,
      isInteractive: !widget.isSubEditorOpen,
      highPerformanceMode:
          widget.layerInteractionManager.freeStyleHighPerformance,
      onEditTap: () => _handleEditTap(index, layer),
      onTap: _handleLayerTap,
      onTapUp: () => _handleTapUp(layer),
      onTapDown: () => _handleTapDown(index, layer),
      onScaleRotateDown: (details, layerOriginalSize) =>
          _handleScaleRotateDown(index, layerOriginalSize, layer),
      onContextMenuToggled: widget.onContextMenuToggled,
      onScaleRotateUp: (details) => _handleScaleRotateUp(),
      onRemoveTap: () => _handleRemoveLayer(layer),
    );
  }
}
