import 'package:material_ui/material_ui.dart';

/// A stateless widget for inputting and sending AI text commands.
class AiReplaceBackgroundToolbarWidget extends StatelessWidget {
  /// Creates the AI command input widget.
  const AiReplaceBackgroundToolbarWidget({
    super.key,
    required this.inputCtrl,
    required this.inputFocus,
    required this.onSend,
    required this.isProcessingNotifier,
    required this.alignTopNotifier,
  });

  /// Indicates whether a command is currently being processed.
  final ValueNotifier<bool> isProcessingNotifier;

  /// Controls whether the toolbar is aligned to the top.
  final ValueNotifier<bool> alignTopNotifier;

  /// Controller for the text input field.
  final TextEditingController inputCtrl;

  /// Focus node for managing the text field's focus.
  final FocusNode inputFocus;

  /// Callback triggered when the send button is pressed.
  final Function() onSend;

  final _animationDuration = const Duration(milliseconds: 220);

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: alignTopNotifier,
      builder: (_, alignTop, __) {
        return AnimatedAlign(
          duration: _animationDuration,
          curve: Curves.ease,
          alignment: alignTop ? Alignment.topCenter : Alignment.bottomCenter,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: LayoutBuilder(builder: (_, constraints) {
              bool isMobile = constraints.maxWidth < 560;

              if (isMobile) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  spacing: 7,
                  children: [
                    _buildActionRow(),
                    _buildInput(),
                  ],
                );
              } else {
                return Row(
                  spacing: 12,
                  children: [
                    Expanded(child: _buildInput()),
                    _buildActionRow(),
                  ],
                );
              }
            }),
          ),
        );
      },
    );
  }

  Widget _buildActionRow() {
    return Container(
      decoration: ShapeDecoration(
        shadows: kElevationToShadow[6],
        color: const Color(0xFF28282C),
        shape: const StadiumBorder(),
      ),
      child: _buildPositionSwitcher(),
    );
  }

  Widget _buildInput() {
    return DecoratedBox(
      decoration: BoxDecoration(boxShadow: kElevationToShadow[6]),
      child: ValueListenableBuilder(
          valueListenable: isProcessingNotifier,
          builder: (_, isProcessing, __) {
            return TextField(
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
                hint: const Text(
                  'Describe what the new background image should look like.',
                  style: TextStyle(color: Colors.white54),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                suffixIcon: _buildSuffixIcon(isProcessing),
              ),
            );
          }),
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

  Widget _buildPositionSwitcher() {
    return IconButton(
      tooltip: 'Shift the input to the other side of the screen',
      icon: AnimatedRotation(
        duration: _animationDuration,
        turns: alignTopNotifier.value ? 0.5 : 0,
        child: const Icon(Icons.arrow_upward),
      ),
      onPressed: () {
        alignTopNotifier.value = !alignTopNotifier.value;
      },
    );
  }
}
