import 'package:flutter/material.dart';

import '../utils/debounce.dart';

// TODO: write docs
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
    _resizeDebounce$ = Debounce(const Duration(milliseconds: 250));
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

class ResizeEvent {
  final BoxConstraints oldConstraints;
  final BoxConstraints newConstraints;
  final EdgeInsets imageMargin;

  const ResizeEvent({
    required this.oldConstraints,
    required this.newConstraints,
    required this.imageMargin,
  });

  double get widthChanged => newConstraints.maxWidth - oldConstraints.maxWidth;
  double get heightChanged =>
      newConstraints.maxHeight - oldConstraints.maxHeight;
}
