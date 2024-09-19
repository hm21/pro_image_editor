import 'utils/custom_widgets_typedef.dart';

/// A class that defines a layer of interaction for custom widgets,
/// allowing editing, removing, and rotating/scaling actions.
///
/// Each interaction can be represented by specific buttons passed into
/// the constructor.
///
/// Example usage:
/// ```dart
/// CustomWidgetsLayerInteraction(
///   editIcon: LayerInteractionTapButton(...),
///   removeIcon: LayerInteractionTapButton(...),
///   rotateScaleIcon: LayerInteractionScaleRotateButton(...),
/// );
/// ```

class CustomWidgetsLayerInteraction {
  /// Creates a [CustomWidgetsLayerInteraction] with optional interaction
  /// buttons.
  ///
  /// * [editIcon]: A button that triggers the edit action.
  /// * [removeIcon]: A button that triggers the remove action.
  /// * [rotateScaleIcon]: A button for rotate/scale actions.
  const CustomWidgetsLayerInteraction({
    this.editIcon,
    this.removeIcon,
    this.rotateScaleIcon,
  });

  /// The button for the edit interaction, represented by
  /// [LayerInteractionTapButton].
  final LayerInteractionTapButton? editIcon;

  /// The button for the remove interaction, represented by
  /// [LayerInteractionTapButton].
  final LayerInteractionTapButton? removeIcon;

  /// The button for the rotate/scale interaction, represented by
  /// [LayerInteractionScaleRotateButton].
  final LayerInteractionScaleRotateButton? rotateScaleIcon;

  /// Returns a copy of this object with the given fields updated.
  ///
  /// If no values are provided for the fields, the current values will be kept.
  ///
  /// * [editIcon]: Updates the button for the edit action.
  /// * [removeIcon]: Updates the button for the remove action.
  /// * [rotateScaleIcon]: Updates the button for rotate/scale actions.
  CustomWidgetsLayerInteraction copyWith({
    LayerInteractionTapButton? editIcon,
    LayerInteractionTapButton? removeIcon,
    LayerInteractionScaleRotateButton? rotateScaleIcon,
  }) {
    return CustomWidgetsLayerInteraction(
      editIcon: editIcon ?? this.editIcon,
      removeIcon: removeIcon ?? this.removeIcon,
      rotateScaleIcon: rotateScaleIcon ?? this.rotateScaleIcon,
    );
  }
}
