import 'package:flutter/widgets.dart';

import '/core/models/editor_configs/video/layer_timeline_configs.dart';
import '/core/models/layers/layer.dart';
import '/shared/utils/timeline_progress.dart';

/// Controls layer visibility based on [Layer.startTime] / [Layer.endTime]
/// relative to the current video time.
///
/// The animation progress is derived directly from the video position so that
/// seeking immediately reflects the correct transition state (e.g. seeking to
/// the middle of a 5 s fade-in shows the layer at 50 %).
class LayerTimelineVisibility extends StatefulWidget {
  /// Creates a [LayerTimelineVisibility].
  const LayerTimelineVisibility({
    super.key,
    required this.layer,
    required this.playTimeNotifier,
    required this.configs,
    required this.child,
  });

  /// The layer whose time range is evaluated.
  final Layer layer;

  /// Notifier that provides the current video playback position.
  final ValueNotifier<Duration> playTimeNotifier;

  /// Animation configuration for the enter/exit transition.
  final LayerTimelineConfigs configs;

  /// The layer widget to show/hide.
  final Widget child;

  @override
  State<LayerTimelineVisibility> createState() =>
      _LayerTimelineVisibilityState();
}

class _LayerTimelineVisibilityState extends State<LayerTimelineVisibility>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);

    _controller.value = _computeProgress(widget.playTimeNotifier.value);
    widget.playTimeNotifier.addListener(_onTimeChanged);
  }

  @override
  void didUpdateWidget(covariant LayerTimelineVisibility oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.playTimeNotifier != widget.playTimeNotifier) {
      oldWidget.playTimeNotifier.removeListener(_onTimeChanged);
      widget.playTimeNotifier.addListener(_onTimeChanged);
    }
  }

  @override
  void dispose() {
    widget.playTimeNotifier.removeListener(_onTimeChanged);
    _controller.dispose();
    super.dispose();
  }

  /// Computes a curved progress value (0.0 – 1.0) based on [currentTime].
  double _computeProgress(Duration currentTime) {
    return computeTimelineProgress(
      currentTime: currentTime,
      startTime: widget.layer.startTime,
      endTime: widget.layer.endTime,
      enterDuration: widget.layer.enterDuration,
      exitDuration: widget.layer.exitDuration,
      defaultEnterCurve: widget.configs.enterCurve,
      defaultExitCurve: widget.configs.exitCurve,
      enterCurve: widget.layer.enterCurve,
      exitCurve: widget.layer.exitCurve,
    );
  }

  void _onTimeChanged() {
    final progress = _computeProgress(widget.playTimeNotifier.value);
    if (_controller.value != progress) {
      _controller.value = progress;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        if (_controller.isDismissed) return const SizedBox.shrink();
        final builder =
            widget.layer.transitionBuilder ?? widget.configs.transitionBuilder;
        return builder(child!, _controller);
      },
      child: widget.child,
    );
  }
}
