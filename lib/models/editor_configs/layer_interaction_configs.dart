/// Represents the interaction behavior for a layer.
///
/// This class provides configuration options for layer interactions, such as
/// whether the layer is selectable and its initial selection state.
class LayerInteraction {
  /// Creates a [LayerInteraction] instance.
  ///
  /// This constructor allows configuration of layer interaction behavior,
  /// including the selectable state and the initial selection state.
  ///
  /// Example:
  /// ```
  /// LayerInteraction(
  ///   selectable: LayerInteractionSelectable.manual,
  ///   initialSelected: true,
  /// )
  /// ```
  const LayerInteraction({
    this.selectable = LayerInteractionSelectable.auto,
    this.initialSelected = false,
  });

  /// Specifies the selectability behavior for the layer.
  ///
  /// Defaults to [LayerInteractionSelectable.auto].
  final LayerInteractionSelectable selectable;

  /// The layer is automatically selected upon creation.
  /// This option takes effect only when `selectable` is set to `enabled` or
  /// `auto` where the device is a desktop.
  final bool initialSelected;
}

/// Enumerates the different selectability states for a layer.
enum LayerInteractionSelectable {
  /// Automatically determines if the layer is selectable based on the device
  /// type.
  ///
  /// If the device is a desktop-device, the layer is selectable; otherwise,
  /// the layer is not selectable.
  auto,

  /// Indicates that the layer is selectable.
  enabled,

  /// Indicates that the layer is not selectable.
  disabled,
}
