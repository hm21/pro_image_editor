import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:pro_image_editor/pro_image_editor.dart';

import '../enum/ai_provider_enum.dart';
import '../utils/build_ai_system_config.dart';

/// Base class for AI message providers for image editing commands.
abstract class AiMessageBaseProvider {
  /// Creates a base AI message provider with context and API key.
  const AiMessageBaseProvider({
    required this.context,
    required this.apiKey,
  });

  /// The Flutter build context.
  final BuildContext context;

  /// IMPORTANT: Never expose your API key in production.
  /// Handle it securely on your backend.
  /// I just use it like that so you can easily test it.
  final String apiKey;

  /// Whether the provider supports image generation.
  abstract final bool isImageGenerationSupported;

  /// The AI provider type.
  abstract final AiProvider provider;

  /// The base endpoint used for sending general commands to the API.
  @protected
  abstract final String endpointCommand;

  /// The endpoint specifically used for image generation requests.
  @protected
  abstract final String endpointImageGeneration;

  /// Sends a command to the AI and applies the result to the editor.
  Future<void> sendCommand(ProImageEditorState editor, String command);

  /// Sends a request to generate an image using the AI provider.
  Future<void> sendImageGenerationRequest(
    ProImageEditorState editor,
    String prompt,
  );

  /// Builds a system message describing the current editor state for the AI.
  ///
  /// Includes layers, blur, transforms, filters, and tune adjustments.
  @protected
  String buildSystemMessage(ProImageEditorState editor) {
    final state = editor.stateManager;
    final sizesManager = editor.sizesManager;

    final history = {
      'layers': state.activeLayers.map((layer) => layer.toMap()).toList(),
      'blur': state.activeBlur,
      'transform': state.transformConfigs.isNotEmpty
          ? state.transformConfigs.toMap()
          : null,
      'filters': state.activeFilters.allMatrices,
      'tune': state.activeTuneAdjustments.map((tune) => tune.toMap()).toList(),
    };
    final systemConfig = buildAiSystemConfig(
      configs: editor.configs,
      imageSize: sizesManager.decodedImageSize,
      editorBodySize: sizesManager.bodySize,
      activeHistory: json.encode(history),
      safeArea: const EdgeInsets.all(24),
      enablePaint: true,
      enableText: true,
      enableEmoji: true,
      enableTransform: true,
      enableTune: true,
      enableFilters: true,
      enableBlur: true,
    );

    return systemConfig;
  }

  /// Parses and applies the AI response to the image editor state.
  @protected
  Future<void> handleAiResponse(
    ProImageEditorState editor,
    String response,
  ) async {
    if (!context.mounted) return;
    try {
      final result = json.decode(response) as Map<String, dynamic>;

      final blur =
          result.containsKey('blur') ? safeParseDouble(result['blur']) : null;

      final filters = result.containsKey('filters') && result['filters'] is List
          ? (result['filters'] as List)
              .map((matrix) => (matrix as List)
                  .map((v) => v.toDouble())
                  .toList()
                  .cast<double>())
              .toList()
              .cast<List<double>>()
          : null;

      final tuneAdjustments =
          result.containsKey('tune') && result['tune'] is List
              ? (result['tune'] as List)
                  .whereType<Map<String, dynamic>>()
                  .map(TuneAdjustmentMatrix.fromMap)
                  .toList()
              : null;

      final layers = result.containsKey('layers') && result['layers'] is List
          ? (result['layers'] as List)
              .whereType<Map<String, dynamic>>()
              .map(Layer.fromMap)
              .toList()
          : null;

      final isTransformed = result.containsKey('transform') &&
          result['transform'] is Map &&
          (result['transform'] as Map).isNotEmpty;

      final transformConfigs = isTransformed
          ? TransformConfigs.fromMap(
              result['transform'] as Map<String, dynamic>)
          : null;

      editor.addHistory(
        blur: blur,
        filters: filters != null ? [FilterState(matrices: filters)] : null,
        tuneAdjustments: tuneAdjustments,
        layers: layers,
        transformConfigs: transformConfigs,
      );
    } catch (e) {
      debugPrint('❌ Failed to parse AI response: $e');
    }
  }

  /// Displays a SnackBar warning if the API key for image generation is
  /// invalid.
  ///
  /// Ensures the context is still mounted before showing the message.
  void showInvalidApiKeyWarning() {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Invalid API key for image generation')),
    );
  }
}
