// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:colorfilter_generator/colorfilter_generator.dart';

Widget generateFilteredImage({
  required Widget child,
  required ColorFilterGenerator filter,
  required double opacity,
}) {
  return Opacity(
    opacity: opacity,
    child: filter.build(child),
  );
}
