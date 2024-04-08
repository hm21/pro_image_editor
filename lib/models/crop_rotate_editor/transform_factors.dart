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
}
