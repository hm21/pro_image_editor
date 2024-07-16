// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'content_recorder_controller.dart';

class ContentRecorder extends StatefulWidget {
  final Widget? child;
  final bool autoDestroyController;
  final ContentRecorderController controller;

  const ContentRecorder({
    super.key,
    this.autoDestroyController = true,
    required this.child,
    required this.controller,
  });

  @override
  State<ContentRecorder> createState() => ContentRecorderState();
}

class ContentRecorderState extends State<ContentRecorder> {
  late ContentRecorderController _controller;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller;
  }

  @override
  void dispose() {
    if (widget.autoDestroyController) _controller.destroy();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      key: _controller.containerKey,
      child: widget.child,
    );
  }
}
