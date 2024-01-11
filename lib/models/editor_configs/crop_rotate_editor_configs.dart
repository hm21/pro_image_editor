import '../../modules/crop_rotate_editor/utils/crop_aspect_ratios.dart';

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
  /// Indicates whether the editor is enabled.
  final bool enabled;

  /// Indicating whether the image can be rotated.
  final bool canRotate;

  /// Indicating whether the image can be flipped.
  final bool canFlip;

  /// Indicating whether the aspect ratio of the image can be changed.
  final bool canChangeAspectRatio;

  /// The initial aspect ratio for cropping.
  ///
  /// This value determines the aspect ratio when cropping is enabled and
  /// aspect ratio locking is enabled. By default, it uses the
  /// `CropAspectRatios.custom` value.
  final double? initAspectRatio;

  /// Creates an instance of CropRotateEditorConfigs with optional settings.
  ///
  /// By default, all options are enabled, and the initial aspect ratio is set
  /// to `CropAspectRatios.custom`.
  const CropRotateEditorConfigs({
    this.enabled = true,
    this.canRotate = true,
    this.canFlip = true,
    this.canChangeAspectRatio = true,
    this.initAspectRatio = CropAspectRatios.custom,
  });
}
