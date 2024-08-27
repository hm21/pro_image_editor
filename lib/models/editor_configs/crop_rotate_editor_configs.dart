// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../crop_rotate_editor/aspect_ratio_item.dart';
import '../crop_rotate_editor/rotate_direction.dart';

export '../crop_rotate_editor/rotate_direction.dart';

/// Configuration options for a crop and rotate editor.
///
/// `CropRotateEditorConfigs` allows you to define various settings for a
/// crop and rotate editor. You can enable or disable specific features like
/// cropping, rotating, and maintaining aspect ratio. Additionally, you can
/// specify an initial aspect ratio for cropping.
///
/// Example usage:
/// ```dart
/// CropRotateEditorConfigs(
///   enabled: true,
///   enabledRotate: true,
///   enabledAspectRatio: true,
///   initAspectRatio: CropAspectRatios.custom,
/// );
/// ```
class CropRotateEditorConfigs {
  /// Creates an instance of CropRotateEditorConfigs with optional settings.
  ///
  /// By default, all options are enabled, and the initial aspect ratio is set
  /// to `CropAspectRatios.custom`.
  const CropRotateEditorConfigs({
    this.desktopCornerDragArea = 7,
    this.mobileCornerDragArea = kMinInteractiveDimension,
    this.enabled = true,
    this.canRotate = true,
    this.canFlip = true,
    this.enableDoubleTap = true,
    this.transformLayers = true,
    this.canChangeAspectRatio = true,
    this.canReset = true,
    this.reverseMouseScroll = false,
    this.reverseDragDirection = false,
    this.roundCropper = false,
    this.provideImageInfos = false,
    this.initAspectRatio,
    this.rotateAnimationCurve = Curves.decelerate,
    this.scaleAnimationCurve = Curves.decelerate,
    this.cropDragAnimationCurve = Curves.decelerate,
    this.fadeInOutsideCropAreaAnimationCurve = Curves.decelerate,
    this.rotateDirection = RotateDirection.left,
    this.opacityOutsideCropAreaDuration = const Duration(milliseconds: 100),
    this.animationDuration = const Duration(milliseconds: 250),
    this.fadeInOutsideCropAreaAnimationDuration =
        const Duration(milliseconds: 350),
    this.cropDragAnimationDuration = const Duration(milliseconds: 400),
    this.maxScale = 7,
    this.mouseScaleFactor = 0.1,
    this.doubleTapScaleFactor = 2,
    this.aspectRatios = const [
      AspectRatioItem(text: 'Free', value: -1),
      AspectRatioItem(text: 'Original', value: 0.0),
      AspectRatioItem(text: '1*1', value: 1.0 / 1.0),
      AspectRatioItem(text: '4*3', value: 4.0 / 3.0),
      AspectRatioItem(text: '3*4', value: 3.0 / 4.0),
      AspectRatioItem(text: '16*9', value: 16.0 / 9.0),
      AspectRatioItem(text: '9*16', value: 9.0 / 16.0)
    ],
  })  : assert(maxScale >= 1, 'maxScale must be greater than or equal to 1'),
        assert(desktopCornerDragArea > 0,
            'desktopCornerDragArea must be positive'),
        assert(!roundCropper || !canChangeAspectRatio,
            'In roundCropper mode, canChangeAspectRatio must be disabled.'),
        assert(!roundCropper || initAspectRatio == 1,
            'In roundCropper mode, initAspectRatio must be 1.'),
        assert(
            mobileCornerDragArea > 0, 'mobileCornerDragArea must be positive'),
        assert(doubleTapScaleFactor > 1,
            'doubleTapScaleFactor must be greater than 1');

  /// Indicates whether the editor is enabled.
  final bool enabled;

  /// Indicating whether the image can be rotated.
  final bool canRotate;

  /// Indicating whether the image can be flipped.
  final bool canFlip;

  /// Indicating whether the aspect ratio of the image can be changed.
  final bool canChangeAspectRatio;

  /// Indicating whether the editor can be reset.
  final bool canReset;

  /// Layers will also be transformed like the crop-rotate image.
  final bool transformLayers;

  /// Enables double-tap zoom functionality when set to true.
  final bool enableDoubleTap;

  /// Determines if the mouse scroll direction should be reversed.
  final bool reverseMouseScroll;

  /// Determines if the drag direction should be reversed.
  final bool reverseDragDirection;

  /// The cropper is round and not rectangular, which is optimal for cutting
  /// profile images.
  ///
  /// The round cropper only supports an aspect ratio of 1.
  final bool roundCropper;

  /// A boolean flag that determines whether the `imageInfos` parameter
  /// should be included in the `onDone` callback.
  ///
  /// When set to `true`, the `imageInfos` parameter will be provided in the
  /// `onDone` callback of the crop editor, containing detailed information
  /// about the edited image. If set to `false`, `imageInfos` will be `null`.
  final bool provideImageInfos;

  /// The initial aspect ratio for cropping.
  ///
  /// For free aspect ratio use `-1` and for original aspect ratio use `0.0`.
  final double? initAspectRatio;

  /// The maximum scale allowed for the view.
  final double maxScale;

  /// The scaling factor applied to mouse scrolling.
  final double mouseScaleFactor;

  /// The scaling factor applied when double-tapping.
  final double doubleTapScaleFactor;

  /// The allowed aspect ratios for cropping.
  ///
  /// For free aspect ratio use `-1` and for original aspect ratio use `0.0`.
  final List<AspectRatioItem> aspectRatios;

  /// The duration for the animation controller that handles rotation and
  /// scale animations.
  final Duration animationDuration;

  /// The duration of drag-crop animations.
  final Duration cropDragAnimationDuration;

  /// Fade in animation from content outside the crop area.
  final Duration fadeInOutsideCropAreaAnimationDuration;

  /// The duration of the outside crop area opacity.
  final Duration opacityOutsideCropAreaDuration;

  /// The curve used for the rotation animation.
  final Curve rotateAnimationCurve;

  /// The curve used for the scale animation, which is triggered when the
  /// image needs to resize due to rotation.
  final Curve scaleAnimationCurve;

  /// The animation curve used for crop animations.
  final Curve cropDragAnimationCurve;

  /// The animation curve used for the fade in animation from content outside
  /// the crop area.
  final Curve fadeInOutsideCropAreaAnimationCurve;

  /// The direction in which the image will be rotated.
  final RotateDirection rotateDirection;

  /// Defines the size of the draggable area on corners of the crop rectangle
  /// for desktop devices.
  final double desktopCornerDragArea;

  /// Defines the size of the draggable area on corners of the crop rectangle
  /// for mobile devices.
  final double mobileCornerDragArea;

  /// Creates a copy of this `CropRotateEditorConfigs` object with the given
  /// fields replaced with new values.
  ///
  /// The [copyWith] method allows you to create a new instance of
  /// [CropRotateEditorConfigs] with some properties updated while keeping the
  /// others unchanged.
  CropRotateEditorConfigs copyWith({
    bool? enabled,
    bool? canRotate,
    bool? canFlip,
    bool? canChangeAspectRatio,
    bool? canReset,
    bool? transformLayers,
    bool? enableDoubleTap,
    bool? reverseMouseScroll,
    bool? reverseDragDirection,
    bool? roundCropper,
    bool? provideImageInfos,
    double? initAspectRatio,
    double? maxScale,
    double? mouseScaleFactor,
    double? doubleTapScaleFactor,
    List<AspectRatioItem>? aspectRatios,
    Duration? animationDuration,
    Duration? cropDragAnimationDuration,
    Duration? fadeInOutsideCropAreaAnimationDuration,
    Duration? opacityOutsideCropAreaDuration,
    Curve? rotateAnimationCurve,
    Curve? scaleAnimationCurve,
    Curve? cropDragAnimationCurve,
    Curve? fadeInOutsideCropAreaAnimationCurve,
    RotateDirection? rotateDirection,
    double? desktopCornerDragArea,
    double? mobileCornerDragArea,
  }) {
    return CropRotateEditorConfigs(
      provideImageInfos: provideImageInfos ?? this.provideImageInfos,
      enabled: enabled ?? this.enabled,
      canRotate: canRotate ?? this.canRotate,
      canFlip: canFlip ?? this.canFlip,
      canChangeAspectRatio: canChangeAspectRatio ?? this.canChangeAspectRatio,
      canReset: canReset ?? this.canReset,
      transformLayers: transformLayers ?? this.transformLayers,
      enableDoubleTap: enableDoubleTap ?? this.enableDoubleTap,
      reverseMouseScroll: reverseMouseScroll ?? this.reverseMouseScroll,
      reverseDragDirection: reverseDragDirection ?? this.reverseDragDirection,
      roundCropper: roundCropper ?? this.roundCropper,
      initAspectRatio: initAspectRatio ?? this.initAspectRatio,
      maxScale: maxScale ?? this.maxScale,
      mouseScaleFactor: mouseScaleFactor ?? this.mouseScaleFactor,
      doubleTapScaleFactor: doubleTapScaleFactor ?? this.doubleTapScaleFactor,
      aspectRatios: aspectRatios ?? this.aspectRatios,
      animationDuration: animationDuration ?? this.animationDuration,
      cropDragAnimationDuration:
          cropDragAnimationDuration ?? this.cropDragAnimationDuration,
      fadeInOutsideCropAreaAnimationDuration:
          fadeInOutsideCropAreaAnimationDuration ??
              this.fadeInOutsideCropAreaAnimationDuration,
      opacityOutsideCropAreaDuration:
          opacityOutsideCropAreaDuration ?? this.opacityOutsideCropAreaDuration,
      rotateAnimationCurve: rotateAnimationCurve ?? this.rotateAnimationCurve,
      scaleAnimationCurve: scaleAnimationCurve ?? this.scaleAnimationCurve,
      cropDragAnimationCurve:
          cropDragAnimationCurve ?? this.cropDragAnimationCurve,
      fadeInOutsideCropAreaAnimationCurve:
          fadeInOutsideCropAreaAnimationCurve ??
              this.fadeInOutsideCropAreaAnimationCurve,
      rotateDirection: rotateDirection ?? this.rotateDirection,
      desktopCornerDragArea:
          desktopCornerDragArea ?? this.desktopCornerDragArea,
      mobileCornerDragArea: mobileCornerDragArea ?? this.mobileCornerDragArea,
    );
  }
}
