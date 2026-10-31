import 'dart:ui';

import '../../../shared/extensions/export_bool_extension.dart';
import '../../../shared/utils/parser/bool_parser.dart';
import '../../../shared/utils/parser/double_parser.dart';

/// A class representing the interaction settings for a layer.
///
/// The `LayerInteraction` class defines the enablement of various interaction
/// capabilities for a layer, including moving, scaling, rotating, and
/// selection, and the limits a gesture keeps the layer within: how far it may
/// be scaled and where it may be placed.
class LayerInteraction {
  /// Creates a new instance of [LayerInteraction] with customizable
  /// interaction settings.
  ///
  /// All interaction settings are enabled by default unless specified
  /// otherwise, and no limits are set.
  ///
  /// - [enableMove]: Enables the ability to move the layer.
  /// - [enableScale]: Enables the ability to scale the layer.
  /// - [enableRotate]: Enables the ability to rotate the layer.
  /// - [enableSelection]: Enables the ability to select the layer.
  /// - [enableEdit]: Enables the ability to edit the layer.
  /// - [minScale]: The smallest scale a gesture may give the layer.
  /// - [maxScale]: The largest scale a gesture may give the layer.
  /// - [bounds]: The area the layer stays inside.
  LayerInteraction({
    this.enableMove = true,
    this.enableScale = true,
    this.enableRotate = true,
    this.enableSelection = true,
    this.enableEdit = true,
    this.minScale,
    this.maxScale,
    this.bounds,
  }) : assert(
         minScale == null || maxScale == null || maxScale >= minScale,
         'maxScale must be greater than or equal to minScale',
       );

  /// Creates a [LayerInteraction] instance from a [Map].
  ///
  /// - [map]: The map containing interaction settings with keys matching
  ///   the property names.
  /// - [keyConverter]: An optional function to convert keys from the map to
  ///   match the property names. Defaults to identity mapping.
  ///
  /// [bounds] is not stored, so the instance has none.
  factory LayerInteraction.fromMap(
    Map<String, dynamic> map, {
    Function(String key)? keyConverter,
  }) {
    keyConverter ??= (String key) => key;

    return LayerInteraction(
      enableMove: safeParseBool(
        map[keyConverter('enableMove')],
        fallback: true,
      ),
      enableScale: safeParseBool(
        map[keyConverter('enableScale')],
        fallback: true,
      ),
      enableRotate: safeParseBool(
        map[keyConverter('enableRotate')],
        fallback: true,
      ),
      enableSelection: safeParseBool(
        map[keyConverter('enableSelection')],
        fallback: true,
      ),
      enableEdit: safeParseBool(
        map[keyConverter('enableEdit')],
        fallback: true,
      ),
      minScale: tryParseDouble(map[keyConverter('minScale')]),
      maxScale: tryParseDouble(map[keyConverter('maxScale')]),
    );
  }

  /// Creates a [LayerInteraction] instance with all interaction properties
  /// set to the specified [value].
  ///
  /// The [value] parameter is used to set the following properties:
  /// - [enableMove]
  /// - [enableScale]
  /// - [enableRotate]
  /// - [enableSelection]
  /// - [enableEdit]
  ///
  /// This factory constructor allows for quick initialization of a
  /// [LayerInteraction] object with uniform interaction capabilities.
  factory LayerInteraction.fromDefaultValue(bool value) {
    return LayerInteraction(
      enableMove: value,
      enableScale: value,
      enableRotate: value,
      enableSelection: value,
      enableEdit: value,
    );
  }

  /// Whether moving the layer is enabled.
  bool enableMove;

  /// Whether scaling the layer is enabled.
  bool enableScale;

  /// Whether rotating the layer is enabled.
  bool enableRotate;

  /// Whether selecting the layer is enabled.
  bool enableSelection;

  /// Whether the layer is editable. This option currently affects only
  /// TextLayers or WidgetLayers when the onTapEditSticker callback is set.
  bool enableEdit;

  /// The smallest `Layer.scale` a gesture may give the layer, or `null` for
  /// the limit of its type, such as `StickerEditorConfigs.minScale` for a
  /// `WidgetLayer`.
  ///
  /// It replaces the limit of the type for this layer, in either direction,
  /// and it applies to pinching the layer, dragging the scale button of its
  /// selection and the scroll and keyboard shortcuts on a desktop. [bounds]
  /// never shrink the layer below it.
  ///
  /// It is stored with the layer when the editor state is exported.
  double? minScale;

  /// The largest `Layer.scale` a gesture may give the layer, or `null` for
  /// the limit of its type, such as `StickerEditorConfigs.maxScale` for a
  /// `WidgetLayer`.
  ///
  /// It replaces the limit of the type for this layer, in either direction,
  /// and it applies where [minScale] does.
  ///
  /// It is stored with the layer when the editor state is exported.
  double? maxScale;

  /// The area the layer stays inside while it is moved, scaled or rotated,
  /// or `null` to let it go anywhere.
  ///
  /// The function receives the size of the main editor's body and returns
  /// the area in the logical pixels of that body, measured from its top left
  /// corner, like `TextEditorConfigs.layerBounds`. It is called whenever the
  /// layer is moved, so the area can follow anything that changes it, such
  /// as the aspect ratio of an export.
  ///
  /// The whole layer stays inside: the box it is drawn in, at its scale and
  /// turned by its rotation, without the selection frame. Dragged towards an
  /// edge, it stops there while the finger keeps going, and moves again once
  /// the finger is back where it stopped. Pinched or rotated at an edge, it is
  /// pushed inwards, and it moves back as it gets smaller within the same
  /// gesture. A layer larger than the area is shrunk to fit it, even when
  /// [enableScale] is off, but never below its [minScale]; one that does not
  /// fit even then is centered in the area along the side it is too big for.
  /// The scroll and keyboard shortcuts on a desktop keep it inside as well.
  ///
  /// The area applies only when the layer is moved: a layer that is added or
  /// changed outside it by code stays where it is until then, and so does a
  /// text box widened past it by its resize handles. Each layer of a
  /// multi-selection stops at its own area.
  ///
  /// A function cannot be stored, so an exported state does not hold the
  /// area: set it again on the layers after an import. Copies of the layer,
  /// such as the ones in the history, share it.
  Rect Function(Size editorBodySize)? bounds;

  /// Enables or disables all interaction capabilities for a layer.
  ///
  /// The following interactions can be enabled or disabled:
  /// - Editing
  /// - Moving
  /// - Scaling
  /// - Rotating
  /// - Selection
  ///
  /// Each interaction is controlled by the `value` parameter. The limits,
  /// [minScale], [maxScale] and [bounds], stay as they are.
  ///
  /// Parameters:
  /// - `value` (bool): The value to set for enabling or disabling the
  ///   interactions.
  void toggleAll(bool enableInteraction) {
    enableEdit = enableInteraction;
    enableMove = enableInteraction;
    enableScale = enableInteraction;
    enableRotate = enableInteraction;
    enableSelection = enableInteraction;
  }

  /// Creates a copy of this [LayerInteraction] with optional overrides.
  ///
  /// - [enableMove]: If provided, overrides the current `enableMove` setting.
  /// - [enableScale]: If provided, overrides the current `enableScale` setting.
  /// - [enableRotate]: If provided, overrides the current `enableRotate`
  ///   setting.
  /// - [enableSelection]: If provided, overrides the current `enableSelection`
  ///   setting.
  /// - [enableEdit]: if provided, overrides the current `enableEdit`
  ///   setting.
  /// - [minScale], [maxScale] and [bounds]: If provided, override the current
  ///   limits. A `null` keeps the current limit, so to remove one, set the
  ///   field to `null` on the copy.
  LayerInteraction copyWith({
    bool? enableMove,
    bool? enableScale,
    bool? enableRotate,
    bool? enableSelection,
    bool? enableEdit,
    double? minScale,
    double? maxScale,
    Rect Function(Size editorBodySize)? bounds,
  }) {
    return LayerInteraction(
      enableMove: enableMove ?? this.enableMove,
      enableScale: enableScale ?? this.enableScale,
      enableRotate: enableRotate ?? this.enableRotate,
      enableSelection: enableSelection ?? this.enableSelection,
      enableEdit: enableEdit ?? this.enableEdit,
      minScale: minScale ?? this.minScale,
      maxScale: maxScale ?? this.maxScale,
      bounds: bounds ?? this.bounds,
    );
  }

  /// Converts this [LayerInteraction] instance into a [Map].
  ///
  /// Returns a map representation of the interaction settings with keys
  /// corresponding to the property names. [minScale] and [maxScale] are
  /// written only when they are set; [bounds] never is.
  Map<String, dynamic> toMap({bool enableMinify = false}) {
    return {
      'enableMove': enableMove.minify(enableMinify),
      'enableScale': enableScale.minify(enableMinify),
      'enableRotate': enableRotate.minify(enableMinify),
      'enableSelection': enableSelection.minify(enableMinify),
      'enableEdit': enableEdit.minify(enableMinify),
      if (minScale != null) 'minScale': minScale,
      if (maxScale != null) 'maxScale': maxScale,
    };
  }

  /// Converts this [LayerInteraction] instance into a [Map] while comparing
  /// it to another reference [LayerInteraction].
  ///
  /// Only includes the properties where the current instance's values differ
  /// from the [interaction] reference. A scale limit that was removed is
  /// written as `null`.
  Map<String, dynamic> toMapFromReference(
    LayerInteraction interaction, {
    bool enableMinify = false,
  }) {
    return {
      if (interaction.enableMove != enableMove)
        'enableMove': enableMove.minify(enableMinify),
      if (interaction.enableScale != enableScale)
        'enableScale': enableScale.minify(enableMinify),
      if (interaction.enableRotate != enableRotate)
        'enableRotate': enableRotate.minify(enableMinify),
      if (interaction.enableSelection != enableSelection)
        'enableSelection': enableSelection.minify(enableMinify),
      if (interaction.enableEdit != enableEdit)
        'enableEdit': enableEdit.minify(enableMinify),
      if (interaction.minScale != minScale) 'minScale': minScale,
      if (interaction.maxScale != maxScale) 'maxScale': maxScale,
    };
  }

  /// Returns a string representation of the [LayerInteraction] instance.
  @override
  String toString() {
    return 'LayerInteraction(enableMove: $enableMove, '
        'enableScale: $enableScale, '
        'enableRotate: $enableRotate, '
        'enableSelection: $enableSelection, '
        'enableEdit: $enableEdit, '
        'minScale: $minScale, '
        'maxScale: $maxScale, '
        'bounds: ${bounds == null ? 'none' : 'set'})';
  }

  /// Compares this [LayerInteraction] instance with another for equality.
  ///
  /// Two [LayerInteraction] instances are considered equal if all their
  /// properties match. [bounds] match when they are the same function.
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is LayerInteraction &&
        other.enableMove == enableMove &&
        other.enableScale == enableScale &&
        other.enableRotate == enableRotate &&
        other.enableSelection == enableSelection &&
        other.enableEdit == enableEdit &&
        other.minScale == minScale &&
        other.maxScale == maxScale &&
        other.bounds == bounds;
  }

  /// Returns a hash code for this [LayerInteraction] instance.
  @override
  int get hashCode {
    return enableMove.hashCode ^
        enableScale.hashCode ^
        enableRotate.hashCode ^
        enableSelection.hashCode ^
        enableEdit.hashCode ^
        minScale.hashCode ^
        maxScale.hashCode ^
        bounds.hashCode;
  }
}
