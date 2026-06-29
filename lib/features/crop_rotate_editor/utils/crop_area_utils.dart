import 'dart:ui';

import '../enums/crop_area_part.dart';
import '../enums/crop_mode.enum.dart';

/// Determines which part of the crop area the user is interacting with
/// based on the pointer position, crop rectangle, zoom, and crop mode.
///
/// Returns a [CropAreaPart] enum indicating whether the pointer is:
/// - inside the crop area
/// - on one of the edges or corners
/// - or outside (`none`).
CropAreaPart determineCropAreaPart({
  required Offset localPosition,
  required Offset translate,
  required double interactiveCornerArea,
  required double userScaleFactor,
  required Rect cropRect,
  required CropMode cropMode,
  required Size renderedImageSize,
}) {
  Offset offset =
      convertCropHitPoint(
        zoom: userScaleFactor,
        position: localPosition,
        renderedImageSize: renderedImageSize,
      ) +
      translate * userScaleFactor;
  double dx = offset.dx;
  double dy = offset.dy;
  if (cropMode == CropMode.oval) {
    double halfWidth = cropRect.width / 2;
    double halfHeight = cropRect.height / 2;
    double halfInteractiveCornerArea = interactiveCornerArea / 2;

    // Normalize against expanded ellipse for hit area
    double ellipseHitX = dx / (halfWidth + halfInteractiveCornerArea);
    double ellipseHitY = dy / (halfHeight + halfInteractiveCornerArea);
    bool isWithinHitArea =
        (ellipseHitX * ellipseHitX + ellipseHitY * ellipseHitY) <= 1;

    // Normalize against exact ellipse for inside check
    double normalizedX = dx / (halfWidth - halfInteractiveCornerArea);
    double normalizedY = dy / (halfHeight - halfInteractiveCornerArea);
    bool isInsideEllipse =
        (normalizedX * normalizedX + normalizedY * normalizedY) <= 1;

    if (isWithinHitArea) {
      double cursorAreaHitWidth = halfWidth * 0.5;
      double cursorAreaHitHeight = halfHeight * 0.5;

      bool nearTopEdge = dy < -cursorAreaHitHeight;
      bool nearBottomEdge = dy > cursorAreaHitHeight;
      bool nearLeftEdge = dx < -cursorAreaHitWidth;
      bool nearRightEdge = dx > cursorAreaHitWidth;

      if (isInsideEllipse) {
        return CropAreaPart.inside;
      }
      // Bottom Left
      else if (nearBottomEdge && nearLeftEdge) {
        return CropAreaPart.bottomLeft;
      }
      // Bottom Right
      else if (nearBottomEdge && nearRightEdge) {
        return CropAreaPart.bottomRight;
      }
      // Top Left
      else if (nearTopEdge && nearLeftEdge) {
        return CropAreaPart.topLeft;
      }
      // Top Right
      else if (nearTopEdge && nearRightEdge) {
        return CropAreaPart.topRight;
      }
      // Bottom
      else if (nearBottomEdge) {
        return CropAreaPart.bottom;
      }
      // Top
      else if (nearTopEdge) {
        return CropAreaPart.top;
      }
      // Left
      else if (nearLeftEdge) {
        return CropAreaPart.left;
      }
      // Right
      else if (nearRightEdge) {
        return CropAreaPart.right;
      }

      return CropAreaPart.inside;
    } else {
      return CropAreaPart.none;
    }
  }

  Rect rect = Rect.fromCenter(
    center: cropRect.center - translate,
    width: cropRect.width + interactiveCornerArea,
    height: cropRect.height + interactiveCornerArea,
  );

  double halfCropWidth = rect.width / 2;
  double halfCropHeight = rect.height / 2;

  double left = dx + halfCropWidth;
  double right = dx - halfCropWidth;
  double top = dy + halfCropHeight;
  double bottom = dy - halfCropHeight;

  bool nearLeftEdge = left.abs() <= interactiveCornerArea;
  bool nearRightEdge = right.abs() <= interactiveCornerArea;
  bool nearTopEdge = top.abs() <= interactiveCornerArea;
  bool nearBottomEdge = bottom.abs() <= interactiveCornerArea;

  if (rect.contains(localPosition)) {
    if (nearLeftEdge && nearTopEdge) {
      return CropAreaPart.topLeft;
    } else if (nearRightEdge && nearTopEdge) {
      return CropAreaPart.topRight;
    } else if (nearLeftEdge && nearBottomEdge) {
      return CropAreaPart.bottomLeft;
    } else if (nearRightEdge && nearBottomEdge) {
      return CropAreaPart.bottomRight;
    } else if (nearLeftEdge) {
      return CropAreaPart.left;
    } else if (nearRightEdge) {
      return CropAreaPart.right;
    } else if (nearTopEdge) {
      return CropAreaPart.top;
    } else if (nearBottomEdge) {
      return CropAreaPart.bottom;
    } else {
      return CropAreaPart.inside;
    }
  } else {
    return CropAreaPart.none;
  }
}

/// Converts a pointer position into crop-relative coordinates,
/// accounting for zoom and centering relative to the rendered image.
///
/// This transformation ensures that hit detection operates in the same
/// coordinate space as the crop rectangle.
Offset convertCropHitPoint({
  required double zoom,
  required Offset position,
  required Size renderedImageSize,
}) {
  double imgW = renderedImageSize.width;
  double imgH = renderedImageSize.height;

  // Calculate the transformed local position of the pointer
  Offset transformedLocalPosition = position * zoom;
  // Calculate the size of the transformed image
  Size transformedImgSize = Size(imgW, imgH) * zoom;

  // Calculate the center offset point from the old zoomed view
  return Offset(
    transformedLocalPosition.dx - transformedImgSize.width / 2,
    transformedLocalPosition.dy - transformedImgSize.height / 2,
  );
}
