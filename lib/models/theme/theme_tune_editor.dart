// Flutter imports:
import 'package:flutter/widgets.dart';

// Project imports:
import 'theme_shared_values.dart';

/// A theme class for the Tune Editor that allows customization of colors
/// used in the app bar and background.
class TuneEditorTheme {
  /// Creates an instance of [TuneEditorTheme] with customizable color options.
  ///
  /// - [appBarBackgroundColor] defines the background color of the app bar in
  /// the tune editor.
  /// - [appBarForegroundColor] specifies the color used for text and icons in
  /// the app bar.
  /// - [background] defines the background color of the entire tune editor.
  const TuneEditorTheme({
    this.appBarBackgroundColor = imageEditorAppBarColor,
    this.appBarForegroundColor = const Color(0xFFE1E1E1),
    this.bottomBarColor = imageEditorAppBarColor,
    this.bottomBarActiveItemColor = imageEditorPrimaryColor,
    this.bottomBarInactiveItemColor = const Color(0xFFEEEEEE),
    this.background = imageEditorBackgroundColor,
  });

  /// Background color of the app bar in the tune editor.
  final Color appBarBackgroundColor;

  /// Foreground color (text and icons) of the app bar.
  final Color appBarForegroundColor;

  /// Background color of the tune editor.
  final Color background;

  /// Background color of the bottom navigation bar.
  final Color bottomBarColor;

  /// Color of active items in the bottom navigation bar.
  final Color bottomBarActiveItemColor;

  /// Color of inactive items in the bottom navigation bar.
  final Color bottomBarInactiveItemColor;

  /// Creates a copy of this [TuneEditorTheme] object with the given fields
  /// replaced with new values.
  ///
  /// The [copyWith] method allows you to create a new instance of
  /// [TuneEditorTheme] with some properties updated while keeping the
  /// others unchanged.
  ///
  /// - [appBarBackgroundColor] updates the background color of the app bar.
  /// - [appBarForegroundColor] updates the color of the text and icons in the
  /// app bar.
  /// - [background] updates the background color of the tune editor.
  TuneEditorTheme copyWith({
    Color? appBarBackgroundColor,
    Color? appBarForegroundColor,
    Color? background,
    Color? bottomBarColor,
    Color? bottomBarActiveItemColor,
    Color? bottomBarInactiveItemColor,
  }) {
    return TuneEditorTheme(
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
    );
  }
}
