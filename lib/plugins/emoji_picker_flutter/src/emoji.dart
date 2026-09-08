import 'package:material_ui/material_ui.dart';

/// Delimiter for keywords
const _keywordDelimiter = ' | ';

/// A class to store data for each individual emoji
@immutable
class Emoji {
  /// Emoji constructor
  const Emoji(this.emoji, this.name, {this.hasSkinTone = false});

  /// The unicode string for this emoji
  ///
  /// This is the string that should be displayed to view the emoji
  final String emoji;

  /// The name or description for this emoji
  final String name;

  /// Flag if emoji supports multiple skin tones
  final bool hasSkinTone;

  /// List of keywords that describe the emoji
  List<String> get keywords => name.split(_keywordDelimiter);

  @override
  String toString() {
    return 'Emoji: $emoji, Name: $name, HasSkinTone: $hasSkinTone';
  }

  /// Parse Emoji from json
  static Emoji fromJson(Map<String, dynamic> json) {
    return Emoji(
      json['emoji'] as String,
      json['name'] as String,
      hasSkinTone: json['hasSkinTone'] != null
          ? json['hasSkinTone'] as bool
          : false,
    );
  }

  ///  Encode Emoji to json
  Map<String, dynamic> toJson() {
    return {'emoji': emoji, 'name': name, 'hasSkinTone': hasSkinTone};
  }

  /// Copy method
  Emoji copyWith({String? name, String? emoji, bool? hasSkinTone}) {
    return Emoji(
      emoji ?? this.emoji,
      name ?? this.name,
      hasSkinTone: hasSkinTone ?? this.hasSkinTone,
    );
  }
}
