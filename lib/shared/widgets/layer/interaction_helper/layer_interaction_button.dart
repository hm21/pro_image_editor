// Flutter imports:
import 'package:flutter/rendering.dart';
import 'package:material_ui/material_ui.dart';

/// A stateful widget that represents a customizable button for interacting
/// with layers.
///
/// The button provides multiple functionalities, including detecting scale and
/// rotate gestures, handling taps, and displaying tooltips. It is designed for
/// use in scenarios such as image editing applications where user interactions
/// with layers are required.
class LayerInteractionButton extends StatefulWidget {
  /// Creates a [LayerInteractionButton].
  ///
  /// This button can be customized with an icon, rotation, tooltip, and various
  /// gesture callbacks. It is suitable for applications where layer
  /// manipulation is required, offering visual feedback and user interaction
  /// capabilities.
  ///
  /// Example:
  /// ```
  /// LayerInteractionButton(
  ///   icon: Icons.crop_rotate,
  ///   cursor: SystemMouseCursors.click,
  ///   buttonRadius: 20.0,
  ///   rotation: 0.0,
  ///   tooltip: 'Rotate Layer',
  ///   color: Colors.white,
  ///   background: Colors.blue,
  ///   onTap: () {
  ///     // Handle tap action
  ///   },
  ///   onScaleRotateDown: (event) {
  ///     // Handle scale rotate down
  ///   },
  ///   onScaleRotateUp: (event) {
  ///     // Handle scale rotate up
  ///   },
  ///   toggleTooltipVisibility: (isVisible) {
  ///     // Toggle tooltip visibility
  ///   },
  /// )
  /// ```
  const LayerInteractionButton({
    super.key,
    this.onScaleRotateDown,
    this.onScaleRotateUp,
    this.onTap,
    required this.icon,
    required this.cursor,
    required this.buttonRadius,
    required this.rotation,
    required this.tooltip,
    required this.color,
    required this.background,
  });

  @override
  State<LayerInteractionButton> createState() => _LayerInteractionButtonState();

  /// Callback for handling pointer down events associated with scale and
  /// rotate gestures.
  ///
  /// This callback is triggered when the user presses down on the button,
  /// enabling handling of scale and rotate interactions.
  final Function(PointerDownEvent)? onScaleRotateDown;

  /// Callback for handling pointer up events associated with scale and
  /// rotate gestures.
  ///
  /// This callback is triggered when the user releases the button after a scale
  /// or rotate gesture, allowing for finalizing interactions.
  final Function(PointerUpEvent)? onScaleRotateUp;

  /// Callback for handling tap events on the button.
  ///
  /// This callback is invoked when the user taps the button, allowing for
  /// custom behavior in response to the tap action.
  final Function()? onTap;

  /// The icon to be displayed on the button.
  ///
  /// This icon visually represents the action or purpose of the button.
  final IconData icon;

  /// The cursor to be displayed when hovering over the button.
  ///
  /// This provides visual feedback to the user about the button's
  /// interactivity.
  final MouseCursor cursor;

  /// The radius of the button, used to calculate its size and border radius.
  ///
  /// This value determines the size of the button and its rounded corners.
  final double buttonRadius;

  /// The rotation angle of the button, in radians.
  ///
  /// This value specifies how much the button is rotated, allowing for
  /// visual effects such as rotating icons.
  final double rotation;

  /// The tooltip message to be displayed when hovering over the button.
  ///
  /// This provides additional context or information about the button's
  /// purpose.
  final String tooltip;

  /// The background color of the button.
  ///
  /// This color fills the button's background, providing visual styling.
  final Color background;

  /// The color of the icon displayed on the button.
  ///
  /// This color affects the icon's appearance, allowing for customization
  /// based on design requirements.
  final Color color;
}

class _LayerInteractionButtonState extends State<LayerInteractionButton> {
  final _tooltipKey = GlobalKey<TooltipState>();

  void _showTooltip() => _tooltipKey.currentState?.ensureTooltipVisible();

  void _hideTooltip() => Tooltip.dismissAllToolTips();

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: widget.rotation,
      child: MouseRegion(
        cursor: widget.cursor,
        hitTestBehavior: HitTestBehavior.translucent,
        onEnter: (_) => _showTooltip(),
        onExit: (_) => _hideTooltip(),
        child: Listener(
          behavior: HitTestBehavior.translucent,
          onPointerDown: widget.onScaleRotateDown,
          onPointerUp: widget.onScaleRotateUp,
          child: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: widget.onTap,
            child: _HitTestTransparent(
              child: Tooltip(
                key: _tooltipKey,
                message: widget.tooltip,
                triggerMode: TooltipTriggerMode.manual,
                child: Container(
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(
                      widget.buttonRadius * 2,
                    ),
                    color: widget.background,
                  ),
                  child: Icon(
                    widget.icon,
                    color: widget.color,
                    size: widget.buttonRadius * 2,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _HitTestTransparent extends SingleChildRenderObjectWidget {
  const _HitTestTransparent({required super.child});

  @override
  RenderObject createRenderObject(BuildContext context) {
    return _RenderHitTestTransparent();
  }
}

class _RenderHitTestTransparent extends RenderProxyBox {
  @override
  bool hitTest(BoxHitTestResult result, {required Offset position}) {
    // Always skip this widget in hit testing
    return false;
  }
}
