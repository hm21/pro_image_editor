import 'package:flutter/widgets.dart';

import '../../utils/parser/double_parser.dart';
import '../paint_editor/painted_model.dart';
import 'layer.dart';

/// A class representing a layer with custom paint content.
///
/// PaintLayerData is a subclass of [Layer] that allows you to display
/// custom-painted content on a canvas. You can specify the painted item and
/// its raw size, along with optional properties like offset, rotation,
/// scale, and more.
///
/// Example usage:
/// ```dart
/// PaintLayerData(
///   item: CustomPaintedItem(),
///   rawSize: Size(200.0, 150.0),
///   offset: Offset(50.0, 50.0),
///   rotation: -30.0,
///   scale: 1.5,
/// );
/// ```
class PaintLayerData extends Layer {
  /// Creates an instance of PaintLayerData.
  ///
  /// The [item] and [rawSize] parameters are required, and other properties
  /// are optional.
  PaintLayerData({
    required this.item,
    required this.rawSize,
    required this.opacity,
    super.offset,
    super.rotation,
    super.scale,
    super.id,
    super.flipX,
    super.flipY,
    super.enableInteraction,
  });

  /// Factory constructor for creating a PaintLayerData instance from a
  /// Layer and a map.
  factory PaintLayerData.fromMap(Layer layer, Map<String, dynamic> map) {
    /// Constructs and returns a PaintLayerData instance with properties
    /// derived from the layer and map.
    return PaintLayerData(
      flipX: layer.flipX,
      flipY: layer.flipY,
      enableInteraction: layer.enableInteraction,
      offset: layer.offset,
      rotation: layer.rotation,
      scale: layer.scale,
      opacity: safeParseDouble(map['opacity'], fallback: 1.0),
      rawSize: Size(
        safeParseDouble(map['rawSize']?['w'], fallback: 0),
        safeParseDouble(map['rawSize']?['h'], fallback: 0),
      ),
      item: PaintedModel.fromMap(map['item'] ?? {}),
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
}
