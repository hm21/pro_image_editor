import 'dart:math';

import 'package:material_ui/material_ui.dart';
import 'package:pro_image_editor/pro_image_editor.dart';

import '/core/constants/example_constants.dart';
import '/core/mixin/example_helper.dart';
import 'enum/ai_generation_mode_enum.dart';
import 'providers/ai_message_base_provider.dart';
import 'utils/ai_message_provider_factory.dart';
import 'widgets/ai_command_toolbar_widget.dart';
import 'widgets/ai_setup_widget.dart';

/// A Flutter image-editor that demonstrates the usage of
/// AI-powered text commands.
class AiTextCommandsExample extends StatefulWidget {
  /// Creates an instance of [AiTextCommandsExample].
  const AiTextCommandsExample({super.key});

  @override
  State<AiTextCommandsExample> createState() => _AiTextCommandsExampleState();
}

class _AiTextCommandsExampleState extends State<AiTextCommandsExample>
    with ExampleHelperState<AiTextCommandsExample> {
  final _alignTopNotifier = ValueNotifier(false);
  final _isProcessingNotifier = ValueNotifier(false);
  final _generationModeNotifier = ValueNotifier(AiGenerationMode.text);

  final _inputCtrl = TextEditingController();
  final _inputFocus = FocusNode();

  late final _editorConfigs = ProImageEditorConfigs(
    designMode: platformDesignMode,
    imageGeneration: const ImageGenerationConfigs(
      outputFormat: OutputFormat.png,
    ),
    mainEditor: MainEditorConfigs(
      enableCloseButton: !isDesktopMode(context),
      widgets: _buildBodyItems(),
    ),
  );
  late final _editorCallbacks = ProImageEditorCallbacks(
    onImageEditingStarted: onImageEditingStarted,
    onImageEditingComplete: onImageEditingComplete,
    onCloseEditor: (editorMode) => onCloseEditor(editorMode: editorMode),
    mainEditorCallbacks: MainEditorCallbacks(
      helperLines: HelperLinesCallbacks(onLineHit: vibrateLineHit),
    ),
  );

  AiMessageBaseProvider? _aiProvider;

  @override
  void initState() {
    super.initState();
    preCacheImage(assetPath: kImageEditorExampleAssetPath);
  }

  @override
  void dispose() {
    _alignTopNotifier.dispose();
    _isProcessingNotifier.dispose();
    _generationModeNotifier.dispose();
    _inputCtrl.dispose();
    _inputFocus.dispose();
    super.dispose();
  }

  void _sendCommand() async {
    /// Validate input
    final command = _inputCtrl.value.text.trim();
    if (command.isEmpty) return;

    /// Prepare state
    FocusManager.instance.primaryFocus?.unfocus();
    _isProcessingNotifier.value = true;
    final editor = editorKey.currentState!;

    /// Send command or generate image
    if (_generationModeNotifier.value == AiGenerationMode.image) {
      await _aiProvider!.sendImageGenerationRequest(editor, command);
    } else {
      await _aiProvider!.sendCommand(editor, command);
    }

    /// Reset state
    if (!mounted) return;
    _inputCtrl.value = TextEditingValue.empty;
    _isProcessingNotifier.value = false;
    if (isDesktop) _inputFocus.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    if (_aiProvider == null) {
      return AiSetupWidget(onChanged: (apiKey, provider) {
        _aiProvider = AiMessageProviderFactory.create(
          apiKey: apiKey,
          provider: provider,
          context: context,
        );
        setState(() {});
      });
    } else if (!isPreCached) {
      return const PrepareImageWidget();
    }

    return ProImageEditor.asset(
      kImageEditorExampleAssetPath,
      key: editorKey,
      callbacks: _editorCallbacks,
      configs: _editorConfigs,
    );
  }

  MainEditorWidgets _buildBodyItems() {
    return MainEditorWidgets(
      bodyItems: (editor, rebuildStream) {
        return [
          ReactiveWidget(
            stream: rebuildStream,
            builder: (_) {
              return AnimatedSwitcher(
                duration: const Duration(milliseconds: 220),
                child: editor.isLayerBeingTransformed || editor.isSubEditorOpen
                    ? SizedBox.shrink(key: UniqueKey())
                    : _buildCommandLine(),
              );
            },
          ),
        ];
      },
    );
  }

  Widget _buildCommandLine() {
    return Padding(
      padding: EdgeInsets.only(
        bottom: max(
          0,
          MediaQuery.viewInsetsOf(context).bottom - kBottomNavigationBarHeight,
        ),
      ),
      child: AiCommandToolbarWidget(
        isProcessingNotifier: _isProcessingNotifier,
        alignTopNotifier: _alignTopNotifier,
        generationModeNotifier: _generationModeNotifier,
        isImageGenerationSupported: _aiProvider!.isImageGenerationSupported,
        inputCtrl: _inputCtrl,
        inputFocus: _inputFocus,
        onSend: _sendCommand,
      ),
    );
  }
}
