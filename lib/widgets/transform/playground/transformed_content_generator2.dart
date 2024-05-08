import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:pro_image_editor/models/editor_configs/pro_image_editor_configs.dart';

import '../../../models/crop_rotate_editor/transform_factors.dart';

/// TODO: delete full file is just for tests
class TransformedContentGenerator extends StatefulWidget {
  final Widget child;
  final TransformConfigs transformConfigs;
  final ProImageEditorConfigs configs;
  final bool fitToScreenSize;

  const TransformedContentGenerator({
    required this.child,
    required this.transformConfigs,
    required this.configs,
    this.fitToScreenSize = true,
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
        double fitFactorWidth = size.width / (size.width - cropScreenPadding);
        double fitFactorHeight = size.height / configs.originalSize.height;

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
        fitChangedScaleHelper = 1.0;

        return Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: size.width - 40,
              height: size.height - 40,
              color: Colors.yellow,
              child: Transform.scale(
                scale: 1,
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
          ],
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
    late Widget childClipper;
    if (widget.configs.cropRotateEditorConfigs.roundCropper) {
      childClipper = ClipOval(clipper: clipper, child: child);
    } else {
      childClipper = ClipRect(clipper: clipper, child: child);
    }

    return Container(
      color: Colors.blue.shade100,
      margin: const EdgeInsets.all(0.0),
      child: childClipper,
    );
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

bool _stickToWidth(double ratioOld, double ratioNew) => ratioOld <= ratioNew;
