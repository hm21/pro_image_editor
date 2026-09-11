import 'dart:async';

import 'package:material_ui/material_ui.dart';

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
import '/shared/widgets/layer/paint_layer_raster_cache_host.dart';
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

class _MainEditorLayersState extends State<MainEditorLayers>
    with PaintLayerRasterCacheHost {
  @override
  ProImageEditorConfigs get configs => widget.configs;

  /// Represents the dimensions of the body.
  Size _editorBodySize = Size.infinite;

  /// A hash of the layers the cache could draw at the last play time it saw.
  /// Only a change in that set — a layer crossing its timeline edge — is
  /// worth a rebuild; the play time itself moves every frame.
  int _timelineSignature = 0;

  /// Whether the editor was zoomed at the last matrix change. Zooming scales
  /// the cached image, so the cache steps aside while the editor is zoomed.
  bool _wasZoomed = false;

  StreamSubscription<void>? _zoomSubscription;

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
  void initState() {
    super.initState();
    if (rasterCache != null) {
      widget.playTimeNotifier?.addListener(_onPlayTimeChanged);
      _zoomSubscription = widget.controllers.cropLayerPainterCtrl.stream.listen(
        (_) => _onZoomMaybeChanged(),
      );
    }
  }

  @override
  void didUpdateWidget(covariant MainEditorLayers oldWidget) {
    super.didUpdateWidget(oldWidget);
    final cache = rasterCache;
    if (cache == null) return;
    if (oldWidget.playTimeNotifier != widget.playTimeNotifier) {
      oldWidget.playTimeNotifier?.removeListener(_onPlayTimeChanged);
      widget.playTimeNotifier?.addListener(_onPlayTimeChanged);
    }
    // A sub-editor renders these layers live (hero flights need painted
    // sources) and its `LayerStack` brings a cache of its own, so the images
    // here would only sit in GPU memory until it closes. One re-render on
    // return is cheaper than holding two canvases' worth of textures.
    if (widget.isSubEditorOpen && !oldWidget.isSubEditorOpen) {
      cache.clear();
    }
  }

  @override
  void dispose() {
    _zoomSubscription?.cancel();
    widget.playTimeNotifier?.removeListener(_onPlayTimeChanged);
    super.dispose();
  }

  /// Rebuilds when a layer enters or leaves its timeline window, which moves
  /// it between the cache and live rendering.
  void _onPlayTimeChanged() {
    if (!mounted) return;
    final signature = _computeTimelineSignature();
    if (signature == _timelineSignature) return;
    _timelineSignature = signature;
    setState(() {});
  }

  void _onZoomMaybeChanged() {
    if (!mounted) return;
    final isZoomed = _isZoomed;
    if (isZoomed == _wasZoomed) return;
    _wasZoomed = isZoomed;
    setState(() {});
  }

  bool get _isZoomed =>
      widget.state.interactiveViewer.currentState?.isZoomed ?? false;

  int _computeTimelineSignature() {
    final playTime = widget.playTimeNotifier?.value;
    var signature = 17;
    for (final layer in widget.activeLayers) {
      if (layer is! PaintLayer) continue;
      final start = layer.startTime;
      final end = layer.endTime;
      final visible =
          playTime == null ||
          ((start == null || playTime >= start) &&
              (end == null || playTime <= end));
      signature = Object.hash(signature, layer.id, visible);
    }
    return signature;
  }

  /// The stack children, with static paint layers drawn from the cache.
  ///
  /// Selected and interacting layers stay live so they are pixel-exact while
  /// they move; so does everything while a sub-editor is open (hero flights
  /// need painted sources) and while the editor is zoomed (the image would be
  /// upscaled).
  List<Widget> _buildLayerChildren(BuildContext context) {
    final children = buildRasterCachedLayers(
      layers: widget.activeLayers,
      excludedIds: {
        ..._layerInteractionManager.selectedLayerIds,
        if (_layerInteractionManager.activeInteractionLayer != null)
          _layerInteractionManager.activeInteractionLayer!.id,
      },
      playTime: widget.playTimeNotifier?.value,
      editorBodySize: _editorBodySize,
      pixelRatio: MediaQuery.devicePixelRatioOf(context),
      suspend: widget.isSubEditorOpen || _isZoomed,
      buildLayer: _buildLayerWidget,
    );
    _timelineSignature = _computeTimelineSignature();
    return children;
  }

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
                    children: _buildLayerChildren(context),
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
  Widget _buildLayerWidget(Layer layer, {bool isRasterCached = false}) {
    return LayerWidget(
      key: layer.key,
      layer: layer,
      isRasterCached: isRasterCached,
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
