import 'dart:io';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:pro_image_editor/models/editor_configs/pro_image_editor_configs.dart';
import 'package:pro_image_editor/models/theme/theme_layer_interaction.dart';
import 'package:pro_image_editor/widgets/pro_image_editor_desktop_mode.dart';
import 'package:vibration/vibration.dart';

import '../../../utils/debounce.dart';
import '../../../models/history/last_position.dart';
import '../../../models/layer.dart';

/// A helper class responsible for managing layer interactions in the editor.
///
/// The `LayerInteractionHelper` class provides methods for handling various interactions
/// with layers in an image editing environment, including scaling, rotating, flipping,
/// and zooming. It also manages the display of helper lines and provides haptic feedback
/// when interacting with these lines to enhance the user experience.
class LayerInteractionHelper {
  /// Debounce for scaling actions in the editor.
  late Debounce scaleDebounce;

  /// Y-coordinate of the rotation helper line.
  double rotationHelperLineY = 0;

  /// X-coordinate of the rotation helper line.
  double rotationHelperLineX = 0;

  /// Rotation angle of the rotation helper line.
  double rotationHelperLineDeg = 0;

  /// The base scale factor for the editor.
  double baseScaleFactor = 1.0;

  /// The base angle factor for the editor.
  double baseAngleFactor = 0;

  /// X-coordinate where snapping started.
  double snapStartPosX = 0;

  /// Y-coordinate where snapping started.
  double snapStartPosY = 0;

  /// Initial rotation angle when snapping started.
  double snapStartRotation = 0;

  /// Last recorded rotation angle during snapping.
  double snapLastRotation = 0;

  /// Flag indicating if vertical helper lines should be displayed.
  bool showVerticalHelperLine = false;

  /// Flag indicating if horizontal helper lines should be displayed.
  bool showHorizontalHelperLine = false;

  /// Flag indicating if rotation helper lines should be displayed.
  bool showRotationHelperLine = false;

  /// Flag indicating if the device can vibrate.
  bool deviceCanVibrate = false;

  /// Flag indicating if the device can perform custom vibration.
  bool deviceCanCustomVibrate = false;

  /// Flag indicating if rotation helper lines have started.
  bool rotationStartedHelper = false;

  /// Flag indicating if helper lines should be displayed.
  bool showHelperLines = false;

  /// Flag indicating if the remove button is hovered.
  bool hoverRemoveBtn = false;

  /// Enables or disables hit detection.
  /// When `true`, allows detecting user interactions with the painted layer.
  bool enabledHitDetection = true;

  /// Controls high-performance scaling for free-style drawing.
  /// When `true`, enables optimized scaling for improved performance.
  bool freeStyleHighPerformanceScaling = false;

  /// Controls high-performance moving for free-style drawing.
  /// When `true`, enables optimized moving for improved performance.
  bool freeStyleHighPerformanceMoving = false;

  /// Flag indicating if the scaling tool is active.
  bool _activeScale = false;

  /// Span for detecting hits on layers.
  final double hitSpan = 10;

  /// The ID of the currently selected layer.
  String selectedLayerId = '';

  /// Helper variable for scaling during rotation of a layer.
  double? rotateScaleLayerScaleHelper;

  /// Helper variable for storing the size of a layer during rotation and scaling operations.
  Size? rotateScaleLayerSizeHelper;

  /// Last recorded X-axis position for layers.
  LayerLastPosition lastPositionX = LayerLastPosition.center;

  /// Last recorded Y-axis position for layers.
  LayerLastPosition lastPositionY = LayerLastPosition.center;

  /// Determines if layers are selectable based on the configuration and device type.
  bool layersAreSelectable(ProImageEditorConfigs configs) {
    if (configs.layerInteraction.selectable ==
        LayerInteractionSelectable.auto) {
      return isDesktop;
    }
    return configs.layerInteraction.selectable ==
        LayerInteractionSelectable.enabled;
  }

  /// Calculates scaling and rotation based on user interactions.
  calculateInteractiveButtonScaleRotate({
    required ScaleUpdateDetails details,
    required Layer activeLayer,
    required EdgeInsets screenPaddingHelper,
    required bool configEnabledHitVibration,
    required ThemeLayerInteraction layerTheme,
  }) {
    Offset layerOffset = Offset(
      activeLayer.offset.dx + screenPaddingHelper.left,
      activeLayer.offset.dy + screenPaddingHelper.top,
    );
    Size activeSize = rotateScaleLayerSizeHelper!;

    final touchPositionFromCenter = details.focalPoint - layerOffset;

    double newDistance = touchPositionFromCenter.distance;

    double margin = layerTheme.buttonRadius + layerTheme.strokeWidth * 2;
    var realSize = Offset(
          activeSize.width / 2 - margin,
          activeSize.height / 2 - margin,
        ) /
        rotateScaleLayerScaleHelper!;

    activeLayer.scale = newDistance / realSize.distance;
    activeLayer.rotation =
        touchPositionFromCenter.direction - atan(1 / activeSize.aspectRatio);

    checkRotationLine(
      activeLayer: activeLayer,
      screenPaddingHelper: screenPaddingHelper,
      configEnabledHitVibration: configEnabledHitVibration,
    );
  }

  /// Calculates movement of a layer based on user interactions, considering various conditions such as hit areas and screen boundaries.
  calculateMovement({
    required BuildContext context,
    required ScaleUpdateDetails detail,
    required Layer activeLayer,
    required double screenMiddleX,
    required double screenMiddleY,
    required EdgeInsets screenPaddingHelper,
    required bool configEnabledHitVibration,
  }) {
    if (_activeScale) return;

    activeLayer.offset = Offset(
      activeLayer.offset.dx + detail.focalPointDelta.dx,
      activeLayer.offset.dy + detail.focalPointDelta.dy,
    );

    hoverRemoveBtn = detail.focalPoint.dx <= kToolbarHeight &&
        detail.focalPoint.dy <=
            kToolbarHeight + MediaQuery.of(context).viewPadding.top;

    bool vibarate = false;
    double posX = activeLayer.offset.dx + screenPaddingHelper.left;
    double posY = activeLayer.offset.dy + screenPaddingHelper.top;

    bool hitAreaX = detail.focalPoint.dx >= snapStartPosX - hitSpan &&
        detail.focalPoint.dx <= snapStartPosX + hitSpan;
    bool hitAreaY = detail.focalPoint.dy >= snapStartPosY - hitSpan &&
        detail.focalPoint.dy <= snapStartPosY + hitSpan;

    bool helperGoNearLineLeft =
        posX >= screenMiddleX && lastPositionX == LayerLastPosition.left;
    bool helperGoNearLineRight =
        posX <= screenMiddleX && lastPositionX == LayerLastPosition.right;
    bool helperGoNearLineTop =
        posY >= screenMiddleY && lastPositionY == LayerLastPosition.top;
    bool helperGoNearLineBottom =
        posY <= screenMiddleY && lastPositionY == LayerLastPosition.bottom;

    /// Calc vertical helper line
    if ((!showVerticalHelperLine &&
            (helperGoNearLineLeft || helperGoNearLineRight)) ||
        (showVerticalHelperLine && hitAreaX)) {
      if (!showVerticalHelperLine) {
        vibarate = true;
        snapStartPosX = detail.focalPoint.dx;
      }
      showVerticalHelperLine = true;
      activeLayer.offset = Offset(
          screenMiddleX - screenPaddingHelper.left, activeLayer.offset.dy);
      lastPositionX = LayerLastPosition.center;
    } else {
      showVerticalHelperLine = false;
      lastPositionX = posX <= screenMiddleX
          ? LayerLastPosition.left
          : LayerLastPosition.right;
    }

    /// Calc horizontal helper line
    if ((!showHorizontalHelperLine &&
            (helperGoNearLineTop || helperGoNearLineBottom)) ||
        (showHorizontalHelperLine && hitAreaY)) {
      if (!showHorizontalHelperLine) {
        vibarate = true;
        snapStartPosY = detail.focalPoint.dy;
      }
      showHorizontalHelperLine = true;
      activeLayer.offset = Offset(
          activeLayer.offset.dx, screenMiddleY - screenPaddingHelper.top);
      lastPositionY = LayerLastPosition.center;
    } else {
      showHorizontalHelperLine = false;
      lastPositionY = posY <= screenMiddleY
          ? LayerLastPosition.top
          : LayerLastPosition.bottom;
    }

    if (configEnabledHitVibration && vibarate) {
      _lineHitVibrate();
    }
  }

  /// Calculates scaling and rotation of a layer based on user interactions.
  calculateScaleRotate({
    required ScaleUpdateDetails detail,
    required Layer activeLayer,
    required EdgeInsets screenPaddingHelper,
    required bool configEnabledHitVibration,
  }) {
    _activeScale = true;

    activeLayer.scale = baseScaleFactor * detail.scale;
    activeLayer.rotation = baseAngleFactor + detail.rotation;

    checkRotationLine(
      activeLayer: activeLayer,
      screenPaddingHelper: screenPaddingHelper,
      configEnabledHitVibration: configEnabledHitVibration,
    );

    scaleDebounce(() => _activeScale = false);
  }

  /// Checks the rotation line based on user interactions, adjusting rotation accordingly.
  checkRotationLine({
    required Layer activeLayer,
    required EdgeInsets screenPaddingHelper,
    required bool configEnabledHitVibration,
  }) {
    double rotation = activeLayer.rotation - baseAngleFactor;
    double hitSpanX = hitSpan / 2;
    double deg = activeLayer.rotation * 180 / pi;
    double degChange = rotation * 180 / pi;
    double degHit = (snapStartRotation + degChange) % 45;

    bool hitAreaBelow = degHit <= hitSpanX;
    bool hitAreaAfter = degHit >= 45 - hitSpanX;
    bool hitArea = hitAreaBelow || hitAreaAfter;

    if ((!showRotationHelperLine &&
            ((degHit > 0 && degHit <= hitSpanX && snapLastRotation < deg) ||
                (degHit < 45 &&
                    degHit >= 45 - hitSpanX &&
                    snapLastRotation > deg))) ||
        (showRotationHelperLine && hitArea)) {
      if (rotationStartedHelper) {
        activeLayer.rotation =
            (deg - (degHit > 45 - hitSpanX ? degHit - 45 : degHit)) / 180 * pi;
        rotationHelperLineDeg = activeLayer.rotation;

        double posY = activeLayer.offset.dy + screenPaddingHelper.top;
        double posX = activeLayer.offset.dx + screenPaddingHelper.left;

        rotationHelperLineX = posX;
        rotationHelperLineY = posY;
        if (configEnabledHitVibration && !showRotationHelperLine) {
          _lineHitVibrate();
        }
        showRotationHelperLine = true;
      }
      snapLastRotation = deg;
    } else {
      showRotationHelperLine = false;
      rotationStartedHelper = true;
    }
  }

  /// Handles cleanup and resets various flags and states after scaling interaction ends.
  onScaleEnd() {
    enabledHitDetection = true;
    freeStyleHighPerformanceScaling = false;
    freeStyleHighPerformanceMoving = false;
    showHorizontalHelperLine = false;
    showVerticalHelperLine = false;
    showRotationHelperLine = false;
    showHelperLines = false;
    hoverRemoveBtn = false;
  }

  /// Rotate a layer.
  ///
  /// This method rotates a layer based on various factors, including flip and angle.
  void rotateLayer({
    required Layer layer,
    required bool beforeIsFlipX,
    required double newImgW,
    required double newImgH,
    required double rotationScale,
    required double rotationRadian,
    required double rotationAngle,
  }) {
    if (beforeIsFlipX) {
      layer.rotation -= rotationRadian;
    } else {
      layer.rotation += rotationRadian;
    }

    if (rotationAngle == 90) {
      layer.scale /= rotationScale;
      layer.offset = Offset(
        newImgW - layer.offset.dy / rotationScale,
        layer.offset.dx / rotationScale,
      );
    } else if (rotationAngle == 180) {
      layer.offset = Offset(
        newImgW - layer.offset.dx,
        newImgH - layer.offset.dy,
      );
    } else if (rotationAngle == 270) {
      layer.scale /= rotationScale;
      layer.offset = Offset(
        layer.offset.dy / rotationScale,
        newImgH - layer.offset.dx / rotationScale,
      );
    }
  }

  /// Handles zooming of a layer.
  ///
  /// This method calculates the zooming of a layer based on the specified parameters.
  /// It checks if the layer should be zoomed and performs the necessary transformations.
  ///
  /// Returns `true` if the layer was zoomed, otherwise `false`.
  bool zoomedLayer({
    required Layer layer,
    required double scale,
    required double scaleX,
    required double oldFullH,
    required double oldFullW,
    required double pixelRatio,
    required Rect cropRect,
    required bool isHalfPi,
  }) {
    var paddingTop = cropRect.top / pixelRatio;
    var paddingLeft = cropRect.left / pixelRatio;
    var paddingRight = oldFullW - cropRect.right;
    var paddingBottom = oldFullH - cropRect.bottom;

    // important to check with < 1 and >-1 cuz crop-editor has rounding bugs
    if (paddingTop > 0.1 ||
        paddingTop < -0.1 ||
        paddingLeft > 0.1 ||
        paddingLeft < -0.1 ||
        paddingRight > 0.1 ||
        paddingRight < -0.1 ||
        paddingBottom > 0.1 ||
        paddingBottom < -0.1) {
      var initialIconX = (layer.offset.dx - paddingLeft) * scaleX;
      var initialIconY = (layer.offset.dy - paddingTop) * scaleX;
      layer.offset = Offset(
        initialIconX,
        initialIconY,
      );

      layer.scale *= scale;
      return true;
    }
    return false;
  }

  /// Flip a layer horizontally or vertically.
  ///
  /// This method flips a layer either horizontally or vertically based on the specified parameters.
  void flipLayer({
    required Layer layer,
    required bool flipX,
    required bool flipY,
    required bool isHalfPi,
    required double imageWidth,
    required double imageHeight,
  }) {
    if (flipY) {
      if (isHalfPi) {
        layer.flipY = !layer.flipY;
      } else {
        layer.flipX = !layer.flipX;
      }
      layer.offset = Offset(
        imageWidth - layer.offset.dx,
        layer.offset.dy,
      );
    }
    if (flipX) {
      layer.flipX = !layer.flipX;
      layer.offset = Offset(
        layer.offset.dx,
        imageHeight - layer.offset.dy,
      );
    }
  }

  /// Vibrates the device briefly if enabled and supported.
  ///
  /// This function checks if helper lines hit vibration is enabled in the widget's
  /// configurations (`widget.configs.helperLines.hitVibration`) and whether the
  /// device supports vibration. If both conditions are met, it triggers a brief
  /// vibration on the device.
  ///
  /// If the device supports custom vibrations, it uses the `Vibration.vibrate`
  /// method with a duration of 3 milliseconds to produce the vibration.
  ///
  /// On older Android devices, it initiates vibration using `Vibration.vibrate`,
  /// and then, after 3 milliseconds, cancels the vibration using `Vibration.cancel`.
  ///
  /// This function is used to provide haptic feedback when helper lines are interacted
  /// with, enhancing the user experience.
  void _lineHitVibrate() {
    if (deviceCanVibrate && deviceCanCustomVibrate) {
      Vibration.vibrate(duration: 3);
    } else if (!kIsWeb && Platform.isAndroid) {
      // On old android devices we can stop the vibration after 3 milliseconds
      // iOS: only works for custom haptic vibrations using CHHapticEngine.
      // This will set `deviceCanCustomVibrate` anyway to true so it's impossible to fake it.
      Vibration.vibrate();
      Future.delayed(const Duration(milliseconds: 3)).whenComplete(() {
        Vibration.cancel();
      });
    }
  }
}
