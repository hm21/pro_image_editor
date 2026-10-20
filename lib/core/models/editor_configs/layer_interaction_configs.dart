import '../custom_widgets/layer_interaction_widgets.dart';
import '../icons/layer_interaction_icons.dart';
import '../styles/layer_interaction_style.dart';

export '../icons/layer_interaction_icons.dart';
export '../styles/layer_interaction_style.dart';

/// Represents the interaction behavior for a layer.
///
/// This class provides configuration options for layer interactions, such as
/// whether the layer is selectable and its initial selection state.
class LayerInteractionConfigs {
  /// Creates a [LayerInteractionConfigs] instance.
  ///
  /// This constructor allows configuration of layer interaction behavior,
  /// including the selectable state and the initial selection state.
  const LayerInteractionConfigs({
    this.selectable = LayerInteractionSelectable.auto,
    this.initialSelected = false,
    this.hideToolbarOnInteraction = false,
    this.hideVideoControlsOnInteraction = true,
    this.keepSelectionOnInteraction = true,
    this.enableKeyboardMultiSelection = true,
    this.enableLongPressMultiSelection = true,
    this.enableLayerDragSelection = true,
    this.enableMobilePinchScale = true,
    this.enableMobilePinchRotate = true,
    this.enableTextBoxResize = false,
    this.mouseButtonPrimaryAction = MouseButtonAction.selectOrSpaceMove,
    this.mouseButtonSecondaryAction = MouseButtonAction.pan,
    this.mouseButtonMiddleAction = MouseButtonAction.pan,
    this.videoControlsSwitchDuration = const Duration(milliseconds: 220),
    this.icons = const LayerInteractionIcons(),
    this.widgets = const LayerInteractionWidgets(),
    this.style = const LayerInteractionStyle(),
  });

  /// Specifies the selectability behavior for the layer.
  ///
  /// Defaults to [LayerInteractionSelectable.auto].
  final LayerInteractionSelectable selectable;

  /// The layer is automatically selected upon creation.
  /// This option takes effect only when `selectable` is set to `enabled` or
  /// `auto` where the device is a desktop.
  final bool initialSelected;

  /// Determines whether the toolbars should be hidden when the user interacts
  /// with the editor.
  final bool hideToolbarOnInteraction;

  /// Determines whether pinch-to-scale gestures are enabled for layers on
  /// mobile devices.
  ///
  /// If set to `true`, users can scale the layer using a pinch gesture.
  /// If `false`, pinch scaling is disabled.
  final bool enableMobilePinchScale;

  /// Determines whether pinch-to-rotate gestures are enabled for layers on
  /// mobile devices.
  ///
  /// If set to `true`, users can rotate the layer using a pinch gesture
  /// (two-finger rotation).
  /// If `false`, pinch rotation is disabled.
  final bool enableMobilePinchRotate;

  /// Whether the default selection overlay shows handles on the edges of a
  /// text layer with a `TextLayer.box`, which resize the box without
  /// scaling its text.
  ///
  /// A custom `LayerInteractionWidgets.overlayChildBuilder` can show its own
  /// handles with `TextLayerBoxHandles` and
  /// `LayerItemInteractions.textBoxResizeDown`, whatever this says.
  final bool enableTextBoxResize;

  /// Determines whether the video controls should be hidden when the user
  /// interacts with the editor.
  final bool hideVideoControlsOnInteraction;

  /// Determines whether the current selection should be retained when
  /// interacting with layers.
  ///
  /// If set to `true`, the selection remains active during layer interactions.
  /// If set to `false`, the selection will be cleared upon interaction.
  final bool keepSelectionOnInteraction;

  /// Enables multi-selection using keyboard modifiers (Ctrl or Shift).
  ///
  /// When set to `true`, users can select multiple layers by holding down
  /// Ctrl or Shift while clicking or tapping.
  final bool enableKeyboardMultiSelection;

  /// Enables multi-selection via long-press gestures.
  ///
  /// When set to `true`, users can enter multi-select mode by long-pressing
  /// on a layer (useful for touch devices).
  final bool enableLongPressMultiSelection;

  /// Whether drag-to-select functionality is enabled.
  ///
  /// This only takes effect if [selectable] is set to
  /// [LayerInteractionSelectable.enabled], or when set to
  /// [LayerInteractionSelectable.auto], it must be running on a desktop
  /// platform (Windows, macOS, or Linux).
  final bool enableLayerDragSelection;

  /// The duration of the switch animation when the video controls show/hide.
  final Duration videoControlsSwitchDuration;

  /// Defines icons used in layer interactions.
  final LayerInteractionIcons icons;

  /// Widgets associated with layer interactions.
  final LayerInteractionWidgets widgets;

  /// Style configuration for layer interactions.
  final LayerInteractionStyle style;

  /// The action assigned to the **primary mouse button** (usually left-click).
  final MouseButtonAction mouseButtonPrimaryAction;

  /// The action assigned to the **secondary mouse button**
  /// (usually right-click).
  final MouseButtonAction mouseButtonSecondaryAction;

  /// The action assigned to the **middle mouse button**
  /// (usually mouse wheel click).
  final MouseButtonAction mouseButtonMiddleAction;

  /// Creates a copy of this `LayerInteractionConfigs` object with the given
  /// fields replaced with new values.
  ///
  /// The [copyWith] method allows you to create a new instance of
  /// [LayerInteractionConfigs] with some properties updated while keeping the
  /// others unchanged.
  LayerInteractionConfigs copyWith({
    LayerInteractionSelectable? selectable,
    bool? initialSelected,
    bool? hideToolbarOnInteraction,
    bool? enableMobilePinchScale,
    bool? enableMobilePinchRotate,
    bool? enableTextBoxResize,
    bool? hideVideoControlsOnInteraction,
    bool? keepSelectionOnInteraction,
    bool? enableKeyboardMultiSelection,
    bool? enableLongPressMultiSelection,
    bool? enableLayerDragSelection,
    Duration? videoControlsSwitchDuration,
    LayerInteractionIcons? icons,
    LayerInteractionWidgets? widgets,
    LayerInteractionStyle? style,
    MouseButtonAction? mouseButtonPrimaryAction,
    MouseButtonAction? mouseButtonSecondaryAction,
    MouseButtonAction? mouseButtonMiddleAction,
  }) {
    return LayerInteractionConfigs(
      selectable: selectable ?? this.selectable,
      initialSelected: initialSelected ?? this.initialSelected,
      hideToolbarOnInteraction:
          hideToolbarOnInteraction ?? this.hideToolbarOnInteraction,
      enableMobilePinchScale:
          enableMobilePinchScale ?? this.enableMobilePinchScale,
      enableMobilePinchRotate:
          enableMobilePinchRotate ?? this.enableMobilePinchRotate,
      enableTextBoxResize: enableTextBoxResize ?? this.enableTextBoxResize,
      hideVideoControlsOnInteraction:
          hideVideoControlsOnInteraction ?? this.hideVideoControlsOnInteraction,
      keepSelectionOnInteraction:
          keepSelectionOnInteraction ?? this.keepSelectionOnInteraction,
      enableKeyboardMultiSelection:
          enableKeyboardMultiSelection ?? this.enableKeyboardMultiSelection,
      enableLongPressMultiSelection:
          enableLongPressMultiSelection ?? this.enableLongPressMultiSelection,
      enableLayerDragSelection:
          enableLayerDragSelection ?? this.enableLayerDragSelection,
      videoControlsSwitchDuration:
          videoControlsSwitchDuration ?? this.videoControlsSwitchDuration,
      icons: icons ?? this.icons,
      widgets: widgets ?? this.widgets,
      style: style ?? this.style,
      mouseButtonPrimaryAction:
          mouseButtonPrimaryAction ?? this.mouseButtonPrimaryAction,
      mouseButtonSecondaryAction:
          mouseButtonSecondaryAction ?? this.mouseButtonSecondaryAction,
      mouseButtonMiddleAction:
          mouseButtonMiddleAction ?? this.mouseButtonMiddleAction,
    );
  }
}

/// Represents the possible actions that can be performed with a mouse button
/// in the context of layer interaction within the editor.
enum MouseButtonAction {
  /// Used to pan the editor content when zoom is enabled.
  /// Falls back to [dragSelect] if zoom is disabled
  pan,

  /// Used to draw a selection rectangle.
  dragSelect,

  /// Dynamically decides between [dragSelect] or a temporary [pan] mode when
  /// the spacebar is held. Useful for keyboard-assisted navigation.
  selectOrSpaceMove,

  /// Enables direct multi-selection of layers when clicked, without requiring
  /// keyboard modifiers like Ctrl/Shift or long-press gestures.
  multiSelect,

  /// No specific action is assigned to the mouse button.
  none,
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
