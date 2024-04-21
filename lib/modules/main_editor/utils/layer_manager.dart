import 'dart:ui';

import 'package:pro_image_editor/models/layer.dart';

/// A class responsible for managing layers in an image editing environment.
///
/// The `LayerManager` provides methods for copying layers to create new instances
/// of the same type. It supports various types of layers, including text, emoji,
/// painting, and sticker layers.
class LayerManager {
  /// Copy a layer to create a new instance of the same type.
  ///
  /// This method takes a [layer] as input and creates a new instance of the same type.
  /// If the layer type is not recognized, it returns the original layer unchanged.
  Layer copyLayer(Layer layer) {
    if (layer is TextLayerData) {
      return createCopyTextLayer(layer);
    } else if (layer is EmojiLayerData) {
      return createCopyEmojiLayer(layer);
    } else if (layer is PaintingLayerData) {
      return createCopyPaintingLayer(layer);
    } else if (layer is StickerLayerData) {
      return createCopyStickerLayer(layer);
    } else {
      return layer;
    }
  }

  /// Create a copy of a TextLayerData instance.
  TextLayerData createCopyTextLayer(TextLayerData layer) {
    return TextLayerData(
      id: layer.id,
      text: layer.text,
      align: layer.align,
      fontScale: layer.fontScale,
      background: Color(layer.background.value),
      color: Color(layer.color.value),
      colorMode: layer.colorMode,
      colorPickerPosition: layer.colorPickerPosition,
      offset: Offset(layer.offset.dx, layer.offset.dy),
      rotation: layer.rotation,
      textStyle: layer.textStyle,
      scale: layer.scale,
      flipX: layer.flipX,
      flipY: layer.flipY,
    );
  }

  /// Create a copy of an EmojiLayerData instance.
  EmojiLayerData createCopyEmojiLayer(EmojiLayerData layer) {
    return EmojiLayerData(
      id: layer.id,
      emoji: layer.emoji,
      offset: Offset(layer.offset.dx, layer.offset.dy),
      rotation: layer.rotation,
      scale: layer.scale,
      flipX: layer.flipX,
      flipY: layer.flipY,
    );
  }

  /// Create a copy of an EmojiLayerData instance.
  StickerLayerData createCopyStickerLayer(StickerLayerData layer) {
    return StickerLayerData(
      id: layer.id,
      sticker: layer.sticker,
      offset: Offset(layer.offset.dx, layer.offset.dy),
      rotation: layer.rotation,
      scale: layer.scale,
      flipX: layer.flipX,
      flipY: layer.flipY,
    );
  }

  /// Create a copy of a PaintingLayerData instance.
  PaintingLayerData createCopyPaintingLayer(PaintingLayerData layer) {
    return PaintingLayerData(
      id: layer.id,
      offset: Offset(layer.offset.dx, layer.offset.dy),
      rotation: layer.rotation,
      scale: layer.scale,
      flipX: layer.flipX,
      flipY: layer.flipY,
      item: layer.item.copy(),
      rawSize: layer.rawSize,
    );
  }
}
