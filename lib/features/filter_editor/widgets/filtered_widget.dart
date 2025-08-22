// Dart imports:
import 'dart:ui';

// Flutter imports:
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

// Project imports:
import '/core/models/editor_configs/pro_image_editor_configs.dart';
import '/core/models/editor_image.dart';
import '/shared/widgets/auto_image.dart';
import '../../tune_editor/models/tune_adjustment_matrix.dart';
import '../types/filter_matrix.dart';
import 'filter_generator.dart';

/// Represents an image where filters and blur factors can be applied.
class FilteredWidget extends StatelessWidget {
  /// Constructor for creating an instance of FilteredImage.
  const FilteredWidget({
    super.key,
    required this.width,
    required this.height,
    required this.configs,
    required this.filters,
    required this.tuneAdjustments,
    required this.blurFactor,
    this.filterKey,
    this.fit = BoxFit.contain,
    this.image,
    this.videoPlayer,
    this.enableCachedSize = false,
  }) : assert(image != null || videoPlayer != null,
            'Image and video player cannot be null');

  /// A key that uniquely identifies the [ColorFilterGeneratorState] widget and
  /// allows access to its state. This can be used to manipulate the state of
  /// the color filter generator from outside the widget tree.
  ///
  /// This key is optional and can be null.
  final GlobalKey<ColorFilterGeneratorState>? filterKey;

  /// The width of the image.
  final double width;

  /// The height of the image.
  final double height;

  /// A class representing configuration options for the Image Editor.
  final ProImageEditorConfigs configs;

  /// The list of filters to be applied on the image.
  final FilterMatrix filters;

  /// The list of tune adjustments to be applied on the image.
  final List<TuneAdjustmentMatrix> tuneAdjustments;

  /// The editor image to display.
  final EditorImage? image;

  /// The video player to display.
  final Widget? videoPlayer;

  /// How the image should be inscribed into the space allocated for it.
  final BoxFit fit;

  /// The blur factor
  final double blurFactor;

  /// Indicate to the engine that the image must be decoded at the specified
  /// size.
  final bool enableCachedSize;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: Stack(
        // StackFit.expand is important for [transformed_content_generator.dart]
        fit: StackFit.expand,
        alignment: Alignment.center,
        children: [
          ColorFilterGenerator(
            key: filterKey,
            filters: filters,
            tuneAdjustments: tuneAdjustments,
            child: _buildContent(),
          ),
          if (blurFactor > 0) _buildBlur(),
        ],
      ),
    );
  }

  Widget _buildBlur() {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blurFactor, sigmaY: blurFactor),
        child: SizedBox(
          width: width,
          height: height,
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (videoPlayer != null) return videoPlayer!;

    return AutoImage(
      image!,
      enableCachedSize: enableCachedSize,
      fit: fit,
      width: width,
      height: height,
      configs: configs,
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);

    properties
      ..add(DoubleProperty('width', width))
      ..add(DoubleProperty('height', height))
      ..add(DiagnosticsProperty<FilterMatrix>('filters', filters))
      ..add(IterableProperty<TuneAdjustmentMatrix>(
          'tuneAdjustments', tuneAdjustments))
      ..add(DoubleProperty('blurFactor', blurFactor))
      ..add(EnumProperty<BoxFit>('fit', fit))
      ..add(FlagProperty('enableCachedSize',
          value: enableCachedSize, ifTrue: 'cached size enabled'))
      ..add(DiagnosticsProperty<EditorImage?>('image', image))
      ..add(FlagProperty('hasVideoPlayer',
          value: videoPlayer != null, ifTrue: 'video player set'));
  }
}
