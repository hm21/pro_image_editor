import 'package:flutter/material.dart';
import 'package:pro_image_editor/models/editor_configs/pro_image_editor_configs.dart';

import '../../models/crop_rotate_editor/transform_factors.dart';

class TransformedContentGenerator extends StatefulWidget {
  final Widget child;
  final TransformConfigs transformConfigs;
  final ProImageEditorConfigs configs;

  const TransformedContentGenerator({
    required this.child,
    required this.transformConfigs,
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
    return LayoutBuilder(
      builder: (context, constraints) {
        Size size = constraints.biggest;

        double scaleHeightHelper = (size.height + 40) / size.height;

        return FittedBox(
          alignment: Alignment.center,
          clipBehavior: Clip.hardEdge,
          child: Transform.rotate(
            angle: widget.transformConfigs.angle,
            alignment: Alignment.center,
            child: Transform.flip(
              flipX: widget.transformConfigs.flipX,
              flipY: widget.transformConfigs.flipY,
              child: Builder(builder: (context) {
                Widget child = Transform.scale(
                  scale: widget.transformConfigs.scale,
                  alignment: Alignment.center,
                  child: Transform.translate(
                    offset: widget.transformConfigs.offset * scaleHeightHelper,
                    child: widget.child,
                  ),
                );

                CutOutsideArea clipper =
                    CutOutsideArea(configs: widget.transformConfigs);

                if (widget.configs.cropRotateEditorConfigs.roundCropper) {
                  return ClipOval(clipper: clipper, child: child);
                } else {
                  return ClipRect(clipper: clipper, child: child);
                }
              }),
            ),
          ),
        );
      },
    );
  }
}

class CutOutsideArea extends CustomClipper<Rect> {
  final TransformConfigs configs;

  CutOutsideArea({
    required this.configs,
  });
  @override
  Rect getClip(Size size) {
    Rect cropRect = configs.cropRect;
    double scaleRatio = configs.scaleRotation;

    double scaleHeightHelper = (size.height + 40) / size.height;

    Offset center = cropRect.center;

    double cropWidth = cropRect.width;
    double cropHeight = cropRect.height;

    return Rect.fromCenter(
      center: center * scaleHeightHelper,
      width: cropWidth * scaleHeightHelper * scaleRatio,
      height: cropHeight * scaleHeightHelper * scaleRatio,
    );
  }

  @override
  bool shouldReclip(covariant CustomClipper<Rect> oldClipper) {
    //TODO:
    return true;
    return oldClipper is! CutOutsideArea || oldClipper.configs != configs;
  }
}
