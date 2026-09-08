import 'package:material_ui/material_ui.dart';

import '/plugins/emoji_picker_flutter/emoji_picker_flutter.dart';

/// Default method for locale selection
List<CategoryEmoji> getDefaultEmojiLocale(Locale locale) {
  switch (locale.languageCode) {
    case 'de':
      return emojiSetGerman;
    case 'en':
      return emojiSetEnglish;
    case 'es':
      return emojiSetSpanish;
    case 'fr':
      return emojiSetFrance;
    case 'hi':
      return emojiSetHindi;
    case 'it':
      return emojiSetItalian;
    case 'ja':
      return emojiSetJapanese;
    case 'pt':
      return emojiSetPortuguese;
    case 'ru':
      return emojiSetRussian;
    case 'zh':
      return emojiSetChinese;
    default:
      return emojiSetEnglish;
  }
}
