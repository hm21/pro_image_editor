import 'package:flutter/widgets.dart';

import '/features/paint_editor/models/painted_model.dart';
import '/shared/services/import_export/utils/key_minifier.dart';
import '/shared/utils/parser/double_parser.dart';
import 'layer.dart';

/// A class representing a layer with custom paint content.
///
/// PaintLayer is a subclass of [Layer] that allows you to display
/// custom-painted content on a canvas. You can specify the painted item and
/// its raw size, along with optional properties like offset, rotation,
/// scale, and more.
///
/// Example usage:
/// ```dart
/// PaintLayer(
///   item: CustomPaintedItem(),
///   rawSize: Size(200.0, 150.0),
///   offset: Offset(50.0, 50.0),
///   rotation: -30.0,
///   scale: 1.5,
/// );
/// ```
class PaintLayer extends Layer {
  /// Creates an instance of PaintLayer.
  ///
  /// The [item] and [rawSize] parameters are required, and other properties
  /// are optional.
  PaintLayer({
    required this.item,
    required this.rawSize,
    required this.opacity,
    super.offset,
    super.rotation,
    super.scale,
    super.id,
    super.flipX,
    super.flipY,
    super.interaction,
    super.isDeleted,
    super.meta,
    super.boxConstraints,
  });

  /// Factory constructor for creating a PaintLayer instance from a
  /// Layer and a map.
  factory PaintLayer.fromMap(
    Layer layer,
    Map<String, dynamic> map, {
    EditorKeyMinifier? minifier,
  }) {
    var keyConverter = minifier?.convertLayerKey ?? (String key) => key;

    /// Constructs and returns a PaintLayer instance with properties
    /// derived from the layer and map.
    return PaintLayer(
      id: layer.id,
      flipX: layer.flipX,
      flipY: layer.flipY,
      interaction: layer.interaction,
      offset: layer.offset,
      rotation: layer.rotation,
      scale: layer.scale,
      isDeleted: layer.isDeleted,
      meta: layer.meta,
      opacity: safeParseDouble(map[keyConverter('opacity')], fallback: 1.0),
      rawSize: Size(
        safeParseDouble(map[keyConverter('rawSize')]?['w'], fallback: 0),
        safeParseDouble(map[keyConverter('rawSize')]?['h'], fallback: 0),
      ),
      item: PaintedModel.fromMap(
        map[keyConverter('item')] ?? {},
        keyConverter: minifier?.convertPaintKey,
      ),
    );
  }

  /// The custom-painted item to display on the layer.
  final PaintedModel item;

  /// The raw size of the painted item before applying scaling.
  final Size rawSize;

  /// The opacity level of the drawing.
  final double opacity;

  /// Returns the size of the layer after applying the scaling factor.
  Size get size => Size(rawSize.width * scale, rawSize.height * scale);

  @override
  Map<String, dynamic> toMap() {
    return {
      ...super.toMap(),
      'item': item.toMap(),
      'rawSize': {
        'w': rawSize.width,
        'h': rawSize.height,
      },
      'opacity': opacity,
      'type': 'paint',
    };
  }

  @override
  Map<String, dynamic> toMapFromReference(Layer layer) {
    var paintLayer = layer as PaintLayer;
    return {
      ...super.toMapFromReference(layer),
      if (paintLayer.item != item) 'item': item.toMap(),
      if (paintLayer.rawSize != rawSize)
        'rawSize': {
          'w': rawSize.width,
          'h': rawSize.height,
        },
      if (paintLayer.opacity != opacity) 'opacity': opacity,
    };
  }
}
