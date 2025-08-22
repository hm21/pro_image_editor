// Flutter imports:
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import '/core/models/editor_configs/pro_image_editor_configs.dart';
import '/core/models/editor_image.dart';
import '../extensions/double_extension.dart';
import 'platform/platform_circular_progress_indicator.dart';

/// A versatile widget for displaying images with various sources.
class AutoImage extends StatelessWidget {
  /// Creates an [AutoImage] widget with the specified image source and
  /// optional parameters.
  const AutoImage(
    this.image, {
    super.key,
    this.fit,
    this.width,
    this.height,
    required this.configs,
    this.enableCachedSize = false,
  });

  /// The image to be displayed, wrapped as an [EditorImage].
  final EditorImage image;

  /// How the image should be inscribed into the space allocated for it.
  final BoxFit? fit;

  /// The preferred width of the image. If null, it will be determined by the
  /// parent widget.
  final double? width;

  /// The preferred height of the image. If null, it will be determined by the
  /// parent widget.
  final double? height;

  /// Indicate to the engine that the image must be decoded at the specified
  /// size.
  final bool enableCachedSize;

  /// The design mode of the editor.
  final ProImageEditorConfigs configs;

  @override
  Widget build(BuildContext context) {
    // Display the image based on its type.
    switch (image.type) {
      case EditorImageType.memory:
        return Image.memory(
          image.byteArray!,
          fit: fit,
          width: width,
          height: height,
          cacheWidth: enableCachedSize ? width?.toDevicePixels(context) : null,
        );
      case EditorImageType.file:
        return Image.file(
          image.file! as dynamic,
          fit: fit,
          width: width,
          height: height,
          cacheWidth: enableCachedSize ? width?.toDevicePixels(context) : null,
        );
      case EditorImageType.network:
        return Image.network(
          image.networkUrl!,
          fit: fit,
          width: width,
          height: height,
          cacheWidth: enableCachedSize ? width?.toDevicePixels(context) : null,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) {
              return child;
            } else {
              // Display a circular progress indicator while the image is
              // loading.
              return Center(
                child: PlatformCircularProgressIndicator(configs: configs),
              );
            }
          },
        );
      case EditorImageType.asset:
        return Image.asset(
          image.assetPath!,
          fit: fit,
          width: width,
          height: height,
          cacheWidth: enableCachedSize ? width?.toDevicePixels(context) : null,
        );
    }
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);

    properties
      ..add(DiagnosticsProperty<EditorImage>('image', image))
      ..add(EnumProperty<EditorImageType>('imageType', image.type))
      ..add(EnumProperty<BoxFit?>('fit', fit))
      ..add(DoubleProperty('width', width))
      ..add(DoubleProperty('height', height))
      ..add(FlagProperty('enableCachedSize',
          value: enableCachedSize, ifTrue: 'cached size enabled'));
  }
}
