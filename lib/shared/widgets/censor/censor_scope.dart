import 'package:flutter/widgets.dart';

import 'layer_space_pixelate_filter.dart';

/// Groups the censor areas painted together, such as the layers of one layer
/// stack, so the renderer filters their backdrop once instead of once per
/// area.
///
/// The renderer filters many backdrop filters in one pass only when they
/// share a [BackdropKey] and all of their filters are equal; a single area
/// that differs makes every area of the key render its own offscreen pass.
/// So blur areas and pixelate areas each get a key of their own, and areas
/// pixelated in their own coordinates share passes of a
/// [LayerSpacePixelateGroup].
///
/// Each scope has keys of its own, so its areas sample the backdrop of their
/// own stack, and a pass only holds areas whose filters can agree: the main
/// editor and its sub-editors pixelate with different settings, such as
/// `ImageInfosProvider.imageFitToWidth`, which only the main editor provides.
/// Areas outside any scope, such as layers on their hero flight to a
/// sub-editor, share [CensorScopeData.unscoped].
class CensorScope extends StatefulWidget {
  /// Creates a scope for the censor areas in [child].
  const CensorScope({super.key, required this.child});

  /// The widget below this scope.
  final Widget child;

  /// The scope of the censor areas at [context].
  static CensorScopeData of(BuildContext context) {
    return context
            .dependOnInheritedWidgetOfExactType<_CensorScopeInherited>()
            ?.data ??
        CensorScopeData.unscoped;
  }

  @override
  State<CensorScope> createState() => _CensorScopeState();
}

class _CensorScopeState extends State<CensorScope> {
  final CensorScopeData _data = CensorScopeData();

  @override
  void dispose() {
    _data.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _CensorScopeInherited(data: _data, child: widget.child);
  }
}

class _CensorScopeInherited extends InheritedWidget {
  const _CensorScopeInherited({required this.data, required super.child});

  final CensorScopeData data;

  @override
  bool updateShouldNotify(_CensorScopeInherited oldWidget) =>
      data != oldWidget.data;
}

/// The backdrop keys and shared passes of a [CensorScope].
class CensorScopeData {
  /// Creates the data of a scope.
  CensorScopeData();

  /// The data of the censor areas outside any [CensorScope].
  static final CensorScopeData unscoped = CensorScopeData();

  /// The key of the scope's blur areas.
  final BackdropKey blurKey = BackdropKey();

  /// The key of the scope's areas pixelated in screen space.
  final BackdropKey pixelateKey = BackdropKey();

  /// The shared passes of the scope's areas pixelated in their own
  /// coordinates.
  final LayerSpacePixelateGroup pixelateGroup = LayerSpacePixelateGroup();

  /// Releases the shaders of [pixelateGroup].
  void dispose() => pixelateGroup.dispose();
}
