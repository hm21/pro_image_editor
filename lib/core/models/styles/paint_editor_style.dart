// Flutter imports:
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../../constants/editor_style_constants.dart';

/// Flutter PaintEditorStyle Class Documentation
///
/// The `PaintEditorStyle` class defines the styles for the paint editor
/// in the image editor.
/// It includes properties such as colors for the app bar, background, bottom
/// bar, and more.
///
/// Usage:
///
/// ```dart
/// PaintEditorStyle PaintEditorStyle = PaintEditorStyle(
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
/// - `appBarBackgroundColor`: Background color of the app bar in the paint
///    editor.
///
/// - `appBarForegroundColor`: Foreground color (text and icons) of the app bar.
///
/// - `background`: Background color of the paint editor.
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
/// PaintEditorStyle paintEditorStyle = PaintEditorStyle(
///   appBarBackgroundColor: Colors.black,
///   appBarForegroundColor: Colors.white,
///   background: Colors.grey,
///   bottomBarColor: Colors.black,
///   bottomBarActiveItemColor: Colors.blue,
/// );
///
/// Color appBarBackgroundColor = PaintEditorStyle.appBarBackgroundColor;
/// Color background = PaintEditorStyle.background;
/// // Access other style properties...
/// ```
class PaintEditorStyle {
  /// Creates an instance of the `PaintEditorStyle` class with the specified
  /// style properties.
  const PaintEditorStyle({
    this.lineWidthBottomSheetTitle,
    this.opacityBottomSheetTitle,
    this.appBarBackground = kImageEditorAppBarBackground,
    this.appBarColor = kImageEditorAppBarColor,
    this.lineWidthBottomSheetBackground = const Color(0xFF252728),
    this.opacityBottomSheetBackground = const Color(0xFF252728),
    this.background = kImageEditorBackground,
    this.bottomBarBackground = kImageEditorBottomBarBackground,
    this.bottomBarActiveItemColor = kImageEditorPrimaryColor,
    this.bottomBarInactiveItemColor = const Color(0xFFEEEEEE),
    this.initialStrokeWidth = 10.0,
    this.initialOpacity = 1.0,
    this.uiOverlayStyle = kImageEditorUiOverlayStyle,
    this.initialColor = const Color(0xffff0000),
  })  : assert(initialStrokeWidth > 0, 'initialStrokeWidth must be positive'),
        assert(initialOpacity >= 0 && initialOpacity <= 1,
            'initialOpacity must be between 0 and 1');

  /// Background color of the paint editor.
  final Color background;

  /// Background color of the bottom bar.
  final Color bottomBarBackground;

  /// Color of the app bar.
  final Color appBarColor;

  /// Background color of the app bar.
  final Color appBarBackground;

  /// Color of active items in the bottom navigation bar.
  final Color bottomBarActiveItemColor;

  /// Color of inactive items in the bottom navigation bar.
  final Color bottomBarInactiveItemColor;

  /// Color of the bottom sheet used to select line width.
  final Color lineWidthBottomSheetBackground;

  /// Color of the bottom sheet used to change the opacity.
  final Color opacityBottomSheetBackground;

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

  /// UI overlay style, defining the appearance of system status bars.
  final SystemUiOverlayStyle uiOverlayStyle;

  /// Creates a copy of this `PaintEditorStyle` object with the given fields
  /// replaced with new values.
  ///
  /// The [copyWith] method allows you to create a new instance of
  /// [PaintEditorStyle] with some properties updated while keeping the
  /// others unchanged.
  PaintEditorStyle copyWith({
    Color? bottomBarBackground,
    Color? appBarColor,
    Color? appBarBackground,
    Color? background,
    Color? bottomBarActiveItemColor,
    Color? bottomBarInactiveItemColor,
    Color? lineWidthBottomSheetBackground,
    Color? opacityBottomSheetBackground,
    TextStyle? lineWidthBottomSheetTitle,
    TextStyle? opacityBottomSheetTitle,
    double? initialStrokeWidth,
    double? initialOpacity,
    Color? initialColor,
    SystemUiOverlayStyle? uiOverlayStyle,
  }) {
    return PaintEditorStyle(
      background: background ?? this.background,
      bottomBarBackground: bottomBarBackground ?? this.bottomBarBackground,
      appBarColor: appBarColor ?? this.appBarColor,
      appBarBackground: appBarBackground ?? this.appBarBackground,
      bottomBarActiveItemColor:
          bottomBarActiveItemColor ?? this.bottomBarActiveItemColor,
      bottomBarInactiveItemColor:
          bottomBarInactiveItemColor ?? this.bottomBarInactiveItemColor,
      lineWidthBottomSheetBackground:
          lineWidthBottomSheetBackground ?? this.lineWidthBottomSheetBackground,
      opacityBottomSheetBackground:
          opacityBottomSheetBackground ?? this.opacityBottomSheetBackground,
      lineWidthBottomSheetTitle:
          lineWidthBottomSheetTitle ?? this.lineWidthBottomSheetTitle,
      opacityBottomSheetTitle:
          opacityBottomSheetTitle ?? this.opacityBottomSheetTitle,
      initialStrokeWidth: initialStrokeWidth ?? this.initialStrokeWidth,
      initialOpacity: initialOpacity ?? this.initialOpacity,
      initialColor: initialColor ?? this.initialColor,
      uiOverlayStyle: uiOverlayStyle ?? this.uiOverlayStyle,
    );
  }
}
