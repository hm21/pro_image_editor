// ignore_for_file: constant_identifier_names

import 'dart:math';

import 'package:material_ui/material_ui.dart';

import '/plugins/emoji_picker_flutter/emoji_picker_flutter.dart';

/// Callback function for custom view
typedef EmojiViewBuilder =
    Widget Function(
      Config config,
      EmojiViewState state,
      VoidCallback showSearchBar,
    );

/// Default Widget if no recent is available
const DefaultNoRecentsWidget = Text(
  'No Recents',
  style: TextStyle(fontSize: 20, color: Colors.black26),
  textAlign: TextAlign.center,
);

/// Emoji View Config
class EmojiViewConfig {
  /// Constructor
  const EmojiViewConfig({
    this.columns = 10,
    this.emojiSizeMax = 28.0,
    this.backgroundColor = const Color(0xFFEBEFF2),
    this.verticalSpacing = 0,
    this.horizontalSpacing = 0,
    this.gridPadding = EdgeInsets.zero,
    this.recentsLimit = 28,
    this.replaceEmojiOnLimitExceed = false,
    this.noRecents = DefaultNoRecentsWidget,
    this.loadingIndicator = const SizedBox.shrink(),
    this.buttonMode = ButtonMode.MATERIAL,
  });

  /// Number of emojis per row
  final int columns;

  /// Width and height the emoji will be maximal displayed
  /// Can be smaller due to screen size and amount of columns
  final double emojiSizeMax;

  /// The background color of the emoji view
  final Color backgroundColor;

  /// Verical spacing between emojis
  final double verticalSpacing;

  /// Horizontal spacing between emojis
  final double horizontalSpacing;

  /// Limit of recently used emoji that will be saved
  final int recentsLimit;

  /// A widget (usually [Text]) to be displayed if no recent emojis to display
  /// Hot reload is not supported
  final Widget noRecents;

  /// A widget to display while emoji picker is initializing
  /// Hot reload is not supported
  final Widget loadingIndicator;

  /// Choose visual response for tapping on an emoji cell
  final ButtonMode buttonMode;

  /// The padding of GridView, default is [EdgeInsets.zero]
  final EdgeInsets gridPadding;

  /// Replace latest emoji on recents list on limit exceed
  final bool replaceEmojiOnLimitExceed;

  /// Get Emoji size based on properties and screen width
  double getEmojiSize(double width) {
    final maxSize = width / columns;
    return min(maxSize, emojiSizeMax);
  }

  /// Get Emoji hitbox size based on properties and screen width
  double getEmojiBoxSize(double width) {
    return width / columns;
  }

  @override
  bool operator ==(other) {
    return (other is EmojiViewConfig) &&
        other.columns == columns &&
        other.emojiSizeMax == emojiSizeMax &&
        other.backgroundColor == backgroundColor &&
        other.verticalSpacing == verticalSpacing &&
        other.horizontalSpacing == horizontalSpacing &&
        other.recentsLimit == recentsLimit &&
        other.buttonMode == buttonMode &&
        other.gridPadding == gridPadding &&
        other.replaceEmojiOnLimitExceed == replaceEmojiOnLimitExceed;
  }

  @override
  int get hashCode =>
      columns.hashCode ^
      emojiSizeMax.hashCode ^
      backgroundColor.hashCode ^
      verticalSpacing.hashCode ^
      horizontalSpacing.hashCode ^
      recentsLimit.hashCode ^
      buttonMode.hashCode ^
      gridPadding.hashCode ^
      replaceEmojiOnLimitExceed.hashCode;
}
