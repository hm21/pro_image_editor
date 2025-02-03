import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '/core/models/editor_configs/image_generation_configs/image_generation_configs.dart';
import '/shared/utils/decode_image.dart';
import '/shared/widgets/extended/repaint/extended_render_repaint_boundary.dart';

/// Service for rendering images from widgets or custom canvases.
/// This service captures and processes images from the widget tree,
/// applying configurations like pixel ratio and cropping options.
class ImageRenderService {
  /// Initializes the service with the specified image generation
  ///  configurations.
  ///
  /// - [configs]: Defines settings like maximum output size, pixel ratio, and
  ///   whether to capture only the drawing bounds of the widget.
  ImageRenderService(this.configs);

  /// Configuration settings for image generation and processing.
  ///
  /// This includes parameters like output format, compression quality, and
  /// other options that dictate how images should be processed and converted.
  final ImageGenerationConfigs configs;

  /// Captures a raw image from the widget tree using the specified rendering
  /// settings.
  ///
  /// This method uses the `GlobalKey` of a widget to locate its `RenderObject`
  /// and captures it as a `ui.Image`. The method ensures the render object is
  /// fully painted before capturing. It also applies scaling, cropping, or
  /// adjusts the pixel ratio based on the configurations.
  ///
  /// - [imageInfos]: Contains metadata about the image to be captured,
  ///   including pixel ratio and rendered size.
  /// - [containerKey]: The key of the widget containing the content to be
  ///   captured.
  /// - [widgetKey]: (Optional) A specific widget's key for rendering; defaults
  ///   to `containerKey` if not provided.
  /// - [useThumbnailSize]: Determines if thumbnail size constraints should be
  ///   applied.
  ///
  /// Returns the captured `ui.Image` or `null` if the operation fails.
  Future<ui.Image?> getRawRenderedImage({
    required ImageInfos imageInfos,
    required GlobalKey containerKey,
    GlobalKey? widgetKey,
    bool useThumbnailSize = false,
  }) async {
    try {
      widgetKey ??= containerKey;

      RenderObject? findRenderObject =
          widgetKey.currentContext?.findRenderObject();
      if (findRenderObject == null) return null;

      // Wait until the render object's paint information is ready.
      int retryHelper = 0;
      while (!findRenderObject.attached && retryHelper < 25) {
        await Future.delayed(const Duration(milliseconds: 20));
        retryHelper++;
      }

      ExtendedRenderRepaintBoundary boundary =
          findRenderObject as ExtendedRenderRepaintBoundary;
      BuildContext? context = widgetKey.currentContext;

      // Determine pixel ratio
      double outputRatio = imageInfos.pixelRatio;
      if (!configs.captureOnlyDrawingBounds &&
          context != null &&
          context.mounted) {
        outputRatio =
            max(imageInfos.pixelRatio, MediaQuery.devicePixelRatioOf(context));
      }

      bool isOutputSizeTooLarge = checkOutputSizeIsTooLarge(
        imageInfos.renderedSize,
        outputRatio,
        useThumbnailSize,
      );

      if (isOutputSizeTooLarge) {
        outputRatio = max(
          _maxOutputDimension(useThumbnailSize).width / boundary.size.width,
          _maxOutputDimension(useThumbnailSize).height / boundary.size.height,
        );
      }

      double pixelRatio = configs.customPixelRatio ?? outputRatio;

      // Capture image
      ui.Image image = await _convertToDartUiImage(
        boundary,
        imageInfos,
        pixelRatio,
      );

      return image;
    } catch (e) {
      debugPrint('Failed to read image data: ${e.toString()}');
      return null;
    }
  }

  /// Checks if the computed output size of the image exceeds the maximum
  /// allowed dimensions.
  ///
  /// - [renderedSize]: The size of the content to be rendered.
  /// - [outputRatio]: The pixel ratio applied to the rendered content.
  /// - [useThumbnailSize]: Determines if thumbnail size constraints are
  /// applied.
  ///
  /// Returns `true` if the output size exceeds the allowed dimensions,
  /// otherwise `false`.
  bool checkOutputSizeIsTooLarge(
    Size renderedSize,
    double outputRatio,
    bool useThumbnailSize,
  ) {
    Size outputSize = renderedSize * outputRatio;

    return outputSize.width > _maxOutputDimension(useThumbnailSize).width ||
        outputSize.height > _maxOutputDimension(useThumbnailSize).height;
  }

  /// Calculates the maximum output dimensions based on whether thumbnail
  /// constraints are applied.
  ///
  /// - [useThumbnailSize]: If `true`, uses the maximum thumbnail size;
  /// otherwise, uses the full output size.
  ///
  /// Returns the maximum allowable `Size` for the output.
  Size _maxOutputDimension(bool useThumbnailSize) =>
      !useThumbnailSize ? configs.maxOutputSize : configs.maxThumbnailSize;

  /// Crops an image to remove transparent areas, focusing on the bounds of the
  /// visible content.
  ///
  /// This method uses the `ImageInfos` metadata to calculate the crop
  /// rectangle and adjust the image accordingly, ensuring the final image
  /// matches the desired aspect ratio and size.
  ///
  /// - [image]: The input `ui.Image` to be cropped.
  /// - [imageInfos]: Metadata about the image, including its rotation and
  /// cropping details.
  ///
  /// Returns a new `ui.Image` cropped to the appropriate dimensions.
  Future<ui.Image> _convertToDartUiImage(
    ExtendedRenderRepaintBoundary boundary,
    ImageInfos imageInfos,
    double pixelRatio,
  ) async {
    // If cropping is not required, return the image directly
    if (!configs.captureOnlyDrawingBounds) {
      return boundary.toImage(pixelRatio: pixelRatio);
    }

    /// Start calculate the "real" image bounding
    double imageWidth = boundary.size.width;
    double imageHeight = boundary.size.height;

    double cropRectRatio = !imageInfos.isRotated
        ? imageInfos.cropRectSize.aspectRatio
        : 1 / imageInfos.cropRectSize.aspectRatio;

    Size convertedImgSize = Size(imageWidth, imageHeight);

    double convertedImgWidth = convertedImgSize.width;
    double convertedImgHeight = convertedImgSize.height;

    if (convertedImgSize.aspectRatio > cropRectRatio) {
      // Fit to height
      convertedImgSize = Size(
        convertedImgHeight * cropRectRatio,
        convertedImgHeight,
      );
    } else {
      // Fit to width
      convertedImgSize = Size(
        convertedImgWidth,
        convertedImgWidth / cropRectRatio,
      );
    }

    double cropWidth = convertedImgSize.width;
    double cropHeight = convertedImgSize.height;
    double cropX = max(0, imageWidth - cropWidth) / 2;
    double cropY = max(0, imageHeight - cropHeight) / 2;

    return boundary.toImage(
      rect: Rect.fromLTWH(cropX, cropY, cropWidth, cropHeight),
      pixelRatio: pixelRatio,
    );
  }
}
