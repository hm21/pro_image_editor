// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '/shared/widgets/extended/repaint/extended_repaint_boundary.dart';
import '../controllers/content_recorder_controller.dart';

export '../widgets/record_invisible_widget.dart';

/// A widget that records content using a [ContentRecorderController].
///
/// [autoDestroyController] determines whether to automatically destroy
/// the controller when the widget is disposed.
/// [child] is the widget to be recorded.
/// [controller] is the instance of [ContentRecorderController] used for
/// recording.
class ContentRecorder extends StatefulWidget {
  /// A widget that records content using a [ContentRecorderController].
  const ContentRecorder({
    super.key,
    this.autoDestroyController = true,
    required this.child,
    required this.controller,
  });

  /// The widget to be recorded.
  final Widget? child;

  /// Whether to automatically destroy the controller when disposed.
  final bool autoDestroyController;

  /// The [ContentRecorderController] instance used for recording.
  final ContentRecorderController controller;

  @override
  State<ContentRecorder> createState() => ContentRecorderState();
}

/// State class for managing the [ContentRecorder] widget.
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
    return ExtendedRepaintBoundary(
      key: _controller.containerKey,
      child: widget.child,
    );
  }
}
