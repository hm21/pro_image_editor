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
    if (layer.isTextLayer) {
      return createCopyTextLayer(layer as TextLayer);
    } else if (layer.isEmojiLayer) {
      return createCopyEmojiLayer(layer as EmojiLayer);
    } else if (layer.isPaintLayer) {
      return createCopyPaintLayer(layer as PaintLayer);
    } else if (layer.isWidgetLayer) {
      return createCopyWidgetLayer(layer as WidgetLayer);
    } else {
      return layer;
    }
  }

  /// Creates a duplicate of the given layer.
  ///
  /// Returns a new copy of the layer with the same content. If the layer type
  /// is not supported, it returns the original layer without duplication.
  Layer duplicateLayer(
    Layer layer, {
    Offset offset = const Offset(30, 30),
    bool enableCopyId = false,
    bool enableCopyKey = false,
  }) {
    if (layer.isTextLayer) {
      return createCopyTextLayer(
        layer as TextLayer,
        enableCopyId: enableCopyId,
        enableCopyKey: enableCopyKey,
        offset: offset,
      );
    } else if (layer.isEmojiLayer) {
      return createCopyEmojiLayer(
        layer as EmojiLayer,
        enableCopyId: enableCopyId,
        enableCopyKey: enableCopyKey,
        offset: offset,
      );
    } else if (layer.isPaintLayer) {
      return createCopyPaintLayer(
        layer as PaintLayer,
        enableCopyId: enableCopyId,
        enableCopyKey: enableCopyKey,
        offset: offset,
      );
    } else if (layer.isWidgetLayer) {
      return createCopyWidgetLayer(
        layer as WidgetLayer,
        enableCopyId: enableCopyId,
        enableCopyKey: enableCopyKey,
        offset: offset,
      );
    } else {
      return layer;
    }
  }

  /// Copy a list of layers to create a new instances of the same type.
  List<Layer> copyLayerList(List<Layer> layers) {
    return layers.map(copyLayer).toList();
  }

  /// Duplicate a list of layers to create a new instances of the same type.
  List<Layer> duplicateLayerList(
    List<Layer> layers, {
    Offset offset = const Offset(30, 30),
    bool enableCopyId = false,
    bool enableCopyKey = false,
  }) {
    return layers
        .map(
          (layer) => duplicateLayer(
            layer,
            offset: offset,
            enableCopyId: enableCopyId,
            enableCopyKey: enableCopyKey,
          ),
        )
        .toList();
  }

  /// Create a copy of a TextLayer instance.
  TextLayer createCopyTextLayer(
    TextLayer layer, {
    bool enableCopyId = true,
    bool enableCopyKey = true,
    Offset offset = Offset.zero,
  }) {
    return TextLayer(
      id: enableCopyId ? layer.id : null,
      key: enableCopyKey ? layer.key : null,
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
      offset: Offset(
        layer.offset.dx + offset.dx,
        layer.offset.dy + offset.dy,
      ),
      rotation: layer.rotation,
      textStyle: layer.textStyle,
      scale: layer.scale,
      flipX: layer.flipX,
      flipY: layer.flipY,
      meta: layer.meta,
      maxTextWidth: layer.maxTextWidth,
      customSecondaryColor: layer.customSecondaryColor,
      interaction: layer.interaction.copyWith(),
      boxConstraints: layer.boxConstraints?.copyWith(),
    )..groupId = layer.groupId;
  }

  /// Create a copy of an EmojiLayer instance.
  EmojiLayer createCopyEmojiLayer(
    EmojiLayer layer, {
    bool enableCopyId = true,
    bool enableCopyKey = true,
    Offset offset = Offset.zero,
  }) {
    return EmojiLayer(
      id: enableCopyId ? layer.id : null,
      key: enableCopyKey ? layer.key : null,
      emoji: layer.emoji,
      offset: Offset(
        layer.offset.dx + offset.dx,
        layer.offset.dy + offset.dy,
      ),
      rotation: layer.rotation,
      scale: layer.scale,
      flipX: layer.flipX,
      flipY: layer.flipY,
      meta: layer.meta,
      interaction: layer.interaction.copyWith(),
      boxConstraints: layer.boxConstraints?.copyWith(),
    )..groupId = layer.groupId;
  }

  /// Create a copy of an WidgetLayer instance.
  WidgetLayer createCopyWidgetLayer(
    WidgetLayer layer, {
    bool enableCopyId = true,
    bool enableCopyKey = true,
    Offset offset = Offset.zero,
  }) {
    return WidgetLayer(
      id: enableCopyId ? layer.id : null,
      key: enableCopyKey ? layer.key : null,
      widget: layer.widget,
      offset: Offset(
        layer.offset.dx + offset.dx,
        layer.offset.dy + offset.dy,
      ),
      rotation: layer.rotation,
      scale: layer.scale,
      flipX: layer.flipX,
      flipY: layer.flipY,
      meta: layer.meta,
      width: layer.width,
      interaction: layer.interaction.copyWith(),
      boxConstraints: layer.boxConstraints?.copyWith(),
      exportConfigs: layer.exportConfigs.copyWith(),
    )..groupId = layer.groupId;
  }

  /// Create a copy of a PaintLayer instance.
  PaintLayer createCopyPaintLayer(
    PaintLayer layer, {
    bool enableCopyId = true,
    bool enableCopyKey = true,
    Offset offset = Offset.zero,
  }) {
    return PaintLayer(
      id: enableCopyId ? layer.id : null,
      key: enableCopyKey ? layer.key : null,
      offset: Offset(
        layer.offset.dx + offset.dx,
        layer.offset.dy + offset.dy,
      ),
      rotation: layer.rotation,
      scale: layer.scale,
      flipX: layer.flipX,
      flipY: layer.flipY,
      meta: layer.meta,
      item: layer.item.copy(),
      rawSize: layer.rawSize,
      opacity: layer.opacity,
      interaction: layer.interaction.copyWith(),
      boxConstraints: layer.boxConstraints?.copyWith(),
    )..groupId = layer.groupId;
  }
}
