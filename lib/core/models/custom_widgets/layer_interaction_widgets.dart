import 'utils/custom_widgets_typedef.dart';

export '/shared/widgets/layer/models/layer_item_interaction.dart';

/// A class that defines a layer of interaction for custom widgets,
/// allowing editing, removing, and rotating/scaling actions.
///
/// Each interaction can be represented by specific buttons passed
/// into the constructor.
///
/// This class provides a structured way to manage interactive elements
/// within a custom widget, such as buttons for editing, removing,
/// and manipulating the widget's position and size.
///
/// **Note:** When the `children` property is used, the default
/// interaction buttons (`editButton`, `removeButton`, `rotateScaleButton`)
/// may not be directly visible or functional as they might be
/// obscured or overridden by the child widgets.
/// Consider customizing the child widgets or their layout to
/// ensure proper interaction with the layer's default buttons.
class LayerInteractionWidgets {
  /// Creates a [LayerInteractionWidgets] with optional interaction buttons.
  ///
  /// * [editButton]: A button that triggers the edit action.
  ///   May not be directly visible or functional when `children` is used.
  /// * [removeButton]: A button that triggers the remove action.
  ///   May not be directly visible or functional when `children` is used.
  /// * [rotateScaleButton]: A button for rotate/scale actions.
  ///   May not be directly visible or functional when `children` is used.
  /// * [children]: A list of child widgets to be displayed within the
  /// interaction layer.
  /// * [border]: An optional border to be displayed around the interaction
  /// layer.
  const LayerInteractionWidgets({
    this.editButton,
    this.removeButton,
    this.rotateScaleButton,
    this.children,
    this.border,
  });

  /// The button for the edit interaction, represented by
  /// [LayerInteractionTapButton].
  ///
  /// **Note:** May not be directly visible or functional when `children` is
  /// used.
  final LayerInteractionTapButton? editButton;

  /// The button for the remove interaction, represented by
  /// [LayerInteractionTapButton].
  ///
  /// **Note:** May not be directly visible or functional when `children` is
  /// used.
  final LayerInteractionTapButton? removeButton;

  /// The button for the rotate/scale interaction, represented by
  /// [LayerInteractionScaleRotateButton].
  ///
  /// **Note:** May not be directly visible or functional when `children` is
  /// used.
  final LayerInteractionScaleRotateButton? rotateScaleButton;

  /// A list of child widgets to be displayed within the interaction layer.
  ///
  /// **Example:**
  /// ```dart
  /// children: [
  ///   (rebuildStream, layer, interactions) => ReactiveWidget(
  ///         stream: rebuildStream,
  ///         builder: (_) => Positioned(
  ///             top: 0,
  ///             left: 0,
  ///             child: Transform.rotate(
  ///               angle: -layer.rotation,
  ///               child: MouseRegion(
  ///                 cursor: SystemMouseCursors.click,
  ///                 child: Listener(
  ///                   /// Required only for scale-rotate
  ///                   /// onPointerDown: interactions.scaleRotateDown,
  ///                   /// onPointerUp: interactions.scaleRotateUp,
  ///                   child: GestureDetector(
  ///                     onTap: interactions.edit,
  ///                     child: Tooltip(
  ///                       message: 'Edit',
  ///                       child: Container(
  ///                         padding: const EdgeInsets.all(3),
  ///                         decoration: BoxDecoration(
  ///                           borderRadius:
  ///                               BorderRadius.circular(10 * 2),
  ///                           color: Colors.white,
  ///                         ),
  ///                         child: const Icon(
  ///                           Icons.edit,
  ///                           color: Colors.black,
  ///                           size: 10 * 2,
  ///                         ),
  ///                       ),
  ///                     ),
  ///                   ),
  ///                 ),
  ///               ),
  ///             )),
  ///       ),
  ///   (rebuildStream, layer, interactions) => ReactiveWidget(
  ///         stream: rebuildStream,
  ///         builder: (_) => Positioned(
  ///           top: 0,
  ///           right: 0,
  ///           child: LayerInteractionButton(
  ///             rotation: -layer.rotation,
  ///             onTap: interactions.edit,
  ///             buttonRadius: 10,
  ///             cursor: SystemMouseCursors.click,
  ///             icon: Icons.clear,
  ///             tooltip: 'Remove',
  ///             color: Colors.black,
  ///             background: Colors.white,
  ///           ),
  ///         ),
  ///       ),
  ///   (rebuildStream, layer, interactions) => ReactiveWidget(
  ///         stream: rebuildStream,
  ///         builder: (_) => Positioned(
  ///           bottom: 0,
  ///           left: 0,
  ///           child: LayerInteractionButton(
  ///             rotation: -layer.rotation,
  ///             onScaleRotateDown: interactions.scaleRotateDown,
  ///             onScaleRotateUp: interactions.scaleRotateUp,
  ///             buttonRadius: 10,
  ///             cursor: SystemMouseCursors.click,
  ///             icon: Icons.sync,
  ///             tooltip: 'Rotate and Scale',
  ///             color: Colors.black,
  ///             background: Colors.white,
  ///           ),
  ///         ),
  ///       ),
  /// ]
  /// ```
  final List<LayerInteractionItem>? children;

  /// An optional border to be displayed around the interaction layer.
  ///
  /// **Example:**
  /// ```dart
  ///  border: (layerWidget, layerData) => Container(
  ///   margin: const EdgeInsets.all(10),
  ///   child: CustomPaint(
  ///     foregroundPainter: LayerInteractionBorderPainter(
  ///       style: const LayerInteractionStyle(),
  ///     ),
  ///     child: layerWidget,
  ///   ),
  /// )
  /// ```
  final LayerInteractionBorder? border;

  /// Returns a copy of this object with the given fields updated.
  ///
  /// If no values are provided for the fields, the current values will be kept.
  ///
  /// * [editButton]: Updates the button for the edit action.
  /// * [removeButton]: Updates the button for the remove action.
  /// * [rotateScaleButton]: Updates the button for rotate/scale actions.
  /// * [children]: Updates the list of child widgets.
  /// * [border]: Updates the border of the interaction layer.
  LayerInteractionWidgets copyWith({
    LayerInteractionTapButton? editButton,
    LayerInteractionTapButton? removeButton,
    LayerInteractionScaleRotateButton? rotateScaleButton,
    List<LayerInteractionItem>? children,
    LayerInteractionBorder? border,
  }) {
    return LayerInteractionWidgets(
      editButton: editButton ?? this.editButton,
      removeButton: removeButton ?? this.removeButton,
      rotateScaleButton: rotateScaleButton ?? this.rotateScaleButton,
      children: children ?? this.children,
      border: border ?? this.border,
    );
  }
}
