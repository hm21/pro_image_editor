// Flutter imports:
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

// Project imports:
import 'outside_gesture_behavior.dart';
import 'outside_gesture_listener.dart';
import 'outside_render_semantics_gesture_handler.dart';

/// OutsideRawGestureDetector
class OutsideRawGestureDetector extends StatefulWidget {
  /// Creates a widget that detects gestures.
  ///
  /// Gesture detectors can contribute semantic information to the tree that is
  /// used by assistive technology. The behavior can be configured by
  /// [semantics], or disabled with [excludeFromSemantics].
  const OutsideRawGestureDetector({
    super.key,
    this.child,
    this.gestures = const <Type, GestureRecognizerFactory>{},
    this.behavior,
    this.excludeFromSemantics = false,
    this.externListener = false,
    this.semantics,
  });

  /// Listener is external
  final bool externListener;

  /// The widget below this widget in the tree.
  ///
  /// {@macro flutter.widgets.ProxyWidget.child}
  final Widget? child;

  /// The gestures that this widget will attempt to recognize.
  ///
  /// This should be a map from [GestureRecognizer] subclasses to
  /// [GestureRecognizerFactory] subclasses specialized with the same type.
  ///
  /// This value can be late-bound at layout time using
  /// [OutsideRawGestureDetectorState.replaceGestureRecognizers].
  final Map<Type, GestureRecognizerFactory> gestures;

  /// How this gesture detector should behave during hit testing.
  ///
  /// This defaults to [OutsideHitTestBehavior.deferToChild] if [child] is not
  /// null and
  /// [OutsideHitTestBehavior.translucent] if child is null.
  final OutsideHitTestBehavior? behavior;

  /// Whether to exclude these gestures from the semantics tree. For
  /// example, the long-press gesture for showing a tooltip is
  /// excluded because the tooltip itself is included in the semantics
  /// tree directly and so having a gesture to show it would result in
  /// duplication of information.
  final bool excludeFromSemantics;

  /// Describes the semantics notations that should be added to the underlying
  /// render object [OutsideRenderSemanticsGestureHandler].
  ///
  /// It has no effect if [excludeFromSemantics] is true.
  ///
  /// When [semantics] is null, [OutsideRawGestureDetector] will fall back to a
  /// default delegate which checks if the detector owns certain gesture
  /// recognizers and calls their callbacks if they exist:
  ///
  ///  * During a semantic tap, it calls [TapGestureRecognizer]'s
  ///    `onTapDown`, `onTapUp`, and `onTap`.
  ///  * During a semantic long press, it calls [LongPressGestureRecognizer]'s
  ///    `onLongPressDown`, `onLongPressStart`, `onLongPress`, `onLongPressEnd`
  ///    and `onLongPressUp`.
  ///  * During a semantic horizontal drag, it calls
  /// [HorizontalDragGestureRecognizer]'s
  ///    `onDown`, `onStart`, `onUpdate` and `onEnd`, then
  ///    [PanGestureRecognizer]'s `onDown`, `onStart`, `onUpdate` and `onEnd`.
  ///  * During a semantic vertical drag, it calls
  /// [VerticalDragGestureRecognizer]'s
  ///    `onDown`, `onStart`, `onUpdate` and `onEnd`, then
  ///    [PanGestureRecognizer]'s `onDown`, `onStart`, `onUpdate` and `onEnd`.
  ///
  /// {@tool snippet}
  /// This custom gesture detector listens to force presses, while also allows
  /// the same callback to be triggered by semantic long presses.
  ///
  /// ```dart
  /// class ForcePressGestureDetectorWithSemantics extends StatelessWidget {
  ///   const ForcePressGestureDetectorWithSemantics({
  ///     super.key,
  ///     required this.child,
  ///     required this.onForcePress,
  ///   });
  ///
  ///   final Widget child;
  ///   final VoidCallback onForcePress;
  ///
  ///   @override
  ///   Widget build(BuildContext context) {
  ///     return RawGestureDetector(
  ///       gestures: <Type, GestureRecognizerFactory>{
  ///         ForcePressGestureRecognizer:
  /// GestureRecognizerFactoryWithHandlers<ForcePressGestureRecognizer>(
  ///           () => ForcePressGestureRecognizer(debugOwner: this),
  ///           (ForcePressGestureRecognizer instance) {
  ///             instance.onStart = (_) => onForcePress();
  ///           }
  ///         ),
  ///       },
  ///       behavior: OutsideHitTestBehavior.opaque,
  ///       semantics: _LongPressSemanticsDelegate(onForcePress),
  ///       child: child,
  ///     );
  ///   }
  /// }
  ///
  /// class _LongPressSemanticsDelegate extends SemanticsGestureDelegate {
  ///   _LongPressSemanticsDelegate(this.onLongPress);
  ///
  ///   VoidCallback onLongPress;
  ///
  ///   @override
  ///   void assignSemantics(OutsideRenderSemanticsGestureHandler renderObject)
  /// {
  ///     renderObject.onLongPress = onLongPress;
  ///   }
  /// }
  /// ```
  /// {@end-tool}
  final SemanticsGestureDelegate? semantics;

  @override
  OutsideRawGestureDetectorState createState() =>
      OutsideRawGestureDetectorState();
}

/// State for a [OutsideRawGestureDetector].
class OutsideRawGestureDetectorState extends State<OutsideRawGestureDetector> {
  Map<Type, GestureRecognizer>? _recognizers =
      const <Type, GestureRecognizer>{};
  SemanticsGestureDelegate? _semantics;

  @override
  void initState() {
    super.initState();
    _semantics = widget.semantics ?? _DefaultSemanticsGestureDelegate(this);
    _syncAll(widget.gestures);
  }

  @override
  void didUpdateWidget(OutsideRawGestureDetector oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!(oldWidget.semantics == null && widget.semantics == null)) {
      _semantics = widget.semantics ?? _DefaultSemanticsGestureDelegate(this);
    }
    _syncAll(widget.gestures);
  }

  /// This method can be called after the build phase, during the
  /// layout of the nearest descendant [RenderObjectWidget] of the
  /// gesture detector, to update the list of active gesture
  /// recognizers.
  ///
  /// The typical use case is [Scrollable]s, which put their viewport
  /// in their gesture detector, and then need to know the dimensions
  /// of the viewport and the viewport's child to determine whether
  /// the gesture detector should be enabled.
  ///
  /// The argument should follow the same conventions as
  /// [OutsideRawGestureDetector.gestures]. It acts like a temporary
  /// replacement for
  /// that value until the next build.
  void replaceGestureRecognizers(Map<Type, GestureRecognizerFactory> gestures) {
    assert(() {
      if (!context.findRenderObject()!.owner!.debugDoingLayout) {
        throw FlutterError.fromParts(<DiagnosticsNode>[
          ErrorSummary(
              'Unexpected call to replaceGestureRecognizers() method of '
              'RawGestureDetectorState.'),
          ErrorDescription(
              'The replaceGestureRecognizers() method can only be called '
              'during the layout phase.'),
          ErrorHint(
            'To set the gesture recognizers at other times, trigger a new '
            'build using setState() '
            'and provide the new gesture recognizers as constructor arguments '
            'to the corresponding '
            'RawGestureDetector or GestureDetector object.',
          ),
        ]);
      }
      return true;
    }());
    _syncAll(gestures);
    if (!widget.excludeFromSemantics) {
      final OutsideRenderSemanticsGestureHandler semanticsGestureHandler =
          context.findRenderObject()! as OutsideRenderSemanticsGestureHandler;
      _updateSemanticsForRenderObject(semanticsGestureHandler);
    }
  }

  /// This method can be called to filter the list of available semantic
  /// actions,
  /// after the render object was created.
  ///
  /// The actual filtering is happening in the next frame and a frame will be
  /// scheduled if non is pending.
  ///
  /// This is used by [Scrollable] to configure system accessibility tools so
  /// that they know in which direction a particular list can be scrolled.
  ///
  /// If this is never called, then the actions are not filtered. If the list of
  /// actions to filter changes, it must be called again.
  void replaceSemanticsActions(Set<SemanticsAction> actions) {
    if (widget.excludeFromSemantics) {
      return;
    }

    final OutsideRenderSemanticsGestureHandler? semanticsGestureHandler =
        context.findRenderObject() as OutsideRenderSemanticsGestureHandler?;
    assert(() {
      if (semanticsGestureHandler == null) {
        throw FlutterError(
          'Unexpected call to replaceSemanticsActions() method of '
          'RawGestureDetectorState.\n'
          'The replaceSemanticsActions() method can only be called after the '
          'OutsideRenderSemanticsGestureHandler has been created.',
        );
      }
      return true;
    }());

    semanticsGestureHandler!.validActions =
        actions; // will call _markNeedsSemanticsUpdate(), if required.
  }

  @override
  void dispose() {
    for (final GestureRecognizer recognizer in _recognizers!.values) {
      recognizer.dispose();
    }
    _recognizers = null;
    super.dispose();
  }

  void _syncAll(Map<Type, GestureRecognizerFactory> gestures) {
    assert(_recognizers != null);
    final Map<Type, GestureRecognizer> oldRecognizers = _recognizers!;
    _recognizers = <Type, GestureRecognizer>{};
    for (final Type type in gestures.keys) {
      assert(gestures[type] != null);
      /*  assert(gestures[type]!._debugAssertTypeMatches(type)); */
      assert(!_recognizers!.containsKey(type));
      _recognizers![type] =
          oldRecognizers[type] ?? gestures[type]!.constructor();
      assert(
          _recognizers![type].runtimeType == type,
          'GestureRecognizerFactory of type $type created a GestureRecognizer'
          'of type ${_recognizers![type].runtimeType}. The '
          'GestureRecognizerFactory must be specialized with the type of the '
          'class that it returns from its constructor method.');
      gestures[type]!.initializer(_recognizers![type]!);
    }
    for (final Type type in oldRecognizers.keys) {
      if (!_recognizers!.containsKey(type)) {
        oldRecognizers[type]!.dispose();
      }
    }
  }

  /// Handles pointer down events for gesture recognition.
  ///
  /// This method is called when a pointer (such as a finger or stylus) is
  /// detected to be in contact with the screen. It adds the pointer event to
  /// each gesture recognizer present in the `_recognizers` collection,
  /// enabling them to begin tracking the gesture.
  ///
  /// The method assumes that `_recognizers` is not null, and asserts this
  /// condition to ensure the gesture recognizers are initialized before
  /// handling events.
  ///
  /// - Parameter event: The pointer event containing details about the pointer
  ///   contact, such as its position and device type.
  void handlePointerDown(PointerDownEvent event) {
    assert(_recognizers != null);
    for (final GestureRecognizer recognizer in _recognizers!.values) {
      recognizer.addPointer(event);
    }
  }

  /// Handles pointer pan-zoom start events for gesture recognition.
  ///
  /// This method is called when a pan-zoom gesture begins, such as when a user
  /// starts a two-finger pinch gesture on the screen. It adds the pan-zoom
  /// start event to each gesture recognizer present in the `_recognizers`
  /// collection, enabling them to track the gesture's progress.
  ///
  /// The method assumes that `_recognizers` is not null, and asserts this
  /// condition to ensure the gesture recognizers are initialized before
  /// handling events.
  ///
  /// - Parameter event: The pan-zoom start event containing details about the
  ///   initial state of the pan-zoom gesture, such as the focal point and
  /// scale.
  void handlePointerPanZoomStart(PointerPanZoomStartEvent event) {
    assert(_recognizers != null);
    for (final GestureRecognizer recognizer in _recognizers!.values) {
      recognizer.addPointerPanZoom(event);
    }
  }

  OutsideHitTestBehavior get _defaultBehavior {
    return widget.child == null
        ? OutsideHitTestBehavior.translucent
        : OutsideHitTestBehavior.deferToChild;
  }

  void _updateSemanticsForRenderObject(
      OutsideRenderSemanticsGestureHandler renderObject) {
    assert(!widget.excludeFromSemantics);
    assert(_semantics != null);
    _semantics!.assignSemantics(renderObject);
  }

  @override
  Widget build(BuildContext context) {
    Widget result = widget.externListener && widget.child != null
        ? (widget.child!)
        : OutsideListener(
            onPointerDown: handlePointerDown,
            onPointerPanZoomStart: handlePointerPanZoomStart,
            behavior: widget.behavior ?? _defaultBehavior,
            child: widget.child,
          );
    if (!widget.excludeFromSemantics) {
      result = _GestureSemantics(
        behavior: widget.behavior ?? _defaultBehavior,
        assignSemantics: _updateSemanticsForRenderObject,
        child: result,
      );
    }
    return result;
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    if (_recognizers == null) {
      properties.add(DiagnosticsNode.message('DISPOSED'));
    } else {
      final List<String> gestures = _recognizers!.values
          .map<String>(
              (GestureRecognizer recognizer) => recognizer.debugDescription)
          .toList();
      properties
        ..add(IterableProperty<String>('gestures', gestures, ifEmpty: '<none>'))
        ..add(IterableProperty<GestureRecognizer>(
            'recognizers', _recognizers!.values,
            level: DiagnosticLevel.fine))
        ..add(DiagnosticsProperty<bool>(
            'excludeFromSemantics', widget.excludeFromSemantics,
            defaultValue: false));
      if (!widget.excludeFromSemantics) {
        properties.add(DiagnosticsProperty<SemanticsGestureDelegate>(
            'semantics', widget.semantics,
            defaultValue: null));
      }
    }
    properties.add(EnumProperty<OutsideHitTestBehavior>(
        'behavior', widget.behavior,
        defaultValue: null));
  }
}

class _DefaultSemanticsGestureDelegate extends SemanticsGestureDelegate {
  _DefaultSemanticsGestureDelegate(this.detectorState);

  final OutsideRawGestureDetectorState detectorState;

  @override
  void assignSemantics(OutsideRenderSemanticsGestureHandler renderObject) {
    assert(!detectorState.widget.excludeFromSemantics);
    final Map<Type, GestureRecognizer> recognizers =
        detectorState._recognizers!;
    renderObject
      ..onTap = _getTapHandler(recognizers)
      ..onLongPress = _getLongPressHandler(recognizers)
      ..onHorizontalDragUpdate = _getHorizontalDragUpdateHandler(recognizers)
      ..onVerticalDragUpdate = _getVerticalDragUpdateHandler(recognizers);
  }

  GestureTapCallback? _getTapHandler(Map<Type, GestureRecognizer> recognizers) {
    final TapGestureRecognizer? tap =
        recognizers[TapGestureRecognizer] as TapGestureRecognizer?;
    if (tap == null) {
      return null;
    }

    return () {
      tap.onTapDown?.call(TapDownDetails());
      tap.onTapUp?.call(TapUpDetails(kind: PointerDeviceKind.unknown));
      tap.onTap?.call();
    };
  }

  GestureLongPressCallback? _getLongPressHandler(
      Map<Type, GestureRecognizer> recognizers) {
    final LongPressGestureRecognizer? longPress =
        recognizers[LongPressGestureRecognizer] as LongPressGestureRecognizer?;
    if (longPress == null) {
      return null;
    }

    return () {
      longPress.onLongPressDown?.call(const LongPressDownDetails());
      longPress.onLongPressStart?.call(const LongPressStartDetails());
      longPress.onLongPress?.call();
      longPress.onLongPressEnd?.call(const LongPressEndDetails());
      longPress.onLongPressUp?.call();
    };
  }

  GestureDragUpdateCallback? _getHorizontalDragUpdateHandler(
      Map<Type, GestureRecognizer> recognizers) {
    final HorizontalDragGestureRecognizer? horizontal =
        recognizers[HorizontalDragGestureRecognizer]
            as HorizontalDragGestureRecognizer?;
    final PanGestureRecognizer? pan =
        recognizers[PanGestureRecognizer] as PanGestureRecognizer?;

    final GestureDragUpdateCallback? horizontalHandler = horizontal == null
        ? null
        : (DragUpdateDetails details) {
            horizontal.onDown?.call(DragDownDetails());
            horizontal.onStart?.call(DragStartDetails());
            horizontal.onUpdate?.call(details);
            horizontal.onEnd?.call(DragEndDetails(primaryVelocity: 0.0));
          };

    final GestureDragUpdateCallback? panHandler = pan == null
        ? null
        : (DragUpdateDetails details) {
            pan.onDown?.call(DragDownDetails());
            pan.onStart?.call(DragStartDetails());
            pan.onUpdate?.call(details);
            pan.onEnd?.call(DragEndDetails());
          };

    if (horizontalHandler == null && panHandler == null) {
      return null;
    }
    return (DragUpdateDetails details) {
      if (horizontalHandler != null) {
        horizontalHandler(details);
      }
      if (panHandler != null) {
        panHandler(details);
      }
    };
  }

  GestureDragUpdateCallback? _getVerticalDragUpdateHandler(
      Map<Type, GestureRecognizer> recognizers) {
    final VerticalDragGestureRecognizer? vertical =
        recognizers[VerticalDragGestureRecognizer]
            as VerticalDragGestureRecognizer?;
    final PanGestureRecognizer? pan =
        recognizers[PanGestureRecognizer] as PanGestureRecognizer?;

    final GestureDragUpdateCallback? verticalHandler = vertical == null
        ? null
        : (DragUpdateDetails details) {
            vertical.onDown?.call(DragDownDetails());
            vertical.onStart?.call(DragStartDetails());
            vertical.onUpdate?.call(details);
            vertical.onEnd?.call(DragEndDetails(primaryVelocity: 0.0));
          };

    final GestureDragUpdateCallback? panHandler = pan == null
        ? null
        : (DragUpdateDetails details) {
            pan.onDown?.call(DragDownDetails());
            pan.onStart?.call(DragStartDetails());
            pan.onUpdate?.call(details);
            pan.onEnd?.call(DragEndDetails());
          };

    if (verticalHandler == null && panHandler == null) {
      return null;
    }
    return (DragUpdateDetails details) {
      if (verticalHandler != null) {
        verticalHandler(details);
      }
      if (panHandler != null) {
        panHandler(details);
      }
    };
  }
}

class _GestureSemantics extends SingleChildRenderObjectWidget {
  const _GestureSemantics({
    super.child,
    required this.behavior,
    required this.assignSemantics,
  });

  final OutsideHitTestBehavior behavior;
  final _AssignSemantics assignSemantics;

  @override
  OutsideRenderSemanticsGestureHandler createRenderObject(
      BuildContext context) {
    final OutsideRenderSemanticsGestureHandler renderObject =
        OutsideRenderSemanticsGestureHandler()..behavior = behavior;
    assignSemantics(renderObject);
    return renderObject;
  }

  @override
  void updateRenderObject(
      BuildContext context, OutsideRenderSemanticsGestureHandler renderObject) {
    renderObject.behavior = behavior;
    assignSemantics(renderObject);
  }
}

typedef _AssignSemantics = void Function(OutsideRenderSemanticsGestureHandler);

/// SemanticsGestureDelegate
abstract class SemanticsGestureDelegate {
  /// Create a delegate of gesture semantics.
  const SemanticsGestureDelegate();

  /// Assigns semantics notations to the [OutsideRenderSemanticsGestureHandler]
  /// render object of the gesture detector.
  ///
  /// This method is called when the widget is created, updated, or during
  /// [RawGestureDetectorState.replaceGestureRecognizers].
  void assignSemantics(OutsideRenderSemanticsGestureHandler renderObject);

  @override
  String toString() =>
      '${objectRuntimeType(this, 'SemanticsGestureDelegate')}()';
}
