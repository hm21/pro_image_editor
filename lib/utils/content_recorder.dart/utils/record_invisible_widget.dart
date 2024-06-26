import 'package:flutter/widgets.dart';
import 'package:pro_image_editor/utils/content_recorder.dart/content_recorder_controller.dart';

/// A widget that records an invisible child widget.
class RecordInvisibleWidget extends StatefulWidget {
  final Widget child;
  final ContentRecorderController controller;

  const RecordInvisibleWidget({
    super.key,
    required this.child,
    required this.controller,
  });

  @override
  State<RecordInvisibleWidget> createState() => _RecordInvisibleWidgetState();
}

class _RecordInvisibleWidgetState extends State<RecordInvisibleWidget> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Widget?>(
        stream: widget.controller.recorderStream.stream,
        builder: (context, snapshot) {
          if (!widget.controller.recordReadyHelper.isCompleted) {
            widget.controller.recordReadyHelper.complete(true);
          }

          return Stack(
            children: [
              if (snapshot.data != null)
                RepaintBoundary(
                  key: widget.controller.recorderKey,
                  child: snapshot.data,
                ),
              widget.child,
            ],
          );
        });
  }
}
