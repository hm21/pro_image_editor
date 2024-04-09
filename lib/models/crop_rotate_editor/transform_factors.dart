import 'package:flutter/widgets.dart';

class TransformConfigs {
  final Offset offset;
  final double angle;
  final double scale;
  final bool flipX;
  final bool flipY;

  const TransformConfigs({
    required this.angle,
    required this.scale,
    required this.flipX,
    required this.flipY,
    required this.offset,
  });

  factory TransformConfigs.fromMap(Map map) {
    return TransformConfigs(
      angle: map['angle'] ?? 0,
      scale: map['scale'] ?? 1,
      flipX: map['flipX'] ?? false,
      flipY: map['flipY'] ?? false,
      offset: Offset(
        map['offset']?['dx'] ?? 0,
        map['offset']?['dy'] ?? 0,
      ),
    );
  }
  factory TransformConfigs.empty() {
    return const TransformConfigs(
      angle: 0,
      scale: 1,
      flipX: false,
      flipY: false,
      offset: Offset(0, 0),
    );
  }

  TransformConfigs reverse() {
    // TODO: function?
    return TransformConfigs(
      angle: angle,
      scale: scale,
      flipX: flipX,
      flipY: flipY,
      offset: offset,
    );
  }

  Map toMap() {
    return {
      'angle': angle,
      'scale': scale,
      'flipX': flipX,
      'flipY': flipY,
      'offset': {
        'dx': offset.dx,
        'dy': offset.dy,
      },
    };
  }
}
