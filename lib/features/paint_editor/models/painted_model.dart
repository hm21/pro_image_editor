import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import '/core/constants/int_constants.dart';
import '/shared/extensions/color_extension.dart';
import '/shared/extensions/export_bool_extension.dart';
import '/shared/extensions/num_extension.dart';
import '/shared/utils/parser/bool_parser.dart';
import '/shared/utils/parser/double_parser.dart';
import '/shared/utils/unique_id_generator.dart';
import '../enums/paint_editor_enum.dart';
import 'eraser_model.dart';

/// Represents a unit of shape or drawing information used in paint.
class PaintedModel {
  /// Creates a new PaintedModel instance.
  ///
  /// - [mode]: The mode indicating the type of shape or drawing.
  /// - [offsets]: The list of offsets representing the points of the shape.
  /// - [color]: The color used for drawing or filling.
  /// - [strokeWidth]: The width of the stroke used for drawing.
  /// - [opacity]: The opacity of the drawing.
  /// - [fill]: A boolean indicating whether the shape should be filled.
  /// - [hit]: A boolean flag indicating whether this unit of drawing has been
  /// hit.
  PaintedModel({
    GlobalKey? key,
    required this.mode,
    required this.offsets,
    required this.erasedOffsets,
    required this.color,
    required this.strokeWidth,
    required this.opacity,
    this.fill = false,
    this.hit = false,
  }) : key = key ?? GlobalKey() {
    id = generateUniqueId();
  }

  /// Factory constructor for creating a PaintedModel instance from a map.
  factory PaintedModel.fromMap(
    Map<String, dynamic> map, {
    Function(String key)? keyConverter,
  }) {
    keyConverter ??= (String key) => key;

    /// List to hold offset points for the paint.
    final offsets = List.from(map[keyConverter('offsets')] ?? [])
        .map((el) => Offset(safeParseDouble(el['x']), safeParseDouble(el['y'])))
        .toList();

    final erasedOffsets = List<Map<String, dynamic>>.from(
            map[keyConverter('erasedOffsets')] ?? [])
        .map(ErasedOffset.fromMap)
        .toList();

    /// Constructs and returns a PaintedModel instance with properties
    /// derived from the map.
    return PaintedModel(
      mode: PaintMode.values
          .firstWhere((element) => element.name == map[keyConverter!('mode')]),
      offsets: offsets,
      erasedOffsets: erasedOffsets,
      color: Color(map[keyConverter('color')]),
      strokeWidth:
          safeParseDouble(map[keyConverter('strokeWidth')], fallback: 1),
      fill: safeParseBool(map[keyConverter('fill')]),
      opacity: safeParseDouble(map[keyConverter('opacity')], fallback: 1),
    );
  }

  /// A [GlobalKey] used to uniquely identify and access the widget associated
  /// with this model.
  /// This key can be used for retrieving the widget's state, context, or for
  /// other widget-related operations.
  final GlobalKey key;

  /// Unique id from the paint-model
  late final String id;

  /// The mode of the paint method, indicating the type of shape or drawing.
  final PaintMode mode;

  /// The color used for drawing or filling the shape.
  Color color;

  /// The width of the stroke used for drawing.
  double strokeWidth;

  /// The opacity for the drawing.
  double opacity;

  /// A list of offsets representing the points of the shape or drawing.
  /// For shapes like circles and rectangles, it contains two points.
  /// For [FreeStyle], it contains a list of points.
  List<Offset?> offsets;

  /// A list of offset points that have been erased from the painted content.
  ///
  /// This list contains the coordinates where eraser tool operations have been
  /// applied, allowing the system to track which areas of the painted content
  /// have been removed.
  List<ErasedOffset> erasedOffsets;

  /// A boolean indicating whether the drawn shape should be filled.
  bool fill;

  /// A boolean flag indicating whether this unit of drawing has been hit.
  bool hit = false;

  /// Gets the Paint object configured based on the properties of this
  /// PaintedModel.
  Paint get paint => Paint()
    ..color = color
    ..strokeWidth = strokeWidth
    ..style = shouldFill ? PaintingStyle.fill : PaintingStyle.stroke;

  /// Determines whether the shape should be filled based on the paint mode.
  bool get shouldFill {
    if (canBeFilled) {
      return fill;
    } else {
      return false;
    }
  }

  /// Returns `true` if the current paint mode represents a censoring area.
  ///
  /// This getter checks if the painting mode is either blur or pixelate,
  /// which are typically used for censoring or obscuring content in images.
  ///
  /// Returns:
  ///   - `true` if mode is [PaintMode.blur] or [PaintMode.pixelate]
  ///   - `false` for all other paint modes
  bool get isCensorArea => mode == PaintMode.blur || mode == PaintMode.pixelate;

  /// Determines whether the current paint mode supports being filled.
  ///
  /// This getter returns `true` if the [mode] is one of the following:
  /// - [PaintMode.circle]: A circular shape that can be filled.
  /// - [PaintMode.rect]: A rectangular shape that can be filled.
  /// - [PaintMode.polygon]: A polygonal shape that can be filled.
  ///
  /// Returns `false` for other paint modes that do not support filling.
  bool get canBeFilled {
    return mode == PaintMode.circle ||
        mode == PaintMode.rect ||
        mode == PaintMode.polygon ||
        mode == PaintMode.hexagon;
  }

  /// Creates a copy of this PaintedModel instance.
  PaintedModel copy() {
    return PaintedModel(
      mode: mode,
      offsets: [...offsets],
      erasedOffsets: [...erasedOffsets],
      color: color,
      strokeWidth: strokeWidth,
      fill: fill,
      hit: hit,
      opacity: opacity,
    );
  }

  /// Converts the PaintedModel instance into a map.
  Map<String, dynamic> toMap({
    int maxDecimalPlaces = kMaxSafeDecimalPlaces,
    bool enableMinify = false,
  }) {
    final offsetMaps = offsets
        .whereType<Offset>() // filters out nulls if offsets is List<Offset?>
        .map((o) => {
              'x': o.dx.roundSmart(maxDecimalPlaces),
              'y': o.dy.roundSmart(maxDecimalPlaces),
            })
        .toList();
    final erasedOffsetsMaps = erasedOffsets.map((el) => el.toMap()).toList();

    /// Returns a map representation of the PaintedModel instance.
    return {
      'mode': mode.name,
      'offsets': offsetMaps,
      'erasedOffsets': erasedOffsetsMaps,
      'color': color.toHex(),
      'strokeWidth': strokeWidth.roundSmart(maxDecimalPlaces),
      'opacity': opacity.roundSmart(maxDecimalPlaces),
      'fill': fill.minify(enableMinify),
    };
  }

  @override
  int get hashCode => Object.hash(
        mode,
        color,
        strokeWidth,
        opacity,
        fill,
        hit,
        id,
        Object.hashAll(offsets),
        Object.hashAll(erasedOffsets),
      );

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    bool isListEqual(List<dynamic> list1, List<dynamic> list2) {
      if (list1.length != list2.length) return false;

      for (int i = 0; i < list1.length; i++) {
        if (list1[i] != list2[i]) {
          return false;
        }
      }

      return true;
    }

    return other is PaintedModel &&
        other.mode == mode &&
        other.color == color &&
        other.strokeWidth == strokeWidth &&
        other.opacity == opacity &&
        other.fill == fill &&
        other.id == id &&
        isListEqual(other.offsets, offsets) &&
        isListEqual(other.erasedOffsets, erasedOffsets);
  }

  /// Creates a copy of this `PaintedModel` with the given fields replaced by
  /// new values.
  PaintedModel copyWith({
    GlobalKey? key,
    PaintMode? mode,
    Color? color,
    double? strokeWidth,
    double? opacity,
    List<Offset?>? offsets,
    List<ErasedOffset>? erasedOffsets,
    bool? fill,
    bool? hit,
  }) {
    return PaintedModel(
      key: key ?? this.key,
      mode: mode ?? this.mode,
      color: color ?? this.color,
      offsets: offsets ?? this.offsets,
      erasedOffsets: erasedOffsets ?? this.erasedOffsets,
      opacity: opacity ?? this.opacity,
      strokeWidth: strokeWidth ?? this.strokeWidth,
      fill: fill ?? this.fill,
      hit: hit ?? this.hit,
    );
  }

  /// Fills the given [DiagnosticPropertiesBuilder] with properties of this
  /// PaintedModel for debugging and development tools.
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    // Core identity
    properties
      ..add(StringProperty('id', id))
      ..add(EnumProperty<PaintMode>('mode', mode))

      // Paint attributes
      ..add(ColorProperty('color', color))
      ..add(DoubleProperty('strokeWidth', strokeWidth))
      ..add(DoubleProperty('opacity', opacity))

      // Flags
      ..add(DiagnosticsProperty<bool>('fill', fill))
      ..add(DiagnosticsProperty<bool>('hit', hit))
      ..add(DiagnosticsProperty<bool>('isCensorArea', isCensorArea))
      ..add(DiagnosticsProperty<bool>('canBeFilled', canBeFilled))

      // Collections (show sizes instead of dumping all Offsets)
      ..add(IntProperty('offsetsCount', offsets.length))
      ..add(IntProperty('erasedOffsetsCount', erasedOffsets.length));

    if (offsets.isNotEmpty && offsets.first != null) {
      properties.add(DiagnosticsProperty<Offset>('firstOffset', offsets.first));
    }
    if (offsets.isNotEmpty && offsets.last != null) {
      properties.add(DiagnosticsProperty<Offset>('lastOffset', offsets.last));
    }
  }
}
