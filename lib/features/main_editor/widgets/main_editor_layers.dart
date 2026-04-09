import 'package:flutter/material.dart';

import '/core/models/editor_callbacks/pro_image_editor_callbacks.dart';
import '/core/models/editor_configs/pro_image_editor_configs.dart';
import '/core/models/layers/layer.dart';
import '/core/services/mouse_service.dart';
import '/core/utils/size_utils.dart';
import '/features/main_editor/controllers/main_editor_controllers.dart';
import '/features/main_editor/services/layer_interaction_manager.dart';
import '/features/main_editor/services/sizes_manager.dart';
import '/plugins/defer_pointer/defer_pointer.dart';
import '/shared/widgets/extended/mouse_region/extended_rebuild_mouse_region.dart';
import '/shared/widgets/layer/layer_widget.dart';
import '../main_editor.dart';
import '../services/layer_drag_selection_service.dart';
import '../services/main_editor_layers_service.dart';

/// A widget that manages and displays layers in the main editor, handling
/// interactions, configurations, and callbacks for user actions.
class MainEditorLayers extends StatefulWidget {
  /// Creates a `MainEditorLayers` widget with the necessary configurations,
  /// managers, and callbacks.
  const MainEditorLayers({
    super.key,
    required this.controllers,
    required this.layerInteractionManager,
    required this.configs,
    required this.callbacks,
    required this.sizesManager,
    required this.activeLayers,
    required this.isSubEditorOpen,
    required this.onCheckInteractiveViewer,
    required this.onTextLayerTap,
    required this.onEditPaintLayer,
    required this.state,
    required this.onContextMenuToggled,
    required this.onDuplicateLayer,
    required this.mouseService,
    required this.dragSelectionService,
    this.playTimeNotifier,
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

  /// Handles interactions with editor layers.
  final LayerInteractionManager layerInteractionManager;

  /// A service responsible for handling drag and selection operations
  /// within the editor layers. This service facilitates user interactions
  /// such as dragging and selecting layers in the main editor.
  final LayerDragSelectionService dragSelectionService;

  /// A service that handles mouse interactions within the editor.
  /// This is used to manage mouse-related events and behaviors.
  final MouseService mouseService;

  /// List of active layers in the editor.
  final List<Layer> activeLayers;

  /// Indicates whether a sub-editor is currently open.
  final bool isSubEditorOpen;

  /// Callback to check the state of the interactive viewer.
  final Function() onCheckInteractiveViewer;

  /// Callback triggered when a text layer is tapped.
  final Function(TextLayer layer) onTextLayerTap;

  /// A callback function that is triggered when a paint layer is edited.
  final Function(PaintLayer layer) onEditPaintLayer;

  /// Callback triggered when a layer should be copied.
  final Function(Layer layer) onDuplicateLayer;

  /// Callback triggered when the context menu is toggled.
  final Function(bool isOpen)? onContextMenuToggled;

  /// Notifier providing the current video playback position.
  ///
  /// When non-null, layers with [Layer.startTime] / [Layer.endTime] are
  /// animated in/out based on the current time.
  final ValueNotifier<Duration>? playTimeNotifier;

  @override
  State<MainEditorLayers> createState() => _MainEditorLayersState();
}

class _MainEditorLayersState extends State<MainEditorLayers> {
  /// Represents the dimensions of the body.
  Size _editorBodySize = Size.infinite;

  late final _layerInteractionManager = widget.layerInteractionManager;
  late final _layersService = MainEditorLayersService(
    state: widget.state,
    mouseService: widget.mouseService,
    layerInteraction: _layerInteractionManager,
    configs: widget.configs,
    callbacks: widget.callbacks,
    dragSelectionService: widget.dragSelectionService,
    getIsMounted: () => mounted,
    getActiveLayers: () => widget.activeLayers,
    onCheckInteractiveViewer: widget.onCheckInteractiveViewer,
    onUpdateState: () {
      if (mounted) setState(() {});
    },
    controllers: widget.controllers,
    onTextLayerTap: widget.onTextLayerTap,
    onEditPaintLayer: widget.onEditPaintLayer,
  );

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<bool>(
      stream: widget.controllers.layerHeroResetCtrl.stream,
      initialData: false,
      builder: (_, resetLayerSnapshot) {
        // Render an empty container when resetting layers
        if (resetLayerSnapshot.data!) return const SizedBox.shrink();

        return LayoutBuilder(
          builder: (context, constraints) {
            _editorBodySize = getValidSizeOrDefault(
              widget.sizesManager.bodySize,
              constraints.biggest,
            );
            return _buildLayerRepaintBoundary();
          },
        );
      },
    );
  }

  /// Builds the layer repaint boundary widget
  Widget _buildLayerRepaintBoundary() {
    return ExtendedRebuildMouseRegion(
      key: _layersService.mouseCursorsKey,
      onHover: isDesktop ? _layersService.handleMouseHover : null,
      child: ValueListenableBuilder(
        valueListenable: _layersService.deferId,
        builder: (_, deferId, _) {
          return DeferredPointerHandler(
            id: deferId,
            selectedLayerId: _layerInteractionManager.selectedLayerId,
            child: StreamBuilder(
              stream: widget.controllers.uiLayerCtrl.stream,
              builder: (context, snapshot) {
                return GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTap: () {
                    _layerInteractionManager.clearSelectedLayers();
                    widget.onCheckInteractiveViewer();
                    setState(() {});
                  },
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      for (Layer layer in widget.activeLayers)
                        _buildLayerWidget(layer),
                    ],
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  /// Builds a single layer widget
  Widget _buildLayerWidget(Layer layer) {
    return LayerWidget(
      key: layer.key,
      layer: layer,
      configs: widget.configs,
      callbacks: widget.callbacks,
      layersService: _layersService,
      layerInteractionManager: _layerInteractionManager,
      editorBodySize: _editorBodySize,
      isInteractive: !widget.isSubEditorOpen,
      enableMouseCursor: !widget.dragSelectionService.isActive,
      onDuplicate: () => widget.onDuplicateLayer(layer),
      onContextMenuToggled: widget.onContextMenuToggled,
      playTimeNotifier: widget.playTimeNotifier,
    );
  }
}
