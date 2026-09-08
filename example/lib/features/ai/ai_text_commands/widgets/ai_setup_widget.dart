import 'package:material_ui/material_ui.dart';

import '../enum/ai_provider_enum.dart';

/// A widget that provides a UI for setting up AI configuration options,
/// such as selecting a provider and entering an API key.
class AiSetupWidget extends StatefulWidget {
  /// Creates an instance of [AiSetupWidget].
  const AiSetupWidget({
    super.key,
    required this.onChanged,
    this.enableChatGpt = true,
    this.enableGemini = true,
  });

  /// Whether the Gemini AI integration is enabled.
  final bool enableGemini;

  /// Whether the ChatGPT integration is enabled.
  final bool enableChatGpt;

  /// Called when the user changes the AI provider or API key.
  final Function(String apiKey, AiProvider provider) onChanged;

  @override
  State<AiSetupWidget> createState() => _AiSetupWidgetState();
}

class _AiSetupWidgetState extends State<AiSetupWidget> {
  final _apiKeyController = TextEditingController();
  AiProvider _selectedProvider = AiProvider.openAi;
  bool _obscureText = true;

  @override
  void dispose() {
    _apiKeyController.dispose();
    super.dispose();
  }

  void _startTest() {
    final apiKey = _apiKeyController.text.trim();
    if (apiKey.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter an API key')),
      );
      return;
    }

    widget.onChanged(apiKey, _selectedProvider);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Setup'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'This example uses the API key for testing purposes only. '
            'Never expose your real API key in production applications.',
            style: TextStyle(fontSize: 14, color: Colors.redAccent),
          ),
          const SizedBox(height: 24),
          _buildProviderSelector(),
          if (_selectedProvider == AiProvider.gemini) ...[
            const SizedBox(height: 4),
            const Text(
              'When you use Gemini in this example, '
              'you can’t generate new images.',
            ),
          ],
          const SizedBox(height: 20),
          _buildApiKeyInput(),
          const SizedBox(height: 24),
          Center(
            child: FilledButton(
              onPressed: _startTest,
              child: const Text('Start Test'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildApiKeyInput() {
    return TextField(
      controller: _apiKeyController,
      onEditingComplete: _startTest,
      keyboardType: TextInputType.visiblePassword,
      textInputAction: TextInputAction.send,
      textCapitalization: TextCapitalization.none,
      decoration: InputDecoration(
        labelText: 'API Key',
        border: const OutlineInputBorder(),
        suffixIcon: IconButton(
          icon: Icon(
            _obscureText ? Icons.visibility : Icons.visibility_off,
          ),
          onPressed: () {
            setState(() {
              _obscureText = !_obscureText;
            });
          },
        ),
      ),
      obscureText: _obscureText,
    );
  }

  Widget _buildProviderSelector() {
    return DropdownButtonFormField<AiProvider>(
      initialValue: _selectedProvider,
      decoration: const InputDecoration(
        labelText: 'Provider',
        border: OutlineInputBorder(),
      ),
      items: [
        if (widget.enableChatGpt)
          const DropdownMenuItem(
            value: AiProvider.openAi,
            child: Text('ChatGPT (OpenAI)'),
          ),
        if (widget.enableGemini)
          const DropdownMenuItem(
            value: AiProvider.gemini,
            child: Text('Gemini (Google)'),
          ),
      ],
      onChanged: (value) {
        if (value != null) {
          setState(() => _selectedProvider = value);
        }
      },
    );
  }
}
