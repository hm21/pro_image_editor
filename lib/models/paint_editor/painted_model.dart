import 'dart:ui';

import '../../modules/paint_editor/utils/paint_editor_enum.dart';

/// Represents a unit of shape or drawing information used in painting.
class PaintedModel {
  /// The mode of the paint method, indicating the type of shape or drawing.
  final PaintModeE mode;

  /// The color used for drawing or filling the shape.
  final Color color;

  /// The width of the stroke used for drawing.
  final double strokeWidth;

  /// A list of offsets representing the points of the shape or drawing.
  /// For shapes like circles and rectangles, it contains two points.
  /// For [FreeStyle], it contains a list of points.
  List<Offset?> offsets;

  /// A boolean indicating whether the drawn shape should be filled.
  bool fill;

  /// A boolean flag indicating whether this unit of drawing has been hit.
  bool hit = false;

  /// Gets the Paint object configured based on the properties of this PaintedModel.
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

  /// Creates a new PaintedModel instance.
  ///
  /// - [mode]: The mode indicating the type of shape or drawing.
  /// - [offsets]: The list of offsets representing the points of the shape.
  /// - [color]: The color used for drawing or filling.
  /// - [strokeWidth]: The width of the stroke used for drawing.
  /// - [fill]: A boolean indicating whether the shape should be filled.
  /// - [hit]: A boolean flag indicating whether this unit of drawing has been hit.
  PaintedModel({
    required this.mode,
    required this.offsets,
    required this.color,
    required this.strokeWidth,
    this.fill = false,
    this.hit = false,
  });

  factory PaintedModel.fromMap(Map map) {
    List<Offset> offsets = [];

    for (var el in List.from(map['offsets'])) {
      offsets.add(Offset(el['x'], el['y']));
    }

    return PaintedModel(
      mode: PaintModeE.values
          .firstWhere((element) => element.name == map['mode']),
      offsets: offsets,
      color: Color(map['color']),
      strokeWidth: map['strokeWidth'] ?? 1,
      fill: map['fill'] ?? false,
    );
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
    );
  }

  Map toMap() {
    List<Map<String, double>> offsetMaps = [];

    for (var offset in offsets) {
      if (offset != null) {
        offsetMaps.add({'x': offset.dx, 'y': offset.dy});
      }
    }

    return {
      'mode': mode.name,
      'offsets': offsetMaps,
      'color': color.value,
      'strokeWidth': strokeWidth,
      'fill': fill,
    };
  }
}
