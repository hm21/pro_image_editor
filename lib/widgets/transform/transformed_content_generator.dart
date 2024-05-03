import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

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
/*     return MyExample(
      child: widget.child,
      configs: widget.configs,
    ); */
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

  CutOutsideArea({
    required this.cropRect,
  });
  @override
  Rect getClip(Size size) {
    // Draw outline darken layers
    double space = 20;

    Offset center = cropRect.center + Offset(space, space);

    double cropWidth = cropRect.width + space * 2;
    double cropHeight = cropRect.height + space * 2;

    return Rect.fromCenter(
      center: center,
      width: cropWidth,
      height: cropHeight,
    );
  }

  @override
  bool shouldReclip(covariant CustomClipper<Rect> oldClipper) {
    //TODO:
    return oldClipper is! CutOutsideArea || oldClipper.cropRect != cropRect;
  }
}

class MyExample extends SingleChildRenderObjectWidget {
  final TransformConfigs configs;

  const MyExample({
    super.key,
    required Widget super.child,
    required this.configs,
  });

  @override
  RenderObject createRenderObject(BuildContext context) {
    final renderObject = _RenderInnerShadow();
    updateRenderObject(context, renderObject);
    return renderObject;
  }

  @override
  void updateRenderObject(
      BuildContext context, _RenderInnerShadow renderObject) {
    renderObject.configs = configs;
  }
}

class _RenderInnerShadow extends RenderProxyBox {
  late TransformConfigs configs;

  @override
  void paint(PaintingContext context, Offset offset) {
    if (child == null) return;
    final bounds = offset & size;

    /*  context.canvas.saveLayer(bounds, Paint());*/

    print(configs.offset);
    // Create a Matrix4 object for flipping horizontally
    final Matrix4 flipHorizontalMatrix = Matrix4.identity()
      ..scale(configs.flipX ? -1.0 : 1.0, configs.flipY ? -1.0 : 1.0, 1.0)
      ..scale(configs.scale)
      ..translate(
        configs.offset.dx * configs.scale,
        configs.offset.dy * configs.scale,
      );

    // Convert Matrix4 to a Float64List
    final List<double> matrixValues = flipHorizontalMatrix.storage;
    final Float64List transformMatrix = Float64List.fromList(matrixValues);

    // Apply the transformation
    context.canvas.transform(transformMatrix);

    context.paintChild(child!, offset);

    /*    for (final shadow in shadows) {
      final shadowRect = bounds.inflate(shadow.blurSigma);
      final shadowPaint = Paint()
        ..blendMode = BlendMode.srcATop
        ..colorFilter = ColorFilter.mode(shadow.color, BlendMode.srcOut)
        ..imageFilter = ImageFilter.blur(sigmaX: shadow.blurSigma, sigmaY: shadow.blurSigma);
      context.canvas
        ..saveLayer(shadowRect, shadowPaint)
        ..translate(shadow.offset.dx, shadow.offset.dy);
      context.paintChild(child, offset);
      context.canvas.restore();
    } */

    context.canvas.restore();
  }
}
