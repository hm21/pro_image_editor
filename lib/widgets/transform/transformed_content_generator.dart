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
        TransformConfigs configs = widget.transformConfigs;
        Size size = constraints.biggest;

        double aspectRatioScaleHelper = 1;

        print(configs.cropEditorScreenRatio);
        if (configs.cropEditorScreenRatio != 0) {
          // bool beforeOriginalFitToWidth = configs.cropEditorScreenRatio < configs.originalSize.aspectRatio;
          bool beforeOriginalFitToWidth = size.aspectRatio <=
              Size(configs.originalSize.width + 40,
                      configs.originalSize.height + 40)
                  .aspectRatio;
          bool beforeFitToWidth = configs.cropEditorScreenRatio <=
              (configs.is90DegRotated
                  ? 1 / configs.cropRect.size.aspectRatio
                  : configs.cropRect.size.aspectRatio);

          if (!beforeOriginalFitToWidth && beforeFitToWidth) {
            aspectRatioScaleHelper =
                size.aspectRatio / configs.cropEditorScreenRatio;
          } else if (beforeOriginalFitToWidth && !beforeFitToWidth) {
            aspectRatioScaleHelper =
                configs.cropEditorScreenRatio / size.aspectRatio;
          }
        }
        return FittedBox(
          child: SizedBox(
            width: configs.originalSize.isInfinite
                ? null
                : configs.originalSize.width,
            height: configs.originalSize.isInfinite
                ? null
                : configs.originalSize.height,
            child: Transform.scale(
              scale: aspectRatioScaleHelper,
              child: _buildRotationTransform(
                child: _buildFlipTransform(
                  child: _buildRotationScaleTransform(
                    child: _buildCropPainter(
                      child: _buildUserScaleTransform(
                        child: _buildTranslate(
                          child: widget.child,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Transform _buildRotationTransform({required Widget child}) {
    return Transform.rotate(
      angle: widget.transformConfigs.angle,
      alignment: Alignment.center,
      child: child,
    );
  }

  Transform _buildFlipTransform({required Widget child}) {
    return Transform.flip(
      flipX: widget.transformConfigs.flipX,
      flipY: widget.transformConfigs.flipY,
      child: child,
    );
  }

  Transform _buildRotationScaleTransform({required Widget child}) {
    return Transform.scale(
      scale: widget.transformConfigs.scaleRotation,
      alignment: Alignment.center,
      child: child,
    );
  }

  Widget _buildCropPainter({required Widget child}) {
    CutOutsideArea clipper = CutOutsideArea(configs: widget.transformConfigs);

    if (widget.configs.cropRotateEditorConfigs.roundCropper) {
      return ClipOval(clipper: clipper, child: child);
    } else {
      return ClipRect(clipper: clipper, child: child);
    }
  }

  Transform _buildUserScaleTransform({required Widget child}) {
    return Transform.scale(
      scale: widget.transformConfigs.scaleUser,
      alignment: Alignment.center,
      child: child,
    );
  }

  Transform _buildTranslate({required Widget child}) {
    return Transform.translate(
      offset: widget.transformConfigs.offset,
      child: child,
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

    return Rect.fromCenter(
      center: Offset(size.width / 2, size.height / 2),
      width: cropRect.width,
      height: cropRect.height,
    );
  }

  @override
  bool shouldReclip(covariant CustomClipper<Rect> oldClipper) {
    return oldClipper is! CutOutsideArea || oldClipper.configs != configs;
  }
}
