import 'package:material_ui/material_ui.dart';

import '/plugins/emoji_picker_flutter/emoji_picker_flutter.dart';

/// Callback function for custom search view
typedef SearchViewBuilder =
    Widget Function(
      Config config,
      EmojiViewState state,
      VoidCallback showEmojiView,
    );

/// Search view Config
class SearchViewConfig {
  /// Constructor
  const SearchViewConfig({
    this.backgroundColor = const Color(0xFFEBEFF2),
    this.buttonIconColor = Colors.black26,
    this.inputTextStyle,
    this.hintText = 'Search',
    this.hintTextStyle,
    this.customSearchView,
  });

  /// Background color of search bar
  final Color backgroundColor;

  /// Icon color of hide search view button
  final Color buttonIconColor;

  /// Inpit text style
  final TextStyle? inputTextStyle;

  /// Custom hint text
  final String? hintText;

  /// Custom hint text style
  final TextStyle? hintTextStyle;

  /// Custom search bar
  /// Hot reload is not supported
  final SearchViewBuilder? customSearchView;

  @override
  bool operator ==(other) {
    return (other is SearchViewConfig) &&
        other.backgroundColor == backgroundColor &&
        other.buttonIconColor == buttonIconColor &&
        other.hintText == hintText &&
        other.hintTextStyle == hintTextStyle &&
        other.inputTextStyle == inputTextStyle;
  }

  @override
  int get hashCode =>
      backgroundColor.hashCode ^
      buttonIconColor.hashCode ^
      hintText.hashCode ^
      hintTextStyle.hashCode ^
      inputTextStyle.hashCode;
}
