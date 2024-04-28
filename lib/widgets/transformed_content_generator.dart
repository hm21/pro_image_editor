import 'package:flutter/material.dart';

import '../models/crop_rotate_editor/transform_factors.dart';

class TransformedContentGenerator extends StatefulWidget {
  final Widget child;
  final TransformConfigs configs;

  const TransformedContentGenerator({
    required this.child,
    required this.configs,
    super.key,
  });

  @override
  State<TransformedContentGenerator> createState() =>
      _TransformedContentGeneratorState();
}

class _TransformedContentGeneratorState
    extends State<TransformedContentGenerator> {
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      return Transform.rotate(
        angle: widget.configs.angle,
        alignment: Alignment.center,
        child: Transform.flip(
          flipX: widget.configs.flipX,
          flipY: widget.configs.flipY,
          child: Transform.scale(
            scale: widget.configs.scale,
            alignment: Alignment.center,
            child: Transform.translate(
              offset: widget.configs.offset,
              child: widget.child,
            ),
          ),
        ),
      );
    });
  }
}
