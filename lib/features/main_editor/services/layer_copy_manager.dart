// Dart imports:
import 'dart:ui';

// Project imports:
import '/core/models/layers/layer.dart';

/// A class responsible for managing layers in an image editing environment.
///
/// The `LayerManager` provides methods for copying layers to create new
/// instances of the same type. It supports various types of layers, including
/// text, emoji, paint, and sticker layers.
class LayerCopyManager {
  /// Copy a layer to create a new instance of the same type.
  ///
  /// This method takes a [layer] as input and creates a new instance of the
  /// same type.
  /// If the layer type is not recognized, it returns the original layer
  /// unchanged.
  Layer copyLayer(Layer layer) {
    if (layer is TextLayer) {
      return createCopyTextLayer(layer);
    } else if (layer is EmojiLayer) {
      return createCopyEmojiLayer(layer);
    } else if (layer is PaintLayer) {
      return createCopyPaintLayer(layer);
    } else if (layer is WidgetLayer) {
      return createCopyWidgetLayer(layer);
    } else {
      return layer;
    }
  }

  /// Copy a list of layers to create a new instances of the same type.
  List<Layer> copyLayerList(List<Layer> layers) {
    return layers.map(copyLayer).toList();
  }

  /// Create a copy of a TextLayer instance.
  TextLayer createCopyTextLayer(TextLayer layer) {
    return TextLayer(
      id: layer.id,
      text: layer.text,
      align: layer.align,
      fontScale: layer.fontScale,
      background: Color.from(
        red: layer.background.r,
        green: layer.background.g,
        blue: layer.background.b,
        alpha: layer.background.a,
      ),
      color: Color.from(
        red: layer.color.r,
        green: layer.color.g,
        blue: layer.color.b,
        alpha: layer.color.a,
      ),
      colorMode: layer.colorMode,
      colorPickerPosition: layer.colorPickerPosition,
      offset: Offset(layer.offset.dx, layer.offset.dy),
      rotation: layer.rotation,
      textStyle: layer.textStyle,
      scale: layer.scale,
      flipX: layer.flipX,
      flipY: layer.flipY,
      customSecondaryColor: layer.customSecondaryColor,
      interaction: layer.interaction.copyWith(),
      boxConstraints: layer.boxConstraints,
    );
  }

  /// Create a copy of an EmojiLayer instance.
  EmojiLayer createCopyEmojiLayer(EmojiLayer layer) {
    return EmojiLayer(
      id: layer.id,
      emoji: layer.emoji,
      offset: Offset(layer.offset.dx, layer.offset.dy),
      rotation: layer.rotation,
      scale: layer.scale,
      flipX: layer.flipX,
      flipY: layer.flipY,
      interaction: layer.interaction.copyWith(),
      boxConstraints: layer.boxConstraints,
    );
  }

  /// Create a copy of an WidgetLayer instance.
  WidgetLayer createCopyWidgetLayer(WidgetLayer layer) {
    return WidgetLayer(
      id: layer.id,
      widget: layer.widget,
      offset: Offset(layer.offset.dx, layer.offset.dy),
      rotation: layer.rotation,
      scale: layer.scale,
      flipX: layer.flipX,
      flipY: layer.flipY,
      interaction: layer.interaction.copyWith(),
      boxConstraints: layer.boxConstraints,
      exportConfigs: layer.exportConfigs.copyWith(),
    );
  }

  /// Create a copy of a PaintLayer instance.
  PaintLayer createCopyPaintLayer(PaintLayer layer) {
    return PaintLayer(
      id: layer.id,
      offset: Offset(layer.offset.dx, layer.offset.dy),
      rotation: layer.rotation,
      scale: layer.scale,
      flipX: layer.flipX,
      flipY: layer.flipY,
      item: layer.item.copy(),
      rawSize: layer.rawSize,
      opacity: layer.opacity,
      interaction: layer.interaction.copyWith(),
      boxConstraints: layer.boxConstraints,
    );
  }
}
