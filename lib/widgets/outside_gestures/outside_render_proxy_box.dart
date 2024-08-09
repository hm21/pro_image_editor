// Flutter imports:
import 'package:flutter/rendering.dart';

// Project imports:
import 'outside_gesture_behavior.dart';

/// OutsideRenderProxyBoxWithHitTestBehavior
abstract class OutsideRenderProxyBoxWithHitTestBehavior extends RenderProxyBox {
  /// Initializes member variables for subclasses.
  ///
  /// By default, the [behavior] is [OutsideHitTestBehavior.deferToChild].
  OutsideRenderProxyBoxWithHitTestBehavior({
    this.behavior = OutsideHitTestBehavior.deferToChild,
    RenderBox? child,
  }) : super(child);

  /// How to behave during hit testing when deciding how the hit test propagates
  /// to children and whether to consider targets behind this one.
  ///
  /// Defaults to [OutsideHitTestBehavior.deferToChild].
  ///
  /// See [OutsideHitTestBehavior] for the allowed values and their meanings.
  OutsideHitTestBehavior behavior;

  @override
  bool hitTest(BoxHitTestResult result, {required Offset position}) {
    bool hitTarget = false;

    if (behavior == OutsideHitTestBehavior.all) {
      result.add(BoxHitTestEntry(this, position));
    }

    if (size.contains(position)) {
      hitTarget =
          hitTestChildren(result, position: position) || hitTestSelf(position);
      if (behavior != OutsideHitTestBehavior.all) {
        if (hitTarget || behavior == OutsideHitTestBehavior.translucent) {
          result.add(BoxHitTestEntry(this, position));
        }
      }
    }
    return hitTarget;
  }

  @override
  bool hitTestSelf(Offset position) =>
      behavior == OutsideHitTestBehavior.opaque;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(EnumProperty<OutsideHitTestBehavior>('behavior', behavior,
        defaultValue: null));
  }
}
