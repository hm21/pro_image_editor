import 'package:flutter/widgets.dart';

import '/shared/extensions/color_extension.dart';
import '../../utils/parser/double_parser.dart';
import '../../utils/parser/int_parser.dart';
import 'enums/layer_background_mode.dart';
import 'layer.dart';

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
    this.color = const Color(0xFFFFFFFF),
    this.background = const Color(0x00000000),
    this.align = TextAlign.left,
    this.fontScale = 1.0,
    super.offset,
    super.rotation,
    super.scale,
    super.id,
    super.flipX,
    super.flipY,
    super.enableInteraction,
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
    double? wordSpacing = tryParseDouble(map['wordSpacing']);
    double? height = tryParseDouble(map['height']);
    double? letterSpacing = tryParseDouble(map['letterSpacing']);
    int? fontWeight = tryParseInt(map['fontWeight']);
    String? fontStyle = map['fontStyle'] as String?;
    String? decoration = map['decoration'] as String?;

    /// Constructs and returns a TextLayerData instance with properties derived
    /// from the map.
    return TextLayerData(
      flipX: layer.flipX,
      flipY: layer.flipY,
      enableInteraction: layer.enableInteraction,
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
      'color': color.toHex(),
      'background': background.toHex(),
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
