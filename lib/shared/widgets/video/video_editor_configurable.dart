import 'package:flutter/material.dart';

import '/core/models/editor_callbacks/video_editor_callbacks.dart';
import '/core/models/editor_configs/video/video_editor_configs.dart';
import '../../controllers/video_controller.dart';

/// Provides video editor configuration and state management.
///
/// This inherited widget allows access to the video editor's controller,
/// configurations, and state from the widget tree.
class VideoEditorConfigurable extends InheritedWidget {
  /// Creates a [VideoEditorConfigurable] widget.
  ///
  /// Requires a [child] widget and a [controller] to manage video playback.
  const VideoEditorConfigurable({
    super.key,
    required super.child,
    required this.controller,
  });

  /// The video controller managing playback and trim states.
  final ProVideoController controller;

  /// Returns the current video editor configurations.
  VideoEditorConfigs get configs => controller.configs;

  /// Returns the current video editor callbacks.
  VideoEditorCallbacks get callbacks => controller.callbacks;

  /// Notifier for the play state of the video.
  ValueNotifier<bool> get isPlayingNotifier => controller.isPlayingNotifier;

  /// Notifier for the mute state of the video.
  ValueNotifier<bool> get isMutedNotifier => controller.isMutedNotifier;

  /// Notifier that indicates whether the trim time span UI should be shown.
  ///
  /// This is exposed from the underlying [ProVideoController] and can be used
  /// to toggle or listen for visibility changes in the trim UI.
  ValueNotifier<bool> get showTrimTimeSpanNotifier =>
      controller.showTrimTimeSpanNotifier;

  /// Returns the configured video editor icons.
  VideoEditorIcons get icons => configs.icons;

  /// Returns the configured video editor styles.
  VideoEditorStyle get style => configs.style;

  /// Returns the configured video editor widgets.
  VideoEditorWidgets get widgets => configs.widgets;

  /// Retrieves the nearest [VideoEditorConfigurable] instance from the context.
  ///
  /// Throws an assertion error if no instance is found.
  static VideoEditorConfigurable of(BuildContext context) {
    final config = maybeOf(context);
    assert(config != null, 'No VideoEditorConfigurable found in context');
    return config!;
  }

  /// Retrieves the nearest [VideoEditorConfigurable] instance if available.
  static VideoEditorConfigurable? maybeOf(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<VideoEditorConfigurable>();
  }

  @override
  bool updateShouldNotify(covariant VideoEditorConfigurable oldWidget) {
    return false;
  }
}
