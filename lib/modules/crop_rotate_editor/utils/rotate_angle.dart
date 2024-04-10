import 'dart:math';

RotateAngleSide getRotateAngleSide(double angleFactor) {
  double pi2 = pi * 2;
  String factor = (angleFactor % pi2).toStringAsFixed(3);

  if (factor == (pi * 1.5).toStringAsFixed(3)) {
    return RotateAngleSide.left;
  } else if (factor == pi.toStringAsFixed(3)) {
    return RotateAngleSide.bottom;
  } else if (factor == (pi / 2).toStringAsFixed(3)) {
    return RotateAngleSide.right;
  } else {
    return RotateAngleSide.top;
  }
}

enum RotateAngleSide {
  left,
  bottom,
  right,
  top,
}
