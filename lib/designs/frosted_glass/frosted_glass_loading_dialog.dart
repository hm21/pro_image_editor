// Flutter imports:
import 'package:flutter/material.dart';
import 'package:pro_image_editor/pro_image_editor.dart';

// Project imports:
import 'frosted_glass_effect.dart';

/// A stateless widget that displays a loading dialog with a frosted glass
/// effect.
///
/// This dialog is used to indicate loading or processing states within an image
/// editing application, providing a visually appealing overlay with a message.
class FrostedGlassLoadingDialog extends StatelessWidget {
  /// Creates a [FrostedGlassLoadingDialog].
  ///
  /// This dialog displays a loading indicator with a message, using a frosted
  /// glass effect to enhance the user interface during processing operations.
  ///
  /// Example:
  /// ```
  /// FrostedGlassLoadingDialog(
  ///   message: 'Loading, please wait...',
  ///   configs: myEditorConfigs,
  /// )
  /// ```
  const FrostedGlassLoadingDialog({
    super.key,
    required this.message,
    required this.configs,
  });

  /// The message to display within the loading dialog.
  ///
  /// This message provides context or information about the current loading
  /// operation, keeping the user informed about the application's status.
  final String message;

  /// The configuration settings for the loading dialog.
  ///
  /// These settings determine various aspects of the dialog's appearance and
  /// behavior, ensuring it matches the application's overall theme and style.
  final ProImageEditorConfigs configs;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        const ModalBarrier(color: Colors.black38),
        Center(
          child: DefaultTextStyle(
            style: const TextStyle(),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: FrostedGlassEffect(
                radius: BorderRadius.circular(16),
                child: Container(
                  color: Colors.transparent,
                  constraints: const BoxConstraints(maxWidth: 280),
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(right: 20.0),
                        child: SizedBox(
                          height: 40,
                          width: 40,
                          child: FittedBox(
                            child: CircularProgressIndicator(
                              color: Colors.blue.shade200,
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          message,
                          style: const TextStyle(
                              fontSize: 16, color: Colors.white),
                          textAlign: TextAlign.start,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
