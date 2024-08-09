// Dart imports:
import 'dart:ui';

// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../utils/debounce.dart';

/// A widget that detects changes in screen size and notifies listeners.
///
/// This widget listens to screen size changes using [LayoutBuilder] and
/// triggers [onResizeUpdate] and [onResizeEnd] callbacks accordingly.
///
/// When the screen size changes, [onResizeUpdate] is called immediately and
/// [onResizeEnd] is called after a debounce duration to handle resize events
/// efficiently.
///
/// Parameters:
/// - [child]: The child widget to render.
/// - [onResizeUpdate]: A callback function called when the screen size changes.
/// - [onResizeEnd]: A callback function called when the screen resize ends.
class ScreenResizeDetector extends StatefulWidget {
  /// Creates an instance of [ScreenResizeDetector] with the given parameters.
  const ScreenResizeDetector({
    super.key,
    required this.child,
    this.onResizeUpdate,
    this.onResizeEnd,
    this.ignoreSafeArea = false,
  });

  /// The widget to be displayed and resized.
  final Widget child;

  /// Callback to be invoked when the screen is resized and update is detected.
  final Function(ResizeEvent)? onResizeUpdate;

  /// Callback to be invoked when the screen resize ends.
  final Function(ResizeEvent)? onResizeEnd;

  /// Whether to ignore the safe area padding when detecting screen size
  /// changes.
  final bool ignoreSafeArea;

  @override
  State<ScreenResizeDetector> createState() => _ScreenResizeDetectorState();
}

class _ScreenResizeDetectorState extends State<ScreenResizeDetector> {
  Size _startContentSize = Size.zero;
  Size _lastContentSize = Size.zero;
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

  EdgeInsets get _safeArea {
    if (!widget.ignoreSafeArea) return EdgeInsets.zero;

    FlutterView view = WidgetsBinding.instance.platformDispatcher.views.first;
    return MediaQueryData.fromView(view).viewPadding;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      Size newSize = Size(
        constraints.biggest.width - _safeArea.horizontal,
        constraints.biggest.height - _safeArea.vertical,
      );

      if (newSize != _lastContentSize) {
        widget.onResizeUpdate?.call(ResizeEvent(
          oldContentSize: _lastContentSize,
          newContentSize: newSize,
        ));
        _lastContentSize = newSize;

        if (!_activeResizing) {
          _startContentSize = newSize;
          _activeResizing = true;
        }

        _resizeDebounce$(() {
          widget.onResizeEnd?.call(ResizeEvent(
            oldContentSize: _startContentSize,
            newContentSize: newSize,
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
  /// Creates an instance of [ResizeEvent] with the old and new content sizes.
  const ResizeEvent({
    required this.oldContentSize,
    required this.newContentSize,
  });

  /// The old content size before the resize.
  final Size oldContentSize;

  /// The new content size after the resize.
  final Size newContentSize;

  /// Gets the change in width after the resize.
  double get widthChanged => newContentSize.width - oldContentSize.width;

  /// Gets the change in height after the resize.
  double get heightChanged => newContentSize.height - oldContentSize.height;
}
