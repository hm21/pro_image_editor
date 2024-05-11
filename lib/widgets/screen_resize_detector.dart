import 'package:flutter/material.dart';
import '../utils/debounce.dart';

/// A widget that detects changes in screen size and notifies listeners.
///
/// This widget listens to screen size changes using [LayoutBuilder] and triggers
/// [onResizeUpdate] and [onResizeEnd] callbacks accordingly.
///
/// When the screen size changes, [onResizeUpdate] is called immediately and [onResizeEnd]
/// is called after a debounce duration to handle resize events efficiently.
///
/// Parameters:
/// - [child]: The child widget to render.
/// - [onResizeUpdate]: A callback function called when the screen size changes.
/// - [onResizeEnd]: A callback function called when the screen resize ends.
/// - [imageMargin]: The margin around the image.
class ScreenResizeDetector extends StatefulWidget {
  final Widget child;
  final Function(ResizeEvent) onResizeUpdate;
  final Function(ResizeEvent) onResizeEnd;
  final EdgeInsets imageMargin;

  const ScreenResizeDetector({
    super.key,
    required this.child,
    required this.onResizeUpdate,
    required this.onResizeEnd,
    required this.imageMargin,
  });

  @override
  State<ScreenResizeDetector> createState() => _ScreenResizeDetectorState();
}

class _ScreenResizeDetectorState extends State<ScreenResizeDetector> {
  EdgeInsets _startImageMargin = EdgeInsets.zero;
  BoxConstraints _startResizeEvent = const BoxConstraints();
  BoxConstraints _lastConstraints = const BoxConstraints();
  late Debounce _resizeDebounce$;
  bool _activeResizing = false;

  @override
  void initState() {
    _resizeDebounce$ = Debounce(const Duration(milliseconds: 50));
    super.initState();
  }

  @override
  void dispose() {
    _resizeDebounce$.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      if (constraints.biggest != _lastConstraints.biggest) {
        widget.onResizeUpdate(ResizeEvent(
          oldConstraints: _lastConstraints,
          newConstraints: constraints,
          imageMargin: widget.imageMargin,
        ));
        _lastConstraints = constraints;

        if (!_activeResizing) {
          _startResizeEvent = constraints;
          _startImageMargin = widget.imageMargin;
          _activeResizing = true;
        }

        _resizeDebounce$(() {
          widget.onResizeEnd(ResizeEvent(
            oldConstraints: _startResizeEvent,
            newConstraints: constraints,
            imageMargin: _startImageMargin,
          ));
          _activeResizing = false;
        });
      }

      return widget.child;
    });
  }
}

/// Represents an event when the screen is resized.
class ResizeEvent {
  /// The old constraints before the resize.
  final BoxConstraints oldConstraints;

  /// The new constraints after the resize.
  final BoxConstraints newConstraints;

  /// The margin around the image.
  final EdgeInsets imageMargin;

  const ResizeEvent({
    required this.oldConstraints,
    required this.newConstraints,
    required this.imageMargin,
  });

  /// Gets the change in width after the resize.
  double get widthChanged => newConstraints.maxWidth - oldConstraints.maxWidth;

  /// Gets the change in height after the resize.
  double get heightChanged =>
      newConstraints.maxHeight - oldConstraints.maxHeight;
}
