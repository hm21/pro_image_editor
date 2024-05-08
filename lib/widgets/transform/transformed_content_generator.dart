import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
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
    // TODO: remove timeDilation
    timeDilation = 2.5;
    return LayoutBuilder(
      builder: (context, constraints) {
        TransformConfigs configs = widget.transformConfigs;

        Size size = constraints.biggest;
        Size cropSize = configs.cropRect.size;
        double cropScreenPadding = 40;

        double scale = 1;

        double fitChangedScaleHelper = 1;
        double fitFactorWidth = (size.width + cropScreenPadding) / size.width;
        double fitFactorHeight =
            (size.height + cropScreenPadding) / size.height;

        bool beforeStickToWidth =
            _stickToWidth(size.aspectRatio, configs.originalSize.aspectRatio);
        bool afterStickToWidth = _stickToWidth(
            size.aspectRatio,
            configs.is90DegRotated
                ? 1 / cropSize.aspectRatio
                : cropSize.aspectRatio);
/* 
        if (beforeStickToWidth && !afterStickToWidth) {
          fitChangedScaleHelper = 1 / (fitFactorWidth / fitFactorHeight);
        } else if (!beforeStickToWidth && afterStickToWidth) {
          fitChangedScaleHelper = fitFactorWidth / fitFactorHeight;
        }
        print(fitChangedScaleHelper); */

        if (afterStickToWidth) {
          fitChangedScaleHelper = fitFactorWidth;
        } else {
          fitChangedScaleHelper = fitFactorHeight;
        }

        print(fitFactorHeight);

        return FittedBox(
          alignment: Alignment.center,
          clipBehavior: Clip.hardEdge,
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Transform.rotate(
              angle: widget.transformConfigs.angle,
              alignment: Alignment.center,
              child: Transform.flip(
                flipX: widget.transformConfigs.flipX,
                flipY: widget.transformConfigs.flipY,
                child: Transform.scale(
                  scale: fitChangedScaleHelper *
                      configs.scaleUser *
                      configs
                          .scaleRotation /*  configs.scaleUser * configs.scaleAspectRatio * scale */,
                  alignment: Alignment.center,
                  child: Transform.translate(
                    offset: widget.transformConfigs.offset,
                    child: Builder(builder: (context) {
                      CutOutsideArea clipper = CutOutsideArea(
                        configs: widget.transformConfigs,
                        bodySize: size,
                        fitChangedScaleHelper: fitChangedScaleHelper,
                        beforeStickToWidth: beforeStickToWidth,
                        afterStickToWidth: afterStickToWidth,
                      );

                      if (widget.configs.cropRotateEditorConfigs.roundCropper) {
                        return ClipOval(clipper: clipper, child: widget.child);
                      } else {
                        return ClipRect(clipper: clipper, child: widget.child);
                      }
                    }),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class CutOutsideArea extends CustomClipper<Rect> {
  final TransformConfigs configs;
  final Size bodySize;
  final double fitChangedScaleHelper;
  final bool beforeStickToWidth;
  final bool afterStickToWidth;

  CutOutsideArea({
    required this.configs,
    required this.bodySize,
    required this.fitChangedScaleHelper,
    required this.beforeStickToWidth,
    required this.afterStickToWidth,
  });
  @override
  Rect getClip(Size size) {
    /*  return Rect.largest; */
    Rect cropRect = configs.cropRect;
    Size cropSize = cropRect.size;

    double cropWidth = (cropRect.width + 40);
    double cropHeight = (cropRect.height + 40);

    print(cropRect.width);

    if (beforeStickToWidth && afterStickToWidth) {
      cropWidth = (cropRect.width + 40);
      cropHeight = cropWidth / cropSize.aspectRatio;
    } else if (beforeStickToWidth && !afterStickToWidth) {
      cropWidth = cropRect.width * configs.scaleRotation + 40;
      cropHeight = cropRect.height * configs.scaleRotation + 40;
    }

    /*   if (afterStickToWidth) {
      cropHeight = cropWidth / cropSize.aspectRatio;
    } else {
      cropWidth = cropHeight * cropSize.aspectRatio;
    } */

    return Rect.fromCenter(
      center: Offset(size.width / 2, size.height / 2),
      width: cropWidth,
      height: cropHeight,
    );
  }

  @override
  bool shouldReclip(covariant CustomClipper<Rect> oldClipper) {
    //TODO:
    return true;
    return oldClipper is! CutOutsideArea || oldClipper.configs != configs;
  }
}

bool _stickToWidth(double ratioOld, double ratioNew) => ratioOld <= ratioNew;
