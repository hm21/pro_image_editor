// ignore_for_file: constant_identifier_names

import 'dart:math';

import 'package:material_ui/material_ui.dart';

import '/plugins/emoji_picker_flutter/emoji_picker_flutter.dart';
import '/plugins/emoji_picker_flutter/src/emoji_picker_internal_utils.dart';

/// Emoji Regex
/// Keycap Sequence '((\u0023|\u002a|[\u0030-\u0039])\ufe0f\u20e3){1}'
/// Issue: https://github.com/flutter/flutter/issues/36062
const EmojiRegex =
    r'((\u0023|\u002a|[\u0030-\u0039])\ufe0f\u20e3){1}|\p{Emoji}|\u200D|\uFE0F';

/// Helper class that provides extended usage
class EmojiPickerUtils {
  /// Singleton Constructor
  factory EmojiPickerUtils() {
    return _singleton;
  }

  EmojiPickerUtils._internal();

  static final EmojiPickerUtils _singleton = EmojiPickerUtils._internal();
  final List<Emoji> _allAvailableEmojiEntities = [];
  RegExp? _emojiRegExp;

  /// Returns list of recently used emoji from cache
  Future<List<RecentEmoji>> getRecentEmojis() async {
    return EmojiPickerInternalUtils().getRecentEmojis();
  }

  /// Filters out emojis not supported on the platform
  Future<List<CategoryEmoji>> filterUnsupported(List<CategoryEmoji> data) =>
      EmojiPickerInternalUtils().filterUnsupported(data);

  /// Search for related emoticons based on keywords
  Future<List<Emoji>> searchEmoji(
    String search,
    List<CategoryEmoji> emojiSet, {
    bool checkPlatformCompatibility = true,
  }) async {
    if (search.isEmpty) return [];

    if (_allAvailableEmojiEntities.isEmpty) {
      final emojiPickerInternalUtils = EmojiPickerInternalUtils();

      final data = [...emojiSet]
        ..removeWhere((e) => e.category == Category.RECENT);
      final availableCategoryEmoji = checkPlatformCompatibility
          ? await emojiPickerInternalUtils.filterUnsupported(data)
          : data;

      // Set all the emoji entities
      for (var emojis in availableCategoryEmoji) {
        _allAvailableEmojiEntities.addAll(emojis.emoji);
      }
    }

    // Split the input string into a list of lowercase keywords
    final keywordSet = search
        .split(RegExp(r'\s+'))
        .where((e) => e.isNotEmpty)
        .map((e) => e.toLowerCase())
        .toSet();

    if (keywordSet.isEmpty) return [];

    return _allAvailableEmojiEntities.where((emoji) {
      // Perform lowercasing of emoji keywords once
      final emojiKeywordSet = emoji.keywords
          .map((e) => e.toLowerCase())
          .toSet();

      // Check if first keyword is a prefix of any emoji keyword
      final matchFirstKeyword = emojiKeywordSet.any(
        (emojiKeyword) => emojiKeyword.startsWith(keywordSet.first),
      );

      var matchKeywords = false;
      if (matchFirstKeyword) {
        // Check if each search keyword is a prefix of any emoji keyword
        // start from second keyword, returns true if empty (only 1 keyword)
        matchKeywords = keywordSet.skip(1).every((keyword) {
          return emojiKeywordSet.any(
            (emojiKeyword) => emojiKeyword.startsWith(keyword),
          );
        });
      } else {
        matchKeywords = false;
      }

      // Check for an exact match with emoji character
      final matchEmoji = emoji.emoji == search.trim();

      return matchKeywords || matchEmoji;
    }).toList();
  }

  /// Add an emoji to recently used list or increase its counter
  Future<void> addEmojiToRecentlyUsed({
    required GlobalKey<EmojiPickerState> key,
    required Emoji emoji,
    Config config = const Config(),
  }) async {
    return EmojiPickerInternalUtils()
        .addEmojiToRecentlyUsed(emoji: emoji, config: config)
        .then(
          (recentEmojiList) =>
              key.currentState?.updateRecentEmoji(recentEmojiList),
        );
  }

  /// Produce a list of spans to adjust style for emoji characters.
  /// Spans enclosing emojis will have [parentStyle] combined with [emojiStyle].
  /// Other spans will not have an explicit style (this method does not set
  /// [parentStyle] to the whole text.
  List<InlineSpan> setEmojiTextStyle(
    String text, {
    required TextStyle emojiStyle,
    TextStyle? parentStyle,
  }) {
    final composedEmojiStyle = (parentStyle ?? const TextStyle())
        .merge(DefaultEmojiTextStyle)
        .merge(emojiStyle);

    final spans = <TextSpan>[];
    final matches = getEmojiRegex().allMatches(text).toList();
    var cursor = 0;
    for (final match in matches) {
      if (cursor != match.start) {
        // Non emoji text + following emoji
        spans
          ..add(
            TextSpan(
              text: text.substring(cursor, match.start),
              style: parentStyle,
            ),
          )
          ..add(
            TextSpan(
              text: text.substring(match.start, match.end),
              style: composedEmojiStyle,
            ),
          );
      } else {
        if (spans.isEmpty) {
          // Create new span if no previous emoji TextSpan exists
          spans.add(
            TextSpan(
              text: text.substring(match.start, match.end),
              style: composedEmojiStyle,
            ),
          );
        } else {
          // Update last span if current text is still emoji
          final lastIndex = spans.length - 1;
          final lastText = spans[lastIndex].text ?? '';
          final currentText = text.substring(match.start, match.end);
          spans[lastIndex] = TextSpan(
            text: '$lastText$currentText',
            style: composedEmojiStyle,
          );
        }
      }
      // Update cursor
      cursor = match.end;
    }
    // Add remaining text
    if (cursor != text.length) {
      spans.add(
        TextSpan(text: text.substring(cursor, text.length), style: parentStyle),
      );
    }
    return spans;
  }

  /// Applies skin tone to given emoji
  Emoji applySkinTone(Emoji emoji, String color) {
    final codeUnits = emoji.emoji.codeUnits;
    var result = List<int>.empty(growable: true)
      // Basic emoji without gender (until char 2)
      ..addAll(codeUnits.sublist(0, min(codeUnits.length, 2)))
      // Skin tone
      ..addAll(color.codeUnits);
    // add the rest of the emoji (gender, etc.) again
    if (codeUnits.length >= 2) {
      result.addAll(codeUnits.sublist(2));
    }
    return emoji.copyWith(emoji: String.fromCharCodes(result));
  }

  /// Clears the list of recent emojis
  Future<void> clearRecentEmojis({
    required GlobalKey<EmojiPickerState> key,
  }) async {
    return await EmojiPickerInternalUtils()
        .clearRecentEmojisInLocalStorage()
        .then((_) => key.currentState?.updateRecentEmoji([], refresh: true));
  }

  /// Returns the emoji regex
  /// Based on https://unicode.org/reports/tr51/
  RegExp getEmojiRegex() {
    return _emojiRegExp ?? RegExp(EmojiRegex, unicode: true);
  }
}
