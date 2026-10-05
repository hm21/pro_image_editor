import 'dart:ui';

import 'package:material_ui/material_ui.dart';

import '/core/models/editor_configs/paint_editor/censor_configs.dart';
import '/features/main_editor/providers/image_infos_provider.dart';
import '/shared/services/shader_manager.dart';
import 'abstract/censor_area_item.dart';
import 'constants/censor_backdrop_key.dart';
import 'layer_space_pixelate_filter.dart';

/// A widget that applies a pixelate effect to a defined area.
///
/// This class extends [CensorAreaItem] and implements the pixelate effect
/// using a [BackdropFilter] with a pixelate shader.
class PixelateAreaItem extends CensorAreaItem {
  /// Creates a [PixelateAreaItem] with the specified [censorConfigs] and
  /// optional [size].
  const PixelateAreaItem({
    super.key,
    required super.censorConfigs,
    super.size,
    super.strength,
  });

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
    /// Shader already loaded
    if (ShaderManager.instance.containsShader(ShaderMode.pixelate)) {
      return _buildFilter(child: child, context: context);
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

        return _buildFilter(child: child, context: context);
      },
    );
  }

  Widget _buildFilter({required Widget child, required BuildContext context}) {
    final devicePixelRatio = MediaQuery.devicePixelRatioOf(context);
    final logicalSize = MediaQuery.sizeOf(context);
    final physicalSize = logicalSize * devicePixelRatio;

    bool fitToWidth =
        ImageInfosProvider.maybeOf(context)?.imageFitToWidth ?? true;

    return _PixelateArea(
      censorConfigs: censorConfigs,
      blockSize: strength ?? censorConfigs.pixelBlockSize,
      devicePixelRatio: devicePixelRatio,
      deviceSize: physicalSize,
      fitToWidth: fitToWidth,
      child: child,
    );
  }
}

/// Pixelates with a shader of its own.
///
/// [ImageFilter.shader] reads the shader's uniforms only when a new filter is
/// first composed, so areas of different block sizes mounted in the same
/// frame would all take the values of the one built last if they shared a
/// shader.
class _PixelateArea extends StatefulWidget {
  const _PixelateArea({
    required this.censorConfigs,
    required this.blockSize,
    required this.devicePixelRatio,
    required this.deviceSize,
    required this.fitToWidth,
    required this.child,
  });

  final CensorConfigs censorConfigs;
  final double blockSize;
  final double devicePixelRatio;
  final Size deviceSize;
  final bool fitToWidth;
  final Widget child;

  @override
  State<_PixelateArea> createState() => _PixelateAreaState();
}

class _PixelateAreaState extends State<_PixelateArea> {
  /// Loaded by [PixelateAreaItem] before this widget is built.
  final FragmentShader? _shader = ShaderManager.instance.createShader(
    ShaderMode.pixelate,
  );

  @override
  void dispose() {
    _shader?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final shader = _shader;
    if (shader == null) return widget.child;

    if (widget.censorConfigs.pixelateInLayerSpace) {
      return LayerSpacePixelateFilter(
        shader: shader,
        blockSize: widget.blockSize,
        devicePixelRatio: widget.devicePixelRatio,
        deviceSize: widget.deviceSize,
        blendMode: widget.censorConfigs.pixelateBlendMode,
        fitToWidth: widget.fitToWidth,
        backdropKey: kCensorBackdropGroupKey,
        child: widget.child,
      );
    }

    shader
      ..setFloat(2, widget.blockSize / widget.devicePixelRatio)
      ..setFloat(3, widget.deviceSize.width)
      ..setFloat(4, widget.deviceSize.height)
      ..setFloat(5, widget.fitToWidth ? 1.0 : 0.0)
      ..setFloat(6, 0)
      ..setFloat(7, 0)
      ..setFloat(8, 0);

    return BackdropFilter(
      filter: ImageFilter.shader(shader),
      blendMode: widget.censorConfigs.pixelateBlendMode,
      backdropGroupKey: kCensorBackdropGroupKey,
      child: widget.child,
    );
  }
}
