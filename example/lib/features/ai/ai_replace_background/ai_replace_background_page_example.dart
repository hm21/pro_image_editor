import 'dart:convert';
import 'dart:math';

import 'package:http/http.dart' as http;
import 'package:material_ui/material_ui.dart';
import 'package:pro_image_editor/pro_image_editor.dart';

import '/core/constants/example_constants.dart';
import '/core/mixin/example_helper.dart';
import '../ai_text_commands/widgets/ai_setup_widget.dart';
import 'widgets/ai_replace_background_toolbar_widget.dart';

/// A widget that demonstrates AI-powered background replacement functionality.
///
/// This example shows how to use an AI model to replace the background.
class AiReplaceBackgroundExample extends StatefulWidget {
  /// Creates an instance of [AiReplaceBackgroundExample].
  const AiReplaceBackgroundExample({super.key});

  @override
  State<AiReplaceBackgroundExample> createState() =>
      _AiReplaceBackgroundExampleState();
}

class _AiReplaceBackgroundExampleState extends State<AiReplaceBackgroundExample>
    with ExampleHelperState<AiReplaceBackgroundExample> {
  final _alignTopNotifier = ValueNotifier(false);
  final _isProcessingNotifier = ValueNotifier(false);

  final _inputCtrl = TextEditingController();
  final _inputFocus = FocusNode();

  String? _apiKey;
  final String _endpointImageGeneration =
      'https://api.openai.com/v1/images/generations';

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

  @override
  void initState() {
    super.initState();
    preCacheImage(assetPath: kImageEditorExampleAssetPath);
  }

  @override
  void dispose() {
    _alignTopNotifier.dispose();
    _isProcessingNotifier.dispose();
    _inputCtrl.dispose();
    _inputFocus.dispose();
    super.dispose();
  }

  void _generateBackgroundImage() async {
    /// Validate input
    final prompt = _inputCtrl.value.text.trim();
    if (prompt.isEmpty) return;

    /// Prepare state
    FocusManager.instance.primaryFocus?.unfocus();
    _isProcessingNotifier.value = true;
    final editor = editorKey.currentState!;

    /// Generate image
    final response = await http.post(
      Uri.parse(_endpointImageGeneration),
      headers: {
        'Authorization': 'Bearer $_apiKey',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'model': 'dall-e-3',
        'prompt': prompt,
        'n': 1,
        'size': '1024x1024',
      }),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final imageUrl = data['data']?[0]?['url'];

      if (imageUrl != null && imageUrl is String && mounted) {
        await precacheImage(NetworkImage(imageUrl), context);

        await editor.updateBackgroundImage(EditorImage(
          networkUrl: imageUrl,
        ));
      }
    } else {
      debugPrint(
        '❌ Image generation failed: ${response.statusCode} ${response.body}',
      );
      if (response.statusCode == 401 && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Invalid API key for image generation')),
        );
      }
    }

    /// Reset state
    if (!mounted) return;
    _inputCtrl.value = TextEditingValue.empty;
    _isProcessingNotifier.value = false;
    if (isDesktop) _inputFocus.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    if (_apiKey == null) {
      return AiSetupWidget(
        enableGemini: false,
        onChanged: (apiKey, provider) {
          _apiKey = apiKey;
          setState(() {});
        },
      );
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
      child: AiReplaceBackgroundToolbarWidget(
        alignTopNotifier: _alignTopNotifier,
        isProcessingNotifier: _isProcessingNotifier,
        inputCtrl: _inputCtrl,
        inputFocus: _inputFocus,
        onSend: _generateBackgroundImage,
      ),
    );
  }
}
