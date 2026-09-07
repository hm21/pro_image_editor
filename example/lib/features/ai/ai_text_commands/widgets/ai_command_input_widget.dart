import 'package:material_ui/material_ui.dart';

import '../enum/ai_generation_mode_enum.dart';

/// A stateless widget for inputting and sending AI text commands.
class AiCommandInputWidget extends StatelessWidget {
  /// Creates the AI command input widget.
  const AiCommandInputWidget({
    super.key,
    required this.isProcessing,
    required this.inputCtrl,
    required this.inputFocus,
    required this.onSend,
    required this.mode,
  });

  /// Indicates whether a command is currently being processed.
  final bool isProcessing;

  /// Controller for the text input field.
  final TextEditingController inputCtrl;

  /// Focus node for managing the text field's focus.
  final FocusNode inputFocus;

  /// Callback triggered when the send button is pressed.
  final Function() onSend;

  /// The selected AI generation mode (text or image).
  final AiGenerationMode mode;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(boxShadow: kElevationToShadow[6]),
      child: TextField(
        readOnly: isProcessing,
        onEditingComplete: onSend,
        controller: inputCtrl,
        focusNode: inputFocus,
        keyboardType: TextInputType.text,
        textInputAction: TextInputAction.send,
        textCapitalization: TextCapitalization.sentences,
        decoration: InputDecoration(
          filled: true,
          fillColor: const Color(0xFF28282C),
          border: const OutlineInputBorder(),
          hint: Text(
            mode == AiGenerationMode.text
                ? 'Enter a command for what the AI should add or change...'
                : 'Describe the kind of image that should be added...',
            style: const TextStyle(color: Colors.white54),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          suffixIcon: _buildSuffixIcon(isProcessing),
        ),
      ),
    );
  }

  Widget _buildSuffixIcon(bool isProcessing) {
    return Padding(
      padding: const EdgeInsets.only(right: 7.0),
      child: isProcessing
          ? const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox.square(
                  dimension: 24,
                  child: FittedBox(
                    child: CircularProgressIndicator(),
                  ),
                ),
              ],
            )
          : IconButton(
              tooltip: 'Send to AI',
              icon: const Icon(Icons.send),
              onPressed: onSend,
            ),
    );
  }
}
