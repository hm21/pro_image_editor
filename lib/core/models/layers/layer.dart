// Flutter imports:
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

// Project imports:
import '../../utils/parser/double_parser.dart';
import '../../utils/unique_id_generator.dart';
import 'emoji_layer.dart';
import 'paint_layer.dart';
import 'sticker_layer.dart';
import 'text_layer.dart';

export 'emoji_layer.dart';
export 'paint_layer.dart';
export 'sticker_layer.dart';
export 'text_layer.dart';

/// Represents a layer with common properties for widgets.
class Layer {
  /// Creates a new layer with optional properties.
  ///
  /// The [id] parameter can be used to provide a custom identifier for the
  /// layer.
  /// The [offset] parameter determines the position offset of the widget.
  /// The [rotation] parameter sets the rotation angle of the widget in degrees
  /// (default is 0).
  /// The [scale] parameter sets the scale factor of the widget (default is 1).
  /// The [flipX] parameter controls horizontal flipping (default is false).
  /// The [flipY] parameter controls vertical flipping (default is false).
  /// The [enableInteraction] parameter controls if a user can interact with
  /// the layer
  Layer({
    String? id,
    Offset? offset,
    double? rotation,
    double? scale,
    bool? flipX,
    bool? flipY,
    bool? enableInteraction,
  }) {
    key = GlobalKey();
    // Initialize properties with provided values or defaults.
    this.id = id ?? generateUniqueId();
    this.offset = offset ?? Offset.zero;
    this.rotation = rotation ?? 0;
    this.scale = scale ?? 1;
    this.flipX = flipX ?? false;
    this.flipY = flipY ?? false;
    this.enableInteraction = enableInteraction ?? true;
  }

  /// Factory constructor for creating a Layer instance from a map and a list
  /// of stickers.
  factory Layer.fromMap(
    Map<String, dynamic> map,
    List<Uint8List> stickers,
  ) {
    /// Creates a base Layer instance with default or map-provided properties.
    Layer layer = Layer(
      flipX: map['flipX'] ?? false,
      flipY: map['flipY'] ?? false,
      enableInteraction: map['enableInteraction'] ?? true,
      offset: Offset(safeParseDouble(map['x']), safeParseDouble(map['y'])),
      rotation: safeParseDouble(map['rotation']),
      scale: safeParseDouble(map['scale'], fallback: 1),
    );

    /// Determines the layer type from the map and returns the appropriate
    /// LayerData subclass.
    switch (map['type']) {
      case 'text':
        // Returns a TextLayerData instance when type is 'text'.
        return TextLayerData.fromMap(layer, map);
      case 'emoji':
        // Returns an EmojiLayerData instance when type is 'emoji'.
        return EmojiLayerData.fromMap(layer, map);
      case 'paint':
      case 'painting':
        // Returns a PaintLayerData instance when type is 'paint'.
        return PaintLayerData.fromMap(layer, map);
      case 'sticker':
        // Returns a StickerLayerData instance when type is 'sticker',
        // utilizing the stickers list.
        return StickerLayerData.fromMap(layer, map, stickers);
      default:
        // Returns the base Layer instance when type is unrecognized.
        return layer;
    }
  }

  /// Global key associated with the Layer instance, used for accessing the
  /// widget tree.
  late GlobalKey key;

  /// The position offset of the widget.
  late Offset offset;

  /// The rotation and scale values of the widget.
  late double rotation, scale;

  /// Flags to control horizontal and vertical flipping.
  late bool flipX, flipY;

  /// Flag to enable or disable the user interaction with the layer.
  late bool enableInteraction;

  /// A unique identifier for the layer.
  late String id;

  /// Converts this transform object to a Map.
  ///
  /// Returns a Map representing the properties of this layer object,
  /// including the X and Y coordinates, rotation angle, scale factors, and
  /// flip flags.
  Map<String, dynamic> toMap() {
    return {
      'x': offset.dx,
      'y': offset.dy,
      'rotation': rotation,
      'scale': scale,
      'flipX': flipX,
      'flipY': flipY,
      'enableInteraction': enableInteraction,
      'type': 'default',
    };
  }
}
