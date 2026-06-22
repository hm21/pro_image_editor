// Dart imports:
import 'dart:math';

// Flutter imports:
import 'package:flutter/material.dart';

import '/core/models/editor_configs/pro_image_editor_configs.dart';
import '/core/models/history/state_history.dart';
import '/core/models/layers/layer.dart';
import '/shared/widgets/screen_resize_detector.dart';

/// A helper class for managing screen size and padding calculations.
class SizesManager {
  /// Constructor for creating an instance of SizesManager.
  SizesManager({required this.context, required this.configs});

  /// The build context used to obtain screen size information.
  final BuildContext context;

  /// Configuration options for the image editor.
  final ProImageEditorConfigs configs;

  /// Returns the height of the app bar.
  double appBarHeight = 0;

  /// Returns the height of the bottom bar.
  double bottomBarHeight = 0;

  /// Returns the total height of all toolbars.
  double get allToolbarHeight => appBarHeight + bottomBarHeight;

  /// Getter for the screen size of the device.
  Size get screen => MediaQuery.sizeOf(context);

  /// Size of the decoded image.
  Size decodedImageSize = const Size(0, 0);

  /// The raw image size.
  Size? originalImageSize;

  /// Represents a temporary decoded image size which is required for screen
  /// resizing.
  Size temporaryDecodedImageSize = const Size(0, 0);

  /// Getter for the screen inner height, excluding top and bottom padding.
  double get screenInnerHeight =>
      lastScreenSize.height -
      screenPadding.top -
      screenPadding.bottom -
      allToolbarHeight;

  /// Getter for the screen padding, accounting for safe area insets.
  EdgeInsets get screenPadding => MediaQuery.paddingOf(context);

  /// Get the screen padding values.
  EdgeInsets get imageMargin => EdgeInsets.only(
    top:
        (lastScreenSize.height -
            screenPadding.top -
            screenPadding.bottom -
            decodedImageSize.height) /
        2,
    left:
        (lastScreenSize.width -
            screenPadding.left -
            screenPadding.right -
            decodedImageSize.width) /
        2,
  );

  /// Calculates the gaps around the image on the screen using padding and
  /// toolbar height.
  EdgeInsets get imageScreenGaps => EdgeInsets.only(
    /// Calculates the top gap based on screen height, padding, image
    /// height, and toolbar height, centered vertically.
    top:
        (screen.height -
            screenPadding.top -
            screenPadding.bottom -
            decodedImageSize.height -
            allToolbarHeight) /
        2,

    /// Calculates the left gap based on screen width, padding, and image
    /// width, centered horizontally.
    left:
        (screen.width -
            screenPadding.left -
            screenPadding.right -
            decodedImageSize.width) /
        2,
  );

  /// Calculates the vertical center position of the editor.
  double editorCenterY(int selectedLayerIndex) =>
      /// Computes the vertical center by subtracting the heights of the
      /// app bar and bottom bar from the editor's total height.
      (editorSize.height - appBarHeight - bottomBarHeight) / 2;

  /// Stores the last recorded screen size.
  Size lastScreenSize = const Size(0, 0);

  /// Stores the last recorded body size.
  Size bodySize = Size.zero;

  /// Stores the last recorded editor size.
  Size editorSize = Size.zero;

  /// Recalculates the position and scale of layers based on the temporary
  /// decoded image size.
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
      double convertedRatio = transformConfigs.is90DegRotated
          ? 1 / ratio
          : ratio;

      if (convertedRatio < drawSize.aspectRatio) {
        return Size(drawSize.height * convertedRatio, drawSize.height);
      } else {
        return Size(drawSize.width, drawSize.width / convertedRatio);
      }
    }

    // A single layer instance can be shared across multiple history entries
    // (e.g. layers added in one paint session reuse the same pre-existing
    // instances — see `openPaintEditor`). Rescaling in place would otherwise
    // mutate that instance once per entry, compounding the scale factor. Track
    // processed instances by object identity so each is rescaled at most once.
    //
    // `Layer.==` is content-based, so independent-but-equal copies must remain
    // distinct here — a plain `Set<Layer>` would wrongly collapse them.
    final processed = Set<Layer>.identity();

    for (int i = 0; i < history.length; i++) {
      var el = history[i];

      var transform = el.transformConfigs ?? TransformConfigs.empty();

      if (transform.isEmpty) {
        int pointer = i;
        while (pointer > 0 && transform.isEmpty) {
          pointer--;
          final oldConfigs = history[pointer].transformConfigs;
          if (oldConfigs != null) transform = oldConfigs;
        }
      }

      Size oldSize = getCropImageSize(
        transformConfigs: transform,
        drawSize: resizeEvent.oldContentSize,
      );
      Size newSize = getCropImageSize(
        transformConfigs: transform,
        drawSize: resizeEvent.newContentSize,
      );
      double scaleFactor = min(
        oldSize.width / newSize.width,
        oldSize.height / newSize.height,
      );
      if (scaleFactor != 0) {
        for (var layer in el.layers) {
          if (!processed.add(layer)) continue;
          layer
            ..scale /= scaleFactor
            ..offset /= scaleFactor;
        }
      }
    }
  }
}
