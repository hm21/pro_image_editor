import 'dart:ui';

/// Represents the interaction behavior for a layer.
class LayerInteraction {
  /// Specifies the selectability behavior for the layer.
  ///
  /// Defaults to [LayerInteractionSelectable.auto].
  final LayerInteractionSelectable selectable;

  /// The offset position where the new layer will be inserted. If null, it will be inserted in the center of the screen.
  final Offset? newLayerOffsetPosition;

  const LayerInteraction({
    this.selectable = LayerInteractionSelectable.auto,
    this.newLayerOffsetPosition,
  });
}

/// Enumerates the different selectability states for a layer.
enum LayerInteractionSelectable {
  /// Automatically determines if the layer is selectable based on the device type.
  ///
  /// If the device is a desktop-device, the layer is selectable; otherwise, the layer is not selectable.
  auto,

  /// Indicates that the layer is selectable.
  enabled,

  /// Indicates that the layer is not selectable.
  disabled,
}
