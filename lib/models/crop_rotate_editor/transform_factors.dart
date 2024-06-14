// Flutter imports:
import 'package:flutter/widgets.dart';

// Project imports:
import 'package:pro_image_editor/modules/crop_rotate_editor/utils/rotate_angle.dart';

class TransformConfigs {
  final Offset offset;
  late Rect cropRect;
  late Size originalSize;
  late double cropEditorScreenRatio;
  final double angle;
  final double scaleUser;
  final double scaleRotation;
  final double aspectRatio;
  final bool flipX;
  final bool flipY;

  TransformConfigs({
    required this.angle,
    required this.cropRect,
    required this.originalSize,
    required this.cropEditorScreenRatio,
    required this.scaleUser,
    required this.scaleRotation,
    required this.aspectRatio,
    required this.flipX,
    required this.flipY,
    required this.offset,
  });

  factory TransformConfigs.fromMap(Map map) {
    return TransformConfigs(
      angle: map['angle'] ?? 0,
      cropRect: Rect.fromLTRB(
        map['cropRect']?['left'] ?? 0,
        map['cropRect']?['top'] ?? 0,
        map['cropRect']?['right'] ?? 0,
        map['cropRect']?['bottom'] ?? 0,
      ),
      originalSize: Size(
        map['originalSize']?['width'] ?? 0,
        map['originalSize']?['height'] ?? 0,
      ),
      cropEditorScreenRatio: map['cropEditorScreenRatio'] ?? 0,
      scaleUser: map['scaleUser'] ?? 1,
      scaleRotation: map['scaleRotation'] ?? 1,
      aspectRatio: map['aspectRatio'] ?? -1,
      flipX: map['flipX'] ?? false,
      flipY: map['flipY'] ?? false,
      offset: Offset(
        map['offset']?['dx'] ?? 0,
        map['offset']?['dy'] ?? 0,
      ),
    );
  }
  factory TransformConfigs.empty() {
    return TransformConfigs(
      angle: 0,
      originalSize: Size.infinite,
      cropRect: Rect.largest,
      cropEditorScreenRatio: 0,
      scaleUser: 1,
      scaleRotation: 1,
      aspectRatio: -1,
      flipX: false,
      flipY: false,
      offset: const Offset(0, 0),
    );
  }
  bool get isEmpty {
    return angle == 0 &&
        originalSize == Size.infinite &&
        cropRect == Rect.largest &&
        cropEditorScreenRatio == 0 &&
        scaleUser == 1 &&
        scaleRotation == 1 &&
        aspectRatio == -1 &&
        flipX == false &&
        flipY == false &&
        offset == const Offset(0, 0);
  }

  bool get isNotEmpty => !isEmpty;

  double get scale => scaleUser * scaleRotation;
  bool get is90DegRotated {
    RotateAngleSide factor = getRotateAngleSide(angle);
    return factor == RotateAngleSide.left || factor == RotateAngleSide.right;
  }

  Map toMap() {
    if (isEmpty) return {};
    return {
      'angle': angle,
      'cropRect': {
        'left': cropRect.left,
        'top': cropRect.top,
        'right': cropRect.right,
        'bottom': cropRect.bottom,
      },
      'originalSize': {
        'width': originalSize.width,
        'height': originalSize.height,
      },
      'cropEditorScreenRatio': cropEditorScreenRatio,
      'scaleUser': scaleUser,
      'scaleRotation': scaleRotation,
      'aspectRatio': aspectRatio,
      'flipX': flipX,
      'flipY': flipY,
      'offset': {
        'dx': offset.dx,
        'dy': offset.dy,
      },
    };
  }
}

enum ImageMaxSide { horizontal, vertical, unset }
