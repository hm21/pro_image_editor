// Flutter imports:
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

// Project imports:
import '/core/models/editor_configs/pro_image_editor_configs.dart';
import '/features/crop_rotate_editor/enums/crop_mode.enum.dart';

/// A [StatelessWidget] that applies transformations to its [child] widget
/// based on provided transformation and editor configurations.
class TransformedContentGenerator extends StatelessWidget {
  /// Creates an instance of [TransformedContentGenerator] with the given
  /// parameters.
  const TransformedContentGenerator({
    required this.child,
    required this.transformConfigs,
    required this.configs,
    this.isVideoPlayer = false,
    super.key,
  });

  /// The widget to which transformations will be applied.
  final Widget child;

  /// Configuration object for the transformations.
  final TransformConfigs transformConfigs;

  /// Configuration object for the image editor.
  final ProImageEditorConfigs configs;

  /// Indicates if the child is a video player.
  final bool isVideoPlayer;

  TransformConfigs get _transformConfigs => transformConfigs;

  double _computeFitHelper(Size size) {
    final tc = _transformConfigs;
    if (tc.cropEditorScreenRatio == 0) return 1.0;

    final Size orig = tc.originalSize;
    final Rect crop = tc.cropRect;
    final bool rot90 = tc.is90DegRotated;

    final double origRatio = orig.aspectRatio;
    final double cropRatio = crop.size.aspectRatio;
    final double convertedCropRatio = rot90 ? 1 / cropRatio : cropRatio;

    final bool origFitW = size.aspectRatio <= origRatio;
    final bool fitW = size.aspectRatio <= convertedCropRatio;

    final double w = orig.width / crop.width;
    final double h = orig.height / crop.height;
    final double w1 = size.width / orig.width;
    final double h1 = size.height / orig.height;

    double helper;
    if (!origFitW && fitW) {
      helper = w1 / h1;
    } else if (origFitW && !fitW) {
      helper = h1 / w1;
    } else if (!fitW && cropRatio > origRatio) {
      helper = h / w;
    } else if (fitW && cropRatio < origRatio) {
      helper = w / h;
    } else {
      helper = 1.0;
    }

    if (rot90) {
      if (origFitW && fitW) {
        helper *= cropRatio;
      } else if (!origFitW && !fitW) {
        helper /= cropRatio;
      } else {
        final bool useOrig =
            (origFitW && cropRatio > origRatio) ||
            (!origFitW && cropRatio < origRatio);
        helper = fitW
            ? helper * (useOrig ? origRatio : cropRatio)
            : helper / (useOrig ? origRatio : cropRatio);
      }
    }
    return helper;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final Size size = constraints.biggest;
        final double fitFactor = _computeFitHelper(size);
        final Size originalSize = _transformConfigs.originalSize;

        return FittedBox(
          child: SizedBox(
            width: originalSize.isInfinite ? null : originalSize.width,
            height: originalSize.isInfinite ? null : originalSize.height,
            child: _buildFitRotateFlip(
              fitFactor: fitFactor,
              child: _buildCropPainter(child: _buildScaleRotate(child: child)),
            ),
          ),
        );
      },
    );
  }

  Widget _buildFitRotateFlip({
    required Widget child,
    required double fitFactor,
  }) {
    if (fitFactor == 1 &&
        _transformConfigs.angle == 0 &&
        !_transformConfigs.flipX &&
        !_transformConfigs.flipY) {
      return child;
    }

    /// Compose flip, rotate & fitHelper scale into one matrix:
    final Matrix4 outerMatrix = Matrix4.identity()
      // fitHelper
      ..scaleByDouble(fitFactor, fitFactor, fitFactor, 1.0)
      // rotation
      ..rotateZ(_transformConfigs.angle)
      ..scaleByDouble(
        // flip X
        _transformConfigs.flipX ? -1.0 : 1.0,
        // flip Y
        _transformConfigs.flipY ? -1.0 : 1.0,
        1.0,
        1.0,
      );

    return Transform(
      alignment: Alignment.center,
      transform: outerMatrix,
      child: child,
    );
  }

  Widget _buildCropPainter({required Widget child}) {
    if (kIsWeb && isVideoPlayer) return child;

    CropMode cropMode = _transformConfigs.cropMode;

    final effectiveCropMode =
        cropMode == CropMode.oval && !configs.cropRotateEditor.exportOvalMask
        ? CropMode.rectangular
        : cropMode;

    final clipper = CutOutsideArea(
      configs: _transformConfigs,
      cropMode: effectiveCropMode,
      initialOvalCropAspectRatio:
          configs.cropRotateEditor.initialOvalCropAspectRatio,
    );

    if (effectiveCropMode == CropMode.oval) {
      return ClipOval(clipper: clipper, child: child);
    } else {
      return ClipRect(clipper: clipper, child: child);
    }
  }

  Widget _buildScaleRotate({required Widget child}) {
    final offset = _transformConfigs.offset;
    final scale = _transformConfigs.scaleUser;

    // If no pan *and* no scale, just return child
    if (offset == Offset.zero && scale == 1.0) {
      return child;
    }

    // Combine translate + scale into one matrix
    final matrix = Matrix4.identity()
      ..scaleByDouble(scale, scale, scale, 1.0)
      ..translateByDouble(offset.dx, offset.dy, 0.0, 1.0);

    return Transform(
      alignment: Alignment.center,
      transform: matrix,
      child: child,
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);

    properties
      ..add(
        DiagnosticsProperty<TransformConfigs>(
          'transformConfigs',
          transformConfigs,
        ),
      )
      ..add(
        FlagProperty(
          'isVideoPlayer',
          value: isVideoPlayer,
          ifTrue: 'video player',
        ),
      )
      ..add(DoubleProperty('angle', transformConfigs.angle))
      ..add(
        FlagProperty(
          'flipX',
          value: transformConfigs.flipX,
          ifTrue: 'flipped X',
        ),
      )
      ..add(
        FlagProperty(
          'flipY',
          value: transformConfigs.flipY,
          ifTrue: 'flipped Y',
        ),
      )
      ..add(DoubleProperty('scaleUser', transformConfigs.scaleUser))
      ..add(DiagnosticsProperty<Offset>('offset', transformConfigs.offset))
      ..add(EnumProperty<CropMode>('cropMode', transformConfigs.cropMode))
      ..add(DiagnosticsProperty<Rect>('cropRect', transformConfigs.cropRect))
      ..add(
        DiagnosticsProperty<Size>(
          'originalSize',
          transformConfigs.originalSize,
        ),
      );
  }
}

/// A [CustomClipper] that defines the clipping area based on provided
/// configurations.
class CutOutsideArea extends CustomClipper<Rect> {
  /// Creates an instance of [CutOutsideArea] with the given [configs].
  CutOutsideArea({
    required this.configs,
    required this.cropMode,
    this.initialOvalCropAspectRatio,
  });

  /// Defines the cropping shape to apply to an image or video.
  final CropMode cropMode;

  /// The configuration object that provides the crop rectangle.
  final TransformConfigs configs;

  /// The fixed aspect ratio for the initial oval mask, used while no transform
  /// has been applied yet.
  ///
  /// Without this, the empty-config oval mask spans the full image bounds and
  /// exports an ellipse for non-square images even when a fixed ratio such as
  /// `1.0` was requested (see issue #828). `null` keeps the full image bounds.
  final double? initialOvalCropAspectRatio;

  @override
  Rect getClip(Size size) {
    Rect cropRect = configs.cropRect;
    if (configs.isEmpty && cropMode == CropMode.oval) {
      cropRect = _initialOvalCropRect(size);
    }

    return Rect.fromCenter(
      center: Offset(size.width / 2, size.height / 2),
      width: cropRect.width,
      height: cropRect.height,
    );
  }

  /// Builds the centered crop rect for the initial oval mask, honoring
  /// [initialOvalCropAspectRatio] when set and otherwise spanning the full
  /// image.
  Rect _initialOvalCropRect(Size size) {
    final ratio = initialOvalCropAspectRatio;
    if (ratio == null || ratio <= 0) {
      return Rect.fromLTWH(0, 0, size.width, size.height);
    }

    final double width;
    final double height;
    if (size.aspectRatio > ratio) {
      height = size.height;
      width = size.height * ratio;
    } else {
      width = size.width;
      height = size.width / ratio;
    }
    return Rect.fromLTWH(0, 0, width, height);
  }

  @override
  bool shouldReclip(covariant CustomClipper<Rect> oldClipper) {
    return oldClipper is! CutOutsideArea ||
        oldClipper.configs != configs ||
        oldClipper.cropMode != cropMode ||
        oldClipper.initialOvalCropAspectRatio != initialOvalCropAspectRatio;
  }
}
