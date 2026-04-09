import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import '/core/constants/int_constants.dart';
import 'layer.dart';
import 'layer_interaction.dart';

/// A class representing a layer with emoji content.
///
/// EmojiLayer is a subclass of [Layer] that allows you to display emoji
/// on a canvas. You can specify the emoji to display, along with optional
/// properties like offset, rotation, scale, and more.
///
/// Example usage:
/// ```dart
/// EmojiLayer(
///   emoji: '😀',
///   offset: Offset(100.0, 100.0),
///   rotation: 45.0,
///   scale: 2.0,
/// );
/// ```
class EmojiLayer extends Layer {
  /// Creates an instance of EmojiLayer.
  ///
  /// The [emoji] parameter is required, and other properties are optional.
  EmojiLayer({
    required this.emoji,
    super.offset,
    super.rotation,
    super.scale,
    super.id,
    super.flipX,
    super.flipY,
    super.interaction,
    super.meta,
    super.boxConstraints,
    super.key,
    super.groupId,
    super.startTime,
    super.endTime,
    super.enterDuration,
    super.exitDuration,
    super.enterCurve,
    super.exitCurve,
    super.transitionBuilder,
  });

  /// Factory constructor for creating an EmojiLayer instance from a Layer
  /// and a map.
  factory EmojiLayer.fromMap(
    Layer layer,
    Map<String, dynamic> map, {
    Function(String key)? keyConverter,
  }) {
    keyConverter ??= (String key) => key;

    /// Constructs and returns an EmojiLayer instance with properties
    /// derived from the layer and map.
    return EmojiLayer(
      id: layer.id,
      flipX: layer.flipX,
      flipY: layer.flipY,
      interaction: layer.interaction,
      offset: layer.offset,
      rotation: layer.rotation,
      scale: layer.scale,
      meta: layer.meta,
      groupId: layer.groupId,
      startTime: layer.startTime,
      endTime: layer.endTime,
      enterDuration: layer.enterDuration,
      exitDuration: layer.exitDuration,
      enterCurve: layer.enterCurve,
      exitCurve: layer.exitCurve,
      emoji: map[keyConverter('emoji')],
      boxConstraints: layer.boxConstraints,
    );
  }

  /// The emoji to display on the layer.
  String emoji;

  @override
  bool get isEmojiLayer => true;

  @override
  Map<String, dynamic> toMap({
    int maxDecimalPlaces = kMaxSafeDecimalPlaces,
    bool enableMinify = false,
  }) {
    return {
      ...super.toMap(
        maxDecimalPlaces: maxDecimalPlaces,
        enableMinify: enableMinify,
      ),
      'emoji': emoji,
      'type': 'emoji',
    };
  }

  @override
  Map<String, dynamic> toMapFromReference(
    Layer layer, {
    int maxDecimalPlaces = kMaxSafeDecimalPlaces,
    bool enableMinify = false,
  }) {
    return {
      ...super.toMapFromReference(
        layer,
        maxDecimalPlaces: maxDecimalPlaces,
        enableMinify: enableMinify,
      ),
      if ((layer as EmojiLayer).emoji != emoji) 'emoji': emoji,
    };
  }

  /// Creates a copy of this [EmojiLayer] with the given fields replaced with
  /// new values.
  @override
  EmojiLayer copyWith({
    String? emoji,
    Offset? offset,
    double? rotation,
    double? scale,
    bool? flipX,
    bool? flipY,
    LayerInteraction? interaction,
    Map<String, dynamic>? meta,
    BoxConstraints? boxConstraints,
    String? id,
    String? groupId,
    Duration? startTime,
    Duration? endTime,
    Duration? enterDuration,
    Duration? exitDuration,
    Curve? enterCurve,
    Curve? exitCurve,
    LayerTimelineTransitionBuilder? transitionBuilder,
  }) {
    return EmojiLayer(
      emoji: emoji ?? this.emoji,
      offset: offset ?? this.offset,
      rotation: rotation ?? this.rotation,
      scale: scale ?? this.scale,
      flipX: flipX ?? this.flipX,
      flipY: flipY ?? this.flipY,
      interaction: interaction ?? this.interaction,
      meta: meta ?? this.meta,
      boxConstraints: boxConstraints ?? this.boxConstraints,
      id: id ?? this.id,
      groupId: groupId ?? this.groupId,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      enterDuration: enterDuration ?? this.enterDuration,
      exitDuration: exitDuration ?? this.exitDuration,
      enterCurve: enterCurve ?? this.enterCurve,
      exitCurve: exitCurve ?? this.exitCurve,
      transitionBuilder: transitionBuilder ?? this.transitionBuilder,
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(StringProperty('emoji', emoji));
  }
}
