import 'dart:ui';

import 'package:colorfilter_generator/colorfilter_generator.dart';
import 'package:flutter/material.dart';
import 'package:pro_image_editor/models/editor_image.dart';
import 'package:pro_image_editor/utils/design_mode.dart';
import 'package:pro_image_editor/widgets/auto_image.dart';

import '../../../models/history/filter_state_history.dart';
import '../utils/generate_filtered_image.dart';

/// A widget that displays an image with a customizable color filter applied to it.
class ImageWithFilter extends StatelessWidget {
  /// The image to be displayed.
  final EditorImage image;

  /// The color filter to be applied to the image.
  final ColorFilterGenerator filter;

  /// The BoxFit option to control how the image is fitted into the available space.
  final BoxFit? fit;

  /// The opacity of the image.
  final double opacity;

  /// The design mode of the editor.
  final ImageEditorDesignModeE designMode;

  final Size? size;

  final List<FilterStateHistory>? activeFilters;

  final double? blurFactor;

  /// Creates an `ImageWithFilter` widget.
  ///
  /// The [image] and [filter] parameters are required. The [fit] parameter
  /// allows you to specify how the image should be fitted, and the [opacity]
  /// parameter controls the opacity of the image.
  const ImageWithFilter({
    super.key,
    required this.image,
    required this.filter,
    required this.designMode,
    required this.activeFilters,
    required this.blurFactor,
    this.size,
    this.fit,
    this.opacity = 1,
  });

  @override
  Widget build(BuildContext context) {
    var img = AutoImage(
      image,
      fit: fit,
      width: size?.width,
      height: size?.height,
      designMode: designMode,
    );

    if (filter.filters.isEmpty && activeFilters == null) {
      if (blurFactor == null) {
        return img;
      } else {
        return Stack(
          alignment: Alignment.center,
          fit: StackFit.expand,
          children: [
            img,
            BackdropFilter(
              filter:
                  ImageFilter.blur(sigmaX: blurFactor!, sigmaY: blurFactor!),
              child: Container(
                decoration: BoxDecoration(color: Colors.white.withOpacity(0.0)),
              ),
            ),
          ],
        );
      }
    } else {
      List<FilterStateHistory> filters = [
        FilterStateHistory(filter: filter, opacity: opacity),
        if (activeFilters != null) ...activeFilters!,
      ];

      Widget filteredImg = img;
      for (var filter in filters) {
        filteredImg = generateFilteredImage(
          child: filteredImg,
          filter: filter.filter,
          opacity: filter.opacity,
        );
      }

      if (blurFactor == null) {
        return Stack(
          alignment: Alignment.center,
          fit: StackFit.expand,
          children: [
            img,
            filteredImg,
          ],
        );
      } else {
        return Stack(
          alignment: Alignment.center,
          fit: StackFit.expand,
          children: [
            img,
            filteredImg,
            BackdropFilter(
              filter:
                  ImageFilter.blur(sigmaX: blurFactor!, sigmaY: blurFactor!),
              child: Container(
                decoration: BoxDecoration(color: Colors.white.withOpacity(0.0)),
              ),
            ),
          ],
        );
      }
    }
  }
}
