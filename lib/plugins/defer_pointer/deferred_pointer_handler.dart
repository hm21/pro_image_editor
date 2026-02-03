// ignore_for_file: public_member_api_docs

part of 'defer_pointer.dart';

/// Handles paint and hit testing for descendant [DeferPointer] widgets.
/// Deferred painting (aka 'paint on top') is optional and can be defined per
/// [DeferPointer].
class DeferredPointerHandler extends StatefulWidget {
  const DeferredPointerHandler({
    super.key,
    required this.child,
    this.link,
    this.id,
    this.selectedLayerId,
  });
  final Widget child;
  final DeferredPointerHandlerLink? link;
  final String? id;
  final String? selectedLayerId;

  @override
  DeferredPointerHandlerState createState() => DeferredPointerHandlerState();

  /// The state from the closest instance of this class that encloses the given
  /// context, or null if there is no instance in the tree.
  static DeferredPointerHandlerState? maybeOf(BuildContext context) {
    final inherited = context
        .dependOnInheritedWidgetOfExactType<_InheritedDeferredPaintSurface>();
    return inherited?.state;
  }

  /// The state from the closest instance of this class that encloses the given
  /// context.
  static DeferredPointerHandlerState of(BuildContext context) {
    final DeferredPointerHandlerState? result = maybeOf(context);
    assert(
        result != null, 'DeferredPaintSurface was not found on this context.');
    return result!;
  }
}

/// Holds an internal [DeferredPointerHandlerLink] which can be found using
/// [DeferredPointerHandler].of(context).link.
/// Also accepts an external link which will be used instead of the internal
/// one.
class DeferredPointerHandlerState extends State<DeferredPointerHandler> {
  final DeferredPointerHandlerLink _link = DeferredPointerHandlerLink();
  DeferredPointerHandlerLink get link => _link;

  late String _id;

  @override
  void initState() {
    super.initState();
    _setId();
  }

  void _setId() {
    _id = widget.id ?? generateUniqueId();
  }

  @override
  void didUpdateWidget(covariant DeferredPointerHandler oldWidget) {
    if (widget.link != null) {
      _link.removeAll();
    }
    if (widget.id != oldWidget.id) _setId();
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return DeferManager(
      id: _id,
      selectedLayerId: widget.selectedLayerId ?? '',
      child: _InheritedDeferredPaintSurface(
        state: this,
        child: _DeferredHitTargetRenderObjectWidget(
          link: widget.link ?? _link,
          child: widget.child,
        ),
      ),
    );
  }
}

////////////////////////////////
// RENDER OBJECT WIDGET
class _DeferredHitTargetRenderObjectWidget
    extends SingleChildRenderObjectWidget {
  const _DeferredHitTargetRenderObjectWidget({
    required this.link,
    super.child,
  });

  final DeferredPointerHandlerLink link;

  @override
  RenderObject createRenderObject(BuildContext context) =>
      _DeferredHitTargetRenderObject(link);

  @override
  void updateRenderObject(
          BuildContext context, _DeferredHitTargetRenderObject renderObject) =>
      renderObject.link = link;
}

////////////////////////////////
// RENDER OBJECT PAINTER
class _DeferredHitTargetRenderObject extends RenderProxyBox {
  _DeferredHitTargetRenderObject(DeferredPointerHandlerLink link,
      [RenderBox? child])
      : super(child) {
    this.link = link;
  }

  DeferredPointerHandlerLink? _link;
  DeferredPointerHandlerLink get link => _link!;
  set link(DeferredPointerHandlerLink link) {
    if (_link != null) {
      _link!.removeListener(markNeedsPaint);
    }
    _link = link;
    this.link.addListener(markNeedsPaint);
    markNeedsPaint();
  }

  @override
  bool hitTest(BoxHitTestResult result, {required Offset position}) {
    for (final painter in link.painters.reversed) {
      final hit = result.addWithPaintTransform(
        transform: painter.child!.getTransformTo(this),
        position: position,
        hitTest: (BoxHitTestResult result, Offset? position) {
          return painter.child!.hitTest(result, position: position!);
        },
      );
      if (hit) {
        return true;
      }
    }
    return child?.hitTest(result, position: position) ?? false;
  }

  @override
  // paint all the children that want to be rendered on top
  void paint(PaintingContext context, Offset offset) {
    super.paint(context, offset);
    for (final painter in link.painters) {
      if (painter.deferPaint == false) continue;
      context.paintChild(
        painter.child!,
        painter.child!.localToGlobal(Offset.zero, ancestor: this) + offset,
      );
    }
  }
}

////////////////////////////////
// INHERITED WIDGET
class _InheritedDeferredPaintSurface extends InheritedWidget {
  const _InheritedDeferredPaintSurface(
      {required super.child, required this.state});

  final DeferredPointerHandlerState state;
  @override
  bool updateShouldNotify(covariant InheritedWidget oldWidget) => false;
}

class DeferManager extends InheritedWidget {
  const DeferManager({
    super.key,
    required super.child,
    required this.id,
    this.selectedLayerId = '',
  });

  final String selectedLayerId;
  final String id;

  static DeferManager? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<DeferManager>();
  }

  static DeferManager of(BuildContext context) {
    final DeferManager? result = maybeOf(context);
    assert(result != null, 'No DeferManager found in context');
    return result!;
  }

  @override
  bool updateShouldNotify(DeferManager oldWidget) =>
      id != oldWidget.id || selectedLayerId != oldWidget.selectedLayerId;
}
