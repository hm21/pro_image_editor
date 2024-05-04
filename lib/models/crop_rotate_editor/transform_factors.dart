import 'package:flutter/widgets.dart';
import 'package:pro_image_editor/modules/crop_rotate_editor/utils/rotate_angle.dart';

class TransformConfigs {
  final Offset offset;
  final Rect cropRect;
  final double angle;
  final double scaleAspectRatio;
  final double scaleUser;
  final double scaleRotation;
  final double aspectRatio;
  final bool flipX;
  final bool flipY;

  const TransformConfigs({
    required this.angle,
    required this.cropRect,
    required this.scaleAspectRatio,
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
      scaleAspectRatio: map['scaleAspectRatio'] ?? 1,
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
    return const TransformConfigs(
      angle: 0,
      cropRect: Rect.largest,
      scaleAspectRatio: 1,
      scaleUser: 1,
      scaleRotation: 1,
      aspectRatio: -1,
      flipX: false,
      flipY: false,
      offset: Offset(0, 0),
    );
  }
  bool get isEmpty {
    return angle == 0 &&
        cropRect == Rect.largest &&
        scaleAspectRatio == 1 &&
        scaleUser == 1 &&
        scaleRotation == 1 &&
        aspectRatio == -1 &&
        flipX == false &&
        flipY == false &&
        offset == const Offset(0, 0);
  }

  double get scale => scaleUser * scaleRotation * scaleAspectRatio;
  bool get is90DegRotated {
    RotateAngleSide factor = getRotateAngleSide(angle);
    return factor == RotateAngleSide.left || factor == RotateAngleSide.right;
  }

  Map toMap() {
    return {
      'angle': angle,
      'cropRect': {
        'left': cropRect.left,
        'top': cropRect.top,
        'right': cropRect.right,
        'bottom': cropRect.bottom,
      },
      'scaleAspectRatio': scaleAspectRatio,
      'scaleUser': scaleUser,
      'scaleRotation': scaleRotation,
      'flipX': flipX,
      'flipY': flipY,
      'aspectRatio': aspectRatio,
      'offset': {
        'dx': offset.dx,
        'dy': offset.dy,
      },
    };
  }
}

enum ImageMaxSide { horizontal, vertical, unset }
