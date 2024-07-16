// Dart imports:
import 'dart:math';

// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:pro_image_editor/pro_image_editor.dart';
import '../../../models/crop_rotate_editor/transform_factors.dart';
import '../../../models/history/state_history.dart';
import '../../../widgets/screen_resize_detector.dart';

/// A helper class for managing screen size and padding calculations.
class SizesManager {
  /// The build context used to obtain screen size information.
  final BuildContext context;

  /// Configuration options for the image editor.
  final ProImageEditorConfigs configs;

  SizesManager({
    required this.context,
    required this.configs,
  });

  /// Returns the height of the app bar.
  double appBarHeight = 0;

  /// Returns the height of the bottom bar.
  double bottomBarHeight = 0;

  /// Returns the total height of all toolbars.
  double get allToolbarHeight => appBarHeight + bottomBarHeight;

  /// Getter for the screen size of the device.
  Size get screen => MediaQuery.of(context).size;

  /// Size of the decoded image.
  Size decodedImageSize = const Size(0, 0);

  /// The raw image size.
  Size? originalImageSize;

  /// Represents a temporary decoded image size which is required for screen resizing.
  Size temporaryDecodedImageSize = const Size(0, 0);

  /// Getter for the screen inner height, excluding top and bottom padding.
  double get screenInnerHeight =>
      lastScreenSize.height -
      screenPadding.top -
      screenPadding.bottom -
      allToolbarHeight;

  /// Getter for the screen padding, accounting for safe area insets.
  EdgeInsets get screenPadding => MediaQuery.of(context).padding;

  /// Get the screen padding values.
  EdgeInsets get imageMargin => EdgeInsets.only(
        top: (lastScreenSize.height -
                screenPadding.top -
                screenPadding.bottom -
                decodedImageSize.height) /
            2,
        left: (lastScreenSize.width -
                screenPadding.left -
                screenPadding.right -
                decodedImageSize.width) /
            2,
      );
  EdgeInsets get imageScreenGaps => EdgeInsets.only(
        top: (screen.height -
                screenPadding.top -
                screenPadding.bottom -
                decodedImageSize.height -
                allToolbarHeight) /
            2,
        left: (screen.width -
                screenPadding.left -
                screenPadding.right -
                decodedImageSize.width) /
            2,
      );

  double editorCenterY(int selectedLayerIndex) =>
      (editorSize.height - appBarHeight - bottomBarHeight) / 2;

  /// Stores the last recorded screen size.
  Size lastScreenSize = const Size(0, 0);

  /// Stores the last recorded body size.
  Size bodySize = Size.zero;

  /// Stores the last recorded editor size.
  Size editorSize = Size.zero;

  /// Recalculates the position and scale of layers based on the temporary decoded image size.
  void recalculateLayerPosition({
    required List<EditorStateHistory> history,
    required ResizeEvent resizeEvent,
  }) {
    Size getCropImageSize({
      required TransformConfigs transformConfigs,
      required Size drawSize,
    }) {
      double ratio = transformConfigs.originalSize.isInfinite
          ? decodedImageSize.aspectRatio
          : transformConfigs.cropRect.size.aspectRatio;
      double convertedRatio =
          transformConfigs.is90DegRotated ? 1 / ratio : ratio;

      if (convertedRatio < drawSize.aspectRatio) {
        return Size(drawSize.height * convertedRatio, drawSize.height);
      } else {
        return Size(drawSize.width, drawSize.width / convertedRatio);
      }
    }

    for (var el in history) {
      Size oldSize = getCropImageSize(
        transformConfigs: el.transformConfigs,
        drawSize: resizeEvent.oldContentSize,
      );
      Size newSize = getCropImageSize(
        transformConfigs: el.transformConfigs,
        drawSize: resizeEvent.newContentSize,
      );
      double scaleFactor = min(
        oldSize.width / newSize.width,
        oldSize.height / newSize.height,
      );
      if (scaleFactor != 0) {
        for (var layer in el.layers) {
          layer.scale /= scaleFactor;
          layer.offset = Offset(
            layer.offset.dx / scaleFactor,
            layer.offset.dy / scaleFactor,
          );
        }
      }
    }
  }
}
