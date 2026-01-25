import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import '/core/constants/int_constants.dart';
import '/shared/extensions/color_extension.dart';
import '/shared/extensions/num_extension.dart';
import '/shared/utils/parser/double_parser.dart';
import '/shared/utils/parser/int_parser.dart';
import 'enums/layer_background_mode.dart';
import 'layer.dart';
import 'layer_interaction.dart';

/// Represents a text layer with customizable properties.
class TextLayer extends Layer {
  /// Creates a new text layer with customizable properties.
  ///
  /// The [text] parameter specifies the text content of the layer.
  /// The [colorMode] parameter sets the color mode for the text.
  /// The [color] parameter specifies the text color (default is Colors.white).
  /// The [background] parameter defines the background color for the text
  /// (default is Colors.transparent).
  /// The [align] parameter determines the text alignment within the layer
  /// (default is TextAlign.left).
  /// The other optional parameters such as [textStyle], [offset], [rotation],
  /// [scale], [id], [flipX], and [flipY]
  /// can be used to customize the position, appearance, and behavior of the
  /// text layer.
  TextLayer({
    required this.text,
    this.customSecondaryColor = false,
    this.hit = false,
    this.textStyle,
    this.colorMode = LayerBackgroundMode.backgroundAndColor,
    this.color = const Color(0xFF000000),
    this.background = const Color(0xFFFFFFFF),
    this.align = TextAlign.left,
    this.fontScale = 1.0,
    this.maxTextWidth,
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
  });

  /// Factory constructor for creating a TextLayer instance from a Layer
  /// instance and a map.
  factory TextLayer.fromMap(
    Layer layer,
    Map<String, dynamic> map, {
    Function(String key)? keyConverter,
  }) {
    keyConverter ??= (String key) => key;

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
    String? fontFamily = map[keyConverter('fontFamily')] as String?;
    double? wordSpacing = tryParseDouble(map[keyConverter('wordSpacing')]);
    double? height = tryParseDouble(map[keyConverter('height')]);
    double? letterSpacing = tryParseDouble(map[keyConverter('letterSpacing')]);
    double? fontScale = tryParseDouble(map[keyConverter('fontScale')]) ?? 1.0;
    int? fontWeight = tryParseInt(map[keyConverter('fontWeight')]);
    String? fontStyle = map[keyConverter('fontStyle')] as String?;
    String? decoration = map[keyConverter('decoration')] as String?;

    // Parse shadows
    final shadows = List.from(map[keyConverter('shadows')] ?? []).map((raw) {
      final c = safeParseInt(raw['color']);
      final b = safeParseDouble(raw['blurRadius']);
      final ox = safeParseDouble(raw['offsetX']);
      final oy = safeParseDouble(raw['offsetY']);

      return Shadow(
        color: Color(c),
        blurRadius: b,
        offset: Offset(ox, oy),
      );
    }).toList();

    /// Constructs and returns a TextLayer instance with properties derived
    /// from the map.
    return TextLayer(
      id: layer.id,
      flipX: layer.flipX,
      flipY: layer.flipY,
      interaction: layer.interaction,
      offset: layer.offset,
      rotation: layer.rotation,
      scale: layer.scale,
      meta: layer.meta,
      boxConstraints: layer.boxConstraints,
      groupId: layer.groupId,
      text: map[keyConverter('text')] ?? '-',
      fontScale: fontScale,
      maxTextWidth: tryParseDouble(map[keyConverter('maxTextWidth')]),
      textStyle: fontFamily != null ||
              wordSpacing != null ||
              height != null ||
              letterSpacing != null ||
              fontWeight != null ||
              fontStyle != null ||
              decoration != null ||
              shadows.isNotEmpty
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
              shadows: shadows.isNotEmpty ? shadows : null,
            )
          : null,
      colorMode: LayerBackgroundMode.values.firstWhere(
          (element) => element.name == map[keyConverter!('colorMode')]),
      color: Color(map[keyConverter('color')]),
      background: Color(map[keyConverter('background')]),
      align: TextAlign.values
          .firstWhere((element) => element.name == map[keyConverter!('align')]),
      customSecondaryColor: map[keyConverter('customSecondaryColor')] ?? false,
    );
  }

  /// Flag that indicates if the layers hit box is triggered.
  bool hit;

  /// The text content of the layer.
  String text;

  /// The color mode for the text.
  LayerBackgroundMode colorMode;

  /// The text color.
  Color color;

  /// The background color for the text.
  Color background;

  /// This flag define if the secondary color is manually set.
  bool customSecondaryColor;

  /// The text alignment within the layer.
  TextAlign align;

  /// The font scale for text, to make text bigger or smaller.
  double fontScale;

  /// The maximum width that the text can occupy.
  ///
  /// If set, the text will be constrained to this width, and will wrap. If
  /// null, the text will not have a width constraint.
  double? maxTextWidth;

  /// A custom text style for the text. Be careful the editor allow not to
  /// import and export this style.
  TextStyle? textStyle;

  @override
  bool get isTextLayer => true;

  @override
  Map<String, dynamic> toMap({
    int maxDecimalPlaces = kMaxSafeDecimalPlaces,
    bool enableMinify = false,
  }) {
    final result = {
      ...super.toMap(
        maxDecimalPlaces: maxDecimalPlaces,
        enableMinify: enableMinify,
      ),
      'text': text,
      'colorMode': LayerBackgroundMode.values[colorMode.index].name,
      'color': color.toHex(),
      'background': background.toHex(),
      'align': align.name,
      'fontScale': fontScale.roundSmart(maxDecimalPlaces),
      'type': 'text',
      if (maxTextWidth != null)
        'maxTextWidth': maxTextWidth?.roundSmart(maxDecimalPlaces),
      if (customSecondaryColor) 'customSecondaryColor': customSecondaryColor,
      if (textStyle?.fontFamily != null) 'fontFamily': textStyle?.fontFamily,
      if (textStyle?.fontStyle != null) 'fontStyle': textStyle?.fontStyle!.name,
      if (textStyle?.fontWeight != null)
        'fontWeight': textStyle?.fontWeight!.value,
      if (textStyle?.letterSpacing != null)
        'letterSpacing': textStyle?.letterSpacing?.roundSmart(maxDecimalPlaces),
      if (textStyle?.height != null)
        'height': textStyle?.height?.roundSmart(maxDecimalPlaces),
      if (textStyle?.wordSpacing != null)
        'wordSpacing': textStyle?.wordSpacing?.roundSmart(maxDecimalPlaces),
      if (textStyle?.decoration != null)
        'decoration': textStyle?.decoration.toString(),
      if (textStyle?.shadows != null && textStyle!.shadows!.isNotEmpty)
        'shadows': textStyle!.shadows!
            .map((s) => {
                  'color': s.color.toHex(),
                  'blurRadius': s.blurRadius,
                  'offsetX': s.offset.dx,
                  'offsetY': s.offset.dy,
                })
            .toList(),
    };
    return result;
  }

  @override
  Map<String, dynamic> toMapFromReference(
    Layer layer, {
    int maxDecimalPlaces = kMaxSafeDecimalPlaces,
    bool enableMinify = false,
  }) {
    var paintLayer = layer as TextLayer;
    return {
      ...super.toMapFromReference(
        layer,
        maxDecimalPlaces: maxDecimalPlaces,
        enableMinify: enableMinify,
      ),
      if (paintLayer.text != text) 'text': text,
      if (paintLayer.fontScale != fontScale)
        'fontScale': fontScale.roundSmart(maxDecimalPlaces),
      if (paintLayer.color != color) 'color': color.toHex(),
      if (paintLayer.background != background) 'background': background.toHex(),
      if (paintLayer.colorMode.name != colorMode.name)
        'colorMode': LayerBackgroundMode.values[colorMode.index].name,
      if (paintLayer.customSecondaryColor != customSecondaryColor)
        'customSecondaryColor': customSecondaryColor,
      if (paintLayer.textStyle?.fontFamily != textStyle?.fontFamily)
        'fontFamily': textStyle?.fontFamily,
      if (paintLayer.textStyle?.fontStyle != textStyle?.fontStyle)
        'fontStyle': textStyle?.fontStyle!.name,
      if (paintLayer.textStyle?.fontWeight != textStyle?.fontWeight)
        'fontWeight': textStyle?.fontWeight!.value,
      if (paintLayer.textStyle?.letterSpacing != textStyle?.letterSpacing)
        'letterSpacing': textStyle?.letterSpacing?.roundSmart(maxDecimalPlaces),
      if (paintLayer.textStyle?.height != textStyle?.height)
        'height': textStyle?.height?.roundSmart(maxDecimalPlaces),
      if (paintLayer.textStyle?.wordSpacing != textStyle?.wordSpacing)
        'wordSpacing': textStyle?.wordSpacing?.roundSmart(maxDecimalPlaces),
      if (paintLayer.textStyle?.decoration != textStyle?.decoration)
        'decoration': textStyle?.decoration.toString(),
      if (paintLayer.maxTextWidth != maxTextWidth)
        'maxTextWidth': maxTextWidth?.roundSmart(maxDecimalPlaces),
      if (textStyle?.shadows != null && textStyle!.shadows!.isNotEmpty)
        'shadows': textStyle!.shadows!
            .map((s) => {
                  'color': s.color.toHex(),
                  'blurRadius': s.blurRadius,
                  'offsetX': s.offset.dx,
                  'offsetY': s.offset.dy,
                })
            .toList(),
    };
  }

  /// Creates a copy of this [TextLayer] with the given fields replaced with
  /// new values.
  @override
  TextLayer copyWith({
    String? text,
    Color? color,
    Color? background,
    LayerBackgroundMode? colorMode,
    TextAlign? align,
    TextStyle? textStyle,
    double? fontScale,
    Offset? offset,
    double? rotation,
    double? scale,
    double? maxTextWidth,
    bool? hit,
    bool? flipX,
    bool? flipY,
    bool? customSecondaryColor,
    LayerInteraction? interaction,
    Map<String, dynamic>? meta,
    BoxConstraints? boxConstraints,
    String? id,
    String? groupId,
  }) {
    return TextLayer(
      text: text ?? this.text,
      customSecondaryColor: customSecondaryColor ?? this.customSecondaryColor,
      hit: hit ?? this.hit,
      textStyle: textStyle ?? this.textStyle,
      colorMode: colorMode ?? this.colorMode,
      color: color ?? this.color,
      background: background ?? this.background,
      align: align ?? this.align,
      fontScale: fontScale ?? this.fontScale,
      maxTextWidth: maxTextWidth ?? this.maxTextWidth,
      offset: offset ?? this.offset,
      rotation: rotation ?? this.rotation,
      scale: scale ?? this.scale,
      id: id ?? this.id,
      flipX: flipX ?? this.flipX,
      flipY: flipY ?? this.flipY,
      interaction: interaction ?? this.interaction,
      meta: meta ?? this.meta,
      boxConstraints: boxConstraints ?? this.boxConstraints,
      groupId: groupId ?? this.groupId,
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(StringProperty('text', text))
      ..add(EnumProperty<LayerBackgroundMode>('colorMode', colorMode))
      ..add(ColorProperty('color', color))
      ..add(ColorProperty('background', background))
      ..add(DiagnosticsProperty<bool>(
          'customSecondaryColor', customSecondaryColor))
      ..add(EnumProperty<TextAlign>('align', align))
      ..add(DoubleProperty('fontScale', fontScale))
      ..add(DoubleProperty('maxTextWidth', maxTextWidth))
      ..add(DiagnosticsProperty<TextStyle>('textStyle', textStyle))
      ..add(DiagnosticsProperty<bool>('hasHit', hit));
  }
}
