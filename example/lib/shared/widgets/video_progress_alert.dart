import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:pro_image_editor/pro_image_editor.dart';
import 'package:pro_video_editor/pro_video_editor.dart';

/// A dialog that displays real-time export progress for video generation.
///
/// Listens to the [VideoUtilsService.exportProgressStream] and shows a
/// circular progress indicator with percentage text.
class VideoProgressAlert extends StatelessWidget {
  /// Creates a [VideoProgressAlert] widget.
  const VideoProgressAlert({
    super.key,
    this.taskId = '',
  });

  /// Optional taskId of the progress stream.
  final String taskId;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ModalBarrier(
          onDismiss: kDebugMode ? LoadingDialog.instance.hide : null,
          color: Colors.black54,
          dismissible: kDebugMode,
        ),
        Center(
          child: Theme(
            data: Theme.of(context),
            child: AlertDialog(
              contentPadding:
                  const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
              content: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 500),
                child: Padding(
                  padding: const EdgeInsets.only(top: 3.0),
                  child: _buildProgressBody(),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProgressBody() {
    return StreamBuilder<ProgressModel>(
        stream: ProVideoEditor.instance.progressStreamById(taskId),
        builder: (context, snapshot) {
          var progress = snapshot.data?.progress ?? 0;
          return TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0, end: progress),
              duration: const Duration(milliseconds: 300),
              builder: (context, animatedValue, _) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.start,
                  spacing: 10,
                  children: [
                    CircularProgressIndicator(
                      value: animatedValue,
                      // ignore: deprecated_member_use
                      year2023: false,
                    ),
                    Text(
                      '${(animatedValue * 100).toStringAsFixed(1)} / 100',
                      style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w500,
                          fontFeatures: [FontFeature.tabularFigures()]),
                    )
                  ],
                );
              });
        });
  }
}
