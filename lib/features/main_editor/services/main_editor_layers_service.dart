import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '/core/models/editor_callbacks/pro_image_editor_callbacks.dart';
import '/core/models/editor_configs/pro_image_editor_configs.dart';
import '/core/models/layers/layer.dart';
import '/core/services/keyboard_service.dart';
import '/core/services/mouse_service.dart';
import '/shared/utils/unique_id_generator.dart';
import '/shared/widgets/extended/mouse_region/extended_rebuild_mouse_region.dart';
import '../controllers/main_editor_controllers.dart';
import '../main_editor.dart';
import 'layer_drag_selection_service.dart';
import 'layer_interaction_manager.dart';

/// A service that manages interactions with layers in the main editor,
/// including selection, editing, grouping, and pointer events.
class MainEditorLayersService {
  /// The constructor for the [MainEditorLayersService].
  MainEditorLayersService({
    required this.configs,
    required this.callbacks,
    required this.controllers,
    required this.onTextLayerTap,
    required this.onEditPaintLayer,
    required this.onUpdateState,
    required this.onCheckInteractiveViewer,
    required this.layerInteraction,
    required this.dragSelectionService,
    required this.mouseService,
    required this.getActiveLayers,
    required this.state,
    this.getIsMounted,
  });

  final _keyboard = KeyboardService();

  /// Reference to the current editor state.
  final ProImageEditorState state;

  /// Configuration settings for the editor.
  final ProImageEditorConfigs configs;

  /// Provides callbacks for editor interactions.
  final ProImageEditorCallbacks callbacks;

  /// Manages controllers for various parts of the editor.
  final MainEditorControllers controllers;

  /// Handles interactions such as selecting and editing layers.
  final LayerInteractionManager layerInteraction;

  /// Service for selecting multiple layers via drag.
  final LayerDragSelectionService dragSelectionService;

  /// Service for mouse-related utilities and gestures.
  final MouseService mouseService;

  /// Function that returns the currently active layers.
  final List<Layer> Function() getActiveLayers;

  List<Layer> get _activeLayers => getActiveLayers();

  /// Called to check and update the state of the InteractiveViewer.
  final Function() onCheckInteractiveViewer;

  /// Triggers a UI state update.
  final Function() onUpdateState;

  /// Callback triggered when a text layer is tapped.
  final Function(TextLayer layer) onTextLayerTap;

  /// Callback triggered when a paint layer is edited.
  final Function(PaintLayer layer) onEditPaintLayer;

  LayerInteractionConfigs get _layerInteractionConfigs =>
      configs.layerInteraction;

  /// Key for managing mouse cursor states.
  final mouseCursorsKey = GlobalKey<ExtendedRebuildMouseRegionState>();

  /// Unique identifier used to defer updates.
  final deferId = ValueNotifier(generateUniqueId());

  /// Optional function to check if the widget is still mounted.
  /// Used to safely execute callbacks after frame updates.
  final bool Function()? getIsMounted;

  /// Returns whether the widget is still mounted.
  bool get mounted => getIsMounted?.call() ?? true;

  /// Determines whether multi-selection mode is active.
  bool get _enableMultiSelect =>
      state.enableMultiSelectMode ||
      mouseService.validateMultiSelectAction() ||
      ((_keyboard.isCtrlPressed || _keyboard.isShiftPressed) &&
          _layerInteractionConfigs.enableKeyboardMultiSelection);

  Set<String> _temporarySelectedIds = {};
  bool _isScaleInteractionActive = false;
  bool _helperIsPointerDownSelected = false;
  bool _helperEnforceMultiSelect = false;
  bool _helperMouseDownMultiSelect = false;

  /// Handles edit interaction for different layer types.
  void handleEditTap(Layer layer) {
    if (layer.isTextLayer) {
      onTextLayerTap(layer as TextLayer);
    } else if (layer.isPaintLayer) {
      onEditPaintLayer(layer as PaintLayer);
    } else if (layer.isWidgetLayer) {
      callbacks.stickerEditorCallbacks?.onTapEditSticker
          ?.call(state, layer as WidgetLayer);
    }
  }

  /// Handles tap events on a layer to manage selection or editing.
  void handleLayerTap(Layer layer, PointerEvent event) {
    final bool layersAreSelectable =
        layerInteraction.layersAreSelectable(configs);

    if (mouseService.validatePanAction(event: event) && layersAreSelectable) {
      return;
    }

    // Only handle selection if selectable
    if (layer.interaction.enableSelection && layersAreSelectable) {
      final selectedIds = layerInteraction.selectedLayerIds;
      final isAlreadySelected =
          selectedIds.contains(layer.id) && !_helperIsPointerDownSelected;

      // Handle individual layer selection (no group)
      if (!_enableMultiSelect && !_helperMouseDownMultiSelect) {
        layerInteraction.clearSelectedLayers();
        _deselectGroup(layer);
        if (!isAlreadySelected) {
          layerInteraction.addSelectedLayer(layer.id);
          _selectGroup(layer);
        }
      } else {
        if (isAlreadySelected) {
          layerInteraction.removeSelectedLayer(layer.id);
          _deselectGroup(layer);
        } else {
          layerInteraction.addSelectedLayer(layer.id);
          _selectGroup(layer);
        }
      }

      onCheckInteractiveViewer();
    } else if (layer.interaction.enableEdit) {
      if (layer.isTextLayer && configs.textEditor.enableEdit) {
        onTextLayerTap(layer as TextLayer);
      } else if (layer.isPaintLayer && configs.paintEditor.enableEdit) {
        onEditPaintLayer(layer as PaintLayer);
      }
    }

    _helperMouseDownMultiSelect = false;
  }

  /// Handles the tap-up event on a layer and updates the UI.
  void handleTapUp(Layer layer) {
    if (_helperEnforceMultiSelect) {
      _helperEnforceMultiSelect = false;
      return;
    }

    if (!layerInteraction.layersAreSelectable(configs)) {
      layerInteraction.clearSelectedLayers();
      _deselectGroup(layer);
    }
    if (_isScaleInteractionActive) return;
    if (layerInteraction.hoverRemoveBtn) {
      state.removeLayer(layer);
    }

    controllers.uiLayerCtrl.add(null);
    callbacks.mainEditorCallbacks?.handleUpdateUI();
    _validateClearLayer();

    onCheckInteractiveViewer();
    callbacks.mainEditorCallbacks?.onLayerTapUp?.call(layer);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      deferId.value = generateUniqueId();
    });
  }

  /// Handles the tap-down event on a layer to begin selection or interaction.
  void handleTapDown(Layer layer, PointerDownEvent event) {
    if (_isScaleInteractionActive ||
        state.isLayerBeingTransformed ||
        (mouseService.validatePanAction(event: event) && isDesktop)) {
      return;
    }
    mouseService.onPointerDown(event);
    layerInteraction.activeInteractionLayer = layer;

    final selectedIds = layerInteraction.selectedLayerIds;
    _temporarySelectedIds = {...selectedIds};
    _helperIsPointerDownSelected = false;
    _helperMouseDownMultiSelect =
        mouseService.validateMultiSelectAction(event: event);

    /// If a user directly drags a layer, we first need to ensure the layer is
    /// selected when the pointer goes down.
    if (layer.interaction.enableSelection) {
      bool isAlreadySelected = selectedIds.contains(layer.id);

      if (!isAlreadySelected && (selectedIds.isEmpty || _enableMultiSelect)) {
        _helperIsPointerDownSelected = true;
        layerInteraction.addSelectedLayer(layer.id);
      } else if (!isAlreadySelected && !_enableMultiSelect) {
        _helperIsPointerDownSelected = true;
        layerInteraction
          ..clearSelectedLayers()
          ..addSelectedLayer(layer.id);
      }
      _selectGroup(layer);
    }

    onCheckInteractiveViewer();
    callbacks.mainEditorCallbacks?.onLayerTapDown?.call(layer);
  }

  /// Selects all layers in the same group as the given layer.
  void _selectGroup(Layer layer) {
    if (layer.groupId == null) return;
    // If layer is part of a group, handle group selection
    Set<String> groupIds = _activeLayers
        .where(
            (l) => l.groupId == layer.groupId && l.interaction.enableSelection)
        .map((l) => l.id)
        .toSet();

    if (_enableMultiSelect) {
      layerInteraction.addMultipleSelectedLayers(groupIds);
    } else {
      layerInteraction.setSelectedLayers(groupIds);
    }
  }

  /// Deselects all layers in the same group as the given layer.
  void _deselectGroup(Layer layer) {
    if (layer.groupId == null) return;
    // If layer is part of a group, handle group selection
    Set<String> groupIds = _activeLayers
        .where((l) => l.groupId == layer.groupId)
        .map((l) => l.id)
        .toSet();

    if (_enableMultiSelect) {
      layerInteraction.removeMultipleSelectedLayers(groupIds);
    } else {
      layerInteraction.clearSelectedLayers();
    }
  }

  /// Clears layer selection if the interaction config requires it.
  void _validateClearLayer() {
    if (!_layerInteractionConfigs.keepSelectionOnInteraction) {
      layerInteraction.clearSelectedLayers();
    }
  }

  /// Called when scale or rotate interaction starts.
  void handleScaleRotateDown(Size layerOriginalSize, Layer layer) {
    _isScaleInteractionActive = true;

    layerInteraction
      ..activeInteractionLayer = layer
      ..rotateScaleLayerSizeHelper = layerOriginalSize
      ..rotateScaleLayerScaleHelper = layer.scale;
    onCheckInteractiveViewer();
  }

  /// Called when scale or rotate interaction ends.
  void handleScaleRotateUp() {
    _isScaleInteractionActive = false;
    layerInteraction
      ..rotateScaleLayerSizeHelper = null
      ..rotateScaleLayerScaleHelper = null;
    _validateClearLayer();
    onCheckInteractiveViewer();
    callbacks.mainEditorCallbacks?.handleUpdateUI();
  }

  /// Removes the given layer from the canvas and updates the UI.
  void handleRemoveLayer(Layer layer) {
    state.removeLayer(layer);
    callbacks.mainEditorCallbacks?.handleUpdateUI();
  }

  /// Handles grouping of currently selected layers.
  void handleGroupLayers() {
    final groupId = layerInteraction.groupSelectedLayers(
      _activeLayers,
      (updatedLayers) {
        state.addHistory(layers: updatedLayers);
      },
    );

    if (groupId != null) {
      // Trigger UI update
      callbacks.mainEditorCallbacks?.handleUpdateUI();
      onUpdateState();
    }
  }

  /// Handles ungrouping of the specified layer.
  void handleUngroupLayers(Layer layer) {
    final wasUngrouped = layerInteraction.ungroupLayer(
      layer,
      _activeLayers,
      (updatedLayers) {
        state.addHistory(layers: updatedLayers);
      },
    );

    if (wasUngrouped) {
      // Trigger UI update
      callbacks.mainEditorCallbacks?.handleUpdateUI();
      onUpdateState();
    }
  }

  /// Handles mouse hover events to change the cursor style
  void handleMouseHover(PointerHoverEvent event) {
    final bool hasHit = _activeLayers
        .any((element) => element is PaintLayer && element.item.hit);

    final activeCursor = mouseCursorsKey.currentState!.currentCursor;
    final moveCursor = _layerInteractionConfigs.style.hoverCursor;

    if (hasHit && activeCursor != moveCursor) {
      mouseCursorsKey.currentState!.setCursor(moveCursor);
    } else if (!hasHit && activeCursor != SystemMouseCursors.basic) {
      mouseCursorsKey.currentState!.setCursor(SystemMouseCursors.basic);
    }
  }

  /// Handles long-press gesture to trigger multi-layer selection.
  void handleLongPress(
    Layer layer, {
    bool areLayersSelectable = false,
    bool isSelected = false,
  }) {
    if (!areLayersSelectable ||
        !_layerInteractionConfigs.enableLongPressMultiSelection ||
        mouseService.validatePanAction()) {
      return;
    }

    _helperEnforceMultiSelect = true;
    final newIds = {..._temporarySelectedIds, layer.id};
    if (isSelected) newIds.remove(layer.id);
    layerInteraction.setSelectedLayers(newIds);
    onUpdateState();
  }
}
