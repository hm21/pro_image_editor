// Flutter imports:
import 'package:flutter/services.dart';

import '../../constants/editor_style_constants.dart';

/// Defines the visual styles and colors used in the audio editor UI.
class AudioEditorStyle {
  /// Creates a new set of [AudioEditorStyle] values.
  const AudioEditorStyle({
    this.appBarBackground = kImageEditorAppBarBackground,
    this.appBarColor = kImageEditorAppBarColor,
    this.uiOverlayStyle = kImageEditorUiOverlayStyle,
    this.background = const Color(0x00000000),
    this.audioTrackImageBackground = const Color(0xFF9E9E9E),
    this.selectedTrackColor = const Color(0xFF2196F3),
    this.selectedTrackBackground = const Color(0x00000000),
  });

  /// Color of the app bar.
  final Color appBarColor;

  /// Background color of the app bar.
  final Color appBarBackground;

  /// Background color of the audio editor.
  final Color background;

  /// Background color used behind audio track images.
  final Color audioTrackImageBackground;

  /// Color used to highlight the selected audio track.
  final Color selectedTrackColor;

  /// Background color of the selected track.
  final Color selectedTrackBackground;

  /// Defines the system UI overlay style (e.g., status bar icons and color).
  final SystemUiOverlayStyle uiOverlayStyle;

  /// Creates a copy of this instance with the given parameters overridden.
  AudioEditorStyle copyWith({
    Color? appBarColor,
    Color? appBarBackground,
    Color? background,
    Color? audioTrackImageBackground,
    Color? selectedTrackColor,
    Color? selectedTrackBackground,
    SystemUiOverlayStyle? uiOverlayStyle,
  }) {
    return AudioEditorStyle(
      appBarColor: appBarColor ?? this.appBarColor,
      appBarBackground: appBarBackground ?? this.appBarBackground,
      background: background ?? this.background,
      audioTrackImageBackground:
          audioTrackImageBackground ?? this.audioTrackImageBackground,
      selectedTrackColor: selectedTrackColor ?? this.selectedTrackColor,
      selectedTrackBackground:
          selectedTrackBackground ?? this.selectedTrackBackground,
      uiOverlayStyle: uiOverlayStyle ?? this.uiOverlayStyle,
    );
  }
}
