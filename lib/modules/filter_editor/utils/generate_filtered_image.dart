import 'package:colorfilter_generator/colorfilter_generator.dart';
import 'package:flutter/material.dart';

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
