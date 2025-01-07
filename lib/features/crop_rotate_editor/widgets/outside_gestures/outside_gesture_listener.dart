// Flutter imports:
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

// Project imports:
import 'outside_gesture_behavior.dart';
import 'outside_render_proxy_box.dart';

/// Extends the OutsideListener
class OutsideListener extends SingleChildRenderObjectWidget {
  /// Creates a widget that forwards point events to callbacks.
  ///
  /// The [behavior] argument defaults to [HitTestBehavior.deferToChild].
  const OutsideListener({
    super.key,
    this.onPointerDown,
    this.onPointerMove,
    this.onPointerUp,
    this.onPointerHover,
    this.onPointerCancel,
    this.onPointerPanZoomStart,
    this.onPointerPanZoomUpdate,
    this.onPointerPanZoomEnd,
    this.onPointerSignal,
    this.behavior = OutsideHitTestBehavior.deferToChild,
    super.child,
  });

  /// Called when a pointer comes into contact with the screen (for touch
  /// pointers), or has its button pressed (for mouse pointers) at this widget's
  /// location.
  final PointerDownEventListener? onPointerDown;

  /// Called when a pointer that triggered an [onPointerDown] changes position.
  final PointerMoveEventListener? onPointerMove;

  /// Called when a pointer that triggered an [onPointerDown] is no longer in
  /// contact with the screen.
  final PointerUpEventListener? onPointerUp;

  /// Called when a pointer that has not triggered an [onPointerDown] changes
  /// position.
  ///
  /// This is only fired for pointers which report their location when not down
  /// (e.g. mouse pointers, but not most touch pointers).
  final PointerHoverEventListener? onPointerHover;

  /// Called when the input from a pointer that triggered an [onPointerDown] is
  /// no longer directed towards this receiver.
  final PointerCancelEventListener? onPointerCancel;

  /// Called when a pan/zoom begins such as from a trackpad gesture.
  final PointerPanZoomStartEventListener? onPointerPanZoomStart;

  /// Called when a pan/zoom is updated.
  final PointerPanZoomUpdateEventListener? onPointerPanZoomUpdate;

  /// Called when a pan/zoom finishes.
  final PointerPanZoomEndEventListener? onPointerPanZoomEnd;

  /// Called when a pointer signal occurs over this object.
  ///
  /// See also:
  ///
  ///  * [PointerSignalEvent], which goes into more detail on pointer signal
  ///    events.
  final PointerSignalEventListener? onPointerSignal;

  /// How to behave during hit testing.
  final OutsideHitTestBehavior behavior;

  @override
  OutsideRenderPointerListener createRenderObject(BuildContext context) {
    return OutsideRenderPointerListener(
      onPointerDown: onPointerDown,
      onPointerMove: onPointerMove,
      onPointerUp: onPointerUp,
      onPointerHover: onPointerHover,
      onPointerCancel: onPointerCancel,
      onPointerPanZoomStart: onPointerPanZoomStart,
      onPointerPanZoomUpdate: onPointerPanZoomUpdate,
      onPointerPanZoomEnd: onPointerPanZoomEnd,
      onPointerSignal: onPointerSignal,
      behavior: behavior,
    );
  }

  @override
  void updateRenderObject(
      BuildContext context, OutsideRenderPointerListener renderObject) {
    renderObject
      ..onPointerDown = onPointerDown
      ..onPointerMove = onPointerMove
      ..onPointerUp = onPointerUp
      ..onPointerHover = onPointerHover
      ..onPointerCancel = onPointerCancel
      ..onPointerPanZoomStart = onPointerPanZoomStart
      ..onPointerPanZoomUpdate = onPointerPanZoomUpdate
      ..onPointerPanZoomEnd = onPointerPanZoomEnd
      ..onPointerSignal = onPointerSignal
      ..behavior = behavior;
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    final List<String> listeners = <String>[
      if (onPointerDown != null) 'down',
      if (onPointerMove != null) 'move',
      if (onPointerUp != null) 'up',
      if (onPointerHover != null) 'hover',
      if (onPointerCancel != null) 'cancel',
      if (onPointerPanZoomStart != null) 'panZoomStart',
      if (onPointerPanZoomUpdate != null) 'panZoomUpdate',
      if (onPointerPanZoomEnd != null) 'panZoomEnd',
      if (onPointerSignal != null) 'signal',
    ];
    properties
      ..add(IterableProperty<String>('listeners', listeners, ifEmpty: '<none>'))
      ..add(EnumProperty<OutsideHitTestBehavior>('behavior', behavior));
  }
}

/// Extends the OutsidePointerListener
class OutsideRenderPointerListener
    extends OutsideRenderProxyBoxWithHitTestBehavior {
  /// Creates a render object that forwards pointer events to callbacks.
  ///
  /// The [behavior] argument defaults to [OutsideHitTestBehavior.deferToChild].
  OutsideRenderPointerListener({
    this.onPointerDown,
    this.onPointerMove,
    this.onPointerUp,
    this.onPointerHover,
    this.onPointerCancel,
    this.onPointerPanZoomStart,
    this.onPointerPanZoomUpdate,
    this.onPointerPanZoomEnd,
    this.onPointerSignal,
    super.behavior,
    super.child,
  });

  /// Called when a pointer comes into contact with the screen (for touch
  /// pointers), or has its button pressed (for mouse pointers) at this widget's
  /// location.
  PointerDownEventListener? onPointerDown;

  /// Called when a pointer that triggered an [onPointerDown] changes position.
  PointerMoveEventListener? onPointerMove;

  /// Called when a pointer that triggered an [onPointerDown] is no longer in
  /// contact with the screen.
  PointerUpEventListener? onPointerUp;

  /// Called when a pointer that has not an [onPointerDown] changes position.
  PointerHoverEventListener? onPointerHover;

  /// Called when the input from a pointer that triggered an [onPointerDown] is
  /// no longer directed towards this receiver.
  PointerCancelEventListener? onPointerCancel;

  /// Called when a pan/zoom begins such as from a trackpad gesture.
  PointerPanZoomStartEventListener? onPointerPanZoomStart;

  /// Called when a pan/zoom is updated.
  PointerPanZoomUpdateEventListener? onPointerPanZoomUpdate;

  /// Called when a pan/zoom finishes.
  PointerPanZoomEndEventListener? onPointerPanZoomEnd;

  /// Called when a pointer signal occurs over this object.
  PointerSignalEventListener? onPointerSignal;

  @override
  Size computeSizeForNoChild(BoxConstraints constraints) {
    return constraints.biggest;
  }

  @override
  void handleEvent(PointerEvent event, HitTestEntry entry) {
    assert(debugHandleEvent(event, entry));
    if (event is PointerDownEvent) {
      return onPointerDown?.call(event);
    }
    if (event is PointerMoveEvent) {
      return onPointerMove?.call(event);
    }
    if (event is PointerUpEvent) {
      return onPointerUp?.call(event);
    }
    if (event is PointerHoverEvent) {
      return onPointerHover?.call(event);
    }
    if (event is PointerCancelEvent) {
      return onPointerCancel?.call(event);
    }
    if (event is PointerPanZoomStartEvent) {
      return onPointerPanZoomStart?.call(event);
    }
    if (event is PointerPanZoomUpdateEvent) {
      return onPointerPanZoomUpdate?.call(event);
    }
    if (event is PointerPanZoomEndEvent) {
      return onPointerPanZoomEnd?.call(event);
    }
    if (event is PointerSignalEvent) {
      return onPointerSignal?.call(event);
    }
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(FlagsSummary<Function?>(
      'listeners',
      <String, Function?>{
        'down': onPointerDown,
        'move': onPointerMove,
        'up': onPointerUp,
        'hover': onPointerHover,
        'cancel': onPointerCancel,
        'panZoomStart': onPointerPanZoomStart,
        'panZoomUpdate': onPointerPanZoomUpdate,
        'panZoomEnd': onPointerPanZoomEnd,
        'signal': onPointerSignal,
      },
      ifEmpty: '<none>',
    ));
  }
}
