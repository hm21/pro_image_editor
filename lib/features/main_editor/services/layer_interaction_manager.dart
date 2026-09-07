// Dart imports:
import 'dart:async';
import 'dart:math';

// Flutter imports:
import 'package:material_ui/material_ui.dart';

// Project imports:
import '/core/models/editor_callbacks/main_editor/helper_lines/helper_lines_callbacks.dart';
import '/core/models/editor_configs/pro_image_editor_configs.dart';
import '/core/models/history/last_layer_interaction_position.dart';
import '/core/models/layers/layer.dart';
import '/shared/utils/debounce.dart';
import '/shared/utils/unique_id_generator.dart';

/// A helper class responsible for managing layer interactions in the editor.
///
/// The `LayerInteractionManager` class provides methods for handling various
/// interactions with layers in an image editing environment, including
/// scaling, rotating, flipping, and zooming. It also manages the display of
/// helper lines and provides haptic feedback when interacting with these lines
/// to enhance the user experience.
class LayerInteractionManager {
  /// Creates an instance of [LayerInteractionManager].
  ///
  /// - [helperLinesCallbacks]: An optional instance of [HelperLinesCallbacks]
  ///   to handle helper line hit events.
  LayerInteractionManager({
    required this.helperLinesCallbacks,
    required this.configs,
    this.onSelectedLayerChanged,
    required this.onSelectedLayersChanged,
  });

  /// An optional instance of [HelperLinesCallbacks] that defines callback
  ///  functions for handling helper line interactions.
  final HelperLinesCallbacks? helperLinesCallbacks;

  /// The configuration settings for the Pro Image Editor.
  ///
  /// This object contains various customizable options and parameters
  /// that define the behavior and appearance of the image editor.
  final ProImageEditorConfigs configs;

  /// Callback function to be called when the selected layer changes.
  final ValueChanged<String>? onSelectedLayerChanged;

  /// Callback function to be called when the selected layer changes.
  final ValueChanged<Set<String>>? onSelectedLayersChanged;

  /// Debounce for scaling actions in the editor.
  late Debounce scaleDebounce;

  /// Y-coordinate of the rotation helper line.
  double rotationHelperLineY = 0;

  /// X-coordinate of the rotation helper line.
  double rotationHelperLineX = 0;

  /// Rotation angle of the rotation helper line.
  double rotationHelperLineDeg = 0;

  /// A list that stores the layers selected at the start of a scaling
  /// operation.
  /// This is used to keep track of the initial state of the selected layers
  /// before any scaling transformations are applied.
  List<Layer> selectedLayersScaleStart = [];

  /// The base scale factor from the layer;
  final Map<String, double> _baseScaleFactor = {};

  /// The base angle factor from the layer;
  final Map<String, double> _baseAngleFactor = {};

  /// Initial rotation angle when snapping started.
  final Map<String, double> _snapStartRotation = {};

  /// Last recorded rotation angle during snapping.
  final Map<String, double> _snapLastRotation = {};

  /// X-coordinate where snapping started.
  double snapStartPosX = 0;

  /// Y-coordinate where snapping started.
  double snapStartPosY = 0;

  /// Flag indicating if vertical helper lines should be displayed.
  bool showVerticalHelperLine = false;

  /// Flag indicating if horizontal helper lines should be displayed.
  bool showHorizontalHelperLine = false;

  /// Flag indicating if rotation helper lines should be displayed.
  bool showRotationHelperLine = false;

  /// Whether to show the vertical alignment line for the active layer.
  bool isVerticalGuideVisible = false;

  /// Whether to show the horizontal alignment line for the active layer.
  bool isHorizontalGuideVisible = false;

  /// Offset of the horizontal alignment line relative to the editor center.
  Offset horizontalGuideOffset = Offset.zero;

  /// Offset of the vertical alignment line relative to the editor center.
  Offset verticalGuideOffset = Offset.zero;

  /// Whether the currently visible vertical guide is an app-defined custom
  /// guide (drawn with [HelperLineStyle.customGuideColor]) rather than a
  /// layer-alignment guide.
  bool isVerticalGuideCustom = false;

  /// Whether the currently visible horizontal guide is an app-defined custom
  /// guide.
  bool isHorizontalGuideCustom = false;

  /// Flag indicating if rotation helper lines have started.
  bool _rotationStartedHelper = false;

  /// Flag indicating if helper lines should be displayed.
  bool showHelperLines = false;

  /// Flag indicating if the remove button is hovered.
  bool hoverRemoveBtn = false;

  /// Enables or disables hit detection.
  /// When `true`, allows detecting user interactions with the painted layer.
  bool enabledHitDetection = true;

  /// Flag indicating if the scaling tool is active.
  bool _activeScale = false;

  /// Tracks whether any layer has been transformed (moved, scaled, rotated)
  /// during the current editing session.
  bool layerWasTransformed = false;

  /// Checks if there are any selected layers.
  ///
  /// Returns `true` if the list of selected layer IDs is not empty,
  /// indicating that at least one layer is selected. Otherwise, returns
  /// `false`.
  bool get hasSelectedLayers => selectedLayerIds.isNotEmpty;

  double _getLayerBaseScale(String layerId) {
    return _baseScaleFactor[layerId] ?? 1;
  }

  double _getLayerBaseAngle(String layerId) {
    return _baseAngleFactor[layerId] ?? 0;
  }

  double _getLayerSnapStartRotation(String layerId) {
    return _snapStartRotation[layerId] ?? 0;
  }

  double _getLayerSnapLastRotation(String layerId) {
    return _snapLastRotation[layerId] ?? 0;
  }

  /// The set of currently selected layer IDs (for multi-select support).
  final Set<String> selectedLayerIds = <String>{};

  /// Returns the currently selected layer ID.
  ///
  /// If multiple layers are selected, this returns the **last one inserted**.
  /// Returns an empty string if no layer is selected.
  String get selectedLayerId =>
      selectedLayerIds.isNotEmpty ? selectedLayerIds.first : '';

  /// Sets the [selectedLayerIds] to a single [id], replacing any existing
  /// selection.
  ///
  /// This is useful when only single selection is needed.
  set selectedLayerId(String id) {
    selectedLayerIds
      ..clear()
      ..add(id);
    _notifySelectionChanged();
  }

  /// Add a layer to the selection set.
  void addSelectedLayer(String id) {
    selectedLayerIds.add(id);
    _notifySelectionChanged();
  }

  /// Adds multiple layer IDs to the set of selected layers.
  ///
  /// This method takes a set of layer IDs and adds each ID to the
  /// `selectedLayerIds` collection. After updating the selection,
  /// it triggers a notification to indicate that the selection has changed.
  ///
  /// [value] A set of layer IDs to be added to the selection.
  void addMultipleSelectedLayers(Set<String> value) {
    for (final id in value) {
      selectedLayerIds.add(id);
    }
    _notifySelectionChanged();
  }

  /// Remove a layer from the selection set.
  void removeSelectedLayer(String id) {
    selectedLayerIds.remove(id);
    _notifySelectionChanged();
  }

  /// Removes multiple layers from the selection based on the provided set
  /// of layer IDs.
  ///
  /// This method iterates through the given set of layer IDs and removes each
  /// one from the `selectedLayerIds` collection. After the removal process,
  /// it triggers a notification to indicate that the selection has changed.
  ///
  /// [value] A set of layer IDs to be removed from the selection.
  void removeMultipleSelectedLayers(Set<String> value) {
    for (final id in value) {
      selectedLayerIds.remove(id);
    }
    _notifySelectionChanged();
  }

  /// Clear all selected layers.
  void clearSelectedLayers() {
    selectedLayerIds.clear();
    _notifySelectionChanged();
  }

  /// Set selected layers to a specific set.
  void setSelectedLayers(Iterable<String> ids) {
    selectedLayerIds
      ..clear()
      ..addAll(ids);
    _notifySelectionChanged();
  }

  /// Notifies selection change callbacks, both single and multi-select.
  void _notifySelectionChanged() {
    onSelectedLayerChanged?.call(selectedLayerId);
    onSelectedLayersChanged?.call(selectedLayerIds);
  }

  /// Groups the currently selected layers by assigning them a common groupId.
  ///
  /// This method creates a group from all currently selected layers by giving
  /// them the same unique groupId. After grouping, whenever any layer in the
  /// group is selected, all layers in the group will be automatically selected.
  ///
  /// [activeLayers] The list of all active layers in the editor.
  /// [onHistoryChanged] Callback to trigger when the layer history
  /// needs to be updated.
  ///
  /// Returns the groupId that was assigned to the layers, or null
  /// if no layers were selected.
  String? groupSelectedLayers(
    List<Layer> activeLayers,
    Function(List<Layer> layers) onHistoryChanged,
  ) {
    if (selectedLayerIds.isEmpty) return null;

    // Generate a unique group ID
    final groupId = generateUniqueId();

    // Create a copy of the layers list for history
    final updatedLayers = <Layer>[];
    for (final layer in activeLayers) {
      final layerCopy = _copyLayer(layer);
      if (selectedLayerIds.contains(layer.id)) {
        // Assign the new groupId to selected layers
        layerCopy.groupId = groupId;
      }
      updatedLayers.add(layerCopy);
    }

    // Update history with the modified layers
    onHistoryChanged(updatedLayers);

    return groupId;
  }

  /// Ungroups the specified layer by removing its groupId.
  ///
  /// This method removes the groupId from the specified layer and all other
  /// layers that share the same groupId, effectively breaking the group.
  ///
  /// [layer] The layer to ungroup.
  /// [activeLayers] The list of all active layers in the editor.
  /// [onHistoryChanged] Callback to trigger when the layer history
  /// needs to be updated.
  ///
  /// Returns true if any layers were ungrouped, false otherwise.
  bool ungroupLayer(
    Layer layer,
    List<Layer> activeLayers,
    Function(List<Layer> layers) onHistoryChanged,
  ) {
    if (layer.groupId == null) return false;

    final groupIdToRemove = layer.groupId!;

    // Create a copy of the layers list for history
    final updatedLayers = <Layer>[];
    bool hasChanges = false;

    for (final currentLayer in activeLayers) {
      final layerCopy = _copyLayer(currentLayer);
      if (currentLayer.groupId == groupIdToRemove) {
        // Remove the groupId from layers in the group
        layerCopy.groupId = null;
        hasChanges = true;
      }
      updatedLayers.add(layerCopy);
    }

    if (hasChanges) {
      // Update history with the modified layers
      onHistoryChanged(updatedLayers);
    }

    return hasChanges;
  }

  /// Creates a copy of a layer with all its properties.
  Layer _copyLayer(Layer originalLayer) {
    // Copy layer-specific properties based on layer type
    if (originalLayer is TextLayer) {
      return TextLayer(
        id: originalLayer.id,
        text: originalLayer.text,
        textStyle: originalLayer.textStyle,
        colorMode: originalLayer.colorMode,
        color: originalLayer.color,
        background: originalLayer.background,
        align: originalLayer.align,
        fontScale: originalLayer.fontScale,
        customSecondaryColor: originalLayer.customSecondaryColor,
        maxTextWidth: originalLayer.maxTextWidth,
        hit: originalLayer.hit,
        key: originalLayer.key,
        interaction: originalLayer.interaction,
        offset: originalLayer.offset,
        rotation: originalLayer.rotation,
        scale: originalLayer.scale,
        flipX: originalLayer.flipX,
        flipY: originalLayer.flipY,
        meta: originalLayer.meta,
        boxConstraints: originalLayer.boxConstraints,
      )..groupId = originalLayer.groupId;
    } else if (originalLayer is EmojiLayer) {
      return EmojiLayer(
        id: originalLayer.id,
        emoji: originalLayer.emoji,
        key: originalLayer.key,
        interaction: originalLayer.interaction,
        offset: originalLayer.offset,
        rotation: originalLayer.rotation,
        scale: originalLayer.scale,
        flipX: originalLayer.flipX,
        flipY: originalLayer.flipY,
        meta: originalLayer.meta,
        boxConstraints: originalLayer.boxConstraints,
      )..groupId = originalLayer.groupId;
    } else if (originalLayer is PaintLayer) {
      return PaintLayer(
        id: originalLayer.id,
        items: [...originalLayer.items],
        rawSize: originalLayer.rawSize,
        opacity: originalLayer.opacity,
        key: originalLayer.key,
        interaction: originalLayer.interaction,
        offset: originalLayer.offset,
        rotation: originalLayer.rotation,
        scale: originalLayer.scale,
        flipX: originalLayer.flipX,
        flipY: originalLayer.flipY,
        meta: originalLayer.meta,
        boxConstraints: originalLayer.boxConstraints,
      )..groupId = originalLayer.groupId;
    } else if (originalLayer is WidgetLayer) {
      return WidgetLayer(
        id: originalLayer.id,
        widget: originalLayer.widget,
        exportConfigs: originalLayer.exportConfigs,
        key: originalLayer.key,
        interaction: originalLayer.interaction,
        offset: originalLayer.offset,
        rotation: originalLayer.rotation,
        scale: originalLayer.scale,
        flipX: originalLayer.flipX,
        flipY: originalLayer.flipY,
        meta: originalLayer.meta,
        boxConstraints: originalLayer.boxConstraints,
      )..groupId = originalLayer.groupId;
    }

    // Fallback for base Layer type
    return Layer(
      id: originalLayer.id,
      key: originalLayer.key,
      interaction: originalLayer.interaction,
      offset: originalLayer.offset,
      rotation: originalLayer.rotation,
      scale: originalLayer.scale,
      flipX: originalLayer.flipX,
      flipY: originalLayer.flipY,
      meta: originalLayer.meta,
      boxConstraints: originalLayer.boxConstraints,
      groupId: originalLayer.groupId,
    );
  }

  /// Helper variable for scaling during rotation of a layer.
  double? rotateScaleLayerScaleHelper;

  /// Helper variable for storing the size of a layer during rotation and
  /// scaling operations.
  Size? rotateScaleLayerSizeHelper;

  /// Represents the layer being interacted with during a
  /// scale or rotate gesture.
  ///
  /// This is set when the user drags the scale/rotate button from the
  /// selection overlay.
  Layer? activeInteractionLayer;

  /// Last recorded X-axis position for layers.
  LayerLastPosition lastPositionX = LayerLastPosition.center;

  /// Last recorded Y-axis position for layers.
  LayerLastPosition lastPositionY = LayerLastPosition.center;

  /// Local offset of the edge that was closest to the vertical center line in
  /// the previous move frame. Used to detect when the closest edge switches so
  /// the center-line snap is not falsely triggered by the resulting jump in the
  /// tracked position.
  double? _activeClosestLocalOffsetX;

  /// Local offset of the edge that was closest to the horizontal center line in
  /// the previous move frame.
  double? _activeClosestLocalOffsetY;

  Offset? _rotateScaleButtonStartPosition;
  final _horizontalSnapHelper = _LayerAlignGuideHelper();
  final _verticalSnapHelper = _LayerAlignGuideHelper();

  /// Whether [_updateAlignmentGuides] has set up its per-drag state yet.
  bool _alignmentGuidesInitialized = false;

  /// X-axis snap targets the active layer already coincided with when the drag
  /// started. Smart layer targets use `(position, active-anchor kind)` so a
  /// left edge at the same coordinate cannot release a held center. Flag-off
  /// matching and custom guides use `(position, null)` to keep the original
  /// position-only suppression. Held until that key's distance exceeds the
  /// release threshold.
  final Set<(double, _SnapKind?)> _heldAlignXTargets = {};

  /// Y-axis counterpart of [_heldAlignXTargets].
  final Set<(double, _SnapKind?)> _heldAlignYTargets = {};

  /// Pointer-driven offset for the active drag, before helper-line snapping.
  ///
  /// Snap may rewrite [Layer.offset] for display; this value keeps accumulating
  /// the finger/mouse delta so release can be measured from the intended
  /// position rather than the glued snapped position.
  final Map<String, Offset> _unconstrainedOffsets = {};

  /// Optional override for helper line configuration at runtime.
  ///
  /// When set, this takes precedence over [configs.helperLines], allowing
  /// helper lines to be toggled without recreating the editor widget.
  HelperLineConfigs? helperLinesOverride;

  /// Configuration settings for displaying and managing helper lines within
  /// the editor.
  HelperLineConfigs get helperLineConfigs =>
      helperLinesOverride ?? configs.helperLines;

  /// Resets the state of the layer interaction manager by:
  ///
  /// - Setting `_rotateScaleButtonStartPosition` to `null`.
  /// - Setting `_rotationStartedHelper` to `false`.
  /// - Enabling the display of helper lines by setting `showHelperLines` to
  /// `true`.
  void reset() {
    _rotateScaleButtonStartPosition = null;
    _rotationStartedHelper = false;
    showHelperLines = true;
  }

  Offset _getFractionalLayerOffset(Layer layer) {
    if (layer.isTextLayer) {
      return configs.textEditor.layerFractionalOffset;
    } else if (layer.isEmojiLayer) {
      return configs.emojiEditor.layerFractionalOffset;
    } else if (layer.isWidgetLayer) {
      return configs.stickerEditor.layerFractionalOffset;
    } else if (layer.isPaintLayer) {
      return configs.paintEditor.layerFractionalOffset;
    }
    return const Offset(-0.5, -0.5);
  }

  /// Returns the anchor whose position sits closest to the canvas center
  /// (position `0`). Used by the canvas helper lines.
  _LayerSnapAnchor _closestAnchor(List<_LayerSnapAnchor> anchors) {
    return anchors.reduce(
      (a, b) => a.position.abs() <= b.position.abs() ? a : b,
    );
  }

  /// Returns the anchor whose position sits closest to [target].
  _LayerSnapAnchor _nearestAnchorTo(
    List<_LayerSnapAnchor> anchors,
    double target,
  ) {
    return anchors.reduce(
      (a, b) =>
          (a.position - target).abs() <= (b.position - target).abs() ? a : b,
    );
  }

  /// Center-kind anchor, falling back to [_closestAnchor] if none is tagged.
  _LayerSnapAnchor _centerAnchor(List<_LayerSnapAnchor> anchors) {
    for (final anchor in anchors) {
      if (anchor.kind == _SnapKind.center) return anchor;
    }
    return _closestAnchor(anchors);
  }

  /// Anchor used by the canvas center helper lines.
  ///
  /// Smart alignment snaps the layer center only, so a wide text box does not
  /// hit the page midline three times (left, then center, then right).
  _LayerSnapAnchor _canvasSnapAnchor(List<_LayerSnapAnchor> anchors) {
    if (helperLineConfigs.enableSmartAlignment) {
      return _centerAnchor(anchors);
    }
    return _closestAnchor(anchors);
  }

  _SnapFamily _snapFamily(Layer layer) {
    if (layer is TextLayer) return _SnapFamily.text;
    if (layer is PaintLayer) return _SnapFamily.paint;
    return _SnapFamily.other;
  }

  Offset _snapLayerCenter(Layer layer) {
    return layer.computeOffsetFromCenterFraction(
      _getFractionalLayerOffset(layer),
    );
  }

  List<Layer> _nearestSnapLayers(Layer active, List<Layer> others) {
    final limit = helperLineConfigs.smartAlignmentNeighborLimit;
    if (limit <= 0) return const [];
    if (others.length <= limit) return others;

    // Measure every candidate once; the comparator runs O(n log n) times.
    final activeCenter = _snapLayerCenter(active);
    final distances = <String, double>{
      for (final layer in others)
        layer.id: (_snapLayerCenter(layer) - activeCenter).distance,
    };
    final ranked = [...others]
      ..sort((a, b) {
        final cmp = distances[a.id]!.compareTo(distances[b.id]!);
        if (cmp != 0) return cmp;
        return a.id.compareTo(b.id);
      });
    return ranked.sublist(0, limit);
  }

  _LayerSnapAnchor? _anchorForTarget({
    required List<_LayerSnapAnchor> activeAnchors,
    required _SnapGuideTarget target,
    required Layer activeLayer,
  }) {
    if (activeAnchors.isEmpty) return null;
    if (!helperLineConfigs.enableSmartAlignment || target.isCustom) {
      return _nearestAnchorTo(activeAnchors, target.position);
    }
    if (target.family == _snapFamily(activeLayer)) {
      for (final anchor in activeAnchors) {
        if (anchor.kind == target.kind) return anchor;
      }
      return null;
    }
    if (target.kind != _SnapKind.center) return null;
    for (final anchor in activeAnchors) {
      if (anchor.kind == _SnapKind.center) return anchor;
    }
    return null;
  }

  /// Suppression key for a target the active layer is currently matching.
  ///
  /// Smart layer-to-layer targets include the matched active-anchor kind so
  /// coincident edges cannot release each other. Legacy matching and custom
  /// guides stay position-only, matching the original hold behavior.
  (double, _SnapKind?) _heldAlignKey(
    _SnapGuideTarget target,
    _LayerSnapAnchor anchor,
  ) {
    if (helperLineConfigs.enableSmartAlignment && !target.isCustom) {
      return (target.position, anchor.kind);
    }
    return (target.position, null);
  }

  /// Returns the axis-aligned bounding size of [size] rotated by [rotation]
  /// (radians). Equals [size] when the rotation is a multiple of 180°.
  Size _rotatedBoundingSize(Size size, double rotation) {
    if (rotation == 0) return size;
    final double cosR = cos(rotation).abs();
    final double sinR = sin(rotation).abs();
    return Size(
      size.width * cosR + size.height * sinR,
      size.width * sinR + size.height * cosR,
    );
  }

  /// Layer types that expose their edges - not just their center - as snap
  /// anchors.
  ///
  /// Text and paint layers can be aligned by their visible edges (left/center/
  /// right and top/center/bottom); all other layer types expose only their
  /// configured center anchor.
  bool _supportsEdgeSnapping(Layer layer) =>
      helperLineConfigs.enableEdgeSnapping &&
      (layer is TextLayer ||
          (layer is PaintLayer && helperLineConfigs.enablePaintLayerSnapping));

  bool _excludePaintFromLayerAlign(Layer layer) =>
      !helperLineConfigs.enablePaintLayerSnapping && layer is PaintLayer;

  /// Returns the candidate horizontal snap anchors for [layer] in
  /// center-relative editor coordinates.
  ///
  /// Layers that support edge snapping expose their left, center and right
  /// edges; all others expose only their configured anchor.
  List<_LayerSnapAnchor> _horizontalSnapAnchors(Layer layer) {
    final fractionalOffset = _getFractionalLayerOffset(layer);
    final double center = layer
        .computeOffsetFromCenterFraction(fractionalOffset)
        .dx;
    final double localCenter = layer
        .computeLocalCenterOffset(fractionalOffset)
        .dx;

    final centerAnchor = _LayerSnapAnchor(
      position: center,
      localOffset: localCenter,
    );

    if (!_supportsEdgeSnapping(layer)) return [centerAnchor];

    // [renderSize] already reflects the on-screen (scaled) size - the layer's
    // content is rendered at its scaled size, not scaled by a Transform - so it
    // must not be multiplied by [scale] again.
    final size = layer.renderSize;
    if (size == null || size.isEmpty) return [centerAnchor];

    // Use the rotated axis-aligned bounding box so the edges still match a
    // rotated layer (collapses to width/2 when the layer is not rotated).
    final double halfWidth =
        _rotatedBoundingSize(size, layer.rotation).width / 2;
    return [
      _LayerSnapAnchor(
        position: center - halfWidth,
        localOffset: localCenter - halfWidth,
        kind: _SnapKind.start,
      ),
      centerAnchor,
      _LayerSnapAnchor(
        position: center + halfWidth,
        localOffset: localCenter + halfWidth,
        kind: _SnapKind.end,
      ),
    ];
  }

  /// Returns the candidate vertical snap anchors for [layer] in center-relative
  /// editor coordinates.
  ///
  /// Layers that support edge snapping expose their top, center and bottom
  /// edges; all others expose only their configured anchor.
  List<_LayerSnapAnchor> _verticalSnapAnchors(Layer layer) {
    final fractionalOffset = _getFractionalLayerOffset(layer);
    final double center = layer
        .computeOffsetFromCenterFraction(fractionalOffset)
        .dy;
    final double localCenter = layer
        .computeLocalCenterOffset(fractionalOffset)
        .dy;

    final centerAnchor = _LayerSnapAnchor(
      position: center,
      localOffset: localCenter,
    );

    if (!_supportsEdgeSnapping(layer)) return [centerAnchor];

    // [renderSize] already reflects the on-screen (scaled) size, so it must not
    // be multiplied by [scale] again.
    final size = layer.renderSize;
    if (size == null || size.isEmpty) return [centerAnchor];

    // Use the rotated axis-aligned bounding box so the edges still match a
    // rotated layer (collapses to height/2 when the layer is not rotated).
    final double halfHeight =
        _rotatedBoundingSize(size, layer.rotation).height / 2;
    return [
      _LayerSnapAnchor(
        position: center - halfHeight,
        localOffset: localCenter - halfHeight,
        kind: _SnapKind.start,
      ),
      centerAnchor,
      _LayerSnapAnchor(
        position: center + halfHeight,
        localOffset: localCenter + halfHeight,
        kind: _SnapKind.end,
      ),
    ];
  }

  /// Determines if layers are selectable based on the configuration and device
  /// type.
  bool layersAreSelectable(ProImageEditorConfigs configs) {
    if (configs.layerInteraction.selectable ==
        LayerInteractionSelectable.auto) {
      return isDesktop;
    }
    return configs.layerInteraction.selectable ==
        LayerInteractionSelectable.enabled;
  }

  /// Calculates scaling and rotation based on user interactions.
  void calculateInteractiveButtonScaleRotate({
    required double editorScaleFactor,
    required Offset editorScaleOffset,
    required ProImageEditorConfigs configs,
    required ScaleUpdateDetails details,
    required List<Layer> selectedLayers,
    required Size editorSize,
    required LayerInteractionStyle layerTheme,
  }) {
    /// Calculates the rotation angle (in radians) for a button moved to a
    /// new position.
    /// [oldPosition] is the initial button position,
    /// [newPosition] is the final button position.
    double calculateRotation(Offset oldPosition, Offset newPosition) {
      // Calculate the vectors from the origin to the old and new positions
      Offset oldVector = oldPosition;
      Offset newVector = newPosition;

      // Get the angle of each vector relative to the x-axis
      double oldAngle = atan2(oldVector.dy, oldVector.dx);
      double newAngle = atan2(newVector.dy, newVector.dx);

      // Calculate the rotation angle
      double rotation = newAngle - oldAngle;

      // Normalize the rotation angle to be between -pi and pi
      if (rotation > pi) rotation -= 2 * pi;
      if (rotation < -pi) rotation += 2 * pi;

      return rotation; // In radians
    }

    /// Calculates the scale factor based on the movement of a button.
    /// [oldPosition] is the initial button position,
    /// [newPosition] is the final button position.
    double calculateScale(Offset oldPosition, Offset newPosition) {
      // Calculate distances from the origin to the old and new positions
      double oldDistance = (oldPosition).distance;
      double newDistance = (newPosition).distance;

      // Calculate the scale factor
      if (oldDistance == 0 || newDistance == 0) {
        return 1;
      }

      return newDistance / oldDistance;
    }

    for (Layer layer in selectedLayers) {
      /// Optionally, this could be extended to allow multiple layers to be
      /// transformed using a single layer interaction button.
      if (activeInteractionLayer?.id != layer.id) continue;

      Offset layerOffset = layer.offset;

      Offset realTouchPosition =
          (details.localFocalPoint - editorScaleOffset) / editorScaleFactor;

      Offset touchPositionFromLayerCenter =
          realTouchPosition - editorSize.center(Offset.zero) - layerOffset;

      if (layer.flipX) {
        touchPositionFromLayerCenter = Offset(
          -touchPositionFromLayerCenter.dx,
          touchPositionFromLayerCenter.dy,
        );
      }
      if (layer.flipY) {
        touchPositionFromLayerCenter = Offset(
          touchPositionFromLayerCenter.dx,
          -touchPositionFromLayerCenter.dy,
        );
      }

      _rotateScaleButtonStartPosition ??= touchPositionFromLayerCenter;

      if (layer.interaction.enableScale) {
        layer.scale =
            _getLayerBaseScale(layer.id) *
            calculateScale(
              _rotateScaleButtonStartPosition!,
              touchPositionFromLayerCenter,
            );
        _setMinMaxScaleFactor(configs, layer);
      }

      if (layer.interaction.enableRotate) {
        layer.rotation =
            _getLayerBaseAngle(layer.id) +
            calculateRotation(
              _rotateScaleButtonStartPosition!,
              touchPositionFromLayerCenter,
            );

        checkRotationLine(
          layer: layer,
          editorSize: editorSize,
          editorScaleFactor: editorScaleFactor,
        );
      }
    }
  }

  /// Calculates movement of a layer based on user interactions, considering
  /// various conditions such as hit areas and screen boundaries.
  void calculateMovement({
    required double editorScaleFactor,
    required BuildContext context,
    required ScaleUpdateDetails detail,
    required List<Layer> selectedLayers,
    required List<Layer> layerList,
    required GlobalKey removeAreaKey,
    required Function(bool value) onHoveredRemoveChanged,
    required StreamController<void> helperLineCtrl,
    required Size editorBodySize,
  }) {
    if (_activeScale) return;

    _checkLayerHoverRemoveArea(
      detail: detail,
      onHoveredRemoveChanged: onHoveredRemoveChanged,
      removeAreaKey: removeAreaKey,
    );

    bool hasMultiSelection = selectedLayers.length > 1;
    if (!layerWasTransformed) {
      layerWasTransformed = selectedLayers.isNotEmpty;
    }
    for (Layer layer in selectedLayers) {
      if (!layer.interaction.enableMove) continue;

      final pointerDelta = Offset(
        detail.focalPointDelta.dx / editorScaleFactor,
        detail.focalPointDelta.dy / editorScaleFactor,
      );
      if (helperLineConfigs.enableSmartAlignment) {
        final intended =
            (_unconstrainedOffsets[layer.id] ?? layer.offset) + pointerDelta;
        _unconstrainedOffsets[layer.id] = intended;
        layer.offset = intended;
      } else {
        layer.offset = Offset(
          layer.offset.dx + pointerDelta.dx,
          layer.offset.dy + pointerDelta.dy,
        );
      }

      if (hasMultiSelection ||
          (editorScaleFactor > 1 && helperLineConfigs.isDisabledAtZoom) ||
          _excludePaintFromLayerAlign(layer)) {
        continue;
      }

      /// Text and paint layers expose their edges as snap anchors; the edge
      /// currently closest to a center line is the one that snaps to it. The
      /// same closest anchor is computed in [onScaleStart] so the snapping
      /// hysteresis starts from a consistent state (avoiding an immediate
      /// jump). Smart alignment always uses the center so a wide box does not
      /// hit the page midline three times.
      final closestX = _canvasSnapAnchor(_horizontalSnapAnchors(layer));
      final closestY = _canvasSnapAnchor(_verticalSnapAnchors(layer));

      /// When the closest edge switches (e.g. from the left edge to the center)
      /// the tracked position flips discontinuously; suppress a new snap on
      /// that frame so only a genuine crossing snaps to the center line.
      final bool anchorSwitchedX =
          _activeClosestLocalOffsetX != null &&
          _activeClosestLocalOffsetX != closestX.localOffset;
      final bool anchorSwitchedY =
          _activeClosestLocalOffsetY != null &&
          _activeClosestLocalOffsetY != closestY.localOffset;
      _activeClosestLocalOffsetX = closestX.localOffset;
      _activeClosestLocalOffsetY = closestY.localOffset;

      final releaseThreshold = helperLineConfigs.releaseThreshold;
      bool hasLineHit = false;
      double posX = closestX.position;
      double posY = closestY.position;

      bool hitAreaX =
          detail.focalPoint.dx >= snapStartPosX - releaseThreshold &&
          detail.focalPoint.dx <= snapStartPosX + releaseThreshold;
      bool hitAreaY =
          detail.focalPoint.dy >= snapStartPosY - releaseThreshold &&
          detail.focalPoint.dy <= snapStartPosY + releaseThreshold;

      bool helperGoNearLineLeft =
          posX >= 0 && lastPositionX == LayerLastPosition.left;
      bool helperGoNearLineRight =
          posX <= 0 && lastPositionX == LayerLastPosition.right;
      bool helperGoNearLineTop =
          posY >= 0 && lastPositionY == LayerLastPosition.top;
      bool helperGoNearLineBottom =
          posY <= 0 && lastPositionY == LayerLastPosition.bottom;

      /// Calc vertical helper line
      if (helperLineConfigs.showVerticalLine) {
        if ((!anchorSwitchedX &&
                !showVerticalHelperLine &&
                (helperGoNearLineLeft || helperGoNearLineRight)) ||
            (showVerticalHelperLine && hitAreaX)) {
          if (!showVerticalHelperLine) {
            hasLineHit = true;
            snapStartPosX = detail.focalPoint.dx;
          }
          showVerticalHelperLine = true;
          layer.offset = Offset(-closestX.localOffset, layer.offset.dy);
          lastPositionX = LayerLastPosition.center;
        } else {
          showVerticalHelperLine = false;
          lastPositionX = posX <= 0
              ? LayerLastPosition.left
              : LayerLastPosition.right;
        }
      }

      if (helperLineConfigs.showHorizontalLine) {
        /// Calc horizontal helper line
        if ((!anchorSwitchedY &&
                !showHorizontalHelperLine &&
                (helperGoNearLineTop || helperGoNearLineBottom)) ||
            (showHorizontalHelperLine && hitAreaY)) {
          if (!showHorizontalHelperLine) {
            hasLineHit = true;
            snapStartPosY = detail.focalPoint.dy;
          }
          showHorizontalHelperLine = true;
          layer.offset = Offset(layer.offset.dx, -closestY.localOffset);
          lastPositionY = LayerLastPosition.center;
        } else {
          showHorizontalHelperLine = false;
          lastPositionY = posY <= 0
              ? LayerLastPosition.top
              : LayerLastPosition.bottom;
        }
      }

      _updateAlignmentGuides(
        detail: detail,
        layerList: layerList,
        activeLayer: layer,
        helperLineCtrl: helperLineCtrl,
        editorScaleFactor: editorScaleFactor,
        editorBodySize: editorBodySize,
      );

      if (hasLineHit) {
        if (showHorizontalHelperLine) {
          helperLinesCallbacks?.handleHorizontalLineHit();
        }
        if (showVerticalHelperLine) {
          helperLinesCallbacks?.handleVerticalLineHit();
        }
      }
    }
  }

  void _addSharedAxisTargets({
    required List<Layer> others,
    required double snapThreshold,
    required void Function(double pos, _SnapKind kind, _SnapFamily? family)
    addX,
    required void Function(double pos, _SnapKind kind, _SnapFamily? family)
    addY,
  }) {
    void addClusters({
      required bool horizontal,
      required void Function(double pos, _SnapKind kind, _SnapFamily? family)
      add,
    }) {
      final edgeBuckets = <(_SnapFamily, _SnapKind), List<double>>{};
      final centerPositions = <double>[];
      for (final layer in others) {
        final family = _snapFamily(layer);
        final anchors = horizontal
            ? _horizontalSnapAnchors(layer)
            : _verticalSnapAnchors(layer);
        for (final anchor in anchors) {
          if (anchor.kind == _SnapKind.center) {
            centerPositions.add(anchor.position);
          } else {
            edgeBuckets
                .putIfAbsent((family, anchor.kind), () => [])
                .add(anchor.position);
          }
        }
      }

      final sharedMin = helperLineConfigs.smartAlignmentSharedAxisMin;

      void emit(List<double> positions, _SnapKind kind, _SnapFamily? family) {
        final sorted = [...positions]..sort();
        var i = 0;
        while (i < sorted.length) {
          var j = i + 1;
          var sum = sorted[i];
          while (j < sorted.length && sorted[j] - sorted[i] <= snapThreshold) {
            sum += sorted[j];
            j++;
          }
          if (j - i >= sharedMin) {
            // Snap to the real edge closest to the cluster's mean instead of
            // the mean itself, so the guide always overlays an actual layer
            // edge rather than a position no layer sits on.
            final mean = sum / (j - i);
            var best = sorted[i];
            for (var k = i + 1; k < j; k++) {
              if ((sorted[k] - mean).abs() < (best - mean).abs()) {
                best = sorted[k];
              }
            }
            add(best, kind, family);
          }
          i = j;
        }
      }

      // Centers count across layer types so a token and a label on the same
      // X still form a global column. Edges stay type-specific (text lefts
      // do not mix with paint lefts).
      emit(centerPositions, _SnapKind.center, null);
      for (final entry in edgeBuckets.entries) {
        emit(entry.value, entry.key.$2, entry.key.$1);
      }
    }

    addClusters(horizontal: true, add: addX);
    addClusters(horizontal: false, add: addY);
  }

  void _checkLayerHoverRemoveArea({
    required ScaleUpdateDetails detail,
    required GlobalKey removeAreaKey,
    required Function(bool value) onHoveredRemoveChanged,
  }) {
    RenderBox? box =
        removeAreaKey.currentContext?.findRenderObject() as RenderBox?;
    if (box != null) {
      Offset position = box.localToGlobal(Offset.zero);
      bool hit = Rect.fromLTWH(
        position.dx,
        position.dy,
        box.size.width,
        box.size.height,
      ).contains(detail.focalPoint);
      if (hoverRemoveBtn != hit) {
        hoverRemoveBtn = hit;
        onHoveredRemoveChanged.call(hoverRemoveBtn);
      }
    }
  }

  /// Calculates scaling and rotation of a layer based on user interactions.
  void calculateScaleRotate({
    required ProImageEditorConfigs configs,
    required ScaleUpdateDetails detail,
    required List<Layer> selectedLayers,
    required Size editorSize,
    required double editorScaleFactor,
    required EdgeInsets screenPaddingHelper,
  }) {
    _activeScale = true;
    bool enableMobilePinchScale =
        configs.layerInteraction.enableMobilePinchScale;
    bool enableMobilePinchRotate =
        configs.layerInteraction.enableMobilePinchRotate;

    if (enableMobilePinchScale || enableMobilePinchRotate) {
      if (!layerWasTransformed) {
        layerWasTransformed = selectedLayers.isNotEmpty;
      }
      for (Layer layer in selectedLayers) {
        if (layer.interaction.enableScale && enableMobilePinchScale) {
          layer.scale = _getLayerBaseScale(layer.id) * detail.scale;
          _setMinMaxScaleFactor(configs, layer);
        }
        if (layer.interaction.enableRotate && enableMobilePinchRotate) {
          layer.rotation = _getLayerBaseAngle(layer.id) + detail.rotation;

          if (selectedLayers.length <= 1) {
            checkRotationLine(
              layer: layer,
              editorSize: editorSize,
              editorScaleFactor: editorScaleFactor,
            );
          }
        }
      }
    }

    scaleDebounce(() => _activeScale = false);
  }

  /// Checks the rotation line based on user interactions, adjusting rotation
  /// accordingly.
  void checkRotationLine({
    required Layer layer,
    required Size editorSize,
    required double editorScaleFactor,
  }) {
    if (!helperLineConfigs.showRotateLine ||
        (editorScaleFactor > 1 && helperLineConfigs.isDisabledAtZoom)) {
      return;
    }

    double rotation = layer.rotation - _getLayerBaseAngle(layer.id);
    double hitSpanX = helperLineConfigs.releaseThreshold / 2;
    double deg = layer.rotation * 180 / pi;
    double degChange = rotation * 180 / pi;
    double degHit = (_getLayerSnapStartRotation(layer.id) + degChange) % 45;

    bool hitAreaBelow = degHit <= hitSpanX;
    bool hitAreaAfter = degHit >= 45 - hitSpanX;
    bool hitArea = hitAreaBelow || hitAreaAfter;

    double lastRotation = _getLayerSnapLastRotation(layer.id);

    if ((!showRotationHelperLine &&
            ((degHit > 0 && degHit <= hitSpanX && lastRotation < deg) ||
                (degHit < 45 &&
                    degHit >= 45 - hitSpanX &&
                    lastRotation > deg))) ||
        (showRotationHelperLine && hitArea)) {
      if (_rotationStartedHelper) {
        layer.rotation =
            (deg - (degHit > 45 - hitSpanX ? degHit - 45 : degHit)) / 180 * pi;
        rotationHelperLineDeg = layer.rotation;

        final Offset fractionalOffset = _getFractionalLayerOffset(layer);
        layer.computeLocalCenterOffset(fractionalOffset);
        final Offset layerCenterOffset = layer.computeOffsetFromCenterFraction(
          fractionalOffset,
        );

        double posY = layerCenterOffset.dy;
        double posX = layerCenterOffset.dx;

        rotationHelperLineX = posX + editorSize.width / 2;
        rotationHelperLineY = posY + editorSize.height / 2;
        if (!showRotationHelperLine) {
          helperLinesCallbacks?.handleRotateLineHit();
        }
        showRotationHelperLine = true;
      }
      _snapLastRotation[layer.id] = deg;
    } else {
      showRotationHelperLine = false;
      _rotationStartedHelper = true;
    }
  }

  /// Handles the initialization logic when a scaling gesture starts on a layer.
  void onScaleStart({
    required ScaleStartDetails details,
    required List<Layer> selectedLayers,
  }) {
    selectedLayersScaleStart = selectedLayers;
    snapStartPosX = details.focalPoint.dx;
    snapStartPosY = details.focalPoint.dy;

    _alignmentGuidesInitialized = false;
    _heldAlignXTargets.clear();
    _heldAlignYTargets.clear();
    _horizontalSnapHelper.reset();
    _verticalSnapHelper.reset();
    _unconstrainedOffsets.clear();

    for (Layer layer in selectedLayers) {
      _unconstrainedOffsets[layer.id] = layer.offset;
      _baseScaleFactor[layer.id] = layer.scale;
      _baseAngleFactor[layer.id] = layer.rotation;
      _snapStartRotation[layer.id] = layer.rotation * 180 / pi;
      _snapLastRotation[layer.id] = _getLayerSnapStartRotation(layer.id);
      reset();

      // Initialize the snap hysteresis from the same canvas-line anchor that
      // [calculateMovement] evaluates, so dragging never starts with an
      // immediate jump to a center line.
      final closestX = _canvasSnapAnchor(_horizontalSnapAnchors(layer));
      final closestY = _canvasSnapAnchor(_verticalSnapAnchors(layer));
      double posX = closestX.position;
      double posY = closestY.position;
      _activeClosestLocalOffsetX = closestX.localOffset;
      _activeClosestLocalOffsetY = closestY.localOffset;

      final releaseThreshold = helperLineConfigs.releaseThreshold;

      lastPositionY = posY <= -releaseThreshold
          ? LayerLastPosition.top
          : posY >= releaseThreshold
          ? LayerLastPosition.bottom
          : LayerLastPosition.center;
      lastPositionX = posX <= -releaseThreshold
          ? LayerLastPosition.left
          : posX >= releaseThreshold
          ? LayerLastPosition.right
          : LayerLastPosition.center;
    }
  }

  /// Handles cleanup and resets various flags and states after scaling
  /// interaction ends.
  void onScaleEnd() {
    _baseScaleFactor.clear();
    _baseAngleFactor.clear();
    _snapStartRotation.clear();
    _snapLastRotation.clear();

    selectedLayersScaleStart.clear();
    enabledHitDetection = true;
    layerWasTransformed = false;
    showHorizontalHelperLine = false;
    showVerticalHelperLine = false;
    showRotationHelperLine = false;
    isVerticalGuideVisible = false;
    isHorizontalGuideVisible = false;
    isVerticalGuideCustom = false;
    isHorizontalGuideCustom = false;
    showHelperLines = false;
    hoverRemoveBtn = false;
    _activeClosestLocalOffsetX = null;
    _activeClosestLocalOffsetY = null;
    _alignmentGuidesInitialized = false;
    _heldAlignXTargets.clear();
    _heldAlignYTargets.clear();
    _unconstrainedOffsets.clear();
  }

  /// Rotate a layer.
  ///
  /// This method rotates a layer based on various factors, including flip and
  /// angle.
  void rotateLayer({
    required Layer layer,
    required bool beforeIsFlipX,
    required double newImgW,
    required double newImgH,
    required double rotationScale,
    required double rotationRadian,
    required double rotationAngle,
  }) {
    if (beforeIsFlipX) {
      layer.rotation -= rotationRadian;
    } else {
      layer.rotation += rotationRadian;
    }

    if (rotationAngle == 90) {
      layer
        ..scale /= rotationScale
        ..offset = Offset(
          newImgW - layer.offset.dy / rotationScale,
          layer.offset.dx / rotationScale,
        );
    } else if (rotationAngle == 180) {
      layer.offset = Offset(
        newImgW - layer.offset.dx,
        newImgH - layer.offset.dy,
      );
    } else if (rotationAngle == 270) {
      layer
        ..scale /= rotationScale
        ..offset = Offset(
          layer.offset.dy / rotationScale,
          newImgH - layer.offset.dx / rotationScale,
        );
    }
  }

  /// Handles zooming of a layer.
  ///
  /// This method calculates the zooming of a layer based on the specified
  /// parameters.
  /// It checks if the layer should be zoomed and performs the necessary
  /// transformations.
  ///
  /// Returns `true` if the layer was zoomed, otherwise `false`.
  bool zoomedLayer({
    required Layer layer,
    required double scale,
    required double scaleX,
    required double oldFullH,
    required double oldFullW,
    required double pixelRatio,
    required Rect cropRect,
    required bool isHalfPi,
  }) {
    var paddingTop = cropRect.top / pixelRatio;
    var paddingLeft = cropRect.left / pixelRatio;
    var paddingRight = oldFullW - cropRect.right;
    var paddingBottom = oldFullH - cropRect.bottom;

    // important to check with < 1 and >-1 cuz crop-editor has rounding bugs
    if (paddingTop > 0.1 ||
        paddingTop < -0.1 ||
        paddingLeft > 0.1 ||
        paddingLeft < -0.1 ||
        paddingRight > 0.1 ||
        paddingRight < -0.1 ||
        paddingBottom > 0.1 ||
        paddingBottom < -0.1) {
      var initialIconX = (layer.offset.dx - paddingLeft) * scaleX;
      var initialIconY = (layer.offset.dy - paddingTop) * scaleX;
      layer
        ..offset = Offset(initialIconX, initialIconY)
        ..scale *= scale;
      return true;
    }
    return false;
  }

  /// Flip a layer horizontally or vertically.
  ///
  /// This method flips a layer either horizontally or vertically based on the
  /// specified parameters.
  void flipLayer({
    required Layer layer,
    required bool flipX,
    required bool flipY,
    required bool isHalfPi,
    required double imageWidth,
    required double imageHeight,
  }) {
    if (flipY) {
      if (isHalfPi) {
        layer.flipY = !layer.flipY;
      } else {
        layer.flipX = !layer.flipX;
      }
      layer.offset = Offset(imageWidth - layer.offset.dx, layer.offset.dy);
    }
    if (flipX) {
      layer
        ..flipX = !layer.flipX
        ..offset = Offset(layer.offset.dx, imageHeight - layer.offset.dy);
    }
  }

  void _setMinMaxScaleFactor(ProImageEditorConfigs configs, Layer layer) {
    if (layer is PaintLayer) {
      layer.scale = layer.scale.clamp(
        configs.paintEditor.minScale,
        configs.paintEditor.maxScale,
      );
    } else if (layer is TextLayer) {
      layer.scale = layer.scale.clamp(
        configs.textEditor.minScale,
        configs.textEditor.maxScale,
      );
    } else if (layer is EmojiLayer) {
      layer.scale = layer.scale.clamp(
        configs.emojiEditor.minScale,
        configs.emojiEditor.maxScale,
      );
    } else if (layer is WidgetLayer) {
      layer.scale = layer.scale.clamp(
        configs.stickerEditor.minScale,
        configs.stickerEditor.maxScale,
      );
    }
  }

  void _updateAlignmentGuides({
    required List<Layer> layerList,
    required Layer activeLayer,
    required ScaleUpdateDetails detail,
    required StreamController<void> helperLineCtrl,
    required double editorScaleFactor,
    required Size editorBodySize,
  }) {
    final showLayerAlign = helperLineConfigs.showLayerAlignLine;
    final customGuides = helperLineConfigs.customGuides;
    if (!showLayerAlign && customGuides.isEmpty) return;

    final snapThreshold = 3.0 / editorScaleFactor;
    final releaseThreshold = helperLineConfigs.releaseThreshold;
    final holdUntil = max(snapThreshold, releaseThreshold);

    final wasHorizontalGuideVisible = isHorizontalGuideVisible;
    final wasVerticalGuideVisible = isVerticalGuideVisible;

    // Reset guide visibility
    isHorizontalGuideVisible = false;
    isVerticalGuideVisible = false;

    final xTargets = <_SnapGuideTarget>[];
    final yTargets = <_SnapGuideTarget>[];

    void addTarget(
      List<_SnapGuideTarget> list,
      double pos, {
      bool isCustom = false,
      _SnapKind kind = _SnapKind.center,
      _SnapFamily? family,
    }) {
      if (list.any((t) {
        if ((t.position - pos).abs() >= snapThreshold) return false;
        // Custom guides are added first and always own that line.
        if (t.isCustom) return true;
        if (!helperLineConfigs.enableSmartAlignment) return true;
        return t.isCustom == isCustom && t.kind == kind && t.family == family;
      })) {
        return;
      }
      list.add(
        _SnapGuideTarget(
          position: pos,
          isCustom: isCustom,
          kind: kind,
          family: family,
        ),
      );
    }

    void addLayerAnchors(Layer layer) {
      final family = _snapFamily(layer);
      for (final anchor in _horizontalSnapAnchors(layer)) {
        addTarget(xTargets, anchor.position, kind: anchor.kind, family: family);
      }
      for (final anchor in _verticalSnapAnchors(layer)) {
        addTarget(yTargets, anchor.position, kind: anchor.kind, family: family);
      }
    }

    // App-defined custom guides take priority over layer-alignment guides.
    final halfWidth = editorBodySize.width / 2;
    final halfHeight = editorBodySize.height / 2;
    for (final guide in customGuides) {
      final pos = guide.resolvePosition(editorBodySize);
      if (guide.axis == Axis.vertical) {
        addTarget(xTargets, pos - halfWidth, isCustom: true);
      } else {
        addTarget(yTargets, pos - halfHeight, isCustom: true);
      }
    }

    if (showLayerAlign && !_excludePaintFromLayerAlign(activeLayer)) {
      final others = <Layer>[
        for (final layer in layerList)
          if (layer != activeLayer && !_excludePaintFromLayerAlign(layer))
            layer,
      ];
      if (helperLineConfigs.enableSmartAlignment) {
        for (final layer in _nearestSnapLayers(activeLayer, others)) {
          addLayerAnchors(layer);
        }
        _addSharedAxisTargets(
          others: others,
          snapThreshold: snapThreshold,
          addX: (pos, kind, family) =>
              addTarget(xTargets, pos, kind: kind, family: family),
          addY: (pos, kind, family) =>
              addTarget(yTargets, pos, kind: kind, family: family),
        );
      } else {
        for (final layer in others) {
          addLayerAnchors(layer);
        }
      }
    }

    final intended = helperLineConfigs.enableSmartAlignment
        ? _unconstrainedOffsets[activeLayer.id]
        : null;
    final displayOffset = activeLayer.offset;
    if (intended != null) {
      activeLayer.offset = intended;
    }
    final activeXAnchors = _horizontalSnapAnchors(activeLayer);
    final activeYAnchors = _verticalSnapAnchors(activeLayer);
    if (intended != null) {
      activeLayer.offset = displayOffset;
    }

    (double, _SnapKind?)? heldKeyIfCoincident(
      _SnapGuideTarget target,
      List<_LayerSnapAnchor> anchors,
    ) {
      final anchor = _anchorForTarget(
        activeAnchors: anchors,
        target: target,
        activeLayer: activeLayer,
      );
      if (anchor == null) return null;
      if ((anchor.position - target.position).abs() > snapThreshold) {
        return null;
      }
      return _heldAlignKey(target, anchor);
    }

    if (!_alignmentGuidesInitialized) {
      _alignmentGuidesInitialized = true;
      // Remember the target+anchor pairs the active layer already sat on when
      // the drag begins, so they don't immediately trap it. Without this a
      // layer that shares its position with others (e.g. a stack of overlapping
      // layers) is held in place by their coincident alignment guides and
      // can't be dragged away until the pointer travels past every pair.
      _heldAlignXTargets
        ..clear()
        ..addAll([
          for (final t in xTargets) ?heldKeyIfCoincident(t, activeXAnchors),
        ]);
      _heldAlignYTargets
        ..clear()
        ..addAll([
          for (final t in yTargets) ?heldKeyIfCoincident(t, activeYAnchors),
        ]);
    }

    _SnapGuideTarget? matchedX;
    _LayerSnapAnchor? matchedXAnchor;
    for (final target in xTargets) {
      final anchor = _anchorForTarget(
        activeAnchors: activeXAnchors,
        target: target,
        activeLayer: activeLayer,
      );
      if (anchor == null) continue;

      final double distanceX = (anchor.position - target.position).abs();
      final key = _heldAlignKey(target, anchor);

      if (_heldAlignXTargets.contains(key)) {
        if (distanceX <= holdUntil) {
          continue;
        }
        _heldAlignXTargets.remove(key);
        continue;
      }

      if (distanceX <= snapThreshold &&
          (helperLineConfigs.enableSmartAlignment ||
              _verticalSnapHelper.maybeSnap(
                focal: detail.focalPoint.dx,
                focalDelta: detail.focalPointDelta.dx,
                // Encode the snapping edge so every edge can reach the same
                // target.
                offset: Offset(target.position, anchor.localOffset),
                threshold: snapThreshold,
                releaseThreshold: releaseThreshold,
                positiveDirection: LayerLastPosition.left,
                negativeDirection: LayerLastPosition.right,
              ))) {
        matchedX = target;
        matchedXAnchor = anchor;
        break;
      }
    }

    _SnapGuideTarget? matchedY;
    _LayerSnapAnchor? matchedYAnchor;
    for (final target in yTargets) {
      final anchor = _anchorForTarget(
        activeAnchors: activeYAnchors,
        target: target,
        activeLayer: activeLayer,
      );
      if (anchor == null) continue;

      final double distanceY = (anchor.position - target.position).abs();
      final key = _heldAlignKey(target, anchor);

      if (_heldAlignYTargets.contains(key)) {
        if (distanceY <= holdUntil) {
          continue;
        }
        _heldAlignYTargets.remove(key);
        continue;
      }

      if (distanceY <= snapThreshold &&
          (helperLineConfigs.enableSmartAlignment ||
              _horizontalSnapHelper.maybeSnap(
                focal: detail.focalPoint.dy,
                focalDelta: detail.focalPointDelta.dy,
                // Encode the snapping edge so every edge can reach the same
                // target.
                offset: Offset(anchor.localOffset, target.position),
                threshold: snapThreshold,
                releaseThreshold: releaseThreshold,
                positiveDirection: LayerLastPosition.top,
                negativeDirection: LayerLastPosition.bottom,
              ))) {
        matchedY = target;
        matchedYAnchor = anchor;
        break;
      }
    }

    // Handle vertical snapping
    if (matchedX != null) {
      verticalGuideOffset = Offset(matchedX.position, 0);
      isVerticalGuideVisible = true;
      isVerticalGuideCustom = matchedX.isCustom;

      activeLayer.offset = Offset(
        matchedX.position - matchedXAnchor!.localOffset,
        activeLayer.offset.dy,
      );
    }

    // Handle horizontal snapping
    if (matchedY != null) {
      horizontalGuideOffset = Offset(0, matchedY.position);
      isHorizontalGuideVisible = true;
      isHorizontalGuideCustom = matchedY.isCustom;

      activeLayer.offset = Offset(
        activeLayer.offset.dx,
        matchedY.position - matchedYAnchor!.localOffset,
      );
    }

    // Notify UI only if something changed
    final hasChanged =
        isHorizontalGuideVisible != wasHorizontalGuideVisible ||
        isVerticalGuideVisible != wasVerticalGuideVisible;

    if (hasChanged) {
      helperLineCtrl.add(null);

      if ((isHorizontalGuideVisible && !wasHorizontalGuideVisible) ||
          (isVerticalGuideVisible && !wasVerticalGuideVisible)) {
        helperLinesCallbacks?.handleLayerAlignLineHit();
      }
    }
  }
}

enum _SnapKind { start, center, end }

enum _SnapFamily { text, paint, other }

/// A single snap anchor of a layer, expressed in center-relative editor
/// coordinates together with the offset of that anchor from `layer.offset`.
class _LayerSnapAnchor {
  const _LayerSnapAnchor({
    required this.position,
    required this.localOffset,
    this.kind = _SnapKind.center,
  });

  /// Anchor position in center-relative editor coordinates.
  final double position;

  /// Offset of the anchor from `layer.offset` along the same axis.
  final double localOffset;

  /// Which edge of the layer this anchor represents.
  final _SnapKind kind;
}

/// A snap target line in center-relative editor coordinates.
class _SnapGuideTarget {
  const _SnapGuideTarget({
    required this.position,
    required this.isCustom,
    this.kind = _SnapKind.center,
    this.family,
  });

  /// Target position in center-relative editor coordinates.
  final double position;

  /// Whether this target originates from an app-defined custom guide.
  final bool isCustom;

  /// Which edge produced this target. Ignored for custom guides.
  final _SnapKind kind;

  /// Layer family that produced this target. Null for custom guides.
  final _SnapFamily? family;
}

class _LayerAlignGuideHelper {
  LayerLastPosition _lastSnapPosition = LayerLastPosition.center;
  Offset _lastSnapOffset = Offset.infinite;
  double? _lastSnapFocal;

  /// Clears the snapping hysteresis so a new drag gesture starts fresh and
  /// doesn't inherit stale state from a previous interaction.
  void reset() {
    _lastSnapPosition = LayerLastPosition.center;
    _lastSnapOffset = Offset.infinite;
    _lastSnapFocal = null;
  }

  /// Returns true if snapping should occur, otherwise false
  bool maybeSnap({
    required double focal,
    required double focalDelta,
    required Offset offset,
    required double threshold,
    required double releaseThreshold,
    required LayerLastPosition positiveDirection,
    required LayerLastPosition negativeDirection,
  }) {
    final diff = (_lastSnapFocal ?? focal) - focal;

    if (_lastSnapFocal == null || diff.abs() < releaseThreshold) {
      final newPosition = focalDelta > 0
          ? positiveDirection
          : negativeDirection;

      if (newPosition != _lastSnapPosition || _lastSnapOffset != offset) {
        _lastSnapFocal ??= focal;
        _lastSnapOffset = offset;
        _lastSnapPosition = LayerLastPosition.center;
        return true;
      }
    } else if (diff.abs() > releaseThreshold) {
      _lastSnapPosition = focal > _lastSnapFocal!
          ? positiveDirection
          : negativeDirection;
      _lastSnapFocal = null;
    }

    return false;
  }
}
