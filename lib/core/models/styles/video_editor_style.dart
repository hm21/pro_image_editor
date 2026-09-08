import 'package:flutter/widgets.dart';
import 'package:material_ui/material_ui.dart';

/// Defines style configurations for the video editor.
class VideoEditorStyle {
  /// Creates an instance of [VideoEditorStyle].
  ///
  /// Allows customization of colors, text styles, and dimensions for various
  /// video editor UI elements such as play indicators, mute buttons,
  /// trim bar, and banners.
  const VideoEditorStyle({
    this.toolbarPadding = const EdgeInsets.symmetric(horizontal: 16),
    this.playIndicatorColor = const Color(0xFFFFFFFF),
    this.playIndicatorBackground = const Color.fromARGB(128, 0, 0, 0),
    this.muteButtonColor = const Color(0xFFFFFFFF),
    this.muteButtonBackground = const Color.fromARGB(120, 0, 0, 0),
    this.infoBannerTextStyle,
    this.infoBannerTextColor = const Color(0xFFFFFFFF),
    this.infoBannerBackground = const Color.fromARGB(120, 0, 0, 0),
    this.trimDurationTextStyle,
    this.trimDurationTextColor = const Color(0xFFFFFFFF),
    this.trimDurationBackground = const Color.fromARGB(120, 0, 0, 0),
    this.trimBarTextColor = const Color(0xFFFFFFFF),
    this.trimBarTextBackground = const Color.fromARGB(120, 0, 0, 0),
    this.trimBarColor = const Color(0xFFFFFFFF),
    this.trimBarBackground = const Color(0xFFFFFFFF),
    this.trimBarOutsideAreaBackground = const Color.fromARGB(120, 0, 0, 0),
    this.trimBarPlayTimeIndicatorColor = const Color(0xFFFFFFFF),
    this.trimBarPlayTimeIndicatorWidth = 1,
    this.trimBarHandlerButtonSize = 12,
    this.trimBarHeight = 50,
    this.trimBarHandlerWidth = 24,
    this.trimBarHandlerRadius = 0,
    this.trimBarBorderWidth = 1,
    this.trimBarGradientBackground = const LinearGradient(
      colors: [
        Color(0xFF1E1E1E), // Dark gray
        Color(0xFF292929), // Slightly lighter gray
        Color(0xFF121212), // Near black
      ],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    this.trimBarSkeletonColors = const [
      Color(0xFF212121),
      Color(0xFF616161),
      Color(0xFF212121),
    ],
  });

  /// The Padding around the toolbar.
  final EdgeInsets toolbarPadding;

  /// Color of the play indicator icon.
  final Color playIndicatorColor;

  /// Background color of the play indicator.
  final Color playIndicatorBackground;

  /// Color of the mute button icon.
  final Color muteButtonColor;

  /// Background color of the mute button.
  final Color muteButtonBackground;

  /// Text style for the info banner.
  final TextStyle? infoBannerTextStyle;

  /// Text color of the info banner.
  final Color infoBannerTextColor;

  /// Background color of the info banner.
  final Color infoBannerBackground;

  /// Text style for the trim duration display.
  final TextStyle? trimDurationTextStyle;

  /// Text color of the trim duration display.
  final Color trimDurationTextColor;

  /// Background color of the trim duration display.
  final Color trimDurationBackground;

  /// Text color of the trim bar.
  final Color trimBarTextColor;

  /// Background color of the trim bar text.
  final Color trimBarTextBackground;

  /// Color of the trim bar.
  final Color trimBarColor;

  /// Background color of the trim bar.
  final Color trimBarBackground;

  /// The gradient will only be visible if no thumbnails are added.
  /// For the best user experience, it is recommended to add multiple
  /// thumbnails from different timestamps.
  final Gradient trimBarGradientBackground;

  /// A list of [Color]s used to style the skeleton (background or placeholder)
  /// appearance of the trim bar in the video editor UI.
  ///
  /// This can be used to create gradients or multi-colored effects for the
  /// trim bar when the actual content is loading or as a decorative element.
  final List<Color> trimBarSkeletonColors;

  /// Background color of the area outside the trim bar.
  final Color trimBarOutsideAreaBackground;

  /// Height of the trim bar.
  final double trimBarHeight;

  /// Border width of the trim bar.
  final double trimBarBorderWidth;

  /// Color of the play time indicator on the trim bar.
  final Color trimBarPlayTimeIndicatorColor;

  /// Width of the play time indicator on the trim bar.
  final double trimBarPlayTimeIndicatorWidth;

  /// Width of the trim bar handler.
  final double trimBarHandlerWidth;

  /// Button size of the trim bar handler.
  final double trimBarHandlerButtonSize;

  /// Radius of the trim bar handler.
  final double trimBarHandlerRadius;

  /// Creates a copy of this instance with the given parameters overridden.
  VideoEditorStyle copyWith({
    EdgeInsets? toolbarPadding,
    Color? playIndicatorColor,
    Color? playIndicatorBackground,
    Color? muteButtonColor,
    Color? muteButtonBackground,
    TextStyle? infoBannerTextStyle,
    Color? infoBannerTextColor,
    Color? infoBannerBackground,
    TextStyle? trimDurationTextStyle,
    Color? trimDurationTextColor,
    Color? trimDurationBackground,
    Color? trimBarTextColor,
    Color? trimBarTextBackground,
    Color? trimBarColor,
    Color? trimBarBackground,
    Gradient? trimBarGradientBackground,
    List<Color>? trimBarSkeletonColors,
    Color? trimBarOutsideAreaBackground,
    double? trimBarHeight,
    double? trimBarBorderWidth,
    Color? trimBarPlayTimeIndicatorColor,
    double? trimBarPlayTimeIndicatorWidth,
    double? trimBarHandlerWidth,
    double? trimBarHandlerButtonSize,
    double? trimBarHandlerRadius,
  }) {
    return VideoEditorStyle(
      toolbarPadding: toolbarPadding ?? this.toolbarPadding,
      playIndicatorColor: playIndicatorColor ?? this.playIndicatorColor,
      playIndicatorBackground:
          playIndicatorBackground ?? this.playIndicatorBackground,
      muteButtonColor: muteButtonColor ?? this.muteButtonColor,
      muteButtonBackground: muteButtonBackground ?? this.muteButtonBackground,
      infoBannerTextStyle: infoBannerTextStyle ?? this.infoBannerTextStyle,
      infoBannerTextColor: infoBannerTextColor ?? this.infoBannerTextColor,
      infoBannerBackground: infoBannerBackground ?? this.infoBannerBackground,
      trimDurationTextStyle:
          trimDurationTextStyle ?? this.trimDurationTextStyle,
      trimDurationTextColor:
          trimDurationTextColor ?? this.trimDurationTextColor,
      trimDurationBackground:
          trimDurationBackground ?? this.trimDurationBackground,
      trimBarTextColor: trimBarTextColor ?? this.trimBarTextColor,
      trimBarTextBackground:
          trimBarTextBackground ?? this.trimBarTextBackground,
      trimBarColor: trimBarColor ?? this.trimBarColor,
      trimBarBackground: trimBarBackground ?? this.trimBarBackground,
      trimBarGradientBackground:
          trimBarGradientBackground ?? this.trimBarGradientBackground,
      trimBarSkeletonColors:
          trimBarSkeletonColors ?? this.trimBarSkeletonColors,
      trimBarOutsideAreaBackground:
          trimBarOutsideAreaBackground ?? this.trimBarOutsideAreaBackground,
      trimBarHeight: trimBarHeight ?? this.trimBarHeight,
      trimBarBorderWidth: trimBarBorderWidth ?? this.trimBarBorderWidth,
      trimBarPlayTimeIndicatorColor:
          trimBarPlayTimeIndicatorColor ?? this.trimBarPlayTimeIndicatorColor,
      trimBarPlayTimeIndicatorWidth:
          trimBarPlayTimeIndicatorWidth ?? this.trimBarPlayTimeIndicatorWidth,
      trimBarHandlerWidth: trimBarHandlerWidth ?? this.trimBarHandlerWidth,
      trimBarHandlerButtonSize:
          trimBarHandlerButtonSize ?? this.trimBarHandlerButtonSize,
      trimBarHandlerRadius: trimBarHandlerRadius ?? this.trimBarHandlerRadius,
    );
  }
}
