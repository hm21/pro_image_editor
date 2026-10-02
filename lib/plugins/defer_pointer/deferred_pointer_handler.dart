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
      result != null,
      'DeferredPaintSurface was not found on this context.',
    );
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
  const _DeferredHitTargetRenderObjectWidget({required this.link, super.child});

  final DeferredPointerHandlerLink link;

  @override
  RenderObject createRenderObject(BuildContext context) =>
      _DeferredHitTargetRenderObject(link);

  @override
  void updateRenderObject(
    BuildContext context,
    _DeferredHitTargetRenderObject renderObject,
  ) => renderObject.link = link;
}

////////////////////////////////
// RENDER OBJECT PAINTER
class _DeferredHitTargetRenderObject extends RenderProxyBox {
  _DeferredHitTargetRenderObject(
    DeferredPointerHandlerLink link, [
    RenderBox? child,
  ]) : super(child) {
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
    for (final painter in _hitTestablePainters().reversed) {
      final painterChild = painter.child;
      if (painterChild == null) continue;
      final hit = result.addWithPaintTransform(
        transform: painterChild.getTransformTo(this),
        position: position,
        hitTest: (BoxHitTestResult result, Offset? position) {
          return painterChild.hitTest(result, position: position!);
        },
      );
      if (hit) {
        return true;
      }
    }
    return child?.hitTest(result, position: position) ?? false;
  }

  /// The painters that may take the pointer, bottom-most first.
  ///
  /// A deferred child is hit-tested directly, which skips every ancestor that
  /// would normally decide whether, and in which order, it gets the pointer.
  /// The render tree between this handler and the painters is walked instead:
  ///
  /// * A painter below an ignoring [IgnorePointer], an absorbing
  ///   [AbsorbPointer] or an [Offstage] is left out. A layer outside its video
  ///   time range is hidden behind such an [IgnorePointer] and kept catching
  ///   touches meant for the visible layer underneath.
  /// * The painters come in paint order rather than in the order they were
  ///   attached. A layer that comes back into its time range is attached
  ///   again, and took touches meant for the layer drawn on top of it.
  ///
  /// Painters outside this handler's subtree, linked through a shared
  /// [DeferredPointerHandlerLink], keep their attach order and are tested
  /// first, as before.
  List<DeferPointerRenderObject> _hitTestablePainters() {
    final painters = link.painters;
    if (painters.isEmpty) return const [];

    final paintersInSubtree = <DeferPointerRenderObject>{};
    final ancestors = <RenderObject>{};
    final external = <DeferPointerRenderObject>[];
    for (final painter in painters) {
      final path = <RenderObject>[];
      var blocked = false;
      RenderObject? node = painter.parent;
      while (node != null && node != this && !ancestors.contains(node)) {
        path.add(node);
        blocked = blocked || _keepsPointerFromChildren(node);
        node = node.parent;
      }
      if (node == null) {
        if (!blocked) external.add(painter);
      } else {
        paintersInSubtree.add(painter);
        ancestors.addAll(path);
      }
    }

    final ordered = <DeferPointerRenderObject>[];
    void visit(RenderObject node) {
      node.visitChildren((child) {
        if (paintersInSubtree.contains(child)) {
          ordered.add(child as DeferPointerRenderObject);
        }
        if (ancestors.contains(child) && !_keepsPointerFromChildren(child)) {
          visit(child);
        }
      });
    }

    visit(this);
    return [...ordered, ...external];
  }

  /// Whether [node] keeps the pointer from its descendants in a normal hit
  /// test.
  static bool _keepsPointerFromChildren(RenderObject node) => switch (node) {
    RenderIgnorePointer(:final ignoring) => ignoring,
    RenderAbsorbPointer(:final absorbing) => absorbing,
    RenderOffstage(:final offstage) => offstage,
    _ => false,
  };

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
  const _InheritedDeferredPaintSurface({
    required super.child,
    required this.state,
  });

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
