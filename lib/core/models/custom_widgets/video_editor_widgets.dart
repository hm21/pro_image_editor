import 'package:flutter/widgets.dart';

import '/core/models/video/trim_duration_span_model.dart';

/// A configuration class for customizable video editor UI components.
class VideoEditorWidgets {
  /// Creates an instance of [VideoEditorWidgets].
  ///
  /// Allows specifying custom UI elements such as play/pause indicators,
  /// mute button, trim duration info, and more.
  const VideoEditorWidgets({
    this.playIndicator,
    this.pauseIndicator,
    this.muteButton,
    this.playButton,
    this.trimDurationInfo,
    this.infoBanner,
    this.trimBar,
    this.headerToolbar,
    this.trimBarSkeletonLoader,
    this.videoSetupLoadingIndicator,
  });

  /// Widget displayed when the video is playing.
  final Widget? playIndicator;

  /// Widget displayed when the video is paused.
  final Widget? pauseIndicator;

  /// A builder function that builds the mute button.
  ///
  /// The provided callback [setMute] toggles mute state.
  final Widget Function(Function(bool isMuted) setMute)? muteButton;

  /// A builder function for the play button widget. This button is only visible
  /// if `enablePlayButton` is set to `true`.
  ///
  /// The provided [toggleState] callback toggles the playback state,
  /// where `isPlaying` indicates the new state.
  final Widget Function(Function(bool isPlaying) toggleState)? playButton;

  /// A function that builds the trim duration info display.
  ///
  /// Receives the current [TrimDurationSpan].
  final Widget Function(TrimDurationSpan durationSpan)? trimDurationInfo;

  /// A function that builds an informational banner.
  ///
  /// Receives the current [TrimDurationSpan].
  final Widget Function(TrimDurationSpan durationSpan)? infoBanner;

  /// Widget for the trim bar UI component.
  final Widget? trimBar;

  /// Widget for the header toolbar in the video editor.
  final Widget? headerToolbar;

  /// Serves as a skeleton loader for the trim bar, typically displayed while
  /// video thumbnails are loading or processing.
  final Widget? trimBarSkeletonLoader;

  /// A custom widget displayed while the video player is being initialized.
  ///
  /// If not provided, a default circular progress indicator is shown.
  final Widget? videoSetupLoadingIndicator;

  /// Creates a copy of this instance with the given parameters overridden.
  VideoEditorWidgets copyWith({
    Widget? playIndicator,
    Widget? pauseIndicator,
    Widget Function(Function(bool isMuted) setMute)? muteButton,
    Widget Function(TrimDurationSpan durationSpan)? trimDurationInfo,
    Widget Function(TrimDurationSpan durationSpan)? infoBanner,
    Widget? trimBar,
    Widget? headerToolbar,
    Widget? trimBarSkeletonLoader,
    Widget? videoSetupLoadingIndicator,
  }) {
    return VideoEditorWidgets(
      playIndicator: playIndicator ?? this.playIndicator,
      pauseIndicator: pauseIndicator ?? this.pauseIndicator,
      muteButton: muteButton ?? this.muteButton,
      trimDurationInfo: trimDurationInfo ?? this.trimDurationInfo,
      infoBanner: infoBanner ?? this.infoBanner,
      trimBar: trimBar ?? this.trimBar,
      headerToolbar: headerToolbar ?? this.headerToolbar,
      trimBarSkeletonLoader:
          trimBarSkeletonLoader ?? this.trimBarSkeletonLoader,
      videoSetupLoadingIndicator:
          videoSetupLoadingIndicator ?? this.videoSetupLoadingIndicator,
    );
  }
}
