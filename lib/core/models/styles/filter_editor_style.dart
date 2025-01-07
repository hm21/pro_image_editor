// Flutter imports:
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../../constants/editor_style_constants.dart';

/// The `FilterEditorStyle` class defines the style for the filter editor in
/// the image editor.
/// It includes properties such as colors for the app bar, background, and
/// preview text.
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
/// FilterEditorStyle filterEditorStyle = FilterEditorStyle(
///   appBarBackgroundColor: Colors.black,
///   appBarForegroundColor: Colors.white,
///   background: Colors.grey,
///   previewTextColor: Colors.blue,
/// );
///
/// Color appBarBackgroundColor = FilterEditorStyle.appBarBackgroundColor;
/// Color background = FilterEditorStyle.background;
/// // Access other style properties...
/// ```
class FilterEditorStyle {
  /// Creates an instance of the `FilterEditorStyle` class with the specified
  /// style properties.
  const FilterEditorStyle({
    this.appBarBackground = kImageEditorAppBarBackground,
    this.appBarColor = kImageEditorAppBarColor,
    this.previewTextColor = const Color(0xFFE1E1E1),
    this.previewSelectedTextColor = const Color.fromARGB(255, 34, 148, 242),
    this.background = kImageEditorBackground,
    this.filterListSpacing = 15,
    this.filterListMargin = const EdgeInsets.fromLTRB(8, 4, 8, 10),
    this.uiOverlayStyle = kImageEditorUiOverlayStyle,
  });

  /// Background color of the app bar in the filter editor.
  final Color appBarBackground;

  /// Foreground color (text and icons) of the app bar.
  final Color appBarColor;

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

  /// UI overlay style, defining the appearance of system status bars.
  final SystemUiOverlayStyle uiOverlayStyle;

  /// Creates a copy of this `FilterEditorStyle` object with the given fields
  /// replaced with new values.
  ///
  /// The [copyWith] method allows you to create a new instance of
  /// [FilterEditorStyle] with some properties updated while keeping the
  /// others unchanged.
  FilterEditorStyle copyWith({
    Color? appBarBackground,
    Color? appBarColor,
    Color? background,
    Color? previewTextColor,
    Color? previewSelectedTextColor,
    double? filterListSpacing,
    EdgeInsets? filterListMargin,
    SystemUiOverlayStyle? uiOverlayStyle,
  }) {
    return FilterEditorStyle(
      appBarBackground: appBarBackground ?? this.appBarBackground,
      appBarColor: appBarColor ?? this.appBarColor,
      background: background ?? this.background,
      previewTextColor: previewTextColor ?? this.previewTextColor,
      previewSelectedTextColor:
          previewSelectedTextColor ?? this.previewSelectedTextColor,
      filterListSpacing: filterListSpacing ?? this.filterListSpacing,
      filterListMargin: filterListMargin ?? this.filterListMargin,
      uiOverlayStyle: uiOverlayStyle ?? this.uiOverlayStyle,
    );
  }
}
