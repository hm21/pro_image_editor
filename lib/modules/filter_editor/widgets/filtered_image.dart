// Dart imports:
import 'dart:ui';

// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:pro_image_editor/pro_image_editor.dart';
import '../../../widgets/auto_image.dart';
import '../types/filter_matrix.dart';
import 'filter_generator.dart';

/// Represents an image where filters and blur factors can be applied.
class FilteredImage extends StatelessWidget {
  /// The width of the image.
  final double width;

  /// The height of the image.
  final double height;

  /// A class representing configuration options for the Image Editor.
  final ProImageEditorConfigs configs;

  /// The list of filters to be applied on the image.
  final FilterMatrix filters;

  /// The editor image to display.
  final EditorImage image;

  /// How the image should be inscribed into the space allocated for it.
  final BoxFit fit;

  /// The blur factor
  final double blurFactor;

  const FilteredImage({
    super.key,
    required this.width,
    required this.height,
    required this.configs,
    required this.filters,
    required this.image,
    required this.blurFactor,
    this.fit = BoxFit.contain,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: Stack(
        // StackFit.expand is importent for [transformed_content_generator.dart]
        fit: StackFit.expand,
        alignment: Alignment.center,
        children: [
          _buildImage(),
          ColorFilterGenerator(filters: filters, child: _buildImage()),
          ClipRect(
            clipBehavior: Clip.hardEdge,
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: blurFactor, sigmaY: blurFactor),
              child: Container(
                width: width,
                height: height,
                alignment: Alignment.center,
                color: Colors.white.withOpacity(0.0),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImage() {
    return AutoImage(
      image,
      fit: fit,
      width: width,
      height: height,
      configs: configs,
    );
  }
}
