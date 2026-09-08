import 'package:flutter/rendering.dart';
import 'package:material_ui/material_ui.dart';

/// A widget that ignores all pointer events
class HitTestTransparent extends SingleChildRenderObjectWidget {
  /// Creates a hit-test transparent wrapper
  const HitTestTransparent({super.key, required super.child});

  @override
  RenderObject createRenderObject(BuildContext context) {
    return _RenderHitTestTransparent();
  }
}

/// A render object that always skips hit testing
class _RenderHitTestTransparent extends RenderProxyBox {
  @override
  bool hitTest(BoxHitTestResult result, {required Offset position}) {
    // Always skip this widget in hit testing
    return false;
  }
}
