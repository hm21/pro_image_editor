// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '/shared/utils/default_editor_theme.dart';
import '/shared/widgets/layer/layer_widget.dart';
import 'layer_rasterizer.dart';

/// Hosts the layers a [LayerRasterizer] is capturing.
///
/// Mount this above anything that captures — typically once around the whole
/// app — and pass the same [rasterizer] to [LayerRasterizer.capture]:
///
/// ```dart
/// MaterialApp(
///   builder: (context, child) => LayerRasterizerHost(
///     rasterizer: rasterizer,
///     child: child!,
///   ),
/// );
/// ```
///
/// While idle the host adds a [Stack] around [child] and nothing else. During
/// a capture it renders the requested layers *behind* [child]: they have to be
/// painted for their repaint boundaries to hold an image, but [child] covers
/// them so they never reach the user. This mirrors how the editor's own
/// screenshot capture stays invisible — which also means [child] has to be
/// opaque and cover the host, otherwise the layers show through for the two
/// frames a capture takes.
class LayerRasterizerHost extends StatefulWidget {
  /// Creates a host that renders whatever [rasterizer] is capturing.
  const LayerRasterizerHost({
    super.key,
    required this.rasterizer,
    required this.child,
  });

  /// The rasterizer whose captures this host renders.
  final LayerRasterizer rasterizer;

  /// The regular application content, painted over any captured layers.
  final Widget child;

  @override
  State<LayerRasterizerHost> createState() => _LayerRasterizerHostState();
}

class _LayerRasterizerHostState extends State<LayerRasterizerHost> {
  @override
  void initState() {
    super.initState();
    widget.rasterizer.attachHost();
  }

  @override
  void didUpdateWidget(covariant LayerRasterizerHost oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!identical(oldWidget.rasterizer, widget.rasterizer)) {
      oldWidget.rasterizer.detachHost();
      widget.rasterizer.attachHost();
    }
  }

  @override
  void dispose() {
    widget.rasterizer.detachHost();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.rasterizer,
      builder: (context, child) {
        final request = widget.rasterizer.request;
        return Stack(
          clipBehavior: Clip.none,
          children: [
            if (request != null)
              // Positioned so the layers are laid out at the editor's body
              // size rather than stretched to the host's constraints, which
              // would move every layer offset.
              Positioned(
                left: 0,
                top: 0,
                width: request.editorBodySize.width,
                height: request.editorBodySize.height,
                child: ExcludeSemantics(
                  child: IgnorePointer(
                    // The editor wraps its layers in this theme and a Material
                    // (through Scaffold). Layer content reads both — emoji
                    // metrics come from the text theme, and a WidgetLayer built
                    // from Material widgets asserts on a missing Material — so
                    // without them the capture differs from the live session.
                    child: Theme(
                      data: request.configs.theme ?? defaultEditorTheme(),
                      child: Material(
                        type: MaterialType.transparency,
                        child: Stack(
                          fit: StackFit.expand,
                          alignment: Alignment.center,
                          clipBehavior: Clip.none,
                          children: [
                            for (final layer in request.layers)
                              LayerWidget(
                                // Keyed by layer identity: without it the
                                // element of a queued capture is reused for the
                                // next one, and LayerWidget resolves the layer
                                // type only in initState.
                                key: ObjectKey(layer),
                                layer: layer,
                                configs: request.configs,
                                editorBodySize: request.editorBodySize,
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            child!,
          ],
        );
      },
      child: widget.child,
    );
  }
}
