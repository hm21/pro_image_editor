import 'dart:math';
import 'dart:ui';

import 'package:flutter/foundation.dart';

import '/core/models/editor_configs/pro_image_editor_configs.dart';
import '/core/models/layers/layer.dart';
import '/shared/widgets/extended/interactive_viewer/extended_interactive_viewer.dart';
import 'layer_interaction_manager.dart';

/// A service that enables drag-to-select functionality for layers on a canvas.
///
/// It allows users to click and drag a selection rectangle to select
/// multiple visible layers based on their positions and sizes.
///
/// The selection behavior is configurable via [LayerInteractionConfigs].
class LayerDragSelectionService {
  /// Creates a new instance of [LayerDragSelectionService].
  ///
  /// - [configs]: Settings that control drag selection behavior.
  /// - [layerInteractionManager]: Manages current layer selections.
  /// - [activeLayers]: Returns the currently visible layers.
  /// - [bodySize]: Provides the canvas or body size for offset calculations.
  /// - [onUpdateLayers]: Callback triggered when layer selection updates.
  /// - [playTime]: The video's playback position, if any.
  LayerDragSelectionService({
    required this.configs,
    required this.layerInteractionManager,
    required this.activeLayers,
    required this.bodySize,
    required this.onUpdateLayers,
    required this.interactiveViewer,
    this.playTime,
  });

  /// Drag selection configuration options.
  final ProImageEditorConfigs configs;

  /// Manages selection state and interactions between layers.
  final LayerInteractionManager layerInteractionManager;

  /// Provides the currently active (visible) layers.
  final List<Layer> Function() activeLayers;

  /// Provides the size of the canvas or editor body.
  final Size Function() bodySize;

  /// Called when the selected layers have changed.
  final Function() onUpdateLayers;

  /// The state for [ExtendedInteractiveViewer], managing the
  /// interactivity state.
  final ExtendedInteractiveViewerState? Function() interactiveViewer;

  /// The playback position layers with [Layer.keyframes] are drawn at, or
  /// `null` outside the video editor.
  final Duration? Function()? playTime;

  /// Current drag selection rectangle.
  _DragRect _rect = _DragRect.empty();

  /// Notifies listeners when the drag rectangle updates.
  late final dragRectNotifier = ValueNotifier(_rect);

  /// Whether a selection drag is currently active.
  bool get isActive => _rect.isVisible;

  bool get _isEnabled =>
      layerInteractionConfigs.enableLayerDragSelection && _canSelectLayers;

  /// Configuration options for the layer interaction behavior.
  late final layerInteractionConfigs = configs.layerInteraction;

  /// Whether layer selection is currently allowed based on the platform and
  /// config.
  bool get _canSelectLayers {
    if (layerInteractionConfigs.selectable == LayerInteractionSelectable.auto) {
      return isDesktop;
    }
    return layerInteractionConfigs.selectable ==
        LayerInteractionSelectable.enabled;
  }

  Offset get _viewerOffset => interactiveViewer()?.offset ?? Offset.zero;
  double get _viewerScale => interactiveViewer()?.scaleFactor ?? 1;

  /// Starts a drag operation at the given [offset].
  void startDragging(Offset offset) {
    if (!_isEnabled) return;

    _rect = _rect.copyWith(offset: offset, isVisible: true);
  }

  /// Updates the selection rectangle based on the current [offset].
  ///
  /// This is typically called during pointer drag updates.
  void updateSize(Offset offset) {
    if (!_isEnabled) return;

    final newSize = Size(
      (offset.dx - _rect.offset.dx).abs(),
      (offset.dy - _rect.offset.dy).abs(),
    );

    final newOffset = Offset(
      offset.dx < _rect.offset.dx ? offset.dx : _rect.offset.dx,
      offset.dy < _rect.offset.dy ? offset.dy : _rect.offset.dy,
    );

    final updatedRect = _rect.copyWith(offset: newOffset, size: newSize);
    dragRectNotifier.value = updatedRect;

    _checkLayersOverlay(updatedRect);
  }

  /// Ends the current drag operation and clears the selection rectangle.
  void endDragging() {
    _rect = _DragRect.empty();
    dragRectNotifier.value = _rect;
  }

  /// Evaluates which layers intersect with the selection rectangle.
  ///
  /// Updates the selected layer IDs in the [layerInteractionManager].
  void _checkLayersOverlay(_DragRect updatedRect) {
    final halfBodyOffset = Offset(bodySize().width / 2, bodySize().height / 2);

    final realOffset = (updatedRect.offset - _viewerOffset) / _viewerScale;
    final realSize = updatedRect.size / _viewerScale;

    final selectionRect = Rect.fromLTWH(
      realOffset.dx - halfBodyOffset.dx,
      realOffset.dy - halfBodyOffset.dy,
      realSize.width,
      realSize.height,
    );

    final selectionPath = Path()..addRect(selectionRect);
    final textOffset = configs.textEditor.layerFractionalOffset;
    final paintOffset = configs.paintEditor.layerFractionalOffset;
    final emojiOffset = configs.emojiEditor.layerFractionalOffset;
    final widgetOffset = configs.stickerEditor.layerFractionalOffset;

    final selectedLayerIds = <String>[];
    for (final layer in activeLayers()) {
      final context = layer.keyInternalSize.currentContext;
      final size = context?.size;

      if (size == null || size.isEmpty) continue;

      // Skip layers that have enableSelection set to false
      if (!layer.interaction.enableSelection) continue;

      Offset fractionalOffset = layer.isTextLayer
          ? textOffset
          : layer.isPaintLayer
          ? paintOffset
          : layer.isEmojiLayer
          ? emojiOffset
          : layer.isWidgetLayer
          ? widgetOffset
          : const Offset(-0.5, -0.5);
      fractionalOffset += const Offset(0.5, 0.5);

      // A layer with keyframes is drawn where they put it at the playback
      // position, grown and turned around its visual center.
      final time = playTime?.call();
      final placement = time == null ? null : layer.keyframePlacementAt(time);
      final growth = placement == null || layer.scale == 0
          ? 1.0
          : placement.scale / layer.scale;

      final center =
          (placement?.offset ?? layer.offset) +
          Offset(
            size.width * fractionalOffset.dx,
            size.height * fractionalOffset.dy,
          );

      final rotatedCorners = _getRotatedCorners(
        center,
        size * growth,
        placement?.rotation ?? layer.rotation,
      );

      final layerPath = Path()
        ..moveTo(rotatedCorners[0].dx, rotatedCorners[0].dy)
        ..lineTo(rotatedCorners[1].dx, rotatedCorners[1].dy)
        ..lineTo(rotatedCorners[2].dx, rotatedCorners[2].dy)
        ..lineTo(rotatedCorners[3].dx, rotatedCorners[3].dy)
        ..close();

      // First check bounds for fast rejection
      if (!selectionRect.overlaps(layerPath.getBounds())) continue;

      // Then do precise intersection check
      final intersected = Path.combine(
        PathOperation.intersect,
        selectionPath,
        layerPath,
      );

      if (intersected.computeMetrics().isNotEmpty) {
        selectedLayerIds.add(layer.id);
      }
    }

    layerInteractionManager.setSelectedLayers(selectedLayerIds);
    onUpdateLayers();
  }

  /// Returns the four corners of a rectangle [size] centered at [center],
  /// rotated by [rotation] radians.
  List<Offset> _getRotatedCorners(Offset center, Size size, double rotation) {
    final overlayPadding = configs.layerInteraction.style.overlayPadding;
    final hw = size.width / 2;
    final hh = size.height / 2;

    final left = -hw - overlayPadding.left;
    final top = -hh - overlayPadding.top;
    final right = hw + overlayPadding.right;
    final bottom = hh + overlayPadding.bottom;

    final corners = [
      Offset(left, top),
      Offset(right, top),
      Offset(right, bottom),
      Offset(left, bottom),
    ];

    final cosR = cos(rotation);
    final sinR = sin(rotation);

    return corners.map((offset) {
      final rotated = Offset(
        offset.dx * cosR - offset.dy * sinR,
        offset.dx * sinR + offset.dy * cosR,
      );
      return center + rotated;
    }).toList();
  }
}

/// Internal model representing a rectangular drag selection area.
class _DragRect {
  /// Constructs a [_DragRect] with the given properties.
  _DragRect({
    required this.offset,
    required this.size,
    required this.isVisible,
  });

  /// Returns an empty, invisible rectangle.
  factory _DragRect.empty() {
    return _DragRect(offset: Offset.zero, size: Size.zero, isVisible: false);
  }

  /// Top-left corner of the rectangle.
  final Offset offset;

  /// Width and height of the rectangle.
  final Size size;

  /// Whether the rectangle is currently visible.
  final bool isVisible;

  /// Creates a copy of this rectangle with optional new values.
  _DragRect copyWith({Offset? offset, Size? size, bool? isVisible}) {
    return _DragRect(
      offset: offset ?? this.offset,
      size: size ?? this.size,
      isVisible: isVisible ?? this.isVisible,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is _DragRect &&
        other.offset == offset &&
        other.size == size &&
        other.isVisible == isVisible;
  }

  @override
  int get hashCode => offset.hashCode ^ size.hashCode ^ isVisible.hashCode;
}
