// Flutter imports:
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

/// [ExtendedRebuildMouseRegion] is a stateful widget that allows you to handle
/// mouse events and update the mouse cursor without rebuilding the child
/// widget.
/// This widget provides a method to change the cursor dynamically,
/// ensuring only the cursor is rebuilt while the child remains unchanged.
///
/// This is useful for scenarios where you need to dynamically change the cursor
/// style in response to user interactions without affecting the underlying
/// widget tree.
///
/// The [onEnter], [onExit], and [onHover] parameters allow you to handle mouse
/// events.
/// The [initCursor] parameter sets the initial cursor style,
/// the [opaque] parameter specifies whether the region is opaque,
/// and the [hitTestBehavior] parameter defines the hit test behavior.
/// The [child] parameter is the widget to be enclosed within the mouse region.
class ExtendedRebuildMouseRegion extends StatefulWidget {
  /// Creates an instance of [ExtendedRebuildMouseRegion].
  ///
  /// The [child] parameter is required and specifies the widget that will be
  /// displayed within the mouse region. The other parameters are optional:
  const ExtendedRebuildMouseRegion({
    super.key,
    this.onEnter,
    this.onExit,
    this.onHover,
    this.initCursor = MouseCursor.defer,
    this.opaque = true,
    this.hitTestBehavior,
    required this.child,
  });

  /// Callback when the mouse enters the region.
  final PointerEnterEventListener? onEnter;

  /// Callback when the mouse exits the region.
  final PointerExitEventListener? onExit;

  /// Callback when the mouse hovers over the region.
  final PointerHoverEventListener? onHover;

  /// The cursor to display when the mouse is over the region.
  final MouseCursor initCursor;

  /// Whether the region is opaque.
  final bool opaque;

  /// The behavior during hit testing.
  final HitTestBehavior? hitTestBehavior;

  /// The widget to be enclosed within the mouse region.
  final Widget child;

  @override
  State<ExtendedRebuildMouseRegion> createState() =>
      ExtendedRebuildMouseRegionState();
}

/// State class for [ExtendedRebuildMouseRegion], managing the mouse cursor.
class ExtendedRebuildMouseRegionState
    extends State<ExtendedRebuildMouseRegion> {
  /// The current mouse cursor to be displayed within the region.
  late MouseCursor currentCursor;

  @override
  void initState() {
    super.initState();
    currentCursor = widget.initCursor;
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: widget.onEnter,
      onExit: widget.onExit,
      onHover: widget.onHover,
      cursor: currentCursor,
      opaque: widget.opaque,
      hitTestBehavior: widget.hitTestBehavior,
      child: widget.child,
    );
  }

  /// Updates the mouse cursor and triggers a rebuild of the cursor.
  /// This does not rebuild the child widget, making it efficient for
  /// dynamic cursor changes.
  ///
  /// [cursor] - The new mouse cursor.
  void setCursor(MouseCursor cursor) {
    setState(() {
      currentCursor = cursor;
    });
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);

    properties
      ..add(DiagnosticsProperty<PointerEnterEventListener?>(
          'onEnter', widget.onEnter,
          defaultValue: null))
      ..add(DiagnosticsProperty<PointerExitEventListener?>(
          'onExit', widget.onExit,
          defaultValue: null))
      ..add(DiagnosticsProperty<PointerHoverEventListener?>(
          'onHover', widget.onHover,
          defaultValue: null))
      ..add(DiagnosticsProperty<MouseCursor>('initCursor', widget.initCursor))
      ..add(DiagnosticsProperty<MouseCursor>('currentCursor', currentCursor))
      ..add(FlagProperty('opaque', value: widget.opaque, ifTrue: 'opaque'))
      ..add(EnumProperty<HitTestBehavior?>(
          'hitTestBehavior', widget.hitTestBehavior,
          defaultValue: null))
      ..add(DiagnosticsProperty<Widget>('child', widget.child));
  }
}
