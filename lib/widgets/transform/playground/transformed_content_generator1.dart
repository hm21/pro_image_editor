import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:pro_image_editor/models/crop_rotate_editor/transform_factors.dart';
import 'package:pro_image_editor/models/editor_configs/pro_image_editor_configs.dart';

/// TODO: delete full file is just for tests

class TransformedContentGenerator extends StatefulWidget {
  final Widget child;
  final TransformConfigs transformConfigs;
  final ProImageEditorConfigs configs;
  final bool fitToScreenSize;
  final Size bodySize;
  final Size mainImageSize;
  final Size decodedImageSize;

  const TransformedContentGenerator({
    required this.child,
    required this.transformConfigs,
    required this.configs,
    this.fitToScreenSize = true,
    this.mainImageSize = Size.zero,
    this.bodySize = Size.zero,
    this.decodedImageSize = Size.zero,
    super.key,
  });

  @override
  State<TransformedContentGenerator> createState() =>
      _TransformedContentGeneratorState();
}

class _TransformedContentGeneratorState
    extends State<TransformedContentGenerator> {
  double _screenPadding = 20.0;
  double _scaleFactor = 0;
  double _cropSpaceVertical = 0;
  double _cropSpaceHorizontal = 0;

  Rect _viewRect = Rect.zero;
  bool get imageSticksToScreenWidth =>
      widget.mainImageSize.width >= _contentConstraints.width;

  Size get _contentConstraints => widget.bodySize;
  late BoxConstraints _renderedImgConstraints = const BoxConstraints();
  Size get _renderedImgSize => Size(
        widget.transformConfigs.is90DegRotated
            ? _renderedImgConstraints.maxHeight
            : _renderedImgConstraints.maxWidth,
        widget.transformConfigs.is90DegRotated
            ? _renderedImgConstraints.maxWidth
            : _renderedImgConstraints.maxHeight,
      );

  void calcCropRect({bool onlyViewRect = false, double? newRatio}) {
    double imgSizeRatio =
        widget.mainImageSize.height / widget.mainImageSize.width;

    var imgConstraints = _renderedImgConstraints.biggest.isInfinite
        ? widget.decodedImageSize
        : _renderedImgConstraints.biggest;

    double imgW = imgConstraints.width;
    double imgH = imgConstraints.height;

    double realImgW = imageSticksToScreenWidth ? imgW : imgH / imgSizeRatio;
    double realImgH = imageSticksToScreenWidth ? imgW * imgSizeRatio : imgH;

    // Rect stick horizontal
    double ratio = widget.transformConfigs.cropRect.size.aspectRatio;
    double left = 0;
    double top = 0;

    if (imgSizeRatio >= ratio) {
      double newH = realImgW * ratio;

      top = (realImgH - newH) / 2;
      realImgH = newH;
    }
    // Rect stick vertical
    else {
      double newW = realImgH / ratio;
      left = (realImgW - newW) / 2;
      realImgW = newW;
    }

    _cropSpaceVertical = top * 2;
    _cropSpaceHorizontal = left * 2;

    _viewRect = Rect.fromLTWH(left, top, realImgW, realImgH);
  }

  calcFitToScreen() {
    Size contentSize = Size(
      _contentConstraints.width - _screenPadding * 2,
      _contentConstraints.height - _screenPadding * 2,
    );

    double cropSpaceHorizontal = widget.transformConfigs.is90DegRotated
        ? _cropSpaceVertical
        : _cropSpaceHorizontal;
    double cropSpaceVertical = widget.transformConfigs.is90DegRotated
        ? _cropSpaceHorizontal
        : _cropSpaceVertical;

    double scaleX =
        contentSize.width / (_renderedImgSize.width - cropSpaceHorizontal);
    double scaleY =
        contentSize.height / (_renderedImgSize.height - cropSpaceVertical);

    double scale = min(scaleX, scaleY);

    _scaleFactor = scale;
  }

  @override
  Widget build(BuildContext context) {
    // TODO: remove timeDilation
    timeDilation = 2.5;
    return LayoutBuilder(
      builder: (context, constraints) {
        calcCropRect();
        calcFitToScreen();

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

        return Transform.scale(
          scale: 1,
          child: _buildRotationTransform(
            child: _buildFlipTransform(
              child: _buildRotationScaleTransform(
                child: _buildCropPainter(
                  child: _buildUserScaleTransform(
                    child: _buildTranslate(
                      child: Builder(builder: (context) {
                        double maxWidth = widget.mainImageSize.width /
                            widget.mainImageSize.height *
                            (_contentConstraints.height - _screenPadding * 2);
                        double maxHeight =
                            (_contentConstraints.width - _screenPadding * 2) *
                                widget.mainImageSize.height /
                                widget.mainImageSize.width;
                        return ConstrainedBox(
                          constraints: BoxConstraints(
                            maxWidth: maxWidth,
                            maxHeight: maxHeight,
                          ),
                          child: LayoutBuilder(builder: (context, constraints) {
                            _renderedImgConstraints = constraints;
                            return widget.child;
                          }),
                        );
                      }),
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
      scale: _scaleFactor,
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
