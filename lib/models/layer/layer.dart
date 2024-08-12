// ignore_for_file: argument_type_not_assignable

// Flutter imports:
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

// Project imports:
import '../../utils/unique_id_generator.dart';
import '../paint_editor/painted_model.dart';
import 'layer_background_mode.dart';

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
      offset: Offset(map['x'] ?? 0, map['y'] ?? 0),
      rotation: map['rotation'] ?? 0,
      scale: map['scale'] ?? 1,
    );

    /// Determines the layer type from the map and returns the appropriate
    /// LayerData subclass.
    switch (map['type']) {
      case 'text':

        /// Returns a TextLayerData instance when type is 'text'.
        return TextLayerData.fromMap(layer, map);
      case 'emoji':

        /// Returns an EmojiLayerData instance when type is 'emoji'.
        return EmojiLayerData.fromMap(layer, map);
      case 'painting':

        /// Returns a PaintingLayerData instance when type is 'painting'.
        return PaintingLayerData.fromMap(layer, map);
      case 'sticker':

        /// Returns a StickerLayerData instance when type is 'sticker',
        /// utilizing the stickers list.
        return StickerLayerData.fromMap(layer, map, stickers);
      default:

        /// Returns the base Layer instance when type is unrecognized.
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
      'type': 'default',
    };
  }
}

/// Represents a text layer with customizable properties.
class TextLayerData extends Layer {
  /// Creates a new text layer with customizable properties.
  ///
  /// The [text] parameter specifies the text content of the layer.
  /// The [colorMode] parameter sets the color mode for the text.
  /// The [colorPickerPosition] parameter sets the position of the color picker
  /// (if applicable).
  /// The [color] parameter specifies the text color (default is Colors.white).
  /// The [background] parameter defines the background color for the text
  /// (default is Colors.transparent).
  /// The [align] parameter determines the text alignment within the layer
  /// (default is TextAlign.left).
  /// The other optional parameters such as [textStyle], [offset], [rotation],
  /// [scale], [id], [flipX], and [flipY]
  /// can be used to customize the position, appearance, and behavior of the
  /// text layer.
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

  /// Factory constructor for creating a TextLayerData instance from a Layer
  /// instance and a map.
  factory TextLayerData.fromMap(Layer layer, Map<String, dynamic> map) {
    /// Helper function to determine the text decoration style from a string.
    TextDecoration getDecoration(String decoration) {
      if (decoration.contains('combine')) {
        /// List to hold multiple text decoration styles if combined.
        List<TextDecoration> decorations = [];

        /// Adds line-through decoration if specified.
        if (decoration.contains('lineThrough')) {
          decorations.add(TextDecoration.lineThrough);
        }

        /// Adds overline decoration if specified.
        if (decoration.contains('overline')) {
          decorations.add(TextDecoration.overline);
        }

        /// Adds underline decoration if specified.
        if (decoration.contains('underline')) {
          decorations.add(TextDecoration.underline);
        }

        /// Combines multiple decorations into a single TextDecoration.
        return TextDecoration.combine(decorations);
      } else {
        /// Checks and returns line-through decoration.
        if (decoration.contains('lineThrough')) {
          return TextDecoration.lineThrough;
        }

        /// Checks and returns overline decoration.
        else if (decoration.contains('overline')) {
          return TextDecoration.overline;
        }

        /// Checks and returns underline decoration.
        else if (decoration.contains('underline')) {
          return TextDecoration.underline;
        }
      }

      /// Returns no decoration if none is specified.
      return TextDecoration.none;
    }

    /// Optional properties for text styling from the map.
    String? fontFamily = map['fontFamily'] as String?;
    double? wordSpacing = map['wordSpacing'] as double?;
    double? height = map['height'] as double?;
    double? letterSpacing = map['letterSpacing'] as double?;
    int? fontWeight = map['fontWeight'] as int?;
    String? fontStyle = map['fontStyle'] as String?;
    String? decoration = map['decoration'] as String?;

    /// Constructs and returns a TextLayerData instance with properties derived
    /// from the map.
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

  /// A custom text style for the text. Be careful the editor allow not to
  /// import and export this style.
  TextStyle? textStyle;

  @override
  Map<String, dynamic> toMap() {
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

  /// Factory constructor for creating an EmojiLayerData instance from a Layer
  /// and a map.
  factory EmojiLayerData.fromMap(Layer layer, Map<String, dynamic> map) {
    /// Constructs and returns an EmojiLayerData instance with properties
    /// derived from the layer and map.
    return EmojiLayerData(
      flipX: layer.flipX,
      flipY: layer.flipY,
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

  /// Factory constructor for creating a PaintingLayerData instance from a
  /// Layer and a map.
  factory PaintingLayerData.fromMap(Layer layer, Map<String, dynamic> map) {
    /// Constructs and returns a PaintingLayerData instance with properties
    /// derived from the layer and map.
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
      'type': 'painting',
    };
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

  /// Factory constructor for creating a StickerLayerData instance from a
  /// Layer, a map, and a list of stickers.
  factory StickerLayerData.fromMap(
    Layer layer,
    Map<String, dynamic> map,
    List<Uint8List> stickers,
  ) {
    /// Determines the position of the sticker in the list.
    int stickerPosition = (map['listPosition'] as int?) ?? -1;

    /// Widget to display a sticker or a placeholder if not found.
    Widget sticker = kDebugMode
        ? Text(
            'Sticker $stickerPosition not found',
            style: const TextStyle(color: Colors.red, fontSize: 24),
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
  }) {
    return StickerLayerData(
      sticker: sticker ?? this.sticker,
      offset: offset ?? this.offset,
      rotation: rotation ?? this.rotation,
      scale: scale ?? this.scale,
      id: id ?? this.id,
      flipX: flipX ?? this.flipX,
      flipY: flipY ?? this.flipY,
    );
  }
}
