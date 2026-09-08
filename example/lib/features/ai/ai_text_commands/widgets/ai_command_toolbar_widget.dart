import 'package:material_ui/material_ui.dart';

import '../enum/ai_generation_mode_enum.dart';
import '../widgets/ai_command_input_widget.dart';
import 'ai_example_commands_widget.dart';

/// A toolbar widget for sending AI commands with input and control states.
class AiCommandToolbarWidget extends StatefulWidget {
  /// Creates the AI command toolbar.
  const AiCommandToolbarWidget({
    super.key,
    required this.isProcessingNotifier,
    required this.alignTopNotifier,
    required this.generationModeNotifier,
    required this.isImageGenerationSupported,
    required this.inputCtrl,
    required this.inputFocus,
    required this.onSend,
  });

  /// Indicates whether a command is currently being processed.
  final ValueNotifier<bool> isProcessingNotifier;

  /// Controls whether the toolbar is aligned to the top.
  final ValueNotifier<bool> alignTopNotifier;

  /// Notifier for the current AI generation mode selection.
  final ValueNotifier<AiGenerationMode> generationModeNotifier;

  /// Indicates if image generation is supported by the provider.
  final bool isImageGenerationSupported;

  /// Controller for the input text field.
  final TextEditingController inputCtrl;

  /// Focus node for the input field.
  final FocusNode inputFocus;

  /// Callback triggered when the send button is pressed.
  final Function() onSend;

  @override
  State<AiCommandToolbarWidget> createState() => _AiCommandToolbarWidgetState();
}

class _AiCommandToolbarWidgetState extends State<AiCommandToolbarWidget> {
  final _animationDuration = const Duration(milliseconds: 220);

  void _openExampleCommands() async {
    final result = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => const AiExampleCommandsWidget(),
    );

    if (result != null) {
      widget.inputCtrl.value = TextEditingValue(text: result);
      widget.onSend();
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: widget.alignTopNotifier,
      builder: (_, alignTop, __) {
        return AnimatedAlign(
          duration: _animationDuration,
          curve: Curves.ease,
          alignment: alignTop ? Alignment.topCenter : Alignment.bottomCenter,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: ValueListenableBuilder(
                valueListenable: widget.generationModeNotifier,
                builder: (_, mode, __) {
                  bool isTextMode = mode == AiGenerationMode.text;
                  return LayoutBuilder(builder: (_, constraints) {
                    bool isMobile = constraints.maxWidth < 560;

                    if (isMobile) {
                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        spacing: 7,
                        children: [
                          _buildActionRow(isTextMode),
                          _buildInput(),
                        ],
                      );
                    } else {
                      return Row(
                        spacing: 12,
                        children: [
                          Expanded(child: _buildInput()),
                          _buildActionRow(isTextMode),
                        ],
                      );
                    }
                  });
                }),
          ),
        );
      },
    );
  }

  Widget _buildInput() {
    return ValueListenableBuilder(
      valueListenable: widget.isProcessingNotifier,
      builder: (_, isProcessing, __) {
        return AiCommandInputWidget(
          isProcessing: isProcessing,
          inputCtrl: widget.inputCtrl,
          inputFocus: widget.inputFocus,
          onSend: widget.onSend,
          mode: widget.generationModeNotifier.value,
        );
      },
    );
  }

  Widget _buildActionRow(bool isTextMode) {
    return Container(
      decoration: ShapeDecoration(
        shadows: kElevationToShadow[6],
        color: const Color(0xFF28282C),
        shape: const StadiumBorder(),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildExampleListButton(isTextMode),
          if (widget.isImageGenerationSupported) _buildModeSwitcher(isTextMode),
          _buildPositionSwitcher(),
        ],
      ),
    );
  }

  Widget _buildExampleListButton(bool isTextMode) {
    return AnimatedSwitcher(
      duration: _animationDuration,
      transitionBuilder: (child, animation) => SizeTransition(
        sizeFactor: animation,
        axis: Axis.horizontal,
        fixedCrossAxisSizeFactor: 1,
        child: FadeTransition(
          opacity: animation,
          child: child,
        ),
      ),
      child: isTextMode
          ? IconButton(
              tooltip: 'List of Example Commands',
              icon: const Icon(Icons.info_outline),
              onPressed: _openExampleCommands,
            )
          : const SizedBox.shrink(),
    );
  }

  Widget _buildModeSwitcher(bool isTextMode) {
    return IconButton(
      tooltip: isTextMode
          ? 'Switch to image generation mode.'
          : 'Switch to text command mode.',
      icon:
          Icon(isTextMode ? Icons.image_outlined : Icons.description_outlined),
      onPressed: () {
        widget.generationModeNotifier.value =
            isTextMode ? AiGenerationMode.image : AiGenerationMode.text;
      },
    );
  }

  Widget _buildPositionSwitcher() {
    return IconButton(
      tooltip: 'Shift the input to the other side of the screen',
      icon: AnimatedRotation(
        duration: _animationDuration,
        turns: widget.alignTopNotifier.value ? 0.5 : 0,
        child: const Icon(Icons.arrow_upward),
      ),
      onPressed: () {
        widget.alignTopNotifier.value = !widget.alignTopNotifier.value;
      },
    );
  }
}
