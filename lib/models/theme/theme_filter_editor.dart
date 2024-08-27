// Flutter imports:
import 'package:flutter/widgets.dart';

// Project imports:
import 'theme_shared_values.dart';

/// The `FilterEditorTheme` class defines the theme for the filter editor in
/// the image editor.
/// It includes properties such as colors for the app bar, background, and
/// preview text.
///
/// Usage:
///
/// ```dart
/// FilterEditorTheme filterEditorTheme = FilterEditorTheme(
///   appBarBackgroundColor: Colors.black,
///   appBarForegroundColor: Colors.white,
///   background: Colors.grey,
///   previewTextColor: Colors.blue,
/// );
/// ```
///
/// Properties:
///
/// - `appBarBackgroundColor`: Background color of the app bar in the filter
///   editor.
///
/// - `appBarForegroundColor`: Foreground color (text and icons) of the app bar.
///
/// - `background`: Background color of the filter editor.
///
/// - `previewTextColor`: Color of the preview text.
///
/// Example Usage:
///
/// ```dart
/// FilterEditorTheme filterEditorTheme = FilterEditorTheme(
///   appBarBackgroundColor: Colors.black,
///   appBarForegroundColor: Colors.white,
///   background: Colors.grey,
///   previewTextColor: Colors.blue,
/// );
///
/// Color appBarBackgroundColor = filterEditorTheme.appBarBackgroundColor;
/// Color background = filterEditorTheme.background;
/// // Access other theme properties...
/// ```
class FilterEditorTheme {
  /// Creates an instance of the `FilterEditorTheme` class with the specified
  /// theme properties.
  const FilterEditorTheme({
    this.appBarBackgroundColor = imageEditorAppBarColor,
    this.appBarForegroundColor = const Color(0xFFE1E1E1),
    this.previewTextColor = const Color(0xFFE1E1E1),
    this.previewSelectedTextColor = const Color.fromARGB(255, 34, 148, 242),
    this.background = imageEditorBackgroundColor,
    this.filterListSpacing = 15,
    this.filterListMargin = const EdgeInsets.fromLTRB(8, 4, 8, 10),
  });

  /// Background color of the app bar in the filter editor.
  final Color appBarBackgroundColor;

  /// Foreground color (text and icons) of the app bar.
  final Color appBarForegroundColor;

  /// Background color of the filter editor.
  final Color background;

  /// Color of the preview text.
  final Color previewTextColor;

  /// Color of the selected preview text.
  final Color previewSelectedTextColor;

  /// The spacing between items in the filter list.
  final double filterListSpacing;

  /// The margin around the filter list.
  final EdgeInsets filterListMargin;

  /// Creates a copy of this `FilterEditorTheme` object with the given fields
  /// replaced with new values.
  ///
  /// The [copyWith] method allows you to create a new instance of
  /// [FilterEditorTheme] with some properties updated while keeping the
  /// others unchanged.
  FilterEditorTheme copyWith({
    Color? appBarBackgroundColor,
    Color? appBarForegroundColor,
    Color? background,
    Color? previewTextColor,
    Color? previewSelectedTextColor,
    double? filterListSpacing,
    EdgeInsets? filterListMargin,
  }) {
    return FilterEditorTheme(
      appBarBackgroundColor:
          appBarBackgroundColor ?? this.appBarBackgroundColor,
      appBarForegroundColor:
          appBarForegroundColor ?? this.appBarForegroundColor,
      background: background ?? this.background,
      previewTextColor: previewTextColor ?? this.previewTextColor,
      previewSelectedTextColor:
          previewSelectedTextColor ?? this.previewSelectedTextColor,
      filterListSpacing: filterListSpacing ?? this.filterListSpacing,
      filterListMargin: filterListMargin ?? this.filterListMargin,
    );
  }
}
