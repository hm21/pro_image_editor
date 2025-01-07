import 'layer.dart';

/// A class representing a layer with emoji content.
///
/// EmojiLayerData is a subclass of [Layer] that allows you to display emoji
/// on a canvas. You can specify the emoji to display, along with optional
/// properties like offset, rotation, scale, and more.
///
/// Example usage:
/// ```dart
/// EmojiLayerData(
///   emoji: '😀',
///   offset: Offset(100.0, 100.0),
///   rotation: 45.0,
///   scale: 2.0,
/// );
/// ```
class EmojiLayerData extends Layer {
  /// Creates an instance of EmojiLayerData.
  ///
  /// The [emoji] parameter is required, and other properties are optional.
  EmojiLayerData({
    required this.emoji,
    super.offset,
    super.rotation,
    super.scale,
    super.id,
    super.flipX,
    super.flipY,
    super.enableInteraction,
  });

  /// Factory constructor for creating an EmojiLayerData instance from a Layer
  /// and a map.
  factory EmojiLayerData.fromMap(Layer layer, Map<String, dynamic> map) {
    /// Constructs and returns an EmojiLayerData instance with properties
    /// derived from the layer and map.
    return EmojiLayerData(
      flipX: layer.flipX,
      flipY: layer.flipY,
      enableInteraction: layer.enableInteraction,
      offset: layer.offset,
      rotation: layer.rotation,
      scale: layer.scale,
      emoji: map['emoji'],
    );
  }

  /// The emoji to display on the layer.
  String emoji;

  @override
  Map<String, dynamic> toMap() {
    return {
      ...super.toMap(),
      'emoji': emoji,
      'type': 'emoji',
    };
  }
}
