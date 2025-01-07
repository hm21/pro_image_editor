// Flutter imports:
import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';

// Project imports:
import 'outside_gesture_behavior.dart';
import 'outside_raw_gesture_detector.dart';

/// A stateful widget that detects and handles gestures for cropping and
/// rotating.
///
/// This widget provides gesture detection for complex interactions like
/// double-tap and scaling (pinch-to-zoom) gestures, which are commonly used in
/// image editing applications for cropping and rotating images.

class CropRotateGestureDetector extends StatefulWidget {
  /// Creates a [CropRotateGestureDetector].
  ///
  /// The widget captures double-tap and scaling gestures and forwards them to
  /// the provided callback functions. These callbacks enable customization of
  /// the widget's response to user interactions.
  ///
  /// Example:
  /// ```
  /// CropRotateGestureDetector(
  ///   child: ImageWidget(),
  ///   onDoubleTap: () {
  ///     // Handle double-tap gesture
  ///   },
  ///   onScaleUpdate: (ScaleUpdateDetails details) {
  ///     // Handle scale update gesture
  ///   },
  /// )
  /// ```
  const CropRotateGestureDetector({
    super.key,
    this.child,
    this.onDoubleTapDown,
    this.onDoubleTap,
    this.onDoubleTapCancel,
    this.onScaleStart,
    this.onScaleUpdate,
    this.onScaleEnd,
  });

  /// The widget below this widget in the tree.
  ///
  /// {@macro flutter.widgets.ProxyWidget.child}
  final Widget? child;

  /// A pointer that might cause a double tap has contacted the screen at a
  /// particular location.
  ///
  /// Triggered immediately after the down event of the second tap.
  ///
  /// If the user completes the double tap and the gesture wins, [onDoubleTap]
  /// will be called after this callback. Otherwise, [onDoubleTapCancel] will
  /// be called after this callback.
  ///
  /// See also:
  ///
  ///  * [kPrimaryButton], the button this callback responds to.
  final GestureTapDownCallback? onDoubleTapDown;

  /// The user has tapped the screen with a primary button at the same location
  /// twice in quick succession.
  ///
  /// See also:
  ///
  ///  * [kPrimaryButton], the button this callback responds to.
  final GestureTapCallback? onDoubleTap;

  /// The pointer that previously triggered [onDoubleTapDown] will not end up
  /// causing a double tap.
  ///
  /// See also:
  ///
  ///  * [kPrimaryButton], the button this callback responds to.
  final GestureTapCancelCallback? onDoubleTapCancel;

  /// The pointers in contact with the screen have established a focal point and
  /// initial scale of 1.0.
  final GestureScaleStartCallback? onScaleStart;

  /// The pointers in contact with the screen have indicated a new focal point
  /// and/or scale.
  final GestureScaleUpdateCallback? onScaleUpdate;

  /// The pointers are no longer in contact with the screen.
  final GestureScaleEndCallback? onScaleEnd;

  @override
  State<CropRotateGestureDetector> createState() =>
      CropRotateGestureDetectorState();
}

/// The state class for [CropRotateGestureDetector].
///
/// This class manages gesture detection for cropping and rotating functionality
/// in an image editor. It detects double-tap and scale gestures, allowing for
/// actions such as zooming and rotating images based on user interaction.
class CropRotateGestureDetectorState extends State<CropRotateGestureDetector> {
  /// A global key for accessing the state of the [OutsideRawGestureDetector].
  ///
  /// This key is used to control and manage the raw gesture detector that
  /// detects gestures outside the usual hit testing areas.
  final rawKey = GlobalKey<OutsideRawGestureDetectorState>();

  @override
  Widget build(BuildContext context) {
    final Map<Type, GestureRecognizerFactory> gestures =
        <Type, GestureRecognizerFactory>{};
    final DeviceGestureSettings? gestureSettings =
        MediaQuery.maybeGestureSettingsOf(context);

    if (widget.onDoubleTap != null ||
        widget.onDoubleTapDown != null ||
        widget.onDoubleTapCancel != null) {
      gestures[DoubleTapGestureRecognizer] =
          GestureRecognizerFactoryWithHandlers<DoubleTapGestureRecognizer>(
        () => DoubleTapGestureRecognizer(debugOwner: this),
        (DoubleTapGestureRecognizer instance) {
          instance
            ..onDoubleTapDown = widget.onDoubleTapDown
            ..onDoubleTap = widget.onDoubleTap
            ..onDoubleTapCancel = widget.onDoubleTapCancel
            ..gestureSettings = gestureSettings;
        },
      );
    }

    if (widget.onScaleStart != null ||
        widget.onScaleUpdate != null ||
        widget.onScaleEnd != null) {
      gestures[ScaleGestureRecognizer] =
          GestureRecognizerFactoryWithHandlers<ScaleGestureRecognizer>(
        () => ScaleGestureRecognizer(debugOwner: this),
        (ScaleGestureRecognizer instance) {
          instance
            ..onStart = widget.onScaleStart
            ..onUpdate = widget.onScaleUpdate
            ..onEnd = widget.onScaleEnd
            ..gestureSettings = gestureSettings;
        },
      );
    }

    return OutsideRawGestureDetector(
      key: rawKey,
      gestures: gestures,
      behavior: OutsideHitTestBehavior.all,
      externListener: true,
      child: widget.child,
    );
  }
}
