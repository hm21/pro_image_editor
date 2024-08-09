// ignore_for_file: argument_type_not_assignable

// Dart imports:
import 'dart:ui';

// Project imports:
import '../../modules/paint_editor/utils/paint_editor_enum.dart';
import '../../utils/unique_id_generator.dart';

/// Represents a unit of shape or drawing information used in painting.
class PaintedModel {
  /// Factory constructor for creating a PaintedModel instance from a map.
  factory PaintedModel.fromMap(Map<String, dynamic> map) {
    /// List to hold offset points for the painting.
    List<Offset> offsets = [];

    /// Iterate over the offsets in the map and add them to the list.
    for (var el in List.from(map['offsets'])) {
      offsets.add(Offset(el['x'], el['y']));
    }

    /// Constructs and returns a PaintedModel instance with properties
    /// derived from the map.
    return PaintedModel(
      mode: PaintModeE.values
          .firstWhere((element) => element.name == map['mode']),
      offsets: offsets,
      color: Color(map['color']),
      strokeWidth: map['strokeWidth'] ?? 1,
      fill: map['fill'] ?? false,
      opacity: map['opacity'] ?? 1,
    );
  }

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
    required this.mode,
    required this.offsets,
    required this.color,
    required this.strokeWidth,
    required this.opacity,
    this.fill = false,
    this.hit = false,
  }) {
    id = generateUniqueId();
  }

  /// Unique id from the paint-model
  late final String id;

  /// The mode of the paint method, indicating the type of shape or drawing.
  final PaintModeE mode;

  /// The color used for drawing or filling the shape.
  final Color color;

  /// The width of the stroke used for drawing.
  final double strokeWidth;

  /// The opacity for the drawing.
  final double opacity;

  /// A list of offsets representing the points of the shape or drawing.
  /// For shapes like circles and rectangles, it contains two points.
  /// For [FreeStyle], it contains a list of points.
  List<Offset?> offsets;

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
    if (mode == PaintModeE.circle || mode == PaintModeE.rect) {
      return fill;
    } else {
      return false;
    }
  }

  /// Creates a copy of this PaintedModel instance.
  PaintedModel copy() {
    return PaintedModel(
      mode: mode,
      offsets: offsets,
      color: color,
      strokeWidth: strokeWidth,
      fill: fill,
      hit: hit,
      opacity: opacity,
    );
  }

  /// Converts the PaintedModel instance into a map.
  Map<String, dynamic> toMap() {
    /// List to hold the offset points as maps.
    List<Map<String, double>> offsetMaps = [];

    /// Iterate over the offsets and add them to the list as maps.
    for (var offset in offsets) {
      if (offset != null) {
        offsetMaps.add({'x': offset.dx, 'y': offset.dy});
      }
    }

    /// Returns a map representation of the PaintedModel instance.
    return {
      'mode': mode.name,
      'offsets': offsetMaps,
      'color': color.value,
      'strokeWidth': strokeWidth,
      'opacity': opacity,
      'fill': fill,
    };
  }
}
