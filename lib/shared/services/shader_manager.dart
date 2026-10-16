import 'dart:ui';

import '/core/constants/editor_shader_constants.dart';

/// A singleton class that manages and caches fragment shaders for different
/// modes.
class ShaderManager {
  /// Private constructor to enforce singleton pattern.
  ShaderManager._();

  /// The singleton instance of `ShaderManager`.
  static final ShaderManager instance = ShaderManager._();

  /// The loads in progress or done, so each shader is loaded only once.
  final Map<ShaderMode, Future<void>> _loadingFutures = {};

  /// A map that stores loaded shaders by their mode.
  final Map<ShaderMode, FragmentShader> shaders = {};

  /// The loaded programs by their mode, for widgets that need a shader whose
  /// uniforms no other widget changes; see [createShader].
  final Map<ShaderMode, FragmentProgram> programs = {};

  /// Whether [ImageFilter.shader] is supported on the current backend.
  bool get isShaderFilterSupported => ImageFilter.isShaderFilterSupported;

  /// Checks if a shader for the given [mode] is already loaded.
  bool containsShader(ShaderMode mode) => shaders.containsKey(mode);

  /// A new shader of the loaded program for [mode], or `null` while it is not
  /// loaded.
  ///
  /// [shaders] holds one shader per mode, shared by every widget. Its uniforms
  /// are read when a frame is composed, so widgets that set different values
  /// in the same frame need a shader each. The caller disposes it.
  FragmentShader? createShader(ShaderMode mode) =>
      programs[mode]?.fragmentShader();

  /// Loads a shader for the given [mode].
  /// If the shader is already loaded, it returns the cached version.
  /// Otherwise, it asynchronously loads and caches the shader.
  Future<FragmentShader> loadShader(ShaderMode mode) async {
    assert(
      isShaderFilterSupported,
      'Shader filters are not supported on the current backend.',
    );

    if (shaders[mode] != null) return shaders[mode]!;

    await (_loadingFutures[mode] ??= _loadShader(mode));

    return shaders[mode]!;
  }

  /// Internal method to asynchronously load a shader from an asset path.
  Future<void> _loadShader(ShaderMode mode) async {
    String path = '';

    switch (mode) {
      case ShaderMode.pixelate:
        path = kImageEditorPixelateShaderPath;
        break;
      case ShaderMode.pixelateAreas:
        path = kImageEditorPixelateAreasShaderPath;
        break;
    }

    var program = await FragmentProgram.fromAsset(path);

    programs[mode] = program;
    shaders[mode] = program.fragmentShader();
  }
}

/// Enum representing different shader modes.
enum ShaderMode {
  /// Applies a pixelation effect to the image.
  pixelate,

  /// Pixelates many censor areas in one pass, each in its own grid; see
  /// `LayerSpacePixelateGroup`.
  pixelateAreas,
}
