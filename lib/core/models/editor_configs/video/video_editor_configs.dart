import 'package:flutter/widgets.dart';

import '/core/models/custom_widgets/video_editor_widgets.dart';
import '/core/models/icons/video_editor_icons.dart';
import '/core/models/styles/video_editor_style.dart';

export '/core/models/custom_widgets/video_editor_widgets.dart';
export '/core/models/icons/video_editor_icons.dart';
export '/core/models/styles/video_editor_style.dart';

/// Configuration settings for the video editor.
class VideoEditorConfigs {
  /// Creates an instance of [VideoEditorConfigs].
  ///
  /// Allows customization of icons, styles, widgets, and various behavior
  /// settings like initial play state, mute state, trim bar behavior, and
  /// animation configurations.
  const VideoEditorConfigs({
    this.icons = const VideoEditorIcons(),
    this.style = const VideoEditorStyle(),
    this.widgets = const VideoEditorWidgets(),
    this.initialPlay = false,
    this.initialMuted = false,
    this.trimBarInvertMouseScroll = false,
    this.isAudioSupported = true,
    this.enablePlayButton = false,
    this.enableEstimatedFileSize = false,
    this.controlsPosition = VideoEditorControlPosition.top,
    this.minTrimDuration = const Duration(seconds: 7),
    this.maxTrimDuration,
    this.animatedIndicatorDuration = const Duration(milliseconds: 200),
    this.animatedIndicatorSwitchInCurve = Curves.ease,
    this.animatedIndicatorSwitchOutCurve = Curves.ease,
    this.trimBarMinScale = 1,
    this.trimBarMaxScale = 3,
    this.playTimeSmoothingDuration = Duration.zero,
  })  : assert(trimBarMinScale > 0, 'trimBarMinScale must be greater than 0'),
        assert(
          trimBarMaxScale > trimBarMinScale,
          'trimBarMaxScale must be greater than trimBarMinScale',
        );

  /// Configurable icons for the video editor.
  final VideoEditorIcons icons;

  /// Style configurations for the video editor.
  final VideoEditorStyle style;

  /// Customizable UI widgets for the video editor.
  final VideoEditorWidgets widgets;

  /// Whether the video should start playing automatically.
  final bool initialPlay;

  /// Whether the video should start muted.
  final bool initialMuted;

  /// Whether to invert mouse scroll behavior on the trim bar.
  final bool trimBarInvertMouseScroll;

  /// Indicates if the output format support audio.
  final bool isAudioSupported;

  /// If `true` a small play/pause button will be displayed next to the
  /// mute button.
  /// If `false` tapping on the video will toggle play/pause, and a round
  /// play button will be shown over the video.
  final bool enablePlayButton;

  /// Displays an estimated file size based on the trim duration and bitrate.
  ///
  /// **IMPORTANT:** The bitrate must be set in the `ProVideoController`.
  /// Note that not all devices support Constant Bitrate (CBR) mode.
  /// If unsupported, the encoder may silently fall back to Variable Bitrate
  /// (VBR), and the actual bitrate may be constrained by device-specific
  /// limits. That mean the displayed estimated file size could be wrong.
  final bool enableEstimatedFileSize;

  /// Minimum scale factor for the trim bar.
  final double trimBarMinScale;

  /// Maximum scale factor for the trim bar.
  final double trimBarMaxScale;

  /// In some video players, the playtime indicator does not refresh at 60 FPS,
  /// resulting in a choppy appearance and noticeable "jumps."
  /// To improve smoothness, we use `AnimatedPosition` with a duration to
  /// create a more fluid transition.
  final Duration playTimeSmoothingDuration;

  /// Minimum trim duration allowed.
  final Duration minTrimDuration;

  /// Maximum trim duration allowed.
  final Duration? maxTrimDuration;

  /// Position of the control bar in the video editor.
  final VideoEditorControlPosition controlsPosition;

  /// Duration of animated indicators.
  final Duration animatedIndicatorDuration;

  /// Curve for the animated indicator switch-in effect.
  final Curve animatedIndicatorSwitchInCurve;

  /// Curve for the animated indicator switch-out effect.
  final Curve animatedIndicatorSwitchOutCurve;

  /// Creates a copy of this instance with the given parameters overridden.
  VideoEditorConfigs copyWith({
    VideoEditorIcons? icons,
    VideoEditorStyle? style,
    VideoEditorWidgets? widgets,
    bool? initialPlay,
    bool? initialMuted,
    bool? trimBarInvertMouseScroll,
    bool? isAudioSupported,
    bool? enablePlayButton,
    bool? enableEstimatedFileSize,
    double? trimBarMinScale,
    double? trimBarMaxScale,
    Duration? playTimeSmoothingDuration,
    Duration? minTrimDuration,
    Duration? maxTrimDuration,
    VideoEditorControlPosition? controlsPosition,
    Duration? animatedIndicatorDuration,
    Curve? animatedIndicatorSwitchInCurve,
    Curve? animatedIndicatorSwitchOutCurve,
  }) {
    return VideoEditorConfigs(
      icons: icons ?? this.icons,
      style: style ?? this.style,
      widgets: widgets ?? this.widgets,
      initialPlay: initialPlay ?? this.initialPlay,
      initialMuted: initialMuted ?? this.initialMuted,
      trimBarInvertMouseScroll:
          trimBarInvertMouseScroll ?? this.trimBarInvertMouseScroll,
      isAudioSupported: isAudioSupported ?? this.isAudioSupported,
      enablePlayButton: enablePlayButton ?? this.enablePlayButton,
      enableEstimatedFileSize:
          enableEstimatedFileSize ?? this.enableEstimatedFileSize,
      trimBarMinScale: trimBarMinScale ?? this.trimBarMinScale,
      trimBarMaxScale: trimBarMaxScale ?? this.trimBarMaxScale,
      playTimeSmoothingDuration:
          playTimeSmoothingDuration ?? this.playTimeSmoothingDuration,
      minTrimDuration: minTrimDuration ?? this.minTrimDuration,
      maxTrimDuration: maxTrimDuration ?? this.maxTrimDuration,
      controlsPosition: controlsPosition ?? this.controlsPosition,
      animatedIndicatorDuration:
          animatedIndicatorDuration ?? this.animatedIndicatorDuration,
      animatedIndicatorSwitchInCurve:
          animatedIndicatorSwitchInCurve ?? this.animatedIndicatorSwitchInCurve,
      animatedIndicatorSwitchOutCurve: animatedIndicatorSwitchOutCurve ??
          this.animatedIndicatorSwitchOutCurve,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is VideoEditorConfigs &&
        other.icons == icons &&
        other.style == style &&
        other.widgets == widgets &&
        other.initialPlay == initialPlay &&
        other.initialMuted == initialMuted &&
        other.trimBarInvertMouseScroll == trimBarInvertMouseScroll &&
        other.isAudioSupported == isAudioSupported &&
        other.enablePlayButton == enablePlayButton &&
        other.enableEstimatedFileSize == enableEstimatedFileSize &&
        other.trimBarMinScale == trimBarMinScale &&
        other.trimBarMaxScale == trimBarMaxScale &&
        other.playTimeSmoothingDuration == playTimeSmoothingDuration &&
        other.minTrimDuration == minTrimDuration &&
        other.maxTrimDuration == maxTrimDuration &&
        other.controlsPosition == controlsPosition &&
        other.animatedIndicatorDuration == animatedIndicatorDuration &&
        other.animatedIndicatorSwitchInCurve ==
            animatedIndicatorSwitchInCurve &&
        other.animatedIndicatorSwitchOutCurve ==
            animatedIndicatorSwitchOutCurve;
  }

  @override
  int get hashCode {
    return icons.hashCode ^
        style.hashCode ^
        widgets.hashCode ^
        initialPlay.hashCode ^
        initialMuted.hashCode ^
        trimBarInvertMouseScroll.hashCode ^
        isAudioSupported.hashCode ^
        enablePlayButton.hashCode ^
        enableEstimatedFileSize.hashCode ^
        trimBarMinScale.hashCode ^
        trimBarMaxScale.hashCode ^
        playTimeSmoothingDuration.hashCode ^
        minTrimDuration.hashCode ^
        maxTrimDuration.hashCode ^
        controlsPosition.hashCode ^
        animatedIndicatorDuration.hashCode ^
        animatedIndicatorSwitchInCurve.hashCode ^
        animatedIndicatorSwitchOutCurve.hashCode;
  }
}

/// Enum defining possible positions for video editor controls.
enum VideoEditorControlPosition {
  /// Place the controls on the top of the screen.
  top,

  /// Place the controls on the bottom of the screen.
  bottom
}
