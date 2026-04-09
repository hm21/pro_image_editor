import 'package:flutter/material.dart';

import '/core/models/editor_configs/pro_image_editor_configs.dart';
import '/features/filter_editor/types/filter_state.dart';
import '/features/filter_editor/widgets/filter_generator.dart';
import '/shared/widgets/transform/transformed_content_generator.dart';
import '../../filter_editor/widgets/filtered_widget.dart';
import '../services/sizes_manager.dart';
import '../services/state_manager.dart';

/// A widget for displaying the background image in the main editor,
/// supporting color filters and size configurations.
class MainEditorBackgroundVideo extends StatelessWidget {
  /// Creates a `MainEditorBackgroundImage` with the provided configurations
  /// and dependencies.
  ///
  /// - [stateManager]: Manages the state of the editor.
  /// - [sizesManager]: Handles size configurations and adjustments.
  /// - [configs]: The editor's configuration settings.
  /// - [backgroundImageColorFilterKey]: A key for applying color filters
  ///   to the background image.
  /// - [isInitialized]: Indicates whether the editor has been fully
  ///   initialized.
  const MainEditorBackgroundVideo({
    super.key,
    required this.stateManager,
    required this.sizesManager,
    required this.configs,
    required this.backgroundImageColorFilterKey,
    required this.isInitialized,
    required this.videoPlayer,
    this.playTimeNotifier,
  });

  /// Manages the state of the editor.
  final StateManager stateManager;

  /// Handles size configurations and adjustments.
  final SizesManager sizesManager;

  /// Configuration settings for the editor.
  final ProImageEditorConfigs configs;

  /// A key for managing the color filter applied to the background image.
  final GlobalKey<ColorFilterGeneratorState> backgroundImageColorFilterKey;

  /// Indicates whether the editor has been fully initialized.
  final bool isInitialized;

  /// The video player widget to display in the background.
  final Widget videoPlayer;

  /// Notifier that provides the current video playback position.
  final ValueNotifier<Duration>? playTimeNotifier;

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: configs.heroTag,
      createRectTween: (begin, end) => RectTween(begin: begin, end: end),
      child: !isInitialized
          ? videoPlayer
          : TransformedContentGenerator(
              isVideoPlayer: true,
              transformConfigs: stateManager.transformConfigs,
              configs: configs,
              child: FilteredWidget(
                filterKey: backgroundImageColorFilterKey,
                width: sizesManager.decodedImageSize.width,
                height: sizesManager.decodedImageSize.height,
                configs: configs,
                filters: stateManager.activeFilters.allMatrices,
                tuneAdjustments: stateManager.activeTuneAdjustments,
                blurFactor: stateManager.activeBlur,
                videoPlayer: videoPlayer,
                filterStates: stateManager.activeFilters,
                playTimeNotifier: playTimeNotifier,
              ),
            ),
    );
  }
}
