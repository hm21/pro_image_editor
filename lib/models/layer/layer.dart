// Flutter imports:
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

// Project imports:
import '../../utils/unique_id_generator.dart';
import '../paint_editor/painted_model.dart';
import 'layer_background_mode.dart';

/// Represents a layer with common properties for widgets.
class Layer {
  late GlobalKey key;

  /// The position offset of the widget.
  late Offset offset;

  /// The rotation and scale values of the widget.
  late double rotation, scale;

  /// Flags to control horizontal and vertical flipping.
  late bool flipX, flipY;

  /// A unique identifier for the layer.
  late String id;

  /// Creates a new layer with optional properties.
  ///
  /// The [id] parameter can be used to provide a custom identifier for the layer.
  /// The [offset] parameter determines the position offset of the widget.
  /// The [rotation] parameter sets the rotation angle of the widget in degrees (default is 0).
  /// The [scale] parameter sets the scale factor of the widget (default is 1).
  /// The [flipX] parameter controls horizontal flipping (default is false).
  /// The [flipY] parameter controls vertical flipping (default is false).
  Layer({
    String? id,
    Offset? offset,
    double? rotation,
    double? scale,
    bool? flipX,
    bool? flipY,
  }) {
    key = GlobalKey();
    // Initialize properties with provided values or defaults.
    this.id = id ?? generateUniqueId();
    this.offset = offset ?? Offset.zero;
    this.rotation = rotation ?? 0;
    this.scale = scale ?? 1;
    this.flipX = flipX ?? false;
    this.flipY = flipY ?? false;
  }

  factory Layer.fromMap(
    Map map,
    List<Uint8List> stickers,
  ) {
    Layer layer = Layer(
      flipX: map['flipX'] ?? false,
      flipY: map['flipY'] ?? false,
      offset: Offset(map['x'] ?? 0, map['y'] ?? 0),
      rotation: map['rotation'] ?? 0,
      scale: map['scale'] ?? 1,
    );

    switch (map['type']) {
      case 'text':
        return TextLayerData.fromMap(layer, map);
      case 'emoji':
        return EmojiLayerData.fromMap(layer, map);
      case 'painting':
        return PaintingLayerData.fromMap(layer, map);
      case 'sticker':
        return StickerLayerData.fromMap(layer, map, stickers);
      default:
        return layer;
    }
  }

  /// Converts this transform object to a Map.
  ///
  /// Returns a Map representing the properties of this layer object,
  /// including the X and Y coordinates, rotation angle, scale factors, and
  /// flip flags.
  Map toMap() {
    return {
      'x': offset.dx,
      'y': offset.dy,
      'rotation': rotation,
      'scale': scale,
      'flipX': flipX,
      'flipY': flipY,
      'type': 'default',
    };
  }
}

/// Represents a text layer with customizable properties.
class TextLayerData extends Layer {
  /// The text content of the layer.
  String text;

  /// The color mode for the text.
  LayerBackgroundMode? colorMode;

  /// The text color.
  Color color;

  /// The background color for the text.
  Color background;

  /// This flag define if the secondary color is manually set.
  bool customSecondaryColor;

  /// The position of the color picker (if applicable).
  double? colorPickerPosition;

  /// The text alignment within the layer.
  TextAlign align;

  /// The font scale for text, to make text bigger or smaller.
  double fontScale;

  /// A custom text style for the text. Be careful the editor allow not to import
  /// and export this style.
  TextStyle? textStyle;

  /// Creates a new text layer with customizable properties.
  ///
  /// The [text] parameter specifies the text content of the layer.
  /// The [colorMode] parameter sets the color mode for the text.
  /// The [colorPickerPosition] parameter sets the position of the color picker (if applicable).
  /// The [color] parameter specifies the text color (default is Colors.white).
  /// The [background] parameter defines the background color for the text (default is Colors.transparent).
  /// The [align] parameter determines the text alignment within the layer (default is TextAlign.left).
  /// The other optional parameters such as [textStyle], [offset], [rotation], [scale], [id], [flipX], and [flipY]
  /// can be used to customize the position, appearance, and behavior of the text layer.
  TextLayerData({
    required this.text,
    this.customSecondaryColor = false,
    this.textStyle,
    this.colorMode,
    this.colorPickerPosition,
    this.color = Colors.white,
    this.background = Colors.transparent,
    this.align = TextAlign.left,
    this.fontScale = 1.0,
    super.offset,
    super.rotation,
    super.scale,
    super.id,
    super.flipX,
    super.flipY,
  });

  @override
  Map toMap() {
    return {
      ...super.toMap(),
      'text': text,
      'colorMode': LayerBackgroundMode.values[colorMode?.index ?? 0].name,
      'color': color.value,
      'background': background.value,
      'colorPickerPosition': colorPickerPosition ?? 0,
      'align': align.name,
      'fontScale': fontScale,
      'type': 'text',
      if (customSecondaryColor) 'customSecondaryColor': customSecondaryColor,
      if (textStyle?.fontFamily != null) 'fontFamily': textStyle?.fontFamily,
      if (textStyle?.fontStyle != null) 'fontStyle': textStyle?.fontStyle!.name,
      if (textStyle?.fontWeight != null)
        'fontWeight': textStyle?.fontWeight!.value,
      if (textStyle?.letterSpacing != null)
        'letterSpacing': textStyle?.letterSpacing,
      if (textStyle?.height != null) 'height': textStyle?.height,
      if (textStyle?.wordSpacing != null) 'wordSpacing': textStyle?.wordSpacing,
      if (textStyle?.decoration != null)
        'decoration': textStyle?.decoration.toString(),
    };
  }

  factory TextLayerData.fromMap(Layer layer, Map map) {
    TextDecoration getDecoration(String decoration) {
      if (decoration.contains('combine')) {
        List<TextDecoration> decorations = [];

        if (decoration.contains('lineThrough')) {
          decorations.add(TextDecoration.lineThrough);
        }
        if (decoration.contains('overline')) {
          decorations.add(TextDecoration.overline);
        }
        if (decoration.contains('underline')) {
          decorations.add(TextDecoration.underline);
        }

        return TextDecoration.combine(decorations);
      } else {
        if (decoration.contains('lineThrough')) {
          return TextDecoration.lineThrough;
        } else if (decoration.contains('overline')) {
          return TextDecoration.overline;
        } else if (decoration.contains('underline')) {
          return TextDecoration.underline;
        }
      }

      return TextDecoration.none;
    }

    String? fontFamily = map['fontFamily'];
    double? wordSpacing = map['wordSpacing'];
    double? height = map['height'];
    double? letterSpacing = map['letterSpacing'];
    int? fontWeight = map['fontWeight'];
    String? fontStyle = map['fontStyle'];
    String? decoration = map['decoration'];
    return TextLayerData(
      flipX: layer.flipX,
      flipY: layer.flipY,
      offset: layer.offset,
      rotation: layer.rotation,
      scale: layer.scale,
      text: map['text'] ?? '-',
      fontScale: map['fontScale'] ?? 1.0,
      textStyle: map['fontFamily'] != null
          ? TextStyle(
              fontFamily: fontFamily,
              height: height,
              wordSpacing: wordSpacing,
              letterSpacing: letterSpacing,
              decoration: decoration != null ? getDecoration(decoration) : null,
              fontStyle: fontStyle != null
                  ? FontStyle.values
                      .firstWhere((element) => element.name == fontStyle)
                  : null,
              fontWeight: fontWeight != null
                  ? FontWeight.values
                      .firstWhere((element) => element.value == fontWeight)
                  : null,
            )
          : null,
      colorMode: LayerBackgroundMode.values
          .firstWhere((element) => element.name == map['colorMode']),
      color: Color(map['color']),
      background: Color(map['background']),
      colorPickerPosition: map['colorPickerPosition'] ?? 0,
      align: TextAlign.values
          .firstWhere((element) => element.name == map['align']),
      customSecondaryColor: map['customSecondaryColor'] ?? false,
    );
  }
}

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
  /// The emoji to display on the layer.
  String emoji;

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
  });

  @override
  Map toMap() {
    return {
      ...super.toMap(),
      'emoji': emoji,
      'type': 'emoji',
    };
  }

  factory EmojiLayerData.fromMap(Layer layer, Map map) {
    return EmojiLayerData(
      flipX: layer.flipX,
      flipY: layer.flipY,
      offset: layer.offset,
      rotation: layer.rotation,
      scale: layer.scale,
      emoji: map['emoji'],
    );
  }
}

/// A class representing a layer with custom painting content.
///
/// PaintingLayerData is a subclass of [Layer] that allows you to display
/// custom-painted content on a canvas. You can specify the painted item and
/// its raw size, along with optional properties like offset, rotation,
/// scale, and more.
///
/// Example usage:
/// ```dart
/// PaintingLayerData(
///   item: CustomPaintedItem(),
///   rawSize: Size(200.0, 150.0),
///   offset: Offset(50.0, 50.0),
///   rotation: -30.0,
///   scale: 1.5,
/// );
/// ```
class PaintingLayerData extends Layer {
  /// The custom-painted item to display on the layer.
  final PaintedModel item;

  /// The raw size of the painted item before applying scaling.
  final Size rawSize;

  /// The opacity level of the drawing.
  final double opacity;

  /// Creates an instance of PaintingLayerData.
  ///
  /// The [item] and [rawSize] parameters are required, and other properties
  /// are optional.
  PaintingLayerData({
    required this.item,
    required this.rawSize,
    required this.opacity,
    super.offset,
    super.rotation,
    super.scale,
    super.id,
    super.flipX,
    super.flipY,
  });

  /// Returns the size of the layer after applying the scaling factor.
  Size get size => Size(rawSize.width * scale, rawSize.height * scale);

  @override
  Map toMap() {
    return {
      ...super.toMap(),
      'item': item.toMap(),
      'rawSize': {
        'w': rawSize.width,
        'h': rawSize.height,
      },
      'opacity': opacity,
      'type': 'painting',
    };
  }

  factory PaintingLayerData.fromMap(Layer layer, Map map) {
    return PaintingLayerData(
      flipX: layer.flipX,
      flipY: layer.flipY,
      offset: layer.offset,
      rotation: layer.rotation,
      scale: layer.scale,
      opacity: map['opacity'] ?? 1.0,
      rawSize: Size(
        map['rawSize']?['w'] ?? 0,
        map['rawSize']?['h'] ?? 0,
      ),
      item: PaintedModel.fromMap(map['item'] ?? {}),
    );
  }
}

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
  /// The sticker to display on the layer.
  Widget sticker;

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
  });

  /// Converts this transform object to a Map suitable for representing a sticker.
  ///
  /// Returns a Map representing the properties of this transform object, augmented
  /// with the specified [listPosition] indicating the position of the sticker in a list.
  Map toStickerMap(int listPosition) {
    return {
      ...toMap(),
      'listPosition': listPosition,
      'type': 'sticker',
    };
  }

  factory StickerLayerData.fromMap(
    Layer layer,
    Map map,
    List<Uint8List> stickers,
  ) {
    int stickerPosition = map['listPosition'] ?? -1;
    Widget sticker = kDebugMode
        ? Text(
            'Sticker $stickerPosition not found',
            style: const TextStyle(color: Colors.red, fontSize: 24),
          )
        : const SizedBox.shrink();
    if (stickers.isNotEmpty && stickers.length > stickerPosition) {
      sticker = ConstrainedBox(
        constraints: const BoxConstraints(minWidth: 1, minHeight: 1),
        child: Image.memory(
          stickers[stickerPosition],
        ),
      );
    }

    return StickerLayerData(
      flipX: layer.flipX,
      flipY: layer.flipY,
      offset: layer.offset,
      rotation: layer.rotation,
      scale: layer.scale,
      sticker: sticker,
    );
  }
}
