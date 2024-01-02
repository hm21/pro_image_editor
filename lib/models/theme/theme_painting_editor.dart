import 'package:flutter/widgets.dart';

import 'theme_shared_values.dart';

/// Flutter PaintingEditorTheme Class Documentation
///
/// The `PaintingEditorTheme` class defines the theme for the painting editor in the image editor.
/// It includes properties such as colors for the app bar, background, bottom bar, and more.
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
/// - `appBarBackgroundColor`: Background color of the app bar in the painting editor.
///
/// - `appBarForegroundColor`: Foreground color (text and icons) of the app bar.
///
/// - `background`: Background color of the painting editor.
///
/// - `bottomBarColor`: Background color of the bottom navigation bar.
///
/// - `bottomBarActiveItemColor`: Color of active items in the bottom navigation bar.
///
/// - `bottomBarInactiveItemColor`: Color of inactive items in the bottom navigation bar.
///
/// - `lineWidthBottomSheetColor`: Color of the bottom sheet used to select line width.
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

  /// Creates an instance of the `PaintingEditorTheme` class with the specified theme properties.
  const PaintingEditorTheme({
    this.appBarBackgroundColor = imageEditorAppBarColor,
    this.lineWidthBottomSheetColor = const Color(0xFF252728),
    this.appBarForegroundColor = const Color(0xFFE1E1E1),
    this.background = imageEditorBackgroundColor,
    this.bottomBarColor = imageEditorAppBarColor,
    this.bottomBarActiveItemColor = imageEditorPrimaryColor,
    this.bottomBarInactiveItemColor = const Color(0xFFEEEEEE),
  });
}
