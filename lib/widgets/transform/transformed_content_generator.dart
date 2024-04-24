import 'package:flutter/material.dart';

import '../../models/crop_rotate_editor/transform_factors.dart';

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
    return FittedBox(
      alignment: Alignment.center,
      clipBehavior: Clip.hardEdge,
      child: Transform.rotate(
        angle: widget.configs.angle,
        alignment: Alignment.center,
        child: Transform.flip(
          flipX: widget.configs.flipX,
          flipY: widget.configs.flipY,
          child: ClipRect(
            clipper: CutOutsideArea(
              offset: widget.configs.offset,
              scaleFactor: widget.configs.scale,
              cropRect: widget.configs.cropRect,
            ),
            child: Transform.scale(
              scale: widget.configs.scale,
              alignment: Alignment.center,
              child: Transform.translate(
                offset: widget.configs.offset,
                child: widget.child,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class CutOutsideArea extends CustomClipper<Rect> {
  final Rect cropRect;
  final Offset offset;
  final double scaleFactor;

  CutOutsideArea({
    required this.cropRect,
    required this.offset,
    required this.scaleFactor,
  });
  @override
  Rect getClip(Size size) {
    /// Draw outline darken layers
    double cropWidth = cropRect.width;
    double cropHeight = cropRect.height;

    return Rect.fromCenter(
      center: cropRect.center,
      width: cropWidth,
      height: cropHeight,
    );
  }

  @override
  bool shouldReclip(covariant CustomClipper<Rect> oldClipper) {
    return oldClipper is! CutOutsideArea || oldClipper.cropRect != cropRect;
  }
}
