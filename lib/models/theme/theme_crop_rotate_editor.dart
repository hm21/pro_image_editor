// Flutter imports:
import 'package:flutter/widgets.dart';

// Project imports:
import 'theme_shared_values.dart';

/// The `CropRotateEditorTheme` class defines the theme for the crop and rotate
/// editor in the image editor.
/// It includes properties such as colors for the app bar, background, crop
/// corners, and more.
///
/// Usage:
///
/// ```dart
/// CropRotateEditorTheme cropRotateEditorTheme = CropRotateEditorTheme(
///   appBarBackgroundColor: Colors.black,
///   appBarForegroundColor: Colors.white,
///   background: Colors.grey,
///   cropCornerColor: Colors.blue,
///   cropRectType: InitCropRectType.circle,
/// );
/// ```
///
/// Properties:
///
/// - `appBarBackgroundColor`: Background color of the app bar in the crop and
/// rotate editor.
///
/// - `appBarForegroundColor`: Foreground color (text and icons) of the app bar.
///
/// - `background`: Background color of the crop and rotate editor.
///
/// - `cropCornerColor`: Color of the crop corners.
///
/// - `cropRectType`: Type of the initial crop rectangle
/// (e.g., `InitCropRectType.circle`, `InitCropRectType.imageRect`).
///
/// Example Usage:
///
/// ```dart
/// CropRotateEditorTheme cropRotateEditorTheme = CropRotateEditorTheme(
///   appBarBackgroundColor: Colors.black,
///   appBarForegroundColor: Colors.white,
///   background: Colors.grey,
///   cropCornerColor: Colors.blue,
///   cropRectType: InitCropRectType.circle,
/// );
///
/// Color appBarBackgroundColor = cropRotateEditorTheme.appBarBackgroundColor;
/// Color background = cropRotateEditorTheme.background;
/// // Access other theme properties...
/// ```
class CropRotateEditorTheme {
  /// Creates an instance of the `CropRotateEditorTheme` class with the
  /// specified theme properties.
  const CropRotateEditorTheme({
    this.appBarBackgroundColor = imageEditorAppBarColor,
    this.appBarForegroundColor = const Color(0xFFE1E1E1),
    this.helperLineColor = const Color(0xFF000000),
    this.background = imageEditorBackgroundColor,
    this.cropCornerColor = imageEditorPrimaryColor,
    this.cropOverlayColor = const Color(0xFF000000),
    this.bottomBarBackgroundColor = imageEditorAppBarColor,
    this.bottomBarForegroundColor = const Color(0xFFE1E1E1),
    this.aspectRatioSheetBackgroundColor = const Color(0xFF303030),
    this.aspectRatioSheetForegroundColor = const Color(0xFFFAFAFA),
    this.cropCornerLength = 36,
    this.cropCornerThickness = 6,
  });

  /// Background color of the app bar in the crop and rotate editor.
  final Color appBarBackgroundColor;

  /// Foreground color (text and icons) of the app bar.
  final Color appBarForegroundColor;

  /// Background color of the bottom app bar.
  final Color bottomBarBackgroundColor;

  /// Foreground color (text and icons) of the bottom app bar.
  final Color bottomBarForegroundColor;

  /// Background color of the bottomSheet for aspect ratios.
  final Color aspectRatioSheetBackgroundColor;

  /// Foreground color of the bottomSheet for aspect ratios.
  final Color aspectRatioSheetForegroundColor;

  /// Background color of the crop and rotate editor.
  final Color background;

  /// Color of the crop corners.
  final Color cropCornerColor;

  /// Color from the helper lines when moving the image.
  final Color helperLineColor;

  /// This refers to the overlay area atop the image when the cropping area is
  /// smaller than the image.
  ///
  /// The opacity of this area is 0.7 when no interaction is active and 0.45
  /// when an interaction is active.
  final Color cropOverlayColor;

  /// The length of the crop corner.
  final double cropCornerLength;

  /// The thickness of the crop corner.
  final double cropCornerThickness;

  /// Creates a copy of this `CropRotateEditorTheme` object with the given
  /// fields replaced with new values.
  ///
  /// The [copyWith] method allows you to create a new instance of
  /// [CropRotateEditorTheme] with some properties updated while keeping the
  /// others unchanged.
  CropRotateEditorTheme copyWith({
    Color? appBarBackgroundColor,
    Color? appBarForegroundColor,
    Color? bottomBarBackgroundColor,
    Color? bottomBarForegroundColor,
    Color? aspectRatioSheetBackgroundColor,
    Color? aspectRatioSheetForegroundColor,
    Color? background,
    Color? cropCornerColor,
    Color? helperLineColor,
    Color? cropOverlayColor,
    double? cropCornerLength,
    double? cropCornerThickness,
  }) {
    return CropRotateEditorTheme(
      appBarBackgroundColor:
          appBarBackgroundColor ?? this.appBarBackgroundColor,
      appBarForegroundColor:
          appBarForegroundColor ?? this.appBarForegroundColor,
      bottomBarBackgroundColor:
          bottomBarBackgroundColor ?? this.bottomBarBackgroundColor,
      bottomBarForegroundColor:
          bottomBarForegroundColor ?? this.bottomBarForegroundColor,
      aspectRatioSheetBackgroundColor: aspectRatioSheetBackgroundColor ??
          this.aspectRatioSheetBackgroundColor,
      aspectRatioSheetForegroundColor: aspectRatioSheetForegroundColor ??
          this.aspectRatioSheetForegroundColor,
      background: background ?? this.background,
      cropCornerColor: cropCornerColor ?? this.cropCornerColor,
      helperLineColor: helperLineColor ?? this.helperLineColor,
      cropOverlayColor: cropOverlayColor ?? this.cropOverlayColor,
      cropCornerLength: cropCornerLength ?? this.cropCornerLength,
      cropCornerThickness: cropCornerThickness ?? this.cropCornerThickness,
    );
  }
}
