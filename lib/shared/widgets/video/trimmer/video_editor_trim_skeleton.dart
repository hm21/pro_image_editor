import 'package:material_ui/material_ui.dart';

import '../video_editor_configurable.dart';

/// A skeleton widget for the video editor's trim feature.
class VideoEditorTrimSkeleton extends StatefulWidget {
  /// Creates a [VideoEditorTrimSkeleton] widget.
  const VideoEditorTrimSkeleton({super.key});

  @override
  State<VideoEditorTrimSkeleton> createState() =>
      _VideoEditorTrimSkeletonState();
}

class _VideoEditorTrimSkeletonState extends State<VideoEditorTrimSkeleton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
    _animation = Tween<double>(begin: -1.0, end: 2.0).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _buildShimmer(BuildContext context, Widget? child) {
    var player = VideoEditorConfigurable.of(context);
    return ShaderMask(
      shaderCallback: (bounds) {
        return LinearGradient(
          colors: player.style.trimBarSkeletonColors,
          begin: const Alignment(-1, 0),
          end: const Alignment(1, 0),
          stops: const [0.1, 0.5, 0.9],
          transform: _SlidingGradientTransform(slidePercent: _animation.value),
        ).createShader(bounds);
      },
      blendMode: BlendMode.srcATop,
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    var player = VideoEditorConfigurable.of(context);
    return AnimatedBuilder(
      animation: _animation,
      builder: _buildShimmer,
      child: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          color: player.style.trimBarSkeletonColors.first,
          borderRadius: BorderRadius.circular(
            player.style.trimBarHandlerRadius,
          ),
        ),
      ),
    );
  }
}

class _SlidingGradientTransform extends GradientTransform {
  const _SlidingGradientTransform({required this.slidePercent});
  final double slidePercent;

  @override
  Matrix4 transform(Rect bounds, {TextDirection? textDirection}) {
    return Matrix4.translationValues(bounds.width * slidePercent, 0, 0);
  }
}
