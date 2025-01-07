// Flutter imports:
import 'package:flutter/services.dart';

import '../../constants/editor_style_constants.dart';

/// A style class for the Tune Editor that allows customization of colors
/// used in the app bar and background.
class TuneEditorStyle {
  /// Creates an instance of [TuneEditorStyle] with customizable color options.
  ///
  /// - [appBarBackground] defines the background color of the app bar in
  /// the tune editor.
  /// - [appBarColor] specifies the color used for text and icons in
  /// the app bar.
  /// - [background] defines the background color of the entire tune editor.
  const TuneEditorStyle({
    this.appBarBackground = kImageEditorAppBarBackground,
    this.appBarColor = kImageEditorAppBarColor,
    this.bottomBarBackground = kImageEditorBottomBarBackground,
    this.bottomBarActiveItemColor = kImageEditorPrimaryColor,
    this.bottomBarInactiveItemColor = kImageEditorBottomBarColor,
    this.background = kImageEditorBackground,
    this.uiOverlayStyle = kImageEditorUiOverlayStyle,
  });

  /// Background color of the app bar in the tune editor.
  final Color appBarBackground;

  /// Foreground color (text and icons) of the app bar.
  final Color appBarColor;

  /// Background color of the tune editor.
  final Color background;

  /// Background color of the bottom navigation bar.
  final Color bottomBarBackground;

  /// Color of active items in the bottom navigation bar.
  final Color bottomBarActiveItemColor;

  /// Color of inactive items in the bottom navigation bar.
  final Color bottomBarInactiveItemColor;

  /// UI overlay style, defining the appearance of system status bars.
  final SystemUiOverlayStyle uiOverlayStyle;

  /// Creates a copy of this [TuneEditorStyle] object with the given fields
  /// replaced with new values.
  ///
  /// The [copyWith] method allows you to create a new instance of
  /// [TuneEditorStyle] with some properties updated while keeping the
  /// others unchanged.
  ///
  /// - [appBarBackground] updates the background color of the app bar.
  /// - [appBarColor] updates the color of the text and icons in the
  /// app bar.
  /// - [background] updates the background color of the tune editor.
  TuneEditorStyle copyWith({
    Color? appBarBackground,
    Color? appBarColor,
    Color? background,
    Color? bottomBarBackground,
    Color? bottomBarActiveItemColor,
    Color? bottomBarInactiveItemColor,
    SystemUiOverlayStyle? uiOverlayStyle,
  }) {
    return TuneEditorStyle(
      appBarBackground: appBarBackground ?? this.appBarBackground,
      appBarColor: appBarColor ?? this.appBarColor,
      background: background ?? this.background,
      bottomBarBackground: bottomBarBackground ?? this.bottomBarBackground,
      bottomBarActiveItemColor:
          bottomBarActiveItemColor ?? this.bottomBarActiveItemColor,
      bottomBarInactiveItemColor:
          bottomBarInactiveItemColor ?? this.bottomBarInactiveItemColor,
      uiOverlayStyle: uiOverlayStyle ?? this.uiOverlayStyle,
    );
  }
}
