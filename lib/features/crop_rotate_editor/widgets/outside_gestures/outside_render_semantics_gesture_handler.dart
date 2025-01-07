// Flutter imports:
import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

// Project imports:
import 'outside_render_proxy_box.dart';

/// OutsideRenderSemanticsGestureHandler
class OutsideRenderSemanticsGestureHandler
    extends OutsideRenderProxyBoxWithHitTestBehavior {
  /// Creates a render object that listens for specific semantic gestures.
  OutsideRenderSemanticsGestureHandler({
    super.child,
    GestureTapCallback? onTap,
    GestureLongPressCallback? onLongPress,
    GestureDragUpdateCallback? onHorizontalDragUpdate,
    GestureDragUpdateCallback? onVerticalDragUpdate,
    this.scrollFactor = 0.8,
    super.behavior,
  })  : _onTap = onTap,
        _onLongPress = onLongPress,
        _onHorizontalDragUpdate = onHorizontalDragUpdate,
        _onVerticalDragUpdate = onVerticalDragUpdate;

  /// If non-null, the set of actions to allow. Other actions will be omitted,
  /// even if their callback is provided.
  ///
  /// For example, if [onTap] is non-null but [validActions] does not contain
  /// [SemanticsAction.tap], then the semantic description of this node will
  /// not claim to support taps.
  ///
  /// This is normally used to filter the actions made available by
  /// [onHorizontalDragUpdate] and [onVerticalDragUpdate]. Normally, these make
  /// both the right and left, or up and down, actions available. For example,
  /// if [onHorizontalDragUpdate] is set but [validActions] only contains
  /// [SemanticsAction.scrollLeft], then the [SemanticsAction.scrollRight]
  /// action will be omitted.
  Set<SemanticsAction>? get validActions => _validActions;
  Set<SemanticsAction>? _validActions;
  set validActions(Set<SemanticsAction>? value) {
    if (setEquals<SemanticsAction>(value, _validActions)) {
      return;
    }
    _validActions = value;
    markNeedsSemanticsUpdate();
  }

  /// Called when the user taps on the render object.
  GestureTapCallback? get onTap => _onTap;
  GestureTapCallback? _onTap;
  set onTap(GestureTapCallback? value) {
    if (_onTap == value) {
      return;
    }
    final bool hadHandler = _onTap != null;
    _onTap = value;
    if ((value != null) != hadHandler) {
      markNeedsSemanticsUpdate();
    }
  }

  /// Called when the user presses on the render object for a long period of
  /// time.
  GestureLongPressCallback? get onLongPress => _onLongPress;
  GestureLongPressCallback? _onLongPress;
  set onLongPress(GestureLongPressCallback? value) {
    if (_onLongPress == value) {
      return;
    }
    final bool hadHandler = _onLongPress != null;
    _onLongPress = value;
    if ((value != null) != hadHandler) {
      markNeedsSemanticsUpdate();
    }
  }

  /// Called when the user scrolls to the left or to the right.
  GestureDragUpdateCallback? get onHorizontalDragUpdate =>
      _onHorizontalDragUpdate;
  GestureDragUpdateCallback? _onHorizontalDragUpdate;
  set onHorizontalDragUpdate(GestureDragUpdateCallback? value) {
    if (_onHorizontalDragUpdate == value) {
      return;
    }
    final bool hadHandler = _onHorizontalDragUpdate != null;
    _onHorizontalDragUpdate = value;
    if ((value != null) != hadHandler) {
      markNeedsSemanticsUpdate();
    }
  }

  /// Called when the user scrolls up or down.
  GestureDragUpdateCallback? get onVerticalDragUpdate => _onVerticalDragUpdate;
  GestureDragUpdateCallback? _onVerticalDragUpdate;
  set onVerticalDragUpdate(GestureDragUpdateCallback? value) {
    if (_onVerticalDragUpdate == value) {
      return;
    }
    final bool hadHandler = _onVerticalDragUpdate != null;
    _onVerticalDragUpdate = value;
    if ((value != null) != hadHandler) {
      markNeedsSemanticsUpdate();
    }
  }

  /// The fraction of the dimension of this render box to use when
  /// scrolling. For example, if this is 0.8 and the box is 200 pixels
  /// wide, then when a left-scroll action is received from the
  /// accessibility system, it will translate into a 160 pixel
  /// leftwards drag.
  double scrollFactor;

  @override
  void describeSemanticsConfiguration(SemanticsConfiguration config) {
    super.describeSemanticsConfiguration(config);

    if (onTap != null && _isValidAction(SemanticsAction.tap)) {
      config.onTap = onTap;
    }
    if (onLongPress != null && _isValidAction(SemanticsAction.longPress)) {
      config.onLongPress = onLongPress;
    }
    if (onHorizontalDragUpdate != null) {
      if (_isValidAction(SemanticsAction.scrollRight)) {
        config.onScrollRight = _performSemanticScrollRight;
      }
      if (_isValidAction(SemanticsAction.scrollLeft)) {
        config.onScrollLeft = _performSemanticScrollLeft;
      }
    }
    if (onVerticalDragUpdate != null) {
      if (_isValidAction(SemanticsAction.scrollUp)) {
        config.onScrollUp = _performSemanticScrollUp;
      }
      if (_isValidAction(SemanticsAction.scrollDown)) {
        config.onScrollDown = _performSemanticScrollDown;
      }
    }
  }

  bool _isValidAction(SemanticsAction action) {
    return validActions == null || validActions!.contains(action);
  }

  void _performSemanticScrollLeft() {
    if (onHorizontalDragUpdate != null) {
      final double primaryDelta = size.width * -scrollFactor;
      onHorizontalDragUpdate!(DragUpdateDetails(
        delta: Offset(primaryDelta, 0.0),
        primaryDelta: primaryDelta,
        globalPosition: localToGlobal(size.center(Offset.zero)),
      ));
    }
  }

  void _performSemanticScrollRight() {
    if (onHorizontalDragUpdate != null) {
      final double primaryDelta = size.width * scrollFactor;
      onHorizontalDragUpdate!(DragUpdateDetails(
        delta: Offset(primaryDelta, 0.0),
        primaryDelta: primaryDelta,
        globalPosition: localToGlobal(size.center(Offset.zero)),
      ));
    }
  }

  void _performSemanticScrollUp() {
    if (onVerticalDragUpdate != null) {
      final double primaryDelta = size.height * -scrollFactor;
      onVerticalDragUpdate!(DragUpdateDetails(
        delta: Offset(0.0, primaryDelta),
        primaryDelta: primaryDelta,
        globalPosition: localToGlobal(size.center(Offset.zero)),
      ));
    }
  }

  void _performSemanticScrollDown() {
    if (onVerticalDragUpdate != null) {
      final double primaryDelta = size.height * scrollFactor;
      onVerticalDragUpdate!(DragUpdateDetails(
        delta: Offset(0.0, primaryDelta),
        primaryDelta: primaryDelta,
        globalPosition: localToGlobal(size.center(Offset.zero)),
      ));
    }
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    final List<String> gestures = <String>[
      if (onTap != null) 'tap',
      if (onLongPress != null) 'long press',
      if (onHorizontalDragUpdate != null) 'horizontal scroll',
      if (onVerticalDragUpdate != null) 'vertical scroll',
    ];
    if (gestures.isEmpty) {
      gestures.add('<none>');
    }
    properties.add(IterableProperty<String>('gestures', gestures));
  }
}
