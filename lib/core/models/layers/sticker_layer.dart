import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import '../../utils/parser/int_parser.dart';
import 'layer.dart';

/// A class representing a layer with custom sticker content.
///
/// StickerLayerData is a subclass of [Layer] that allows you to display
/// custom sticker content. You can specify properties like offset, rotation,
/// scale, and more.
///
/// Example usage:
/// ```dart
/// StickerLayerData(
///   offset: Offset(50.0, 50.0),
///   rotation: -30.0,
///   scale: 1.5,
/// );
/// ```
class StickerLayerData extends Layer {
  /// Creates an instance of StickerLayerData.
  ///
  /// The [sticker] parameter is required, and other properties are optional.
  StickerLayerData({
    required this.sticker,
    super.offset,
    super.rotation,
    super.scale,
    super.id,
    super.flipX,
    super.flipY,
    super.enableInteraction,
  });

  /// Factory constructor for creating a StickerLayerData instance from a
  /// Layer, a map, and a list of stickers.
  factory StickerLayerData.fromMap(
    Layer layer,
    Map<String, dynamic> map,
    List<Uint8List> stickers,
  ) {
    /// Determines the position of the sticker in the list.
    int stickerPosition = safeParseInt(map['listPosition'], fallback: -1);

    /// Widget to display a sticker or a placeholder if not found.
    Widget sticker = kDebugMode
        ? Text(
            'Sticker $stickerPosition not found',
            style: const TextStyle(color: Color(0xFFF44336), fontSize: 24),
          )
        : const SizedBox.shrink();

    /// Updates the sticker widget if the position is valid.
    if (stickers.isNotEmpty && stickers.length > stickerPosition) {
      sticker = ConstrainedBox(
        constraints: const BoxConstraints(minWidth: 1, minHeight: 1),
        child: Image.memory(
          stickers[stickerPosition],
        ),
      );
    }

    /// Constructs and returns a StickerLayerData instance with properties
    /// derived from the layer and map.
    return StickerLayerData(
      flipX: layer.flipX,
      flipY: layer.flipY,
      enableInteraction: layer.enableInteraction,
      offset: layer.offset,
      rotation: layer.rotation,
      scale: layer.scale,
      sticker: sticker,
    );
  }

  /// The sticker to display on the layer.
  Widget sticker;

  /// Converts this transform object to a Map suitable for representing a
  /// sticker.
  ///
  /// Returns a Map representing the properties of this transform object,
  /// augmented with the specified [listPosition] indicating the position of
  /// the sticker in a list.
  Map<String, dynamic> toStickerMap(int listPosition) {
    return {
      ...toMap(),
      'listPosition': listPosition,
      'type': 'sticker',
    };
  }

  /// Creates a new instance of [StickerLayerData] with modified properties.
  ///
  /// Each property of the new instance can be replaced by providing a value
  /// to the corresponding parameter of this method. Unprovided parameters
  /// will default to the current instance's values.
  StickerLayerData copyWith({
    Widget? sticker,
    Offset? offset,
    double? rotation,
    double? scale,
    String? id,
    bool? flipX,
    bool? flipY,
    bool? enableInteraction,
  }) {
    return StickerLayerData(
      sticker: sticker ?? this.sticker,
      offset: offset ?? this.offset,
      rotation: rotation ?? this.rotation,
      scale: scale ?? this.scale,
      id: id ?? this.id,
      flipX: flipX ?? this.flipX,
      flipY: flipY ?? this.flipY,
      enableInteraction: enableInteraction ?? this.enableInteraction,
    );
  }
}
