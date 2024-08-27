// Flutter imports:
import 'package:flutter/widgets.dart';

// Project imports:
import 'theme_shared_values.dart';

/// Flutter PaintingEditorTheme Class Documentation
///
/// The `PaintingEditorTheme` class defines the theme for the painting editor
/// in the image editor.
/// It includes properties such as colors for the app bar, background, bottom
/// bar, and more.
///
/// Usage:
///
/// ```dart
/// PaintingEditorTheme paintingEditorTheme = PaintingEditorTheme(
///   appBarBackgroundColor: Colors.black,
///   appBarForegroundColor: Colors.white,
///   background: Colors.grey,
///   bottomBarColor: Colors.black,
///   bottomBarActiveItemColor: Colors.blue,
/// );
/// ```
///
/// Properties:
///
/// - `appBarBackgroundColor`: Background color of the app bar in the painting
///    editor.
///
/// - `appBarForegroundColor`: Foreground color (text and icons) of the app bar.
///
/// - `background`: Background color of the painting editor.
///
/// - `bottomBarColor`: Background color of the bottom navigation bar.
///
/// - `bottomBarActiveItemColor`: Color of active items in the bottom
///   navigation bar.
///
/// - `bottomBarInactiveItemColor`: Color of inactive items in the bottom
///   navigation bar.
///
/// - `lineWidthBottomSheetColor`: Color of the bottom sheet used to select
///   line width.
///
/// Example Usage:
///
/// ```dart
/// PaintingEditorTheme paintingEditorTheme = PaintingEditorTheme(
///   appBarBackgroundColor: Colors.black,
///   appBarForegroundColor: Colors.white,
///   background: Colors.grey,
///   bottomBarColor: Colors.black,
///   bottomBarActiveItemColor: Colors.blue,
/// );
///
/// Color appBarBackgroundColor = paintingEditorTheme.appBarBackgroundColor;
/// Color background = paintingEditorTheme.background;
/// // Access other theme properties...
/// ```
class PaintingEditorTheme {
  /// Creates an instance of the `PaintingEditorTheme` class with the specified
  /// theme properties.
  const PaintingEditorTheme({
    this.lineWidthBottomSheetTitle,
    this.opacityBottomSheetTitle,
    this.appBarBackgroundColor = imageEditorAppBarColor,
    this.lineWidthBottomSheetColor = const Color(0xFF252728),
    this.opacityBottomSheetColor = const Color(0xFF252728),
    this.appBarForegroundColor = const Color(0xFFE1E1E1),
    this.background = imageEditorBackgroundColor,
    this.bottomBarColor = imageEditorAppBarColor,
    this.bottomBarActiveItemColor = imageEditorPrimaryColor,
    this.bottomBarInactiveItemColor = const Color(0xFFEEEEEE),
    this.initialStrokeWidth = 10.0,
    this.initialOpacity = 1.0,
    this.initialColor = const Color(0xffff0000),
  })  : assert(initialStrokeWidth > 0, 'initialStrokeWidth must be positive'),
        assert(initialOpacity >= 0 && initialOpacity <= 1,
            'initialOpacity must be between 0 and 1');

  /// Background color of the app bar in the painting editor.
  final Color appBarBackgroundColor;

  /// Foreground color (text and icons) of the app bar.
  final Color appBarForegroundColor;

  /// Background color of the painting editor.
  final Color background;

  /// Background color of the bottom navigation bar.
  final Color bottomBarColor;

  /// Color of active items in the bottom navigation bar.
  final Color bottomBarActiveItemColor;

  /// Color of inactive items in the bottom navigation bar.
  final Color bottomBarInactiveItemColor;

  /// Color of the bottom sheet used to select line width.
  final Color lineWidthBottomSheetColor;

  /// Color of the bottom sheet used to change the opacity.
  final Color opacityBottomSheetColor;

  /// Title of the bottom sheet used to select line width.
  final TextStyle? lineWidthBottomSheetTitle;

  /// Title of the bottom sheet used to change the opacity.
  final TextStyle? opacityBottomSheetTitle;

  /// Indicates the initial stroke width.
  final double initialStrokeWidth;

  /// Indicates the initial opacity level.
  final double initialOpacity;

  /// Indicates the initial drawing color.
  final Color initialColor;

  /// Creates a copy of this `PaintingEditorTheme` object with the given fields
  /// replaced with new values.
  ///
  /// The [copyWith] method allows you to create a new instance of
  /// [PaintingEditorTheme] with some properties updated while keeping the
  /// others unchanged.
  PaintingEditorTheme copyWith({
    Color? appBarBackgroundColor,
    Color? appBarForegroundColor,
    Color? background,
    Color? bottomBarColor,
    Color? bottomBarActiveItemColor,
    Color? bottomBarInactiveItemColor,
    Color? lineWidthBottomSheetColor,
    Color? opacityBottomSheetColor,
    TextStyle? lineWidthBottomSheetTitle,
    TextStyle? opacityBottomSheetTitle,
    double? initialStrokeWidth,
    double? initialOpacity,
    Color? initialColor,
  }) {
    return PaintingEditorTheme(
      appBarBackgroundColor:
          appBarBackgroundColor ?? this.appBarBackgroundColor,
      appBarForegroundColor:
          appBarForegroundColor ?? this.appBarForegroundColor,
      background: background ?? this.background,
      bottomBarColor: bottomBarColor ?? this.bottomBarColor,
      bottomBarActiveItemColor:
          bottomBarActiveItemColor ?? this.bottomBarActiveItemColor,
      bottomBarInactiveItemColor:
          bottomBarInactiveItemColor ?? this.bottomBarInactiveItemColor,
      lineWidthBottomSheetColor:
          lineWidthBottomSheetColor ?? this.lineWidthBottomSheetColor,
      opacityBottomSheetColor:
          opacityBottomSheetColor ?? this.opacityBottomSheetColor,
      lineWidthBottomSheetTitle:
          lineWidthBottomSheetTitle ?? this.lineWidthBottomSheetTitle,
      opacityBottomSheetTitle:
          opacityBottomSheetTitle ?? this.opacityBottomSheetTitle,
      initialStrokeWidth: initialStrokeWidth ?? this.initialStrokeWidth,
      initialOpacity: initialOpacity ?? this.initialOpacity,
      initialColor: initialColor ?? this.initialColor,
    );
  }
}
