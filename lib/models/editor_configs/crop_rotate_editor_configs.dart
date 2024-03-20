import '../aspect_ratio_item.dart';

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

  /// Indicating whether the aspect ratio of the image can be changed.
  final bool canChangeAspectRatio;

  /// The initial aspect ratio for cropping.
  ///
  /// For free aspect ratio use `null` and for original aspect ratio use `0.0`.
  final double? initAspectRatio;

  /// The allowed aspect ratios for cropping.
  ///
  /// For free aspect ratio use `null` and for original aspect ratio use `0.0`.
  final List<AspectRatioItem> aspectRatios;

  /// Creates an instance of CropRotateEditorConfigs with optional settings.
  ///
  /// By default, all options are enabled, and the initial aspect ratio is set
  /// to `CropAspectRatios.custom`.
  const CropRotateEditorConfigs({
    this.enabled = true,
    this.canRotate = true,
    this.canChangeAspectRatio = true,
    this.initAspectRatio,
    this.aspectRatios = const [
      AspectRatioItem(text: 'Free', value: null),
      AspectRatioItem(text: 'Original', value: 0.0),
      AspectRatioItem(text: '1*1', value: 1.0 / 1.0),
      AspectRatioItem(text: '4*3', value: 4.0 / 3.0),
      AspectRatioItem(text: '3*4', value: 3.0 / 4.0),
      AspectRatioItem(text: '16*9', value: 16.0 / 9.0),
      AspectRatioItem(text: '9*16', value: 9.0 / 16.0)
    ],
  });
}
