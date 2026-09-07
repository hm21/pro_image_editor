import 'dart:ui';

import 'package:material_ui/material_ui.dart';

import '/features/main_editor/providers/image_infos_provider.dart';
import '/shared/services/shader_manager.dart';
import 'abstract/censor_area_item.dart';
import 'constants/censor_backdrop_key.dart';

/// A widget that applies a pixelate effect to a defined area.
///
/// This class extends [CensorAreaItem] and implements the pixelate effect
/// using a [BackdropFilter] with a pixelate shader.
class PixelateAreaItem extends CensorAreaItem {
  /// Creates a [PixelateAreaItem] with the specified [censorConfigs] and
  /// optional [size].
  const PixelateAreaItem({super.key, required super.censorConfigs, super.size});

  @override
  Widget build(BuildContext context) {
    if (!ShaderManager.instance.isShaderFilterSupported) {
      assert(false, 'Shader filters are not supported on the current backend.');
      return const SizedBox();
    }

    return super.build(context);
  }

  @override
  Widget buildBackdropFilter({
    required Widget child,
    required BuildContext context,
  }) {
    /// Return cached shader
    if (ShaderManager.instance.containsShader(ShaderMode.pixelate)) {
      return _buildFilter(
        shader: ShaderManager.instance.shaders[ShaderMode.pixelate]!,
        child: child,
        context: context,
      );
    }

    /// Load shader
    return FutureBuilder(
      future: ShaderManager.instance.loadShader(ShaderMode.pixelate),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        } else if (snapshot.hasError) {
          assert(false, 'Error loading shader: ${snapshot.error}');
          return const SizedBox.shrink();
        } else if (!snapshot.hasData) {
          assert(false, 'Shader is null');
          return const SizedBox.shrink();
        }

        FragmentShader shader = snapshot.data!;
        return _buildFilter(shader: shader, child: child, context: context);
      },
    );
  }

  Widget _buildFilter({
    required Widget child,
    required FragmentShader shader,
    required BuildContext context,
  }) {
    final devicePixelRatio = MediaQuery.devicePixelRatioOf(context);
    final logicalSize = MediaQuery.sizeOf(context);
    final physicalSize = logicalSize * devicePixelRatio;
    final pixelBlockSize = censorConfigs.pixelBlockSize / devicePixelRatio;

    bool fitToWidth =
        ImageInfosProvider.maybeOf(context)?.imageFitToWidth ?? true;

    shader
      ..setFloat(2, pixelBlockSize)
      ..setFloat(3, physicalSize.width)
      ..setFloat(4, physicalSize.height)
      ..setFloat(5, fitToWidth ? 1.0 : 0.0);

    return BackdropFilter(
      filter: ImageFilter.shader(shader),
      blendMode: censorConfigs.pixelateBlendMode,
      backdropGroupKey: kCensorBackdropGroupKey,
      child: child,
    );
  }
}
