import 'package:material_ui/material_ui.dart';

/// Emoji text style providing commonly available fallback fonts
// ignore: constant_identifier_names
const DefaultEmojiTextStyle = TextStyle(
  inherit: true,
  // Commonly available fallback fonts.
  fontFamilyFallback: [
    // iOS and MacOs.
    'Apple Color Emoji',
    // Android, ChromeOS, Ubuntu and some other Linux distros.
    'Noto Color Emoji',
    // Windows.
    'Segoe UI Emoji',
  ],
);
